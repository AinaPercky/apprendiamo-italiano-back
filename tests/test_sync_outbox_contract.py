"""Tests du contrat de journalisation des écritures SQL Core dans l'outbox."""

import json

import pytest
from sqlalchemy import Column, Integer, MetaData, String, Table, delete, insert, update

from app.database import (Base, DualWriteSession, _apply_event, _retry_delay_seconds, _is_supabase_transaction_pooler_url, _normalize_db_url, _sync_conflict_id, _quarantine_sync_conflict, sync_conflicts)


class FrozenFakeResult:
    def __init__(self, rows):
        self._rows = rows

    def __call__(self):
        return FakeResult(self._rows)


class FakeResult:
    def __init__(self, rows):
        self._rows = rows

    def freeze(self):
        return FrozenFakeResult(self._rows)

    def mappings(self):
        return self

    def all(self):
        return list(self._rows)


class FakeActiveSession:
    def __init__(self, rows):
        self.rows = rows
        self.dirty = []
        self.executed = []

    async def execute(self, statement, params=None, **kwargs):
        self.executed.append(statement)
        return FakeResult(self.rows)


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("statement_factory", "operation"),
    [
        (lambda table: insert(table).values(id=7, code="studio", name="Studio"), "upsert"),
        (lambda table: update(table).where(table.c.id == 7).values(name="Studio v2"), "upsert"),
        (lambda table: delete(table).where(table.c.id == 7), "delete"),
    ],
)
async def test_core_dml_is_converted_to_row_level_outbox_event(statement_factory, operation):
    metadata = MetaData()
    table = Table(
        "client_applications_test",
        metadata,
        Column("id", Integer, primary_key=True),
        Column("code", String(64), nullable=False),
        Column("name", String(120), nullable=False),
    )
    row = {"id": 7, "code": "studio", "name": "Studio"}
    active = FakeActiveSession([row])
    session = DualWriteSession(active, None, "neon")

    result = await session.execute(statement_factory(table))

    assert len(active.executed) == 1
    # The wrapper adds RETURNING for all columns, without storing executable SQL.
    assert {column.name for column in active.executed[0]._returning} == {"id", "code", "name"}
    returned = result.mappings().all()
    assert returned == [row]

    assert len(session._mutations) == 1
    mutation_type, event, _ = session._mutations[0]
    assert mutation_type == "event"
    assert event["source_db"] == "neon"
    assert event["table_name"] == "client_applications_test"
    assert event["operation"] == operation
    assert json.loads(event["pk_json"]) == {"id": 7}
    assert json.loads(event["payload_json"]) == ({"id": 7} if operation == "delete" else row)
    assert event["status"] == "pending"


@pytest.mark.asyncio
async def test_core_dml_without_primary_key_is_rejected_before_execution():
    metadata = MetaData()
    table = Table(
        "unsafe_table",
        metadata,
        Column("value", String(40), nullable=False),
    )
    active = FakeActiveSession([])
    session = DualWriteSession(active, None, "neon")

    with pytest.raises(ValueError, match="clé primaire"):
        await session.execute(insert(table).values(value="not-replicable"))

    assert active.executed == []
    assert session._mutations == []

@pytest.mark.asyncio
async def test_existing_returning_columns_are_not_duplicated():
    metadata = MetaData()
    table = Table(
        "cards_test",
        metadata,
        Column("id", Integer, primary_key=True),
        Column("front", String(80), nullable=False),
    )
    active = FakeActiveSession([{"id": 9, "front": "ciao"}])
    session = DualWriteSession(active, None, "neon")

    result = await session.execute(
        delete(table).where(table.c.id == 9).returning(table.c.id)
    )

    returned_columns = active.executed[0]._returning
    assert len(returned_columns) == 2
    assert {column.name for column in returned_columns} == {"id", "front"}
    assert result.mappings().all() == [{"id": 9, "front": "ciao"}]
    assert json.loads(session._mutations[0][1]["pk_json"]) == {"id": 9}


class FakeTargetResult:
    def __init__(self, rowcount=0, scalar=None):
        self.rowcount = rowcount
        self._scalar = scalar

    def scalar_one_or_none(self):
        return self._scalar


