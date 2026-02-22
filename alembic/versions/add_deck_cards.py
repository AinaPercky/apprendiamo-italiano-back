"""Add deck_cards association table

Revision ID: add_deck_cards
Revises: add_card_translations
Create Date: 2026-02-11 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.engine.reflection import Inspector

# revision identifiers, used by Alembic.
revision = 'add_deck_cards'
down_revision = 'add_card_translations'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # 1. Create the association table
    op.create_table(
        'deck_cards',
        sa.Column('deck_pk', sa.Integer(), nullable=False),
        sa.Column('card_pk', sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(['deck_pk'], ['decks.deck_pk'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['card_pk'], ['cards.card_pk'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('deck_pk', 'card_pk')
    )

    # 2. Migrate existing data: Populate deck_cards from cards.deck_pk
    # We use raw SQL for this to be efficient
    op.execute("""
        INSERT INTO deck_cards (deck_pk, card_pk)
        SELECT deck_pk, card_pk FROM cards
        WHERE deck_pk IS NOT NULL
    """)

    # 3. Make cards.deck_pk nullable (we don't drop it yet to preserve backward compatibility if needed temporarily)
    op.alter_column('cards', 'deck_pk', existing_type=sa.Integer(), nullable=True)


def downgrade() -> None:
    # We cannot easily restore deck_pk if a card belongs to multiple decks, 
    # so we just pick one (arbitrary) or leave it null.
    # This is a destructive downgrade if not handled carefully.
    
    # 1. Try to restore deck_pk from deck_cards (taking the first one found)
    op.execute("""
        UPDATE cards c
        SET deck_pk = dc.deck_pk
        FROM deck_cards dc
        WHERE c.card_pk = dc.card_pk
        AND c.deck_pk IS NULL
    """)
    
    # 2. Make deck_pk nullable=False again (might fail if some cards have no deck)
    # op.alter_column('cards', 'deck_pk', existing_type=sa.Integer(), nullable=False)
    
    op.drop_table('deck_cards')
