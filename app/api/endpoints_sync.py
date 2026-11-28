"""Internal endpoint used by the external scheduled replication trigger."""
import hmac
import os

from fastapi import APIRouter, Header, HTTPException, status

from ..database import get_db_status, reconcile_once

router = APIRouter(prefix="/internal/sync", tags=["internal sync"])


def _authorize_sync_trigger(authorization: str | None) -> None:
    """Accept only a configured bearer secret; never log or expose its value."""
    expected = os.getenv("SYNC_CRON_SECRET", "")
    if not expected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Sync trigger is not configured",
        )

    scheme, separator, supplied = (authorization or "").partition(" ")
    if (
        not separator
        or scheme.lower() != "bearer"
        or not supplied
        or not hmac.compare_digest(supplied, expected)
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Unauthorized",
            headers={"WWW-Authenticate": "Bearer"},
        )


@router.post("/reconcile")
async def trigger_sync_reconciliation(
    authorization: str | None = Header(default=None, alias="Authorization"),
):
    """Run one bounded reconciliation cycle in both directions.

    The existing reconciler claims at most SYNC_BATCH_SIZE events per source,
    uses row leases/SKIP LOCKED, and returns without waiting for the whole queue.
    """
    _authorize_sync_trigger(authorization)

    before = await get_db_status()
    if not before["dual_write"]:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Both replication databases must be available",
        )

    await reconcile_once()

    after = await get_db_status()
    if not after["dual_write"]:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Replication database health check failed",
        )

    return {
        "status": "completed",
        "pending_events": after["pending_events"],
        "batch_size_per_direction": min(
            500, max(1, int(os.getenv("SYNC_BATCH_SIZE", "100")))
        ),
    }
