import asyncio
import json
import logging
import os
import uuid
from contextlib import asynccontextmanager
from datetime import date, datetime
from decimal import Decimal
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from sqlalchemy import Column, DateTime, Integer, MetaData, String, Table, Text, insert, select, text, update, inspect as sa_inspect
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base

logger = logging.getLogger(__name__)


def _normalize_db_url(url: str) -> tuple[str, dict]:
    """Normalise une URL PostgreSQL pour asyncpg."""
    if not url:
        return url, {}
    if url.startswith("postgres://"):
        url = url.replace("postgres://", "postgresql://", 1)
    if url.startswith("postgresql://") and "+asyncpg" not in url:
        url = url.replace("postgresql://", "postgresql+asyncpg://", 1)

    parsed = urlsplit(url)
    query = dict(parse_qsl(parsed.query, keep_blank_values=True))
    ssl_mode = query.pop("sslmode", "")
    query.pop("channel_binding", None)
    connect_args = {"ssl": True} if ssl_mode.lower() in {"require", "verify-ca", "verify-full"} else {}
    normalized = urlunsplit((parsed.scheme, parsed.netloc, parsed.path, urlencode(query), parsed.fragment))
    return normalized, connect_args


PRIMARY_URL_RAW = os.getenv("DATABASE_URL", "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db")
SECONDARY_URL_RAW = os.getenv("SUPABASE_DATABASE_URL", "")

PRIMARY_URL, PRIMARY_CONNECT_ARGS = _normalize_db_url(PRIMARY_URL_RAW)
SECONDARY_URL, SECONDARY_CONNECT_ARGS = _normalize_db_url(SECONDARY_URL_RAW)

engine = create_async_engine(
    PRIMARY_URL,
    echo=os.getenv("SQL_ECHO", "0") == "1",
    pool_pre_ping=True,
    connect_args=PRIMARY_CONNECT_ARGS,
)
secondary_engine = (
    create_async_engine(
        SECONDARY_URL,
        echo=os.getenv("SQL_ECHO", "0") == "1",
        pool_pre_ping=True,
        connect_args=SECONDARY_CONNECT_ARGS,
    )
    if SECONDARY_URL
    else None
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, class_=AsyncSession, expire_on_commit=False)
SecondarySessionLocal = (
    sessionmaker(autocommit=False, autoflush=False, bind=secondary_engine, class_=AsyncSession, expire_on_commit=False)
    if secondary_engine
    else None
)

Base = declarative_base()

sync_outbox = Table(
    "sync_outbox",
    Base.metadata,
    Column("event_id", String(36), primary_key=True),
    Column("source_db", String(16), nullable=False),
    Column("table_name", String(128), nullable=False),
    Column("operation", String(16), nullable=False),
    Column("pk_json", Text, nullable=False),
    Column("payload_json", Text, nullable=False),
    Column("status", String(16), nullable=False, default="pending"),
    Column("attempts", Integer, nullable=False, default=0),
    Column("last_error", Text, nullable=True),
    Column("created_at", DateTime(timezone=True), nullable=False),
    Column("applied_at", DateTime(timezone=True), nullable=True),
)


def _json_default(value):
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, (bytes, bytearray)):
        return value.decode("utf-8", errors="replace")
    return str(value)


def _object_event(obj, source_db: str, operation: str) -> dict:
    state = sa_inspect(obj)
    mapper = state.mapper
    values = {}
    for column in mapper.columns:
        key = column.key
        if hasattr(obj, key):
            values[key] = getattr(obj, key)
    pk = {column.key: values.get(column.key) for column in mapper.primary_key}
    return {
        "event_id": str(uuid.uuid4()),
        "source_db": source_db,
        "table_name": mapper.local_table.name,
        "operation": operation,
        "pk_json": json.dumps(pk, default=_json_default, sort_keys=True),
        "payload_json": json.dumps(values if operation != "delete" else pk, default=_json_default, sort_keys=True),
        "status": "pending",
        "attempts": 0,
        "created_at": datetime.now().astimezone(),
    }


def _restore_value(column, value):
    if value is None:
        return None
    type_name = column.type.__class__.__name__.lower()
    if "datetime" in type_name or "timestamp" in type_name:
        return datetime.fromisoformat(value) if isinstance(value, str) else value
    if type_name in {"integer", "bigint", "smallinteger"}:
        return int(value)
    if type_name in {"float", "double", "real"}:
        return float(value)
    if type_name == "boolean":
        return value.lower() == "true" if isinstance(value, str) else bool(value)
    if "numeric" in type_name or "decimal" in type_name:
        return Decimal(value)
    return value


async def _healthy(db_engine) -> bool:
    if db_engine is None:
        return False
    try:
        async with db_engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
        return True
    except Exception as exc:
        logger.warning("DB health-check failed for %s: %s", db_engine.url.render_as_string(hide_password=True), exc)
        return False


