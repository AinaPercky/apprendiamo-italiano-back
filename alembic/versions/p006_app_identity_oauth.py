"""Add PKCE authorization codes and exact redirect URI allowlists.

Revision ID: p006_app_identity_oauth
Revises: p006_user_card_progress
"""
from alembic import op
import sqlalchemy as sa

revision = "p006_app_identity_oauth"
down_revision = "p006_user_card_progress"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "client_applications",
        sa.Column("allowed_redirect_uris", sa.Text(), nullable=False, server_default="[]"),
    )
    op.create_table(
        "oauth_authorization_codes",
        sa.Column("code_pk", sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column("code_hash", sa.String(length=64), nullable=False),
        sa.Column("user_pk", sa.Integer(), sa.ForeignKey("users.user_pk", ondelete="CASCADE"), nullable=False),
        sa.Column("client_code", sa.String(length=64), nullable=False),
        sa.Column("redirect_uri", sa.Text(), nullable=False),
        sa.Column("code_challenge", sa.String(length=128), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("consumed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.func.now()),
        sa.UniqueConstraint("code_hash", name="uq_oauth_authorization_codes_hash"),
    )
    op.create_index("ix_oauth_authorization_codes_expiry", "oauth_authorization_codes", ["expires_at"])
    op.create_index("ix_oauth_authorization_codes_client_code", "oauth_authorization_codes", ["client_code"])
    op.create_index("ix_oauth_authorization_codes_user", "oauth_authorization_codes", ["user_pk"])
    op.execute("""
        INSERT INTO client_applications
            (code, name, client_type, description, allowed_origins, allowed_redirect_uris, is_active)
        VALUES
            ('studio', 'Studio pédagogique central', 'public_web',
             'Frontend central de gestion pédagogique',
             '["https://bella-design-lab.vercel.app","http://localhost:8081","http://127.0.0.1:8081","http://localhost:5173","http://127.0.0.1:5173"]',
             '["https://bella-design-lab.vercel.app/oauth/callback","http://localhost:8081/oauth/callback","http://127.0.0.1:8081/oauth/callback","http://localhost:5173/oauth/callback","http://127.0.0.1:5173/oauth/callback"]',
             TRUE)
        ON CONFLICT (code) DO NOTHING
    """)


def downgrade() -> None:
    op.drop_index("ix_oauth_authorization_codes_client_code", table_name="oauth_authorization_codes")
    op.drop_index("ix_oauth_authorization_codes_user", table_name="oauth_authorization_codes")
    op.drop_index("ix_oauth_authorization_codes_expiry", table_name="oauth_authorization_codes")
    op.drop_table("oauth_authorization_codes")
    op.drop_column("client_applications", "allowed_redirect_uris")
