"""Add card translations and examples

Revision ID: add_card_translations
Revises: add_quiz_adaptive
Create Date: 2026-02-11 10:00:00.000000

"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = 'add_card_translations'
down_revision = 'add_quiz_adaptive'
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column('cards', sa.Column('explanation_it', sa.Text(), nullable=True))
    op.add_column('cards', sa.Column('translation_en', sa.Text(), nullable=True))
    op.add_column('cards', sa.Column('translation_de', sa.Text(), nullable=True))
    op.add_column('cards', sa.Column('translation_mg', sa.Text(), nullable=True))
    op.add_column('cards', sa.Column('example', sa.Text(), nullable=True))


def downgrade() -> None:
    op.drop_column('cards', 'explanation_it')
    op.drop_column('cards', 'translation_en')
    op.drop_column('cards', 'translation_de')
    op.drop_column('cards', 'translation_mg')
    op.drop_column('cards', 'example')
