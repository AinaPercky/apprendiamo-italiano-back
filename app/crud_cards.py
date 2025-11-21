# app/crud_cards.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, or_, and_, func
from sqlalchemy.orm import joinedload
from . import models, schemas
import uuid
from typing import List, Optional
from datetime import datetime, timedelta

def generate_id_json() -> str:
    return str(uuid.uuid4()).replace('-', '')[:7]


# ==================== DECKS ====================

async def create_deck(db: AsyncSession, deck: schemas.DeckCreate) -> models.Deck:
    id_json = deck.id_json or generate_id_json()
    db_deck = models.Deck(id_json=id_json, name=deck.name)
    db.add(db_deck)
    await db.commit()
    await db.refresh(db_deck)
    return db_deck


async def get_decks(db: AsyncSession, skip: int = 0, limit: int = 10, search: Optional[str] = None) -> List[models.Deck]:
    stmt = select(models.Deck).options(joinedload(models.Deck.cards)).offset(skip).limit(limit)
    if search:
        stmt = stmt.where(models.Deck.name.ilike(f"%{search}%"))
    result = await db.execute(stmt)
    return result.unique().scalars().all()


async def get_deck(db: AsyncSession, deck_pk: int) -> Optional[models.Deck]:
    stmt = select(models.Deck).options(joinedload(models.Deck.cards)).where(models.Deck.deck_pk == deck_pk)
    result = await db.execute(stmt)
    return result.unique().scalar_one_or_none()


# ==================== CARTES – MISE À JOUR ANKI CRITIQUE ====================

async def create_card(db: AsyncSession, card: schemas.CardCreate) -> models.Card:
    id_json = card.id_json or generate_id_json()
    now = datetime.utcnow()
    db_card = models.Card(
        id_json=id_json,
        deck_pk=card.deck_pk,
        front=card.front,
        back=card.back,
        pronunciation=card.pronunciation,
        image=card.image,
        created_at=now,
        next_review=now + timedelta(days=1),  # Première révision demain
        box=0,
        tags=card.tags or [],

        # === CHAMPS ANKI OBLIGATOIRES ===
        easiness=2.5,
        interval=0,
        consecutive_correct=0,
        last_reviewed_at=None,  # Jamais révisée
    )
    db.add(db_card)
    await db.commit()
    await db.refresh(db_card)
    return db_card


async def get_cards(
    db: AsyncSession,
    skip: int = 0,
    limit: int = 1000,
    deck_pk: Optional[int] = None,
    search: Optional[str] = None,
    min_box: Optional[int] = None,
    tags_filter: Optional[List[str]] = None,
    due_only: bool = False,  # ← NOUVEAU : pour le mode révision Anki
) -> List[models.Card]:
    stmt = select(models.Card)

    if deck_pk:
        stmt = stmt.where(models.Card.deck_pk == deck_pk)
    if search:
        stmt = stmt.where(or_(
            models.Card.front.ilike(f"%{search}%"),
            models.Card.back.ilike(f"%{search}%")
        ))
    if min_box is not None:
        stmt = stmt.where(models.Card.box >= min_box)
    if tags_filter:
        stmt = stmt.where(models.Card.tags.contains(tags_filter))
    if due_only:
        stmt = stmt.where(models.Card.next_review <= datetime.utcnow())

    stmt = stmt.offset(skip).limit(limit).order_by(models.Card.next_review)

    result = await db.execute(stmt)
    return result.scalars().all()


async def get_card(db: AsyncSession, card_pk: int) -> Optional[models.Card]:
    result = await db.execute(select(models.Card).where(models.Card.card_pk == card_pk))
    return result.scalar_one_or_none()


async def update_card(db: AsyncSession, card_pk: int, card_update: schemas.CardBase) -> Optional[models.Card]:
    update_data = card_update.model_dump(exclude_unset=True)
    if not update_data:
        return await get_card(db, card_pk)

    stmt = update(models.Card)\
        .where(models.Card.card_pk == card_pk)\
        .values(**update_data)
        # .returning(models.Card) # Pas nécessaire car on recharge après

    await db.execute(stmt)
    await db.commit()
    
    # Recharger la carte pour éviter MissingGreenlet après commit
    return await get_card(db, card_pk)


async def delete_card(db: AsyncSession, card_pk: int) -> bool:
    result = await db.execute(
        delete(models.Card)
        .where(models.Card.card_pk == card_pk)
        .returning(models.Card.card_pk)
    )
    await db.commit()
    return result.scalar_one_or_none() is not None


# ==================== FONCTION BONUS : Cartes dues aujourd'hui (pour le mode révision) ====================

async def get_due_cards(db: AsyncSession, user_pk: int, limit: int = 50) -> List[models.Card]:
    """Retourne les cartes à réviser aujourd'hui pour l'utilisateur (via user_decks)."""
    stmt = select(models.Card)\
        .join(models.UserDeck, models.UserDeck.deck_pk == models.Card.deck_pk)\
        .where(
            models.UserDeck.user_pk == user_pk,
            models.Card.next_review <= datetime.utcnow()
        )\
        .order_by(models.Card.next_review)\
        .limit(limit)

    result = await db.execute(stmt)
    return result.scalars().all()