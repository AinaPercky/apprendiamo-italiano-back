from __future__ import annotations

import logging
import uuid
from datetime import datetime, timedelta, timezone
from typing import List, Optional

import anyio
from sqlalchemy import and_, delete, or_, select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import joinedload, selectinload

from . import blob_storage, models, schemas
from .core.image_scraper import fetch_icon_urls

logger = logging.getLogger(__name__)


def generate_id_json() -> str:
    return str(uuid.uuid4()).replace("-", "")[:7]


def clean_search_query(query: str) -> str:
    """Prépare une requête de recherche d’illustration."""
    if not query:
        return ""
    query = query.split("/", 1)[0].strip()
    return query[3:].strip() if query.lower().startswith("to ") else query


# ==================== MÉDIAS DE CARTES ====================

async def _prepare_image_source(source: str) -> tuple[bytes, str, Optional[str], str]:
    return await anyio.to_thread.run_sync(blob_storage.prepare_card_image, source)


async def _upload_image_bytes(
    payload: bytes,
    content_type: str,
    sha256: str,
    original_filename: Optional[str],
) -> blob_storage.BlobObject:
    return await anyio.to_thread.run_sync(
        blob_storage.upload_image_bytes,
        payload,
        content_type,
        sha256,
        original_filename,
    )


async def _set_primary_image(
    db: AsyncSession,
    card: models.Card,
    source: str,
) -> models.CardMedia:
    """Stocke une image dans Blob et conserve uniquement sa référence en base."""
    payload, content_type, original_filename, sha256 = await _prepare_image_source(source)

    # Les illustrations identiques déjà stockées partagent le même objet Blob.
    reusable = await db.scalar(
        select(models.CardMedia)
        .where(
            models.CardMedia.kind == "image",
            models.CardMedia.sha256 == sha256,
            models.CardMedia.storage_provider == "vercel_blob",
        )
        .order_by(models.CardMedia.media_pk)
        .limit(1)
    )

    if reusable:
        blob = blob_storage.BlobObject(
            url=reusable.url,
            pathname=reusable.pathname,
            content_type=reusable.content_type,
            size_bytes=reusable.size_bytes,
            sha256=reusable.sha256,
            original_filename=reusable.original_filename,
        )
    else:
        blob = await _upload_image_bytes(payload, content_type, sha256, original_filename)

    primary_media = await db.scalar(
        select(models.CardMedia).where(
            models.CardMedia.card_pk == card.card_pk,
            models.CardMedia.kind == "image",
            models.CardMedia.is_primary.is_(True),
        )
    )

    values = {
        "storage_provider": "vercel_blob",
        "url": blob.url,
        "pathname": blob.pathname,
        "content_type": blob.content_type,
        "size_bytes": blob.size_bytes,
        "sha256": blob.sha256,
        "original_filename": blob.original_filename,
        "is_primary": True,
    }
    if primary_media:
        for field, value in values.items():
            setattr(primary_media, field, value)
        media = primary_media
    else:
        media = models.CardMedia(card_pk=card.card_pk, kind="image", **values)
        db.add(media)

    # Compatibilité avec le frontend actuel : image reste une URL, jamais une Data URI.
    card.image = blob.url
    return media


async def _remove_primary_image(db: AsyncSession, card: models.Card) -> None:
    await db.execute(
        delete(models.CardMedia).where(
            models.CardMedia.card_pk == card.card_pk,
            models.CardMedia.kind == "image",
            models.CardMedia.is_primary.is_(True),
        )
    )
    card.image = None


async def _find_auto_image_source(card: schemas.CardBase) -> Optional[str]:
    search_query = clean_search_query(card.translation_en or card.front)
    if not search_query:
        return None
    try:
        candidates = await anyio.to_thread.run_sync(fetch_icon_urls, search_query)
        return next((url for url in candidates[:5] if url.startswith(("http://", "https://"))), None)
    except Exception as exc:  # L’image automatique ne doit jamais empêcher la création d’une carte.
        logger.warning("Recherche automatique d’image ignorée pour %s : %s", search_query, exc)
        return None


async def _try_set_auto_image(db: AsyncSession, card: models.Card, source: Optional[str]) -> None:
    if not source:
        return
    try:
        await _set_primary_image(db, card, source)
        logger.info("Illustration automatique stockée dans Vercel Blob pour la carte %s", card.card_pk)
    except blob_storage.BlobStorageError as exc:
        logger.warning("Illustration automatique ignorée pour la carte %s : %s", card.card_pk, exc)


async def _card_with_media(db: AsyncSession, card_pk: int) -> Optional[models.Card]:
    return await db.scalar(
        select(models.Card)
        .options(selectinload(models.Card.media))
        .where(models.Card.card_pk == card_pk)
    )


# ==================== DECKS ====================

async def create_deck(db: AsyncSession, deck: schemas.DeckCreate) -> models.Deck:
    db_deck = models.Deck(id_json=deck.id_json or generate_id_json(), name=deck.name)
    db.add(db_deck)
    await db.commit()
    await db.refresh(db_deck)
    return db_deck


