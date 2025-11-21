"""Full Anki algorithm + Deck scoring system (noms réels des quiz)"""

from alembic import op
import sqlalchemy as sa

revision = '20251120_full_anki_and_scoring'
down_revision = None
branch_labels = None
depends_on = None

def upgrade():
    # ==================== CHAMPS ANKI SUR CARDS ====================
    op.add_column('cards', sa.Column('easiness', sa.Float(), nullable=False, server_default='2.5'))
    op.add_column('cards', sa.Column('interval', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('cards', sa.Column('consecutive_correct', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('cards', sa.Column('last_reviewed_at', sa.DateTime(timezone=True), nullable=True))

    # ==================== SCORING PAR TYPE DE QUIZ (tes vrais noms) ====================
    op.add_column('user_decks', sa.Column('mastered_cards', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_decks', sa.Column('learning_cards', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_decks', sa.Column('review_cards', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_decks', sa.Column('total_points', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_decks', sa.Column('total_attempts', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_decks', sa.Column('successful_attempts', sa.Integer(), nullable=False, server_default='0'))

    # Tes 4 vrais quiz
    op.add_column('user_decks', sa.Column('points_frappe', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_decks', sa.Column('points_association', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_decks', sa.Column('points_qcm', sa.Integer(), nullable=False, server_default='0'))
    op.add_column('user_decks', sa.Column('points_classique', sa.Integer(), nullable=False, server_default='0'))  # Jusqu'à 100%

    # Initialisation
    op.execute("UPDATE cards SET easiness = 2.5, interval = 0, consecutive_correct = 0, last_reviewed_at = created_at")
    op.execute("UPDATE cards SET next_review = COALESCE(next_review, created_at + INTERVAL '1 day') WHERE next_review IS NULL")

def downgrade():
    columns_cards = ['last_reviewed_at', 'consecutive_correct', 'interval', 'easiness']
    columns_user_decks = [
        'points_classique', 'points_qcm', 'points_association', 'points_frappe',
        'successful_attempts', 'total_attempts', 'total_points',
        'review_cards', 'learning_cards', 'mastered_cards'
    ]
    for col in columns_cards:
        op.drop_column('cards', col)
    for col in columns_user_decks:
        op.drop_column('user_decks', col)