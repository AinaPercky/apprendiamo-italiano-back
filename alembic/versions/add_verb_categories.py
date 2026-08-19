"""Add frontend verb categories.

Revision ID: add_verb_categories
Revises: add_italian_conjugations
Create Date: 2026-08-18
"""

from alembic import op
import sqlalchemy as sa


revision = "add_verb_categories"
down_revision = "add_italian_conjugations"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "italian_verbs",
        sa.Column("category", sa.String(length=64), nullable=False, server_default="Actions"),
    )
    op.create_index("ix_italian_verbs_category", "italian_verbs", ["category"], unique=False)
    op.alter_column("italian_verbs", "category", server_default=None)


def downgrade() -> None:
    op.drop_index("ix_italian_verbs_category", table_name="italian_verbs")
    op.drop_column("italian_verbs", "category")
