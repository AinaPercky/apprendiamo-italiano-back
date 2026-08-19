"""persist generated TTS audio for serverless runtimes

Revision ID: add_audio_item_base64
Revises: add_verb_grammar_categories
Create Date: 2026-08-19
"""

from alembic import op
import sqlalchemy as sa


revision = "add_audio_item_base64"
down_revision = "add_verb_grammar_categories"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "audio_items",
        sa.Column("audio_data", sa.Text(), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("audio_items", "audio_data")
