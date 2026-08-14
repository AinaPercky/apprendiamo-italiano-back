"""add temporary PostgreSQL base64 audio per card

Revision ID: add_card_audio_base64
Revises: add_card_media_blob_references
Create Date: 2026-08-14
"""

from alembic import op
import sqlalchemy as sa


revision = "add_card_audio_base64"
down_revision = "add_card_media_blob_references"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "card_audio",
        sa.Column("audio_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("card_pk", sa.Integer(), nullable=False),
        sa.Column("filename", sa.String(length=255), nullable=True),
        sa.Column("content_type", sa.String(length=64), nullable=False, server_default="audio/mpeg"),
        sa.Column("size_bytes", sa.Integer(), nullable=False),
        sa.Column("audio_data", sa.Text(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["card_pk"], ["cards.card_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("audio_pk"),
        sa.UniqueConstraint("card_pk", name="uq_card_audio_card_pk"),
    )
    op.create_index("ix_card_audio_audio_pk", "card_audio", ["audio_pk"], unique=False)
    op.create_index("ix_card_audio_card_pk", "card_audio", ["card_pk"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_card_audio_card_pk", table_name="card_audio")
    op.drop_index("ix_card_audio_audio_pk", table_name="card_audio")
    op.drop_table("card_audio")
