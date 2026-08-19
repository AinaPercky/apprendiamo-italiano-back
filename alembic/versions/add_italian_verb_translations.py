"""add French and English translations to Italian verbs

Revision ID: add_italian_verb_translations
Revises: add_audio_item_base64
Create Date: 2026-08-19
"""

from alembic import op
import sqlalchemy as sa


revision = "add_italian_verb_translations"
down_revision = "add_audio_item_base64"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("italian_verbs", sa.Column("translation_fr", sa.String(length=160), nullable=True))
    op.add_column("italian_verbs", sa.Column("translation_en", sa.String(length=160), nullable=True))


def downgrade() -> None:
    op.drop_column("italian_verbs", "translation_en")
    op.drop_column("italian_verbs", "translation_fr")
