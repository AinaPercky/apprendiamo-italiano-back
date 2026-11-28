"""Add idempotent receipts for replicated outbox events.

Revision ID: p007_sync_event_receipts
Revises: p006_user_card_progress
"""
from alembic import op
import sqlalchemy as sa

revision = "p007_sync_event_receipts"
down_revision = "p006_user_card_progress"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "sync_event_receipts",
        sa.Column("event_id", sa.String(length=36), primary_key=True),
        sa.Column("source_db", sa.String(length=16), nullable=False),
        sa.Column(
            "applied_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
    )


def downgrade() -> None:
    # Safe only after replication is paused and pending outbox events are drained.
    op.drop_table("sync_event_receipts")
