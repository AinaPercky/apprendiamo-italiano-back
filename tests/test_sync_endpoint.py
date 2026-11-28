import pytest
from fastapi import HTTPException

from app.api import endpoints_sync


def test_sync_trigger_rejects_missing_configuration(monkeypatch):
    monkeypatch.delenv("SYNC_CRON_SECRET", raising=False)

    with pytest.raises(HTTPException) as error:
        endpoints_sync._authorize_sync_trigger(None)

    assert error.value.status_code == 503


@pytest.mark.parametrize(
    "authorization",
    [None, "", "Basic abc", "Bearer", "Bearer wrong-secret"],
)
def test_sync_trigger_rejects_missing_or_invalid_bearer(monkeypatch, authorization):
    monkeypatch.setenv("SYNC_CRON_SECRET", "test-secret-value")

    with pytest.raises(HTTPException) as error:
        endpoints_sync._authorize_sync_trigger(authorization)

    assert error.value.status_code == 401
    assert error.value.headers["WWW-Authenticate"] == "Bearer"


def test_sync_trigger_accepts_exact_bearer(monkeypatch):
    monkeypatch.setenv("SYNC_CRON_SECRET", "test-secret-value")

    assert endpoints_sync._authorize_sync_trigger("Bearer test-secret-value") is None


@pytest.mark.asyncio
async def test_reconcile_endpoint_runs_one_cycle_and_returns_safe_status(monkeypatch):
    monkeypatch.setenv("SYNC_CRON_SECRET", "test-secret-value")
    calls = []

    async def fake_status():
        return {
            "active": "neon",
            "neon": "up",
            "supabase": "up",
            "pending_events": {"neon": 2, "supabase": 3},
            "dual_write": True,
        }

    async def fake_reconcile():
        calls.append("reconciled")

    monkeypatch.setattr(endpoints_sync, "get_db_status", fake_status)
    monkeypatch.setattr(endpoints_sync, "reconcile_once", fake_reconcile)

    result = await endpoints_sync.trigger_sync_reconciliation(
        authorization="Bearer test-secret-value"
    )

    assert calls == ["reconciled"]
    assert result["status"] == "completed"
    assert result["pending_events"] == {"neon": 2, "supabase": 3}
    assert result["batch_size_per_direction"] == 100
    assert "payload" not in result
    assert "secret" not in result


@pytest.mark.asyncio
async def test_reconcile_endpoint_fails_closed_when_database_unhealthy(monkeypatch):
    monkeypatch.setenv("SYNC_CRON_SECRET", "test-secret-value")
    calls = []

    async def fake_status():
        return {
            "active": "neon",
            "neon": "up",
            "supabase": "down",
            "pending_events": {"neon": 0, "supabase": None},
            "dual_write": False,
        }

    async def fake_reconcile():
        calls.append("must-not-run")

    monkeypatch.setattr(endpoints_sync, "get_db_status", fake_status)
    monkeypatch.setattr(endpoints_sync, "reconcile_once", fake_reconcile)

    with pytest.raises(HTTPException) as error:
        await endpoints_sync.trigger_sync_reconciliation(
            authorization="Bearer test-secret-value"
        )

    assert error.value.status_code == 503
    assert calls == []



@pytest.mark.asyncio
async def test_reconcile_claim_query_caps_configured_batch_size(monkeypatch):
    from app.database import _replicate_pending

    monkeypatch.setenv("SYNC_BATCH_SIZE", "9000")

    class EmptyResult:
        def mappings(self):
            return self

        def all(self):
            return []

    class RecordingSession:
        def __init__(self):
            self.statements = []

        async def execute(self, statement):
            self.statements.append(statement)
            return EmptyResult()

        async def commit(self):
            return None

    source = RecordingSession()
    target = RecordingSession()

    await _replicate_pending(source, target, "neon")

    claim = next(
        statement for statement in source.statements
        if getattr(statement, "_limit_clause", None) is not None
    )
    assert claim._limit_clause.value == 500
