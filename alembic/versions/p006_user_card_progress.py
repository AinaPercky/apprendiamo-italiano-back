"""Move Anki scheduling state to per-user card performance.

Revision ID: p006_user_card_progress
Revises: add_client_applications_registry
"""
from alembic import op
import sqlalchemy as sa

revision = "p006_user_card_progress"
down_revision = "add_client_applications_registry"
branch_labels = None
depends_on = None


def upgrade() -> None:
    bind = op.get_bind()
    duplicate = bind.execute(
        sa.text(
            """
            SELECT user_pk, card_pk, COUNT(*) AS row_count
            FROM card_performance
            GROUP BY user_pk, card_pk
            HAVING COUNT(*) > 1
            LIMIT 1
            """
        )
    ).first()
    if duplicate is not None:
        raise RuntimeError(
            "Migration P0-06 interrompue : plusieurs performances existent pour "
            "un même couple utilisateur/carte. Résoudre les doublons avant migration."
        )

    op.add_column(
        "card_performance",
        sa.Column("easiness", sa.Float(), nullable=False, server_default="2.5"),
    )
    op.add_column(
        "card_performance",
        sa.Column("interval", sa.Integer(), nullable=False, server_default="0"),
    )
    op.add_column(
        "card_performance",
        sa.Column("consecutive_correct", sa.Integer(), nullable=False, server_default="0"),
    )
    op.add_column(
        "card_performance",
        sa.Column("next_review", sa.DateTime(), nullable=False, server_default=sa.func.now()),
    )
    op.add_column(
        "card_performance",
        sa.Column("box", sa.Integer(), nullable=False, server_default="0"),
    )
    op.create_unique_constraint(
        "uq_card_performance_user_card",
        "card_performance",
        ["user_pk", "card_pk"],
    )


def downgrade() -> None:
    op.drop_constraint("uq_card_performance_user_card", "card_performance", type_="unique")
    op.drop_column("card_performance", "box")
    op.drop_column("card_performance", "next_review")
    op.drop_column("card_performance", "consecutive_correct")
    op.drop_column("card_performance", "interval")
    op.drop_column("card_performance", "easiness")
