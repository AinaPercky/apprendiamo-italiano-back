"""add revocable public QR links for cards

Revision ID: add_card_public_qr_links
Revises: add_card_audio_base64
Create Date: 2026-08-15
"""

from alembic import op
import sqlalchemy as sa


revision = "add_card_public_qr_links"
down_revision = "add_card_audio_base64"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "card_public_qr_links",
        sa.Column("qr_link_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("card_pk", sa.Integer(), nullable=False),
        sa.Column("token_hash", sa.String(length=64), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("revoked_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["card_pk"], ["cards.card_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("qr_link_pk"),
        sa.UniqueConstraint("token_hash", name="uq_card_public_qr_links_token_hash"),
    )
    op.create_index("ix_card_public_qr_links_qr_link_pk", "card_public_qr_links", ["qr_link_pk"], unique=False)
    op.create_index("ix_card_public_qr_links_card_pk", "card_public_qr_links", ["card_pk"], unique=False)
    op.create_index("ix_card_public_qr_links_token_hash", "card_public_qr_links", ["token_hash"], unique=True)


def downgrade() -> None:
    op.drop_index("ix_card_public_qr_links_token_hash", table_name="card_public_qr_links")
    op.drop_index("ix_card_public_qr_links_card_pk", table_name="card_public_qr_links")
    op.drop_index("ix_card_public_qr_links_qr_link_pk", table_name="card_public_qr_links")
    op.drop_table("card_public_qr_links")
