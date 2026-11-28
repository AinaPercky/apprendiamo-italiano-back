import asyncio
import json
import logging
import os
import random
import uuid
from contextlib import asynccontextmanager
from datetime import date, datetime, timedelta
from decimal import Decimal
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

from sqlalchemy import Column, DateTime, Integer, MetaData, String, Table, Text, insert, select, text, update, inspect as sa_inspect
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.dialects.postgresql import insert as pg_insert

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
    # asyncpg attend ici le mode ``require`` : ``ssl=True`` active une
    # vérification de certificat qui échoue avec le certificat du pooler.
    connect_args = {"ssl": "require"} if ssl_mode.lower() in {"require", "verify-ca", "verify-full"} else {}
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
    Column("available_at", DateTime(timezone=True), nullable=False, server_default=text("CURRENT_TIMESTAMP")),
    Column("locked_at", DateTime(timezone=True), nullable=True),
    Column("locked_by", String(64), nullable=True),
)

# A receipt is committed atomically with the replicated business row. If the
# source acknowledgement is lost, replay sees the receipt and becomes a no-op.
sync_event_receipts = Table(
    "sync_event_receipts",
    Base.metadata,
    Column("event_id", String(36), primary_key=True),
    Column("source_db", String(16), nullable=False),
    Column("applied_at", DateTime(timezone=True), nullable=False),
)


def _json_default(value):
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, (bytes, bytearray)):
        return value.decode("utf-8", errors="replace")
    return str(value)


def _new_outbox_event(table_name: str, operation: str, values: dict, primary_key: dict, source_db: str) -> dict:
    if not primary_key:
        raise ValueError(f"Impossible de journaliser {table_name}: clé primaire absente")
    payload = values if operation != "delete" else primary_key
    return {
        "event_id": str(uuid.uuid4()),
        "source_db": source_db,
        "table_name": table_name,
        "operation": operation,
        "pk_json": json.dumps(primary_key, default=_json_default, sort_keys=True),
        "payload_json": json.dumps(payload, default=_json_default, sort_keys=True),
        "status": "pending",
        "attempts": 0,
        "last_error": None,
        "created_at": datetime.now().astimezone(),
        "applied_at": None,
    }


def _object_event(obj, source_db: str, operation: str) -> dict:
    state = sa_inspect(obj)
    mapper = state.mapper
    values = {}
    for column in mapper.columns:
        key = column.key
        if hasattr(obj, key):
            values[key] = getattr(obj, key)
    pk = {column.key: values.get(column.key) for column in mapper.primary_key}
    return _new_outbox_event(mapper.local_table.name, operation, values, pk, source_db)


def _dml_events_from_result(table, rows, source_db: str, operation: str) -> list[dict]:
    events = []
    for row in rows:
        values = {column.key: row[column.key] for column in table.columns}
        primary_key = {column.key: values.get(column.key) for column in table.primary_key.columns}
        events.append(_new_outbox_event(table.name, operation, values, primary_key, source_db))
    return events


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
        # Mutations are kept in call order so dependent inserts/deletes are
        # replayed in the same order on the mirror.
        self._mutations: list[tuple[str, object, str | None]] = []
        self._queued_dirty_ids: set[int] = set()

    def _queue_dirty_objects(self):
        for obj in list(self._active.dirty):
            object_id = id(obj)
            if object_id not in self._queued_dirty_ids:
                self._mutations.append(("object", obj, "upsert"))
                self._queued_dirty_ids.add(object_id)

    def add(self, instance, _warn=True):
        self._active.add(instance, _warn=_warn)
        self._mutations.append(("object", instance, "upsert"))
        self._queued_dirty_ids.add(id(instance))

    def add_all(self, instances):
        for instance in instances:
            self.add(instance)

    async def delete(self, instance):
        await self._active.delete(instance)
        self._mutations.append(("object", instance, "delete"))
        self._queued_dirty_ids.add(id(instance))

    async def execute(self, statement, params=None, *, execution_options=None, bind_arguments=None, **kwargs):
        is_dml = any(getattr(statement, flag, False) for flag in ("is_insert", "is_update", "is_delete"))
        if not is_dml:
            return await self._active.execute(
                statement,
                params,
                execution_options=execution_options,
                bind_arguments=bind_arguments,
                **kwargs,
            )

        # Capture ORM changes made before this SQL statement to preserve the
        # transaction's mutation order on the mirror.
        self._queue_dirty_objects()
        table = getattr(statement, "table", None)
        if table is None or not table.primary_key.columns:
            raise ValueError("DML non réplicable: table ou clé primaire introuvable")

        # The outbox stores row-level facts, never executable SQL. RETURNING
        # supplies the exact affected rows, including composite primary keys.
        existing_returning = getattr(statement, "_returning", ())
        returning_clauses = [
            expression.__clause_element__() if hasattr(expression, "__clause_element__") else expression
            for expression in existing_returning
        ]
        missing_columns = [
            column
            for column in table.columns
            if not any(
                hasattr(clause, "shares_lineage") and column.shares_lineage(clause)
                for clause in returning_clauses
            )
        ]
        tracked_statement = statement.returning(*missing_columns) if missing_columns else statement
        result = await self._active.execute(
            tracked_statement,
            params,
            execution_options=execution_options,
            bind_arguments=bind_arguments,
            **kwargs,
        )
        frozen_result = result.freeze()
        rows = frozen_result().mappings().all()
        operation = "delete" if getattr(statement, "is_delete", False) else "upsert"
        for event in _dml_events_from_result(table, rows, self.active_name, operation):
            self._mutations.append(("event", event, None))
        # Return a fresh buffered result to preserve the caller's ability to
        # consume RETURNING values after the outbox has inspected them.
        return frozen_result()

    async def flush(self, *args, **kwargs):
        self._queue_dirty_objects()
        return await self._active.flush(*args, **kwargs)

    async def refresh(self, instance, *args, **kwargs):
        return await self._active.refresh(instance, *args, **kwargs)

    async def get(self, *args, **kwargs):
        return await self._active.get(*args, **kwargs)

    async def rollback(self):
        self._mutations.clear()
        self._queued_dirty_ids.clear()
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
        # Snapshot ORM mutations before flush clears SQLAlchemy's dirty set.
        self._queue_dirty_objects()
        await self._active.flush()

        events = []
        for mutation_type, value, operation in self._mutations:
            if mutation_type == "event":
                events.append(value)
            else:
                events.append(_object_event(value, self.active_name, operation or "upsert"))
        if events:
            # created_at is a stable ordering key for recovery after a process
            # restart; keep the in-transaction mutation order even when ORM
            # events are materialized later than Core DML events.
            event_time = datetime.now().astimezone()
            for index, event in enumerate(events):
                event["created_at"] = event_time + timedelta(microseconds=index)
            # Outbox rows and business writes share the same primary transaction.
            await self._active.execute(insert(sync_outbox), events)

        await self._active.commit()
        if self._mirror is not None:
            try:
                for event in events:
                    await _apply_event(self._mirror, event)
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
        self._mutations.clear()
        self._queued_dirty_ids.clear()


