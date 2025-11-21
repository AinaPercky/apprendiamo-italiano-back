"""Add quiz_type to user_scores

Revision ID: add_quiz_type
Revises: 
Create Date: 2025-11-21

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_quiz_type'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Ajouter la colonne quiz_type à la table user_scores
    op.add_column('user_scores', sa.Column('quiz_type', sa.String(), nullable=False, server_default='classique'))


def downgrade():
    # Supprimer la colonne quiz_type
    op.drop_column('user_scores', 'quiz_type')
