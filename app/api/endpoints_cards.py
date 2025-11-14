from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from .. import crud_cards, schemas
from ..database import get_db

router = APIRouter(
    prefix="", # Les routes seront montées dans main.py
    tags=["decks", "cards"]
)

# --- Decks Endpoints ---

@router.post("/decks/", response_model=schemas.Deck)
async def create_deck(deck: schemas.DeckCreate, db: AsyncSession = Depends(get_db)):
    return await crud_cards.create_deck(db, deck)

@router.get("/decks/", response_model=List[schemas.Deck])
async def read_decks(skip: int = 0, limit: int = 10, search: str = Query(None, description="Recherche par nom"), db: AsyncSession = Depends(get_db)):
    return await crud_cards.get_decks(db, skip=skip, limit=limit, search=search)

@router.get("/decks/{deck_pk}", response_model=schemas.Deck)
async def read_deck(deck_pk: int, db: AsyncSession = Depends(get_db)):
    deck = await crud_cards.get_deck(db, deck_pk)
    if not deck:
        raise HTTPException(status_code=404, detail="Deck not found")
    return deck

@router.put("/decks/{deck_pk}", response_model=schemas.Deck)
async def update_deck(deck_pk: int, deck: schemas.DeckBase, db: AsyncSession = Depends(get_db)):
    updated_deck = await crud_cards.update_deck(db, deck_pk, deck)
    if not updated_deck:
        raise HTTPException(status_code=404, detail="Deck not found")
    return updated_deck

@router.delete("/decks/{deck_pk}")
async def delete_deck(deck_pk: int, db: AsyncSession = Depends(get_db)):
    deleted = await crud_cards.delete_deck(db, deck_pk)
    if not deleted:
        raise HTTPException(status_code=404, detail="Deck not found")
    return {"detail": "Deck deleted"}

# --- Cards Endpoints ---

@router.post("/cards/", response_model=schemas.Card)
async def create_card(card: schemas.CardCreate, db: AsyncSession = Depends(get_db)):
    return await crud_cards.create_card(db, card)

@router.get("/cards/", response_model=List[schemas.Card])
async def read_cards(skip: int = 0, limit: int = 10, deck_pk: int = Query(None, description="Filtre par deck_pk"), 
                   search: str = Query(None, description="Recherche sur front/back"), 
                   min_box: int = Query(None, description="Filtre box >= valeur"), 
                   db: AsyncSession = Depends(get_db)):
    return await crud_cards.get_cards(db, skip=skip, limit=limit, deck_pk=deck_pk, search=search, min_box=min_box)

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
