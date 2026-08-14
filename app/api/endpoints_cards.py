# app/api/endpoints_cards.py
from fastapi import APIRouter, Depends, Query, HTTPException, File, UploadFile, Response
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from .. import crud_cards, crud_decks, crud_card_audio, schemas
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

@router.post("/cards/{card_pk}/audio", response_model=schemas.CardAudioPublic)
async def upload_card_audio(
    card_pk: int,
    audio_file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    try:
        audio = await crud_card_audio.upsert_card_audio(db, card_pk, audio_file)
    except crud_card_audio.CardAudioValidationError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    if audio is None:
        raise HTTPException(status_code=404, detail="Card not found")
    return audio


@router.get("/cards/{card_pk}/audio")
async def read_card_audio(card_pk: int, db: AsyncSession = Depends(get_db)):
    audio_result = await crud_card_audio.get_card_audio_bytes(db, card_pk)
    if audio_result is None:
        raise HTTPException(status_code=404, detail="Audio pronunciation not found")
    payload, content_type = audio_result
    return Response(
        content=payload,
        media_type=content_type,
        headers={"Content-Disposition": 'inline; filename="pronunciation.mp3"'},
    )


@router.delete("/cards/{card_pk}/audio")
async def remove_card_audio(card_pk: int, db: AsyncSession = Depends(get_db)):
    deleted = await crud_card_audio.delete_card_audio(db, card_pk)
    if not deleted:
        raise HTTPException(status_code=404, detail="Audio pronunciation not found")
    return {"detail": "Card audio deleted"}


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