class DualWriteSession:
    """Façade compatible avec les appels AsyncSession utilisés par l’application.

    La base active sert les lectures et reçoit la transaction principale. Les
    opérations ORM et DML sont rejouées immédiatement sur la base miroir. Une
    panne du miroir ne rend pas indisponible la base active ; elle est journalisée
    afin qu’un worker de réconciliation puisse la reprendre.
    """

    def __init__(self, active: AsyncSession, mirror: AsyncSession | None, active_name: str):
        self._active = active
        self._mirror = mirror
        self.active_name = active_name
        self._added: list[object] = []
        self._deleted: list[object] = []
        self._dml: list[tuple[object, object | None]] = []

    def add(self, instance, _warn=True):
        self._active.add(instance, _warn=_warn)
        self._added.append(instance)

    def add_all(self, instances):
        for instance in instances:
            self.add(instance)

    async def delete(self, instance):
        await self._active.delete(instance)
        self._deleted.append(instance)

    async def execute(self, statement, params=None, *, execution_options=None, bind_arguments=None, **kwargs):
        result = await self._active.execute(
            statement,
            params,
            execution_options=execution_options,
            bind_arguments=bind_arguments,
            **kwargs,
        )
        if getattr(statement, "is_insert", False) or getattr(statement, "is_update", False) or getattr(statement, "is_delete", False):
            self._dml.append((statement, params))
        return result

    async def flush(self, *args, **kwargs):
        return await self._active.flush(*args, **kwargs)

    async def refresh(self, instance, *args, **kwargs):
        return await self._active.refresh(instance, *args, **kwargs)

    async def get(self, *args, **kwargs):
        return await self._active.get(*args, **kwargs)

    async def rollback(self):
        self._added.clear()
        self._deleted.clear()
        self._dml.clear()
        await self._active.rollback()
        if self._mirror is not None:
            await self._mirror.rollback()

    def __getattr__(self, name):
        return getattr(self._active, name)

    async def _replicate_objects(self, objects: list[object], deleted: bool = False):
        if self._mirror is None:
            return
        for obj in objects:
            state = sa_inspect(obj)
            mapper = state.mapper
            identity = state.identity
            if deleted:
                if not identity:
                    continue
                target = await self._mirror.get(mapper.class_, identity[0] if len(identity) == 1 else identity)
                if target is not None:
                    await self._mirror.delete(target)
                continue
            values = {}
            for column in mapper.column_attrs:
                key = column.key
                if hasattr(obj, key):
                    values[key] = getattr(obj, key)
            clone = mapper.class_(**values)
            await self._mirror.merge(clone)

    async def commit(self):
        # Les flush explicites des CRUD ont déjà attribué les clés primaires.
        await self._active.flush()
        dirty = list(self._active.dirty)
        added = list(dict.fromkeys(self._added))
        deleted = list(dict.fromkeys(self._deleted))
        dml = list(self._dml)

        events = [_object_event(obj, self.active_name, "upsert") for obj in added + dirty]
        events += [_object_event(obj, self.active_name, "delete") for obj in deleted]
        if events:
            await self._active.execute(insert(sync_outbox), events)

        await self._active.commit()
        if self._mirror is not None:
            try:
                for event in events:
                    await _apply_event(self._mirror, event)
                # Les DML simples restent rejoués immédiatement pour préserver
                # les opérations DELETE/UPDATE existantes non liées à un objet.
                for statement, params in dml:
                    await self._mirror.execute(statement, params)
                await self._mirror.commit()
                if events:
                    await self._active.execute(
                        update(sync_outbox)
                        .where(sync_outbox.c.event_id.in_([event["event_id"] for event in events]))
                        .values(status="applied", applied_at=datetime.now().astimezone())
                    )
                    await self._active.commit()
            except Exception as exc:
                await self._mirror.rollback()
                logger.exception(
                    "Dual-write dégradé: %s a validé la transaction, miroir en attente dans sync_outbox: %s",
                    self.active_name,
                    exc,
                )
        self._clear_tracking()

    def _clear_tracking(self):
        self._added.clear()
        self._deleted.clear()
        self._dml.clear()


async def _apply_event(session: AsyncSession, event: dict):
    """Applique un événement upsert/delete sans supposer le modèle Python."""
    table = Base.metadata.tables.get(event["table_name"])
    if table is None or table.name == "sync_outbox":
        return
    payload = json.loads(event["payload_json"])
    pk = json.loads(event["pk_json"])
    payload = {key: _restore_value(table.c[key], value) for key, value in payload.items() if key in table.c}
    pk = {key: _restore_value(table.c[key], value) for key, value in pk.items() if key in table.c}
    where = [table.c[key] == value for key, value in pk.items() if key in table.c]
    if event["operation"] == "delete":
        if where:
            await session.execute(table.delete().where(*where))
        return
    result = await session.execute(table.update().where(*where).values(**payload)) if where else None
    if result is None or result.rowcount == 0:
        await session.execute(table.insert().values(**payload))


