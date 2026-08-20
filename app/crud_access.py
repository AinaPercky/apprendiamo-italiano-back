from datetime import datetime, timedelta, timezone
from typing import Iterable

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from . import models, schemas

DURATION_DELTAS = {
    "1d": timedelta(days=1),
    "3d": timedelta(days=3),
    "1w": timedelta(days=7),
    "15d": timedelta(days=15),
    "1m": timedelta(days=30),
}

PRODUCT_TYPES = {"deck", "conjugaison", "grammaire"}


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


def normalize_dt(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value


def duration_delta(duration_code: str) -> timedelta:
    try:
        return DURATION_DELTAS[duration_code]
    except KeyError as exc:
        raise ValueError("Durée de pass invalide") from exc


async def validate_target(db: AsyncSession, target_type: str, target_id: int | None) -> None:
    if target_type not in PRODUCT_TYPES:
        raise ValueError("Type de produit invalide")
    if target_type == "deck":
        if target_id is None:
            raise ValueError("Un deck doit avoir un identifiant")
        deck = await db.get(models.Deck, target_id)
        if deck is None:
            raise ValueError("Deck introuvable")
    elif target_id is not None:
        raise ValueError("Ce produit est global et ne prend pas d’identifiant")


async def user_has_access(
    db: AsyncSession,
    user: models.User,
    product_type: str,
    product_id: int | None = None,
) -> models.Subscription | None:
    if user.role in {"admin", "professeur"}:
        return None
    now = utcnow()
    query = select(models.Subscription).where(
        models.Subscription.user_pk == user.user_pk,
        models.Subscription.product_type == product_type,
        models.Subscription.status == "active",
        models.Subscription.start_at <= now,
        models.Subscription.end_at > now,
    )
    if product_id is None:
        query = query.where(models.Subscription.product_id.is_(None))
    else:
        query = query.where(models.Subscription.product_id == product_id)
    result = await db.execute(query.order_by(models.Subscription.end_at.desc()))
    return result.scalars().first()


async def access_response(
    db: AsyncSession,
    user: models.User,
    product_type: str,
    product_id: int | None = None,
) -> schemas.AccessResponse:
    if user.role in {"admin", "professeur"}:
        return schemas.AccessResponse(allowed=True, preview_only=False, reason="role_bypass")
    subscription = await user_has_access(db, user, product_type, product_id)
    if subscription is None:
        return schemas.AccessResponse(allowed=False, preview_only=True, reason="subscription_required")
    return schemas.AccessResponse(
        allowed=True,
        preview_only=False,
        reason="active_subscription",
        expires_at=normalize_dt(subscription.end_at),
    )


async def create_order(db: AsyncSession, user: models.User, payload: schemas.OrderCreate) -> models.Order:
    if user.role != "etudiant":
        raise ValueError("Seuls les étudiants peuvent créer une commande")
    if not payload.items:
        raise ValueError("Le panier est vide")

    order = models.Order(user_pk=user.user_pk, status="pending_payment")
    db.add(order)
    await db.flush()
    for item in payload.items:
        await validate_target(db, item.target_type, item.target_id)
        db.add(models.OrderItem(
            order_pk=order.order_pk,
            target_type=item.target_type,
            target_id=item.target_id,
            duration_code=item.duration_code,
            price_snapshot=item.price_snapshot,
            status="pending",
        ))
    admins = (await db.execute(select(models.User).where(models.User.role == "admin", models.User.is_active.is_(True)))).scalars().all()
    for admin in admins:
        db.add(models.Notification(admin_id=admin.user_pk, order_pk=order.order_pk, kind="order_created"))
    db.add(models.AuditLog(actor_user_pk=user.user_pk, action="order_created", entity_type="order", entity_id=order.order_pk))
    await db.commit()
    await db.refresh(order)
    return order


async def get_order(db: AsyncSession, order_pk: int) -> models.Order | None:
    return await db.get(models.Order, order_pk)


async def list_orders(db: AsyncSession, user: models.User, admin: bool = False) -> list[models.Order]:
    query = select(models.Order).order_by(models.Order.created_at.desc())
    if not admin:
        query = query.where(models.Order.user_pk == user.user_pk)
    return list((await db.execute(query.limit(200))).scalars().all())


async def list_order_items(db: AsyncSession, order_pk: int) -> list[models.OrderItem]:
    return list((await db.execute(select(models.OrderItem).where(models.OrderItem.order_pk == order_pk).order_by(models.OrderItem.order_item_pk))).scalars().all())


async def activate_order(
    db: AsyncSession,
    admin: models.User,
    order_pk: int,
    item_ids: Iterable[int] | None = None,
) -> models.Order:
    order = await get_order(db, order_pk)
    if order is None:
        raise ValueError("Commande introuvable")
    items = await list_order_items(db, order_pk)
    selected = set(item_ids) if item_ids is not None else {item.order_item_pk for item in items if item.status == "pending"}
    now = utcnow()
    activated = 0
    for item in items:
        if item.order_item_pk not in selected or item.status != "pending":
            continue
        await validate_target(db, item.target_type, item.target_id)
        db.add(models.Subscription(
            user_pk=order.user_pk,
            product_type=item.target_type,
            product_id=item.target_id,
            start_at=now,
            end_at=now + duration_delta(item.duration_code),
            status="active",
            origin="commande_etudiant",
            order_item_pk=item.order_item_pk,
            activated_by=admin.user_pk,
        ))
        item.status = "activated"
        item.activated_at = now
        activated += 1
    if activated == 0:
        raise ValueError("Aucune ligne en attente à activer")
    order.status = "activated" if all(item.status == "activated" for item in items) else "partially_activated"
    order.updated_at = now
    db.add(models.AuditLog(actor_user_pk=admin.user_pk, action="order_activated", entity_type="order", entity_id=order_pk))
    await db.commit()
    await db.refresh(order)
    return order


async def create_manual_subscription(
    db: AsyncSession,
    admin: models.User,
    payload: schemas.ManualSubscriptionCreate,
) -> models.Subscription:
    await validate_target(db, payload.product_type, payload.product_id)
    now = utcnow()
    subscription = models.Subscription(
        user_pk=payload.user_pk,
        product_type=payload.product_type,
        product_id=payload.product_id,
        start_at=now,
        end_at=now + duration_delta(payload.duration_code),
        status="active",
        origin="activation_admin",
        activated_by=admin.user_pk,
        admin_note=payload.admin_note,
    )
    db.add(subscription)
    db.add(models.AuditLog(actor_user_pk=admin.user_pk, action="manual_subscription_created", entity_type="subscription"))
    await db.commit()
    await db.refresh(subscription)
    return subscription


async def list_subscriptions(db: AsyncSession, user: models.User, user_pk: int | None = None) -> list[models.Subscription]:
    target_user_pk = user_pk if user.role == "admin" and user_pk is not None else user.user_pk
    result = await db.execute(
        select(models.Subscription)
        .where(models.Subscription.user_pk == target_user_pk)
        .order_by(models.Subscription.end_at.desc())
        .limit(200)
    )
    return list(result.scalars().all())


async def expire_subscriptions(db: AsyncSession) -> int:
    now = utcnow()
    result = await db.execute(
        select(models.Subscription).where(
            models.Subscription.status == "active",
            models.Subscription.end_at <= now,
        )
    )
    subscriptions = result.scalars().all()
    for subscription in subscriptions:
        subscription.status = "expired"
    if subscriptions:
        await db.commit()
    return len(subscriptions)


async def list_notifications(db: AsyncSession, admin: models.User) -> list[models.Notification]:
    result = await db.execute(
        select(models.Notification)
        .where((models.Notification.admin_id == admin.user_pk) | (models.Notification.admin_id.is_(None)))
        .order_by(models.Notification.created_at.desc())
        .limit(200)
    )
    return list(result.scalars().all())


async def mark_notification_read(db: AsyncSession, admin: models.User, notification_pk: int) -> models.Notification | None:
    notification = await db.get(models.Notification, notification_pk)
    if notification is None or (notification.admin_id not in {None, admin.user_pk}):
        return None
    notification.read_at = utcnow()
    await db.commit()
    await db.refresh(notification)
    return notification
