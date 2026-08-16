"""add autonomous italian verb conjugations

Revision ID: add_italian_conjugations
Revises: add_card_public_qr_links
Create Date: 2026-08-16
"""

from alembic import op
import sqlalchemy as sa


revision = "add_italian_conjugations"
down_revision = "add_card_public_qr_links"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "italian_verbs",
        sa.Column("verb_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("infinitive", sa.String(length=160), nullable=False),
        sa.Column("normalized_infinitive", sa.String(length=160), nullable=False),
        sa.Column("source_record_id", sa.String(length=64), nullable=True),
        sa.Column("source_name", sa.String(length=160), nullable=False),
        sa.Column("source_url", sa.Text(), nullable=False),
        sa.Column("source_license", sa.String(length=32), nullable=False),
        sa.Column("source_checksum", sa.String(length=64), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("verb_pk"),
        sa.UniqueConstraint("infinitive", name="uq_italian_verbs_infinitive"),
        sa.UniqueConstraint("normalized_infinitive", name="uq_italian_verbs_normalized_infinitive"),
    )
    op.create_index("ix_italian_verbs_verb_pk", "italian_verbs", ["verb_pk"], unique=False)
    op.create_index("ix_italian_verbs_infinitive", "italian_verbs", ["infinitive"], unique=True)
    op.create_index("ix_italian_verbs_normalized_infinitive", "italian_verbs", ["normalized_infinitive"], unique=True)

    op.create_table(
        "italian_conjugations",
        sa.Column("conjugation_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("verb_pk", sa.Integer(), nullable=False),
        sa.Column("mood", sa.String(length=64), nullable=False),
        sa.Column("tense", sa.String(length=80), nullable=False),
        sa.Column("mood_order", sa.Integer(), nullable=False, server_default="99"),
        sa.Column("tense_order", sa.Integer(), nullable=False, server_default="99"),
        sa.Column("source_conjugation_id", sa.String(length=64), nullable=True),
        sa.Column("raw_italian", sa.Text(), nullable=False),
        sa.Column("raw_portuguese", sa.Text(), nullable=True),
        sa.Column("is_featured", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.ForeignKeyConstraint(["verb_pk"], ["italian_verbs.verb_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("conjugation_pk"),
        sa.UniqueConstraint("verb_pk", "mood", "tense", name="uq_italian_conjugation_verb_mood_tense"),
    )
    op.create_index("ix_italian_conjugations_conjugation_pk", "italian_conjugations", ["conjugation_pk"], unique=False)
    op.create_index("ix_italian_conjugations_verb_pk", "italian_conjugations", ["verb_pk"], unique=False)
    op.create_index("ix_italian_conjugations_mood", "italian_conjugations", ["mood"], unique=False)
    op.create_index("ix_italian_conjugations_tense", "italian_conjugations", ["tense"], unique=False)

    op.create_table(
        "italian_conjugation_forms",
        sa.Column("form_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("conjugation_pk", sa.Integer(), nullable=False),
        sa.Column("person_order", sa.Integer(), nullable=False),
        sa.Column("person_label", sa.String(length=48), nullable=True),
        sa.Column("form_text", sa.Text(), nullable=False),
        sa.Column("raw_line", sa.Text(), nullable=True),
        sa.ForeignKeyConstraint(["conjugation_pk"], ["italian_conjugations.conjugation_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("form_pk"),
        sa.UniqueConstraint("conjugation_pk", "person_order", name="uq_italian_conjugation_form_position"),
    )
    op.create_index("ix_italian_conjugation_forms_form_pk", "italian_conjugation_forms", ["form_pk"], unique=False)
    op.create_index("ix_italian_conjugation_forms_conjugation_pk", "italian_conjugation_forms", ["conjugation_pk"], unique=False)
    op.create_index("ix_italian_conjugation_forms_form_text", "italian_conjugation_forms", ["form_text"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_italian_conjugation_forms_form_text", table_name="italian_conjugation_forms")
    op.drop_index("ix_italian_conjugation_forms_conjugation_pk", table_name="italian_conjugation_forms")
    op.drop_index("ix_italian_conjugation_forms_form_pk", table_name="italian_conjugation_forms")
    op.drop_table("italian_conjugation_forms")
    op.drop_index("ix_italian_conjugations_tense", table_name="italian_conjugations")
    op.drop_index("ix_italian_conjugations_mood", table_name="italian_conjugations")
    op.drop_index("ix_italian_conjugations_verb_pk", table_name="italian_conjugations")
    op.drop_index("ix_italian_conjugations_conjugation_pk", table_name="italian_conjugations")
    op.drop_table("italian_conjugations")
    op.drop_index("ix_italian_verbs_normalized_infinitive", table_name="italian_verbs")
    op.drop_index("ix_italian_verbs_infinitive", table_name="italian_verbs")
    op.drop_index("ix_italian_verbs_verb_pk", table_name="italian_verbs")
    op.drop_table("italian_verbs")