async def _replicate_pending(source_session: AsyncSession, target_session: AsyncSession, source_name: str):
    rows = (await source_session.execute(
        select(sync_outbox)
        .where(sync_outbox.c.status == "pending", sync_outbox.c.source_db == source_name)
        .order_by(sync_outbox.c.created_at)
        .limit(100)
    )).mappings().all()
    for row in rows:
        event = dict(row)
        try:
            await _apply_event(target_session, event)
            await target_session.commit()
            await source_session.execute(
                update(sync_outbox).where(sync_outbox.c.event_id == event["event_id"]).values(
                    status="applied", attempts=sync_outbox.c.attempts + 1,
                    applied_at=datetime.now().astimezone(), last_error=None,
                )
            )
            await source_session.commit()
        except Exception as exc:
            await target_session.rollback()
            await source_session.execute(
                update(sync_outbox).where(sync_outbox.c.event_id == event["event_id"]).values(
                    attempts=sync_outbox.c.attempts + 1, last_error=str(exc)[:4000]
                )
            )
            await source_session.commit()


async def reconcile_once():
    """Réconcilie les événements en attente dans les deux directions."""
    if not (await _healthy(engine)) or not (await _healthy(secondary_engine)):
        return
    async with SessionLocal() as neon, SecondarySessionLocal() as supabase:
        await _replicate_pending(neon, supabase, "neon")
        await _replicate_pending(supabase, neon, "supabase")


async def get_db_status() -> dict:
    neon_ok = await _healthy(engine)
    supabase_ok = await _healthy(secondary_engine)
    pending = {"neon": None, "supabase": None}
    if neon_ok:
        async with SessionLocal() as session:
            pending["neon"] = len((await session.execute(
                select(sync_outbox.c.event_id).where(sync_outbox.c.status == "pending", sync_outbox.c.source_db == "neon").limit(1000)
            )).all())
    if supabase_ok and SecondarySessionLocal:
        async with SecondarySessionLocal() as session:
            pending["supabase"] = len((await session.execute(
                select(sync_outbox.c.event_id).where(sync_outbox.c.status == "pending", sync_outbox.c.source_db == "supabase").limit(1000)
            )).all())
    return {
        "active": "neon" if neon_ok else ("supabase" if supabase_ok else "none"),
        "neon": "up" if neon_ok else "down",
        "supabase": "up" if supabase_ok else "down",
        "pending_events": pending,
        "dual_write": bool(neon_ok and supabase_ok),
    }


async def _sync_worker():
    while True:
        try:
            await reconcile_once()
        except asyncio.CancelledError:
            raise
        except Exception:
            logger.exception("Worker sync_outbox en erreur")
        await asyncio.sleep(int(os.getenv("SYNC_INTERVAL_SECONDS", "10")))


async def init_db():
    """Vérifie les deux bases sans recréer le schéma en production."""
    max_retries = int(os.getenv("DB_MAX_RETRIES", "3"))
    retry_delay = int(os.getenv("DB_RETRY_DELAY", "1"))
    last_error = None
    for attempt in range(1, max_retries + 1):
        try:
            primary_ok = await _healthy(engine)
            secondary_ok = await _healthy(secondary_engine)
            if not primary_ok and not secondary_ok:
                raise ConnectionError("Neon et Supabase sont indisponibles")
            logger.info("DB dual active: neon=%s supabase=%s", primary_ok, secondary_ok)
            for target in (engine if primary_ok else None, secondary_engine if secondary_ok else None):
                if target is not None:
                    async with target.begin() as conn:
                        await conn.run_sync(sync_outbox.create, checkfirst=True)
            if os.getenv("DB_CREATE_TABLES", "0") == "1":
                from . import models
                target_engine = engine if primary_ok else secondary_engine
                async with target_engine.begin() as conn:
                    await conn.run_sync(Base.metadata.create_all)
            return
        except Exception as exc:
            last_error = exc
            logger.warning("Connexion dual échouée (%s/%s): %s", attempt, max_retries, exc)
            await asyncio.sleep(retry_delay)
    raise last_error


@asynccontextmanager
async def lifespan(app):
    logger.info("Démarrage backend dual Neon/Supabase")
    await init_db()
    worker = asyncio.create_task(_sync_worker(), name="sync-outbox-worker")
    yield
    worker.cancel()
    await asyncio.gather(worker, return_exceptions=True)
    await engine.dispose()
    if secondary_engine is not None:
        await secondary_engine.dispose()
    logger.info("Backend dual arrêté")


async def get_db() -> DualWriteSession:
    """Sélectionne la base saine et conserve l’autre comme miroir."""
    primary_ok = await _healthy(engine)
    secondary_ok = await _healthy(secondary_engine)
    if primary_ok:
        async with SessionLocal() as primary_session:
            mirror_context = SecondarySessionLocal() if secondary_ok and SecondarySessionLocal else None
            if mirror_context is not None:
                async with mirror_context as mirror_session:
                    yield DualWriteSession(primary_session, mirror_session, "neon")
            else:
                yield DualWriteSession(primary_session, None, "neon")
    elif secondary_ok and SecondarySessionLocal:
        async with SecondarySessionLocal() as secondary_session:
            yield DualWriteSession(secondary_session, None, "supabase")
    else:
        raise ConnectionError("Aucune base de données disponible")
