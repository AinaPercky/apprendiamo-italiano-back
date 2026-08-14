# app/api/endpoints_cards.py
import os
import secrets
from typing import List, Optional

from fastapi import APIRouter, Depends, Form, Header, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from .. import crud_cards, crud_decks, schemas
from ..database import get_db

router = APIRouter(
    prefix="", 
    tags=["decks", "cards"]
)

# === DECKS ===
@router.post("/decks/", response_model=schemas.DeckSimple)
async def create_deck(deck: schemas.DeckCreate, db: AsyncSession = Depends(get_db)):
    return await crud_cards.create_deck(db, deck)

@router.get("/decks/", response_model=List[schemas.Deck])
async def read_decks(skip: int = 0, limit: int = 10, search: str = Query(None), db: AsyncSession = Depends(get_db)):
    return await crud_cards.get_decks(db, skip=skip, limit=limit, search=search)

@router.get("/decks/{deck_pk}", response_model=schemas.Deck)
async def read_deck(deck_pk: int, db: AsyncSession = Depends(get_db)):
    deck = await crud_cards.get_deck(db, deck_pk)
    if not deck:
        raise HTTPException(status_code=404, detail="Deck not found")
    return deck

@router.delete("/decks/{deck_pk}")
async def delete_deck(deck_pk: int, db: AsyncSession = Depends(get_db)):
    deleted = await crud_decks.delete_deck(db, deck_pk)
    if not deleted:
        raise HTTPException(status_code=404, detail="Deck not found")
    return {"detail": "Deck deleted"}

# === CARTES – IMPORTANT : on expose maintenant les champs Anki ===
@router.post("/cards/batch_import")
async def batch_import_cards(cards: List[schemas.CardCreate], db: AsyncSession = Depends(get_db)):
    """
    Importe une liste de cartes en mode Upsert (Mise à jour ou Création).
    - Met à jour les cartes existantes (basé sur le mot italien 'back').
    - Crée les nouvelles cartes.
    - Gère les liens Many-to-Many avec les decks.
    """
    return await crud_cards.batch_upsert_cards(db, cards)

@router.post("/cards/media/migrate", include_in_schema=False)
async def migrate_card_media(
    limit: int = Query(5, ge=1, le=25),
    x_media_migration_token: Optional[str] = Header(default=None),
    media_migration_token: Optional[str] = Form(default=None),
    db: AsyncSession = Depends(get_db),
):
    """Exécute un lot d’externalisation, réservé à l’opérateur de migration.

    Le champ de formulaire est destiné au déclenchement ponctuel inter-origines
    depuis le tableau Vercel, sans placer le secret dans une URL ni ouvrir CORS.
    """
    expected_token = os.getenv("MEDIA_MIGRATION_TOKEN", "")
    supplied_token = x_media_migration_token or media_migration_token
    if not expected_token or not supplied_token or not secrets.compare_digest(
        supplied_token, expected_token
    ):
        # Ne révèle pas l’existence de cette opération interne.
        raise HTTPException(status_code=404, detail="Not found")
    return await crud_cards.migrate_legacy_card_images(db, limit=limit)


@router.post("/cards/", response_model=schemas.Card)
async def create_card(card: schemas.CardCreate, db: AsyncSession = Depends(get_db)):
    return await crud_cards.create_card(db, card)

@router.get("/cards/", response_model=List[schemas.Card])
async def read_cards(
    skip: int = 0,
    limit: int = 10,
    deck_pk: int = Query(None),
    search: str = Query(None),
    min_box: int = Query(None),
    due_only: bool = Query(False, description="Seulement les cartes à réviser aujourd'hui"),
    db: AsyncSession = Depends(get_db)
):
    return await crud_cards.get_cards(
        db, skip=skip, limit=limit, deck_pk=deck_pk, search=search, 
        min_box=min_box, due_only=due_only
    )

@router.get("/cards/{card_pk}", response_model=schemas.Card)
async def read_card(card_pk: int, db: AsyncSession = Depends(get_db)):
    card = await crud_cards.get_card(db, card_pk)
    if not card:
        raise HTTPException(status_code=404, detail="Card not found")
    return card

@router.put("/cards/{card_pk}", response_model=schemas.Card)
async def update_card(card_pk: int, card: schemas.CardBase, db: AsyncSession = Depends(get_db)):
    updated_card = await crud_cards.update_card(db, card_pk, card)
    if not updated_card:
        raise HTTPException(status_code=404, detail="Card not found")
    return updated_card

@router.delete("/cards/{card_pk}")
async def delete_card(card_pk: int, db: AsyncSession = Depends(get_db)):
    deleted = await crud_cards.delete_card(db, card_pk)
    if not deleted:
        raise HTTPException(status_code=404, detail="Card not found")
    return {"detail": "Card deleted"}