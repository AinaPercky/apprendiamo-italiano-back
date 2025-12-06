"""Add quiz adaptive system tables

Revision ID: add_quiz_adaptive
Revises: 20251120_full_anki_and_scoring
Create Date: 2025-12-04 11:40:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'add_quiz_adaptive'
down_revision = '20251120_full_anki_and_scoring'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create card_performance table
    op.create_table(
        'card_performance',
        sa.Column('performance_pk', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('user_pk', sa.Integer(), nullable=False),
        sa.Column('card_pk', sa.Integer(), nullable=False),
        sa.Column('deck_pk', sa.Integer(), nullable=False),
        sa.Column('correct_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('incorrect_count', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('total_attempts', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('priority_score', sa.Float(), nullable=False, server_default='0.0'),
        sa.Column('last_reviewed_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.PrimaryKeyConstraint('performance_pk'),
        sa.ForeignKeyConstraint(['user_pk'], ['users.user_pk'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['card_pk'], ['cards.card_pk'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['deck_pk'], ['decks.deck_pk'], ondelete='CASCADE'),
    )
    op.create_index('ix_card_performance_performance_pk', 'card_performance', ['performance_pk'])
    op.create_index('ix_card_performance_user_pk', 'card_performance', ['user_pk'])
    op.create_index('ix_card_performance_card_pk', 'card_performance', ['card_pk'])
    op.create_index('ix_card_performance_deck_pk', 'card_performance', ['deck_pk'])
    
    # Create quiz_sessions table
    op.create_table(
        'quiz_sessions',
        sa.Column('session_pk', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('user_pk', sa.Integer(), nullable=False),
        sa.Column('deck_pk', sa.Integer(), nullable=False),
        sa.Column('card_count', sa.Integer(), nullable=False),
        sa.Column('quiz_type', sa.String(), nullable=False, server_default='classique'),
        sa.Column('cycle_number', sa.Integer(), nullable=False, server_default='1'),
        sa.Column('used_card_pks', sa.Text(), nullable=False),
        sa.Column('correct_count', sa.Integer(), nullable=True, server_default='0'),
        sa.Column('total_questions', sa.Integer(), nullable=True, server_default='0'),
        sa.Column('started_at', sa.DateTime(), nullable=False, server_default=sa.text('NOW()')),
        sa.Column('completed_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('session_pk'),
        sa.ForeignKeyConstraint(['user_pk'], ['users.user_pk'], ondelete='CASCADE'),
        sa.ForeignKeyConstraint(['deck_pk'], ['decks.deck_pk'], ondelete='CASCADE'),
    )
    op.create_index('ix_quiz_sessions_session_pk', 'quiz_sessions', ['session_pk'])
    op.create_index('ix_quiz_sessions_user_pk', 'quiz_sessions', ['user_pk'])
    op.create_index('ix_quiz_sessions_deck_pk', 'quiz_sessions', ['deck_pk'])


def downgrade() -> None:
    # Drop quiz_sessions table
    op.drop_index('ix_quiz_sessions_deck_pk', 'quiz_sessions')
    op.drop_index('ix_quiz_sessions_user_pk', 'quiz_sessions')
    op.drop_index('ix_quiz_sessions_session_pk', 'quiz_sessions')
    op.drop_table('quiz_sessions')
    
    # Drop card_performance table
    op.drop_index('ix_card_performance_deck_pk', 'card_performance')
    op.drop_index('ix_card_performance_card_pk', 'card_performance')
    op.drop_index('ix_card_performance_user_pk', 'card_performance')
    op.drop_index('ix_card_performance_performance_pk', 'card_performance')
    op.drop_table('card_performance')
