"""Real PostgreSQL integration test for bidirectional outbox replay and conflicts.

The CI workflow supplies two independent PostgreSQL service databases. This test
uses the production reconcile_once/_replicate_pending code, not mocked sessions.
"""
import json
import uuid
from datetime import datetime, timezone

import pytest
from sqlalchemy import Column, Integer, String, Table, select, insert
from sqlalchemy.ext.asyncio import AsyncSession

from app import database as db


probe = Table(
    "p072_replication_integration_probe",
    db.Base.metadata,
    Column("id", Integer, primary_key=True),
    Column("value", String(120), nullable=False),
)


async def _insert_event(engine, source_db: str, event_id: str, row_id: int, value: str):
    payload = {"id": row_id, "value": value}
    event = {
        "event_id": event_id,
        "source_db": source_db,
        "table_name": probe.name,
        "operation": "upsert",
        "pk_json": json.dumps({"id": row_id}, sort_keys=True),
        "payload_json": json.dumps(payload, sort_keys=True),
        "status": "pending",
        "attempts": 0,
        "last_error": None,
        "created_at": datetime.now(timezone.utc),
        "applied_at": None,
        "available_at": datetime.now(timezone.utc),
        "locked_at": None,
        "locked_by": None,
    }
    async with AsyncSession(engine) as session:
        await session.execute(insert(db.sync_outbox).values(**event))
        await session.commit()


async def _scalar(engine, statement):
    async with AsyncSession(engine) as session:
        return (await session.execute(statement)).scalar_one()


@pytest.mark.asyncio
async def test_real_postgres_replay_both_directions_and_quarantine_conflict():
    assert db.secondary_engine is not None, "SUPABASE_DATABASE_URL must point to second PostgreSQL service"

    # Separate, disposable PostgreSQL services; no production credentials/data.
    for target_engine in (db.engine, db.secondary_engine):
        async with target_engine.begin() as connection:
            await connection.run_sync(db.Base.metadata.create_all)

    neon_event_id = f"it-neon-{uuid.uuid4()}"
    supabase_event_id = f"it-supabase-{uuid.uuid4()}"

    try:
        # Neon -> Supabase through the actual worker/replay implementation.
        await _insert_event(db.engine, "neon", neon_event_id, 101, "from-neon")
        await db.reconcile_once()
        async with AsyncSession(db.secondary_engine) as session:
            mirrored = (await session.execute(select(probe).where(probe.c.id == 101))).mappings().one()
            assert mirrored["value"] == "from-neon"
            receipt = await session.execute(
                select(db.sync_event_receipts.c.event_id).where(
                    db.sync_event_receipts.c.event_id == neon_event_id
                )
            )
            assert receipt.scalar_one() == neon_event_id
        async with AsyncSession(db.engine) as session:
            status = await session.execute(
                select(db.sync_outbox.c.status).where(db.sync_outbox.c.event_id == neon_event_id)
            )
            assert status.scalar_one() == "applied"

        # Supabase -> Neon through the same worker, in the reverse direction.
        await _insert_event(db.secondary_engine, "supabase", supabase_event_id, 202, "from-supabase")
        await db.reconcile_once()
        async with AsyncSession(db.engine) as session:
            mirrored = (await session.execute(select(probe).where(probe.c.id == 202))).mappings().one()
            assert mirrored["value"] == "from-supabase"
            receipt = await session.execute(
                select(db.sync_event_receipts.c.event_id).where(
                    db.sync_event_receipts.c.event_id == supabase_event_id
                )
            )
            assert receipt.scalar_one() == supabase_event_id
        async with AsyncSession(db.secondary_engine) as session:
            status = await session.execute(
                select(db.sync_outbox.c.status).where(db.sync_outbox.c.event_id == supabase_event_id)
            )
            assert status.scalar_one() == "applied"

        # Two independently-originated pending writes for the same PK must not
        # overwrite either business row; both events and conflict registers persist.
        neon_conflict_id = f"it-neon-conflict-{uuid.uuid4()}"
        supabase_conflict_id = f"it-supabase-conflict-{uuid.uuid4()}"
        await _insert_event(db.engine, "neon", neon_conflict_id, 303, "neon-version")
        await _insert_event(db.secondary_engine, "supabase", supabase_conflict_id, 303, "supabase-version")
        await db.reconcile_once()

        async with AsyncSession(db.engine) as session:
            rows = (await session.execute(
                select(db.sync_outbox.c.event_id, db.sync_outbox.c.status).where(
                    db.sync_outbox.c.event_id.in_([neon_conflict_id, supabase_conflict_id])
                )
            )).all()
            assert {row.status for row in rows} == {"quarantined"}
            conflict = (await session.execute(
                select(db.sync_conflicts).where(
                    db.sync_conflicts.c.neon_event_id == neon_conflict_id,
                    db.sync_conflicts.c.supabase_event_id == supabase_conflict_id,
                )
            )).mappings().one()
            assert conflict["status"] == "open"

        async with AsyncSession(db.secondary_engine) as session:
            rows = (await session.execute(
                select(db.sync_outbox.c.event_id, db.sync_outbox.c.status).where(
                    db.sync_outbox.c.event_id.in_([neon_conflict_id, supabase_conflict_id])
                )
            )).all()
            assert {row.status for row in rows} == {"quarantined"}
            conflict = (await session.execute(
                select(db.sync_conflicts).where(
                    db.sync_conflicts.c.neon_event_id == neon_conflict_id,
                    db.sync_conflicts.c.supabase_event_id == supabase_conflict_id,
                )
            )).mappings().one()
            assert conflict["status"] == "open"

        # A second replay must not create duplicate conflict records or mutate
        # either side's business value.
        await db.reconcile_once()
        assert await _scalar(
            db.engine,
            select(probe.c.value).where(probe.c.id == 303),
        ) == "neon-version"
        assert await _scalar(
            db.secondary_engine,
            select(probe.c.value).where(probe.c.id == 303),
        ) == "supabase-version"
        assert await _scalar(
            db.engine,
            select(db.sync_conflicts.c.conflict_id).where(
                db.sync_conflicts.c.neon_event_id == neon_conflict_id,
                db.sync_conflicts.c.supabase_event_id == supabase_conflict_id,
            ),
        )
    finally:
        for target_engine in (db.engine, db.secondary_engine):
            async with target_engine.begin() as connection:
                await connection.run_sync(db.Base.metadata.drop_all)
        await db.engine.dispose()
        await db.secondary_engine.dispose()
