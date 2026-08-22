"""Ensure one collection row exists per user and deck.

Revision ID: add_user_deck_uniqueness
Revises: add_roles_catalog_subscriptions
Create Date: 2026-08-22
"""
from alembic import op
import sqlalchemy as sa

revision = "add_user_deck_uniqueness"
down_revision = "add_roles_catalog_subscriptions"
branch_labels = None
depends_on = None


def upgrade() -> None:
    bind = op.get_bind()
    duplicates = bind.execute(
        sa.text(
            """
            SELECT user_pk, deck_pk, COUNT(*) AS row_count
            FROM user_decks
            GROUP BY user_pk, deck_pk
            HAVING COUNT(*) > 1
            LIMIT 1
            """
        )
    ).first()
    if duplicates is not None:
        raise RuntimeError(
            "Impossible d'ajouter uq_user_decks_user_deck : des doublons user_decks existent. "
            "Nettoyer les doublons avant de rejouer cette migration."
        )
    op.create_unique_constraint(
        "uq_user_decks_user_deck",
        "user_decks",
        ["user_pk", "deck_pk"],
    )


def downgrade() -> None:
    op.drop_constraint("uq_user_decks_user_deck", "user_decks", type_="unique")