async def get_decks(
    db: AsyncSession,
    skip: int = 0,
    limit: int = 10,
    search: Optional[str] = None,
) -> List[models.Deck]:
    stmt = (
        select(models.Deck)
        .options(joinedload(models.Deck.cards).selectinload(models.Card.media))
        .offset(skip)
        .limit(limit)
    )
    if search:
        stmt = stmt.where(models.Deck.name.ilike(f"%{search}%"))
    result = await db.execute(stmt)
    return result.unique().scalars().all()


async def get_deck(db: AsyncSession, deck_pk: int) -> Optional[models.Deck]:
    result = await db.execute(
        select(models.Deck)
        .options(joinedload(models.Deck.cards).selectinload(models.Card.media))
        .where(models.Deck.deck_pk == deck_pk)
    )
    return result.unique().scalar_one_or_none()


# ==================== CARTES ====================

async def create_card(db: AsyncSession, card: schemas.CardCreate) -> models.Card:
    """Crée ou enrichit une carte, avec image externalisée dans Vercel Blob."""
    existing_card = await db.scalar(
        select(models.Card)
        .options(selectinload(models.Card.media))
        .where(models.Card.back.ilike(card.back))
    )

    image_source = card.image
    auto_source = None
    if not image_source and (not existing_card or not existing_card.image):
        auto_source = await _find_auto_image_source(card)

    if existing_card:
        link_exists = await db.execute(
            select(models.deck_cards).where(
                and_(
                    models.deck_cards.c.deck_pk == card.deck_pk,
                    models.deck_cards.c.card_pk == existing_card.card_pk,
                )
            )
        )
        if not link_exists.first():
            await db.execute(
                models.deck_cards.insert().values(deck_pk=card.deck_pk, card_pk=existing_card.card_pk)
            )

        changes = False
        for field in (
            "explanation_it",
            "translation_en",
            "translation_de",
            "translation_mg",
            "example",
            "pronunciation",
        ):
            new_value = getattr(card, field)
            if new_value and not getattr(existing_card, field):
                setattr(existing_card, field, new_value)
                changes = True

        if image_source and not existing_card.image:
            await _set_primary_image(db, existing_card, image_source)
            changes = True
        elif auto_source and not existing_card.image:
            await _try_set_auto_image(db, existing_card, auto_source)

        if changes:
            db.add(existing_card)
        await db.commit()
        loaded = await _card_with_media(db, existing_card.card_pk)
        assert loaded is not None
        loaded.deck_pk = card.deck_pk
        return loaded

    now = datetime.now(timezone.utc)
    db_card = models.Card(
        id_json=card.id_json or generate_id_json(),
        deck_pk=card.deck_pk,
        front=card.front,
        back=card.back,
        pronunciation=card.pronunciation,
        image=None,
        explanation_it=card.explanation_it,
        translation_en=card.translation_en,
        translation_de=card.translation_de,
        translation_mg=card.translation_mg,
        example=card.example,
        created_at=now,
        next_review=now + timedelta(days=1),
        box=0,
        tags=card.tags or [],
        easiness=2.5,
        interval=0,
        consecutive_correct=0,
        last_reviewed_at=None,
    )
    db.add(db_card)
    await db.flush()
    await db.execute(
        models.deck_cards.insert().values(deck_pk=card.deck_pk, card_pk=db_card.card_pk)
    )

    if image_source:
        await _set_primary_image(db, db_card, image_source)
    else:
        await _try_set_auto_image(db, db_card, auto_source)

    await db.commit()
    loaded = await _card_with_media(db, db_card.card_pk)
    assert loaded is not None
    return loaded


async def get_cards(
    db: AsyncSession,
    skip: int = 0,
    limit: int = 1000,
    deck_pk: Optional[int] = None,
    search: Optional[str] = None,
    min_box: Optional[int] = None,
    tags_filter: Optional[List[str]] = None,
    due_only: bool = False,
) -> List[models.Card]:
    stmt = select(models.Card).options(selectinload(models.Card.media))
    if deck_pk:
        stmt = stmt.join(
            models.deck_cards, models.Card.card_pk == models.deck_cards.c.card_pk
        ).where(models.deck_cards.c.deck_pk == deck_pk)
    if search:
        stmt = stmt.where(
            or_(
                models.Card.front.ilike(f"%{search}%"),
                models.Card.back.ilike(f"%{search}%"),
            )
        )
    if min_box is not None:
        stmt = stmt.where(models.Card.box >= min_box)
    if tags_filter:
        stmt = stmt.where(models.Card.tags.contains(tags_filter))
    if due_only:
        stmt = stmt.where(models.Card.next_review <= datetime.now(timezone.utc))

    result = await db.execute(stmt.offset(skip).limit(limit).order_by(models.Card.next_review))
    cards = result.scalars().all()
    if deck_pk:
        for db_card in cards:
            db_card.deck_pk = deck_pk
    return cards


async def get_card(db: AsyncSession, card_pk: int) -> Optional[models.Card]:
    return await _card_with_media(db, card_pk)


