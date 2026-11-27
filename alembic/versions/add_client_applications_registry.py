"""Add the central client application registry.

Revision ID: add_client_applications_registry
Revises: add_user_deck_uniqueness
"""
from alembic import op
import sqlalchemy as sa

revision = "add_client_applications_registry"
down_revision = "add_user_deck_uniqueness"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "client_applications",
        sa.Column("client_application_pk", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("code", sa.String(length=64), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("client_type", sa.String(length=24), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("allowed_origins", sa.Text(), nullable=False, server_default="[]"),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("code", name="uq_client_applications_code"),
    )
    op.create_index("ix_client_applications_code", "client_applications", ["code"], unique=True)
    op.create_index("ix_client_applications_is_active", "client_applications", ["is_active"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_client_applications_is_active", table_name="client_applications")
    op.drop_index("ix_client_applications_code", table_name="client_applications")
    op.drop_table("client_applications")
