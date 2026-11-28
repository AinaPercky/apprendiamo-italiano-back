"""Tests du contrat de journalisation des écritures SQL Core dans l'outbox."""

import json

import pytest
from sqlalchemy import Column, Integer, MetaData, String, Table, delete, insert, update

from app.database import Base, DualWriteSession, _apply_event
from app.client_applications import client_applications as _client_applications


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


class FakeApplySession:
    def __init__(self):
        self.executed = []

    async def execute(self, statement):
        self.executed.append(statement)
        return type("Result", (), {"rowcount": 0})()


def make_outbox_event(table_name="client_applications", operation="upsert", pk=None, payload=None):
    return {
        "table_name": table_name,
        "operation": operation,
        "pk_json": json.dumps(pk if pk is not None else {"client_application_pk": 7}),
        "payload_json": json.dumps(payload if payload is not None else {
            "client_application_pk": 7,
            "code": "studio",
            "name": "Studio",
            "client_type": "internal",
            "allowed_origins": "[]",
            "is_active": True,
        }),
    }


@pytest.mark.asyncio
async def test_apply_event_rejects_unknown_table_instead_of_marking_it_applied():
    session = FakeApplySession()

    with pytest.raises(LookupError, match="Table de réplication inconnue"):
        await _apply_event(session, make_outbox_event(table_name="table_absente"))

    assert session.executed == []


@pytest.mark.asyncio
async def test_apply_event_rejects_columns_missing_from_target_schema():
    session = FakeApplySession()
    payload = make_outbox_event()["payload_json"]
    data = json.loads(payload)
    data["column_from_newer_schema"] = "must not be dropped"
    event = make_outbox_event(payload=data)

    with pytest.raises(ValueError, match="Colonnes absentes du schéma cible"):
        await _apply_event(session, event)

    assert session.executed == []


@pytest.mark.asyncio
async def test_apply_event_rejects_incomplete_primary_key():
    session = FakeApplySession()
    event = make_outbox_event(pk={"unknown_pk": 7})

    with pytest.raises(ValueError, match="Colonnes absentes du schéma cible|Clé primaire incomplète"):
        await _apply_event(session, event)

    assert session.executed == []


@pytest.mark.asyncio
async def test_apply_event_rejects_outbox_recursion():
    session = FakeApplySession()

    with pytest.raises(ValueError, match="sync_outbox"):
        await _apply_event(session, make_outbox_event(table_name="sync_outbox"))

    assert session.executed == []


@pytest.mark.asyncio
async def test_apply_event_rejects_unknown_operation():
    session = FakeApplySession()
    event = make_outbox_event(operation="truncate")

    with pytest.raises(ValueError, match="Opération outbox non prise en charge"):
        await _apply_event(session, event)

    assert session.executed == []