class FakeTargetSession:
    def __init__(self):
        self.executed = []
        self.receipt_attempts = 0

    async def execute(self, statement):
        self.executed.append(statement)
        table = getattr(statement, "table", None)
        if getattr(table, "name", None) == "sync_event_receipts":
            self.receipt_attempts += 1
            # The first delivery inserts the receipt; later deliveries collide
            # on event_id and must not apply the business mutation again.
            return FakeTargetResult(scalar="event-1" if self.receipt_attempts == 1 else None)
        return FakeTargetResult(rowcount=0)


def _replication_event(table_name, payload, pk, operation="upsert"):
    return {
        "event_id": "event-1",
        "source_db": "neon",
        "table_name": table_name,
        "operation": operation,
        "payload_json": json.dumps(payload),
        "pk_json": json.dumps(pk),
    }


@pytest.mark.asyncio
async def test_replay_rejects_unknown_table_instead_of_silent_success():
    target = FakeTargetSession()
    event = _replication_event("table_not_registered_for_replication", {"id": 1}, {"id": 1})

    with pytest.raises(LookupError, match="Table de réplication inconnue"):
        await _apply_event(target, event)

    assert target.executed == []


@pytest.mark.asyncio
async def test_replay_rejects_payload_columns_missing_from_metadata():
    table_name = "p071_replay_schema_test"
    table = Table(
        table_name,
        Base.metadata,
        Column("id", Integer, primary_key=True),
        Column("value", String(40), nullable=False),
    )
    target = FakeTargetSession()
    event = _replication_event(table_name, {"id": 1, "column_only_on_source": "x"}, {"id": 1})

    try:
        with pytest.raises(ValueError, match="Colonnes absentes des métadonnées"):
            await _apply_event(target, event)
        assert target.executed == []
    finally:
        Base.metadata.remove(table)


@pytest.mark.asyncio
async def test_replay_rejects_incomplete_primary_key():
    table_name = "p071_replay_pk_test"
    table = Table(
        table_name,
        Base.metadata,
        Column("tenant_id", Integer, primary_key=True),
        Column("item_id", Integer, primary_key=True),
        Column("value", String(40), nullable=False),
    )
    target = FakeTargetSession()
    event = _replication_event(table_name, {"tenant_id": 1, "item_id": 2, "value": "x"}, {"tenant_id": 1})

    try:
        with pytest.raises(ValueError, match="Clé primaire incomplète"):
            await _apply_event(target, event)
        assert target.executed == []
    finally:
        Base.metadata.remove(table)


@pytest.mark.asyncio
async def test_replay_rejects_unknown_operation():
    table_name = "p071_replay_operation_test"
    table = Table(
        table_name,
        Base.metadata,
        Column("id", Integer, primary_key=True),
        Column("value", String(40), nullable=False),
    )
    target = FakeTargetSession()
    event = _replication_event(table_name, {"id": 1, "value": "x"}, {"id": 1}, operation="truncate")

    try:
        with pytest.raises(ValueError, match="Opération de réplication inconnue"):
            await _apply_event(target, event)
        assert target.executed == []
    finally:
        Base.metadata.remove(table)

@pytest.mark.asyncio
async def test_replay_is_idempotent_when_source_acknowledgement_was_lost():
    table_name = "p072_idempotence_test"
    table = Table(
        table_name,
        Base.metadata,
        Column("id", Integer, primary_key=True),
        Column("value", String(40), nullable=False),
    )
    target = FakeTargetSession()
    event = _replication_event(table_name, {"id": 1, "value": "stable"}, {"id": 1})

    try:
        await _apply_event(target, event)
        await _apply_event(target, event)

        receipt_writes = [
            statement for statement in target.executed
            if getattr(getattr(statement, "table", None), "name", None) == "sync_event_receipts"
        ]
        business_writes = [
            statement for statement in target.executed
            if getattr(getattr(statement, "table", None), "name", None) == table_name
        ]
        assert len(receipt_writes) == 2
        assert len(business_writes) == 1
        assert target.receipt_attempts == 2
    finally:
        Base.metadata.remove(table)


