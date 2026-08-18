"""Add grammatical verb categories.

Revision ID: add_verb_grammar_categories
Revises: add_verb_categories
Create Date: 2026-08-18
"""

from alembic import op
import sqlalchemy as sa


revision = "add_verb_grammar_categories"
down_revision = "add_verb_categories"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "italian_verbs",
        sa.Column("grammar_category", sa.String(length=64), nullable=False, server_default="Verbes irréguliers"),
    )
    op.create_index("ix_italian_verbs_grammar_category", "italian_verbs", ["grammar_category"], unique=False)
    op.alter_column("italian_verbs", "grammar_category", server_default=None)


def downgrade() -> None:
    op.drop_index("ix_italian_verbs_grammar_category", table_name="italian_verbs")
    op.drop_column("italian_verbs", "grammar_category")
