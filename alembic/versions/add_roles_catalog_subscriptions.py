"""add roles catalog subscriptions and orders

Revision ID: add_roles_catalog_subscriptions
Revises: add_italian_verb_translations
Create Date: 2026-08-20
"""
from alembic import op
import sqlalchemy as sa

revision = "add_roles_catalog_subscriptions"
down_revision = "add_italian_verb_translations"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("users", sa.Column("role", sa.String(length=32), nullable=False, server_default="admin"))
    op.create_index("ix_users_role", "users", ["role"], unique=False)
    op.execute("UPDATE users SET role = 'admin' WHERE role IS NULL OR role = ''")
    op.alter_column("users", "role", server_default="etudiant")

    op.add_column("decks", sa.Column("created_by", sa.Integer(), nullable=True))
    op.add_column("decks", sa.Column("visibility", sa.String(length=24), nullable=False, server_default="global"))
    op.add_column("decks", sa.Column("description", sa.Text(), nullable=True))
    op.add_column("decks", sa.Column("published_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("decks", sa.Column("archived_at", sa.DateTime(timezone=True), nullable=True))
    op.create_index("ix_decks_created_by", "decks", ["created_by"], unique=False)
    op.create_index("ix_decks_visibility", "decks", ["visibility"], unique=False)
    op.create_foreign_key("fk_decks_created_by_users", "decks", "users", ["created_by"], ["user_pk"], ondelete="SET NULL")

    op.add_column("audio_items", sa.Column("created_by", sa.Integer(), nullable=True))
    op.add_column("audio_items", sa.Column("deck_pk", sa.Integer(), nullable=True))
    op.add_column("audio_items", sa.Column("visibility", sa.String(length=24), nullable=False, server_default="global"))
    op.add_column("audio_items", sa.Column("description", sa.Text(), nullable=True))
    op.add_column("audio_items", sa.Column("published_at", sa.DateTime(timezone=True), nullable=True))
    op.create_index("ix_audio_items_created_by", "audio_items", ["created_by"], unique=False)
    op.create_index("ix_audio_items_deck_pk", "audio_items", ["deck_pk"], unique=False)
    op.create_index("ix_audio_items_visibility", "audio_items", ["visibility"], unique=False)
    op.create_foreign_key("fk_audio_items_created_by_users", "audio_items", "users", ["created_by"], ["user_pk"], ondelete="SET NULL")
    op.create_foreign_key("fk_audio_items_deck_pk_decks", "audio_items", "decks", ["deck_pk"], ["deck_pk"], ondelete="SET NULL")

    op.create_table(
        "orders",
        sa.Column("order_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_pk", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="pending_payment"),
        sa.Column("admin_note", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_pk"], ["users.user_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("order_pk"),
    )
    op.create_index("ix_orders_user_pk", "orders", ["user_pk"], unique=False)
    op.create_index("ix_orders_status", "orders", ["status"], unique=False)
    op.create_index("ix_orders_created_at", "orders", ["created_at"], unique=False)

    op.create_table(
        "order_items",
        sa.Column("order_item_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("order_pk", sa.Integer(), nullable=False),
        sa.Column("target_type", sa.String(length=24), nullable=False),
        sa.Column("target_id", sa.Integer(), nullable=True),
        sa.Column("duration_code", sa.String(length=16), nullable=False),
        sa.Column("status", sa.String(length=24), nullable=False, server_default="pending"),
        sa.Column("price_snapshot", sa.Numeric(10, 2), nullable=True),
        sa.Column("activated_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["order_pk"], ["orders.order_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("order_item_pk"),
    )
    op.create_index("ix_order_items_order_pk", "order_items", ["order_pk"], unique=False)
    op.create_index("ix_order_items_target_type", "order_items", ["target_type"], unique=False)
    op.create_index("ix_order_items_target_id", "order_items", ["target_id"], unique=False)
    op.create_index("ix_order_items_status", "order_items", ["status"], unique=False)

    op.create_table(
        "subscriptions",
        sa.Column("subscription_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_pk", sa.Integer(), nullable=False),
        sa.Column("product_type", sa.String(length=24), nullable=False),
        sa.Column("product_id", sa.Integer(), nullable=True),
        sa.Column("start_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("end_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("status", sa.String(length=24), nullable=False, server_default="active"),
        sa.Column("origin", sa.String(length=32), nullable=False),
        sa.Column("order_item_pk", sa.Integer(), nullable=True),
        sa.Column("activated_by", sa.Integer(), nullable=True),
        sa.Column("admin_note", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("cancelled_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["activated_by"], ["users.user_pk"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["order_item_pk"], ["order_items.order_item_pk"], ondelete="SET NULL"),
        sa.ForeignKeyConstraint(["user_pk"], ["users.user_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("subscription_pk"),
    )
    op.create_index("ix_subscriptions_user_pk", "subscriptions", ["user_pk"], unique=False)
    op.create_index("ix_subscriptions_product_type", "subscriptions", ["product_type"], unique=False)
    op.create_index("ix_subscriptions_product_id", "subscriptions", ["product_id"], unique=False)
    op.create_index("ix_subscriptions_start_at", "subscriptions", ["start_at"], unique=False)
    op.create_index("ix_subscriptions_end_at", "subscriptions", ["end_at"], unique=False)
    op.create_index("ix_subscriptions_status", "subscriptions", ["status"], unique=False)
    op.create_index("ix_subscriptions_order_item_pk", "subscriptions", ["order_item_pk"], unique=False)
    op.create_index("ix_subscriptions_activated_by", "subscriptions", ["activated_by"], unique=False)

    op.create_table(
        "notifications",
        sa.Column("notification_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("admin_id", sa.Integer(), nullable=True),
        sa.Column("order_pk", sa.Integer(), nullable=True),
        sa.Column("kind", sa.String(length=48), nullable=False, server_default="order_created"),
        sa.Column("read_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["admin_id"], ["users.user_pk"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["order_pk"], ["orders.order_pk"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("notification_pk"),
    )
    op.create_index("ix_notifications_admin_id", "notifications", ["admin_id"], unique=False)
    op.create_index("ix_notifications_order_pk", "notifications", ["order_pk"], unique=False)
    op.create_index("ix_notifications_created_at", "notifications", ["created_at"], unique=False)

    op.create_table(
        "audit_logs",
        sa.Column("audit_log_pk", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("actor_user_pk", sa.Integer(), nullable=True),
        sa.Column("action", sa.String(length=64), nullable=False),
        sa.Column("entity_type", sa.String(length=32), nullable=False),
        sa.Column("entity_id", sa.Integer(), nullable=True),
        sa.Column("details", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["actor_user_pk"], ["users.user_pk"], ondelete="SET NULL"),
        sa.PrimaryKeyConstraint("audit_log_pk"),
    )
    op.create_index("ix_audit_logs_actor_user_pk", "audit_logs", ["actor_user_pk"], unique=False)
    op.create_index("ix_audit_logs_action", "audit_logs", ["action"], unique=False)
    op.create_index("ix_audit_logs_entity_type", "audit_logs", ["entity_type"], unique=False)
    op.create_index("ix_audit_logs_entity_id", "audit_logs", ["entity_id"], unique=False)
    op.create_index("ix_audit_logs_created_at", "audit_logs", ["created_at"], unique=False)


def downgrade() -> None:
    op.drop_table("audit_logs")
    op.drop_table("notifications")
    op.drop_table("subscriptions")
    op.drop_table("order_items")
    op.drop_table("orders")
    op.drop_constraint("fk_audio_items_deck_pk_decks", "audio_items", type_="foreignkey")
    op.drop_constraint("fk_audio_items_created_by_users", "audio_items", type_="foreignkey")
    op.drop_index("ix_audio_items_visibility", table_name="audio_items")
    op.drop_index("ix_audio_items_deck_pk", table_name="audio_items")
    op.drop_index("ix_audio_items_created_by", table_name="audio_items")
    op.drop_column("audio_items", "published_at")
    op.drop_column("audio_items", "description")
    op.drop_column("audio_items", "visibility")
    op.drop_column("audio_items", "deck_pk")
    op.drop_column("audio_items", "created_by")
    op.drop_constraint("fk_decks_created_by_users", "decks", type_="foreignkey")
    op.drop_index("ix_decks_visibility", table_name="decks")
    op.drop_index("ix_decks_created_by", table_name="decks")
    op.drop_column("decks", "archived_at")
    op.drop_column("decks", "published_at")
    op.drop_column("decks", "description")
    op.drop_column("decks", "visibility")
    op.drop_column("decks", "created_by")
    op.drop_index("ix_users_role", table_name="users")
    op.drop_column("users", "role")