@pytest.mark.asyncio
async def test_replay_rejects_payload_primary_key_mismatch():
    table_name = "p072_idempotence_pk_test"
    table = Table(
        table_name,
        Base.metadata,
        Column("id", Integer, primary_key=True),
        Column("value", String(40), nullable=False),
    )
    target = FakeTargetSession()
    event = _replication_event(table_name, {"id": 2, "value": "wrong"}, {"id": 1})

    try:
        with pytest.raises(ValueError, match="Clé primaire incohérente"):
            await _apply_event(target, event)
        assert target.executed == []
    finally:
        Base.metadata.remove(table)



def test_retry_backoff_is_exponential_bounded_and_jittered():
    first = _retry_delay_seconds(1, base_seconds=5, max_seconds=3600)
    second = _retry_delay_seconds(2, base_seconds=5, max_seconds=3600)
    capped = _retry_delay_seconds(20, base_seconds=5, max_seconds=3600)

    assert 4 <= first <= 6
    assert 8 <= second <= 12
    assert 2880 <= capped <= 4320


def test_retry_backoff_never_returns_zero_for_invalid_attempt_number():
    delay = _retry_delay_seconds(0, base_seconds=5, max_seconds=3600)
    assert 4 <= delay <= 6


def test_supabase_transaction_pooler_disables_prepared_statement_caches():
    url = (
        "postgresql+asyncpg://postgres.project:secret@"
        "aws-1-eu-west-1.pooler.supabase.com:6543/postgres"
        "?sslmode=require&channel_binding=require"
    )
    normalized, connect_args = _normalize_db_url(url)

    assert _is_supabase_transaction_pooler_url(url) is True
    assert "prepared_statement_cache_size=0" in normalized
    assert "sslmode" not in normalized
    assert "channel_binding" not in normalized
    assert connect_args == {"ssl": "require", "statement_cache_size": 0}


@pytest.mark.parametrize(
    "url",
    [
        "postgresql+asyncpg://user:secret@db.example.com:5432/postgres",
        "postgresql+asyncpg://user:secret@aws-1-eu-west-1.pooler.supabase.com:5432/postgres",
        "",
    ],
)
def test_supabase_transaction_pooler_detection_does_not_match_other_endpoints(url):
    assert _is_supabase_transaction_pooler_url(url) is False


class FakeConflictSession:
    def __init__(self):
        self.executed = []
        self.commits = 0

    async def execute(self, statement):
        self.executed.append(statement)
        return FakeTargetResult(scalar="conflict-id")

    async def commit(self):
        self.commits += 1


def test_sync_conflict_id_is_stable_independent_of_event_order():
    neon_event = {
        "event_id": "neon-event-1",
        "source_db": "neon",
        "table_name": "cards",
        "pk_json": '{"card_pk":42}',
    }
    supabase_event = {
        "event_id": "supabase-event-1",
        "source_db": "supabase",
        "table_name": "cards",
        "pk_json": '{"card_pk":42}',
    }

    assert _sync_conflict_id(neon_event, supabase_event) == _sync_conflict_id(
        supabase_event, neon_event
    )


@pytest.mark.asyncio
async def test_quarantine_conflict_records_both_events_in_both_databases():
    source = FakeConflictSession()
    target = FakeConflictSession()
    neon_event = {
        "event_id": "neon-event-1",
        "source_db": "neon",
        "table_name": "cards",
        "pk_json": '{"card_pk":42}',
    }
    supabase_event = {
        "event_id": "supabase-event-1",
        "source_db": "supabase",
        "table_name": "cards",
        "pk_json": '{"card_pk":42}',
    }

    conflict_id = await _quarantine_sync_conflict(
        source, target, neon_event, supabase_event, "neon"
    )

    for session in (source, target):
        conflict_inserts = [
            statement for statement in session.executed
            if getattr(getattr(statement, "table", None), "name", None) == "sync_conflicts"
        ]
        outbox_updates = [
            statement for statement in session.executed
            if getattr(getattr(statement, "table", None), "name", None) == "sync_outbox"
        ]
        assert len(conflict_inserts) == 1
        assert len(outbox_updates) == 1
        assert session.commits == 1

    inserted = source.executed[0].compile().params
    assert inserted["conflict_id"] == conflict_id
    assert inserted["neon_event_id"] == "neon-event-1"
    assert inserted["supabase_event_id"] == "supabase-event-1"
    assert inserted["status"] == "open"


def test_sync_conflicts_are_internal_and_registered_for_replay_rejection():
    assert "sync_conflicts" in Base.metadata.tables
