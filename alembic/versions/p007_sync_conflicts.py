"""Add a protected register for cross-database synchronization conflicts.

Revision ID: p007_sync_conflicts
Revises: p007_sync_outbox_retry
"""
from alembic import op
import sqlalchemy as sa

revision = "p007_sync_conflicts"
down_revision = "p007_sync_outbox_retry"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "sync_conflicts",
        sa.Column("conflict_id", sa.String(length=36), primary_key=True),
        sa.Column("table_name", sa.String(length=128), nullable=False),
        sa.Column("pk_json", sa.Text(), nullable=False),
        sa.Column("neon_event_id", sa.String(length=36), nullable=False),
        sa.Column("supabase_event_id", sa.String(length=36), nullable=False),
        sa.Column(
            "detected_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.func.now(),
        ),
        sa.Column("status", sa.String(length=16), nullable=False, server_default="open"),
        sa.Column("resolution", sa.Text(), nullable=True),
        sa.Column("resolved_at", sa.DateTime(timezone=True), nullable=True),
    )
    op.execute("ALTER TABLE sync_conflicts ENABLE ROW LEVEL SECURITY")
    op.execute("REVOKE ALL PRIVILEGES ON TABLE sync_conflicts FROM PUBLIC")
    op.execute("""
        DO $$
        BEGIN
            IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
                REVOKE ALL PRIVILEGES ON TABLE sync_conflicts FROM anon;
            END IF;
            IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
                REVOKE ALL PRIVILEGES ON TABLE sync_conflicts FROM authenticated;
            END IF;
            IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
                GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE sync_conflicts TO service_role;
            END IF;
        END $$;
    """)


def downgrade() -> None:
    # Stop both workers and export open conflicts before downgrading.
    op.drop_table("sync_conflicts")