async def _apply_event(session: AsyncSession, event: dict):
    """Applique un événement une seule fois dans la transaction cible.

    Le reçu et la mutation métier sont validés dans la même transaction.
    Si l'accusé de réception de la source est perdu, un replay du même
    event_id ne réapplique donc pas la mutation.
    """
    table_name = event.get("table_name")
    table = Base.metadata.tables.get(table_name)
    if table is None:
        raise LookupError(f"Table de réplication inconnue dans les métadonnées: {table_name!r}")
    if table.name in {"sync_outbox", "sync_event_receipts"}:
        raise ValueError(f"La table interne {table.name} ne peut pas être répliquée comme donnée métier")

    try:
        payload = json.loads(event["payload_json"])
        pk = json.loads(event["pk_json"])
        event_id = str(event["event_id"])
        source_db = str(event["source_db"])
    except (KeyError, TypeError, json.JSONDecodeError) as exc:
        raise ValueError("Événement de réplication mal formé: identité, payload ou clé primaire invalide") from exc

    if not event_id or source_db not in {"neon", "supabase"}:
        raise ValueError("Identité d'événement ou base source invalide")
    if not isinstance(payload, dict) or not isinstance(pk, dict):
        raise ValueError("Événement de réplication invalide: payload et clé primaire doivent être des objets JSON")

    unknown_payload_columns = set(payload) - set(table.c.keys())
    if unknown_payload_columns:
        raise ValueError(
            f"Colonnes absentes des métadonnées pour {table.name}: {sorted(unknown_payload_columns)}"
        )

    unknown_pk_columns = set(pk) - set(table.c.keys())
    if unknown_pk_columns:
        raise ValueError(
            f"Colonnes de clé primaire inconnues pour {table.name}: {sorted(unknown_pk_columns)}"
        )

    expected_pk_columns = {column.key for column in table.primary_key.columns}
    if not expected_pk_columns or set(pk) != expected_pk_columns or any(pk[key] is None for key in expected_pk_columns):
        raise ValueError(f"Clé primaire incomplète ou invalide pour {table.name}")

    payload = {key: _restore_value(table.c[key], value) for key, value in payload.items()}
    pk = {key: _restore_value(table.c[key], value) for key, value in pk.items()}
    operation = event.get("operation")
    if operation not in {"upsert", "delete"}:
        raise ValueError(f"Opération de réplication inconnue: {operation!r}")
    if operation == "upsert":
        if not expected_pk_columns.issubset(payload):
            raise ValueError(f"Payload incomplet : clé primaire absente pour {table.name}")
        if any(payload[key] != pk[key] for key in expected_pk_columns):
            raise ValueError(f"Clé primaire incohérente entre payload et événement pour {table.name}")

    # PostgreSQL's unique receipt key serializes concurrent replays of the
    # same event. A failed business write rolls this insert back as well.
    receipt = pg_insert(sync_event_receipts).values(
        event_id=event_id,
        source_db=source_db,
        applied_at=datetime.now().astimezone(),
    ).on_conflict_do_nothing(index_elements=[sync_event_receipts.c.event_id]).returning(
        sync_event_receipts.c.event_id
    )
    receipt_result = await session.execute(receipt)
    if receipt_result.scalar_one_or_none() is None:
        return

    where = [table.c[key] == value for key, value in pk.items()]
    if operation == "delete":
        await session.execute(table.delete().where(*where))
        return

    primary_key_columns = [table.c[key] for key in expected_pk_columns]
    update_values = {key: value for key, value in payload.items() if key not in expected_pk_columns}
    statement = pg_insert(table).values(**payload)
    if update_values:
        statement = statement.on_conflict_do_update(
            index_elements=primary_key_columns,
            set_=update_values,
        )
    else:
        statement = statement.on_conflict_do_nothing(index_elements=primary_key_columns)
    await session.execute(statement)


