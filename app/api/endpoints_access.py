from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from .. import crud_access, models, schemas
from ..database import get_db
from ..security import get_current_active_user, require_admin

router = APIRouter(tags=["access", "orders", "subscriptions"])


def serialize_order(order: models.Order, items: list[models.OrderItem]) -> dict:
    return {
        "order_pk": order.order_pk,
        "user_pk": order.user_pk,
        "status": order.status,
        "admin_note": order.admin_note,
        "created_at": order.created_at,
        "updated_at": order.updated_at,
        "items": items,
    }


@router.get("/api/access/check", response_model=schemas.AccessResponse)
async def check_access(
    product_type: str,
    product_id: int | None = None,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    if product_type not in crud_access.PRODUCT_TYPES:
        raise HTTPException(status_code=400, detail="Type de produit invalide")
    return await crud_access.access_response(db, current_user, product_type, product_id)


@router.get("/api/subscriptions", response_model=list[schemas.SubscriptionResponse])
async def read_my_subscriptions(
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    await crud_access.expire_subscriptions(db)
    return await crud_access.list_subscriptions(db, current_user)


@router.post("/api/orders", response_model=schemas.OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    payload: schemas.OrderCreate,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    try:
        order = await crud_access.create_order(db, current_user, payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    items = await crud_access.list_order_items(db, order.order_pk)
    return serialize_order(order, items)


@router.get("/api/orders", response_model=list[schemas.OrderResponse])
async def read_my_orders(
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    orders = await crud_access.list_orders(db, current_user)
    return [serialize_order(order, await crud_access.list_order_items(db, order.order_pk)) for order in orders]


@router.get("/api/orders/{order_pk}", response_model=schemas.OrderResponse)
async def read_my_order(
    order_pk: int,
    current_user: models.User = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db),
):
    order = await crud_access.get_order(db, order_pk)
    if order is None or order.user_pk != current_user.user_pk:
        raise HTTPException(status_code=404, detail="Commande introuvable")
    return serialize_order(order, await crud_access.list_order_items(db, order_pk))


@router.get("/api/admin/users", response_model=list[schemas.UserResponse])
async def read_admin_users(
    search: str | None = Query(default=None, max_length=160),
    _admin: models.User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    query = select(models.User).order_by(models.User.created_at.desc()).limit(500)
    if search:
        query = query.where(
            (models.User.email.ilike(f"%{search}%"))
            | (models.User.full_name.ilike(f"%{search}%"))
        )
    users = (await db.execute(query)).scalars().all()
    return [schemas.UserResponse.model_validate(user) for user in users]


@router.patch("/api/admin/users/{user_pk}", response_model=schemas.UserDetailResponse)
async def update_admin_user(
    user_pk: int,
    payload: schemas.AdminUserUpdate,
    admin: models.User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    user = await db.get(models.User, user_pk)
    if user is None:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")
    if payload.role is None and payload.is_active is None:
        raise HTTPException(status_code=400, detail="Aucune modification demandée")
    if user.user_pk == admin.user_pk and (payload.role not in {None, "admin"} or payload.is_active is False):
        raise HTTPException(status_code=400, detail="Un administrateur ne peut pas désactiver ou rétrograder son propre compte")
    if payload.role is not None:
        user.role = payload.role
    if payload.is_active is not None:
        user.is_active = payload.is_active
    db.add(models.AuditLog(
        actor_user_pk=admin.user_pk,
        action="user_role_or_status_updated",
        entity_type="user",
        entity_id=user_pk,
    ))
    await db.commit()
    await db.refresh(user)
    return schemas.UserDetailResponse.model_validate(user)


@router.get("/api/admin/orders", response_model=list[schemas.OrderResponse])
async def read_all_orders(
    _admin: models.User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    orders = await crud_access.list_orders(db, _admin, admin=True)
    return [serialize_order(order, await crud_access.list_order_items(db, order.order_pk)) for order in orders]


@router.post("/api/admin/orders/{order_pk}/activate", response_model=schemas.OrderResponse)
async def activate_order(
    order_pk: int,
    payload: schemas.OrderActivationRequest | None = None,
    admin: models.User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    try:
        order = await crud_access.activate_order(db, admin, order_pk, payload.item_ids if payload else None)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    return serialize_order(order, await crud_access.list_order_items(db, order_pk))


@router.post("/api/admin/subscriptions/manual", response_model=schemas.SubscriptionResponse, status_code=status.HTTP_201_CREATED)
async def create_manual_subscription(
    payload: schemas.ManualSubscriptionCreate,
    admin: models.User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    try:
        return await crud_access.create_manual_subscription(db, admin, payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/api/admin/notifications", response_model=list[schemas.NotificationResponse])
async def read_admin_notifications(
    admin: models.User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return await crud_access.list_notifications(db, admin)


@router.patch("/api/admin/notifications/{notification_pk}/read", response_model=schemas.NotificationResponse)
async def mark_admin_notification_read(
    notification_pk: int,
    admin: models.User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    notification = await crud_access.mark_notification_read(db, admin, notification_pk)
    if notification is None:
        raise HTTPException(status_code=404, detail="Notification introuvable")
    return notification


@router.post("/api/admin/subscriptions/expire")
async def expire_admin_subscriptions(
    _admin: models.User = Depends(require_admin),
    db: AsyncSession = Depends(get_db),
):
    return {"expired_count": await crud_access.expire_subscriptions(db)}
