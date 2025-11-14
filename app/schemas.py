from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional

# --- Schémas pour les Cartes (Flashcards) ---

class DeckBase(BaseModel):
    name: str

class DeckCreate(DeckBase):
    id_json: Optional[str] = None

class Deck(DeckBase):
    deck_pk: int
    id_json: str
    total_correct: int = 0
    total_attempts: int = 0
    # cards: Optional[List["Card"]] = [] # Retiré pour éviter la dépendance circulaire immédiate

    model_config = {"from_attributes": True}

class CardBase(BaseModel):
    front: str
    back: str
    pronunciation: Optional[str] = None
    image: Optional[str] = None
    box: int = 0
    tags: List[str] = []

class CardCreate(CardBase):
    deck_pk: int
    id_json: Optional[str] = None
    created_at: datetime
    next_review: datetime

class Card(CardBase):
    card_pk: int
    id_json: str
    deck_pk: int
    created_at: datetime
    next_review: datetime

    model_config = {"from_attributes": True}

# --- Schémas pour l'Audio (TTS) ---

class AudioItemBase(BaseModel):
    title: str
    text: str
    category: str
    language: str = 'it'
    ipa: Optional[str] = None

class AudioItemCreate(AudioItemBase):
    pass

class AudioItem(AudioItemBase):
    id: int
    filename: str
    audio_url: str

    model_config = {"from_attributes": True}

# Mise à jour de la référence pour éviter l'erreur de nom non défini
Deck.model_rebuild()
