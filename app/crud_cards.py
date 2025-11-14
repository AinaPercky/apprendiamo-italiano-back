from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, or_
from . import models, schemas
import json
import uuid
from typing import List, Optional

# Générateur d'id_json (7 caractères alphanumériques random)
def generate_id_json() -> str:
    return str(uuid.uuid4()).replace('-', '')[:7]

# --- Decks CRUD (Asynchrone) ---

async def create_deck(db: AsyncSession, deck: schemas.DeckCreate) -> models.Deck:
    id_json = deck.id_json or generate_id_json()
    db_deck = models.Deck(id_json=id_json, name=deck.name)
    db.add(db_deck)
    await db.commit()
    await db.refresh(db_deck)
    return db_deck

async def get_decks(db: AsyncSession, skip: int = 0, limit: int = 10, search: Optional[str] = None) -> List[models.Deck]:
    stmt = select(models.Deck).offset(skip).limit(limit)
    if search:
        stmt = stmt.where(or_(models.Deck.name.ilike(f"%{search}%")))
    
    result = await db.execute(stmt)
    return result.scalars().all()

async def get_deck(db: AsyncSession, deck_pk: int) -> Optional[models.Deck]:
    stmt = select(models.Deck).where(models.Deck.deck_pk == deck_pk)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()

async def update_deck(db: AsyncSession, deck_pk: int, deck: schemas.DeckBase) -> Optional[models.Deck]:
    update_data = deck.model_dump(exclude_unset=True)
    if not update_data:
        return await get_deck(db, deck_pk)  # Rien à mettre à jour

    stmt = update(models.Deck).where(models.Deck.deck_pk == deck_pk).values(**update_data).returning(models.Deck)
    result = await db.execute(stmt)
    await db.commit()
    
    return result.scalar_one_or_none()

async def delete_deck(db: AsyncSession, deck_pk: int) -> bool:
    stmt = delete(models.Deck).where(models.Deck.deck_pk == deck_pk).returning(models.Deck.deck_pk)
    result = await db.execute(stmt)
    await db.commit()
    
    return result.scalar_one_or_none() is not None

# --- Cards CRUD (Asynchrone) ---

def safe_json_loads(value):
    """Charge en JSON uniquement si c'est une str, sinon retourne tel quel."""
    if isinstance(value, str):
        try:
            return json.loads(value)
        except json.JSONDecodeError:
            return []
    elif isinstance(value, list):
        return value
    else:
        return []

async def create_card(db: AsyncSession, card: schemas.CardCreate) -> models.Card:
    id_json = card.id_json or generate_id_json()
    db_card = models.Card(
        id_json=id_json,
        deck_pk=card.deck_pk,
        front=card.front,
        back=card.back,
        pronunciation=card.pronunciation,
        image=card.image,
        created_at=card.created_at,
        box=card.box,
        next_review=card.next_review,
        tags=json.dumps(card.tags) if card.tags is not None else "[]"
    )
    db.add(db_card)
    await db.commit()
    await db.refresh(db_card)
    db_card.tags = safe_json_loads(db_card.tags)
    return db_card

async def get_cards(db: AsyncSession, skip: int = 0, limit: int = 10, deck_pk: Optional[int] = None, search: Optional[str] = None, min_box: Optional[int] = None) -> List[models.Card]:
    stmt = select(models.Card).offset(skip).limit(limit)
    
    if deck_pk:
        stmt = stmt.where(models.Card.deck_pk == deck_pk)
    if search:
        stmt = stmt.where(or_(models.Card.front.ilike(f"%{search}%"), models.Card.back.ilike(f"%{search}%")))
    if min_box is not None:
        stmt = stmt.where(models.Card.box >= min_box)
        
    result = await db.execute(stmt)
    cards = result.scalars().all()
    for card in cards:
        card.tags = safe_json_loads(card.tags)
    return cards

async def get_card(db: AsyncSession, card_pk: int) -> Optional[models.Card]:
    stmt = select(models.Card).where(models.Card.card_pk == card_pk)
    result = await db.execute(stmt)
    card = result.scalar_one_or_none()
    if card:
        card.tags = safe_json_loads(card.tags)
    return card

async def update_card(db: AsyncSession, card_pk: int, card: schemas.CardBase) -> Optional[models.Card]:
    update_data = card.model_dump(exclude_unset=True)
    if 'tags' in update_data:
        update_data['tags'] = json.dumps(update_data['tags']) if update_data['tags'] is not None else "[]"

    if not update_data:
        return await get_card(db, card_pk)  # Rien à mettre à jour

    stmt = update(models.Card).where(models.Card.card_pk == card_pk).values(**update_data).returning(models.Card)
    result = await db.execute(stmt)
    await db.commit()
    
    updated_card = result.scalar_one_or_none()
    if updated_card:
        updated_card.tags = safe_json_loads(updated_card.tags)
    return updated_card

async def delete_card(db: AsyncSession, card_pk: int) -> bool:
    stmt = delete(models.Card).where(models.Card.card_pk == card_pk).returning(models.Card.card_pk)
    result = await db.execute(stmt)
    await db.commit()
    
    return result.scalar_one_or_none() is not None
