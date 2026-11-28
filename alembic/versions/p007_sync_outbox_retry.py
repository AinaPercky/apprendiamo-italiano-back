"""Add leases and retry scheduling to the synchronization outbox.

Revision ID: p007_sync_outbox_retry
Revises: p007_sync_event_receipts
"""
from alembic import op
import sqlalchemy as sa

revision = "p007_sync_outbox_retry"
down_revision = "p007_sync_event_receipts"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "sync_outbox",
        sa.Column("available_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.add_column(
        "sync_outbox",
        sa.Column("locked_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.add_column(
        "sync_outbox",
        sa.Column("locked_by", sa.String(length=64), nullable=True),
    )
    op.execute("UPDATE sync_outbox SET available_at = COALESCE(created_at, CURRENT_TIMESTAMP) WHERE available_at IS NULL")
    op.alter_column(
        "sync_outbox",
        "available_at",
        existing_type=sa.DateTime(timezone=True),
        nullable=False,
        server_default=sa.func.now(),
    )
    op.create_index(
        "ix_sync_outbox_claim",
        "sync_outbox",
        ["source_db", "status", "available_at", "created_at"],
        unique=False,
    )


def downgrade() -> None:
    # Stop workers and drain pending/processing events before downgrading.
    op.drop_index("ix_sync_outbox_claim", table_name="sync_outbox")
    op.drop_column("sync_outbox", "locked_by")
    op.drop_column("sync_outbox", "locked_at")
    op.drop_column("sync_outbox", "available_at")