def _retry_delay_seconds(attempt: int, base_seconds: int = 5, max_seconds: int = 3600) -> float:
    """Backoff exponentiel borné avec jitter pour éviter les reprises synchronisées."""
    safe_attempt = max(1, int(attempt))
    exponential = min(max_seconds, base_seconds * (2 ** min(safe_attempt - 1, 20)))
    return random.uniform(exponential * 0.8, exponential * 1.2)


async def _replicate_pending(source_session: AsyncSession, target_session: AsyncSession, source_name: str):
    """Réserve des événements avec lease, puis les applique avec reprise bornée."""
    now = datetime.now().astimezone()
    lease_seconds = max(30, int(os.getenv("SYNC_EVENT_LEASE_SECONDS", "120")))
    batch_size = min(500, max(1, int(os.getenv("SYNC_BATCH_SIZE", "100"))))
    max_attempts = max(1, int(os.getenv("SYNC_MAX_ATTEMPTS", "10")))
    worker_id = str(uuid.uuid4())

    # Recover work abandoned by a crashed worker after its lease expires.
    await source_session.execute(
        update(sync_outbox)
        .where(
            sync_outbox.c.source_db == source_name,
            sync_outbox.c.status == "processing",
            sync_outbox.c.locked_at.is_not(None),
            sync_outbox.c.locked_at < now - timedelta(seconds=lease_seconds),
        )
        .values(status="pending", locked_at=None, locked_by=None)
    )
    await source_session.commit()

    claim = (
        select(sync_outbox)
        .where(
            sync_outbox.c.source_db == source_name,
            sync_outbox.c.status == "pending",
            sync_outbox.c.available_at <= now,
        )
        .order_by(sync_outbox.c.created_at, sync_outbox.c.event_id)
        .limit(batch_size)
        .with_for_update(skip_locked=True)
    )
    rows = (await source_session.execute(claim)).mappings().all()
    if not rows:
        return

    event_ids = [row["event_id"] for row in rows]
    await source_session.execute(
        update(sync_outbox)
        .where(sync_outbox.c.event_id.in_(event_ids))
        .values(status="processing", locked_at=now, locked_by=worker_id)
    )
    await source_session.commit()

    for row in rows:
        event = dict(row)
        try:
            await _apply_event(target_session, event)
            await target_session.commit()
            await source_session.execute(
                update(sync_outbox)
                .where(
                    sync_outbox.c.event_id == event["event_id"],
                    sync_outbox.c.status == "processing",
                    sync_outbox.c.locked_by == worker_id,
                )
                .values(
                    status="applied",
                    applied_at=datetime.now().astimezone(),
                    last_error=None,
                    locked_at=None,
                    locked_by=None,
                )
            )
            await source_session.commit()
        except Exception as exc:
            await target_session.rollback()
            attempts = int(event.get("attempts") or 0) + 1
            quarantined = attempts >= max_attempts
            delay = _retry_delay_seconds(attempts)
            next_status = "quarantined" if quarantined else "pending"
            # Store only a stable exception class, never SQL text or payloads.
            safe_error = f"{type(exc).__name__}: replication failed"
            await source_session.execute(
                update(sync_outbox)
                .where(
                    sync_outbox.c.event_id == event["event_id"],
                    sync_outbox.c.status == "processing",
                    sync_outbox.c.locked_by == worker_id,
                )
                .values(
                    status=next_status,
                    attempts=attempts,
                    available_at=datetime.now().astimezone() + timedelta(seconds=delay),
                    last_error=safe_error,
                    locked_at=None,
                    locked_by=None,
                )
            )
            await source_session.commit()
            if quarantined:
                logger.error(
                    "Événement outbox placé en quarantaine après %s tentatives (%s)",
                    attempts,
                    type(exc).__name__,
                )
            else:
                logger.warning(
                    "Événement outbox reporté après échec (%s); nouvelle tentative planifiée",
                    type(exc).__name__,
                )


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
