"""add generic card media references for Vercel Blob

Revision ID: add_card_media_blob_references
Revises: add_deck_cards
Create Date: 2026-08-14 15:20:00.000000
"""

from alembic import op
import sqlalchemy as sa


revision = "add_card_media_blob_references"
down_revision = "add_deck_cards"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "card_media",
        sa.Column("media_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("card_pk", sa.Integer(), nullable=False),
        sa.Column("kind", sa.String(length=16), nullable=False),
        sa.Column(
            "storage_provider",
            sa.String(length=32),
            nullable=False,
            server_default="vercel_blob",
        ),
        sa.Column("url", sa.Text(), nullable=False),
        sa.Column("pathname", sa.Text(), nullable=False),
        sa.Column("content_type", sa.String(length=127), nullable=False),
        sa.Column("size_bytes", sa.Integer(), nullable=False),
        sa.Column("sha256", sa.String(length=64), nullable=False),
        sa.Column("original_filename", sa.String(length=255), nullable=True),
        sa.Column("is_primary", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
        sa.CheckConstraint("kind IN ('image', 'audio')", name="ck_card_media_kind"),
        sa.ForeignKeyConstraint(["card_pk"], ["cards.card_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("media_pk"),
    )
    op.create_index("ix_card_media_card_pk", "card_media", ["card_pk"])
    op.create_index("ix_card_media_kind", "card_media", ["kind"])
    op.create_index("ix_card_media_card_kind", "card_media", ["card_pk", "kind"])
    op.create_index("ix_card_media_sha256", "card_media", ["sha256"])
    op.create_index(
        "uq_card_media_primary_kind",
        "card_media",
        ["card_pk", "kind"],
        unique=True,
        postgresql_where=sa.text("is_primary"),
    )


def downgrade() -> None:
    op.drop_index("uq_card_media_primary_kind", table_name="card_media")
    op.drop_index("ix_card_media_sha256", table_name="card_media")
    op.drop_index("ix_card_media_card_kind", table_name="card_media")
    op.drop_index("ix_card_media_kind", table_name="card_media")
    op.drop_index("ix_card_media_card_pk", table_name="card_media")
    op.drop_table("card_media")