async def update_card(
    db: AsyncSession,
    card_pk: int,
    card_update: schemas.CardBase,
) -> Optional[models.Card]:
    card = await _card_with_media(db, card_pk)
    if not card:
        return None

    update_data = card_update.model_dump(exclude_unset=True)
    image_is_present = "image" in update_data
    image_source = update_data.pop("image", None)
    for field, value in update_data.items():
        setattr(card, field, value)

    if image_is_present:
        if image_source:
            await _set_primary_image(db, card, image_source)
        else:
            await _remove_primary_image(db, card)

    await db.commit()
    return await _card_with_media(db, card_pk)


async def delete_card(db: AsyncSession, card_pk: int) -> bool:
    result = await db.execute(
        delete(models.Card)
        .where(models.Card.card_pk == card_pk)
        .returning(models.Card.card_pk)
    )
    await db.commit()
    # Les objets Blob orphelins sont nettoyés séparément : ils peuvent être
    # partagés par plusieurs cartes dédupliquées.
    return result.scalar_one_or_none() is not None


async def get_due_cards(db: AsyncSession, user_pk: int, limit: int = 50) -> List[models.Card]:
    stmt = (
        select(models.Card)
        .options(selectinload(models.Card.media))
        .join(models.deck_cards, models.deck_cards.c.card_pk == models.Card.card_pk)
        .join(models.UserDeck, models.UserDeck.deck_pk == models.deck_cards.c.deck_pk)
        .where(
            models.UserDeck.user_pk == user_pk,
            models.Card.next_review <= datetime.now(timezone.utc),
        )
        .order_by(models.Card.next_review)
        .limit(limit)
    )
    return (await db.execute(stmt)).scalars().all()


# ==================== IMPORTATION EN LOT ====================

async def batch_upsert_cards(db: AsyncSession, cards: List[schemas.CardCreate]) -> dict:
    """Importe des cartes sans écrire de contenu image dans PostgreSQL."""
    results = {"created": 0, "updated": 0, "errors": 0}
    for card in cards:
        try:
            existing = await db.scalar(
                select(models.Card).where(models.Card.back.ilike(card.back))
            )
            if existing:
                # L’appel de création conserve le comportement d’enrichissement et le lien deck.
                await create_card(db, card)
                results["updated"] += 1
            else:
                await create_card(db, card)
                results["created"] += 1
        except Exception as exc:
            await db.rollback()
            logger.exception("Échec d’import de la carte %s : %s", card.back, exc)
            results["errors"] += 1
    return results


async def migrate_legacy_card_images(db: AsyncSession, limit: int = 5) -> dict:
    """Externalise un lot limité d’images historiques vers Vercel Blob.

    La fonction est idempotente : une image dont la référence primaire existe
    déjà n’est pas rechargée. Les identifiants sont prélevés en premier, puis
    chaque carte est rechargée après un commit ou un rollback afin d’éviter les
    accès asynchrones à un objet SQLAlchemy expiré.
    """
    safe_limit = max(1, min(limit, 25))
    candidate_ids = list(
        (
            await db.scalars(
                select(models.Card.card_pk)
                .outerjoin(
                    models.CardMedia,
                    and_(
                        models.CardMedia.card_pk == models.Card.card_pk,
                        models.CardMedia.kind == "image",
                        models.CardMedia.is_primary.is_(True),
                    ),
                )
                .where(
                    models.Card.image.is_not(None),
                    models.Card.image != "",
                    models.CardMedia.media_pk.is_(None),
                )
                .order_by(models.Card.image.like("data:%").desc(), models.Card.card_pk)
                .limit(safe_limit)
            )
        ).all()
    )

    migrated = 0
    skipped = 0
    errors: list[dict[str, str | int]] = []
    for card_pk in candidate_ids:
        card = await _card_with_media(db, card_pk)
        if not card or not card.image:
            skipped += 1
            continue

        existing_primary = next(
            (media for media in card.media if media.kind == "image" and media.is_primary),
            None,
        )
        if existing_primary:
            if card.image != existing_primary.url:
                card.image = existing_primary.url
                await db.commit()
            skipped += 1
            continue

        source = card.image
        try:
            await _set_primary_image(db, card, source)
            await db.commit()
            migrated += 1
        except Exception as exc:
            await db.rollback()
            logger.exception("Échec de migration média carte %s : %s", card_pk, exc)
            errors.append({"card_pk": card_pk, "error": str(exc)[:180]})

    remaining = await db.scalar(
        select(models.Card.card_pk)
        .outerjoin(
            models.CardMedia,
            and_(
                models.CardMedia.card_pk == models.Card.card_pk,
                models.CardMedia.kind == "image",
                models.CardMedia.is_primary.is_(True),
            ),
        )
        .where(
            models.Card.image.is_not(None),
            models.Card.image != "",
            models.CardMedia.media_pk.is_(None),
        )
        .order_by(models.Card.image.like("data:%").desc(), models.Card.card_pk)
        .limit(1)
    )
    return {
        "processed": len(candidate_ids),
        "migrated": migrated,
        "already_referenced": skipped,
        "next_card_pk": remaining,
        "complete": remaining is None,
        "errors": errors,
    }
