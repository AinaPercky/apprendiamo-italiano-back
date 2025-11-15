from pydantic import BaseModel, field_validator
from datetime import datetime
from typing import List, Optional
import json

class DeckBase(BaseModel):
    name: str

class DeckCreate(DeckBase):
    id_json: Optional[str] = None

class Deck(DeckBase):
    deck_pk: int
    id_json: str
    total_correct: int = 0
    total_attempts: int = 0

    cards: List["Card"] = []   # ← GUILLEMETS OBLIGATOIRES

    model_config = {"from_attributes": True}

class CardBase(BaseModel):
    front: str
    back: str
    pronunciation: Optional[str] = None
    image: Optional[str] = None
    box: int = 0
    tags: List[str] = []

    @field_validator("tags", mode="before")
    @classmethod
    def parse_tags_if_string(cls, v):
        if isinstance(v, str):
            try:
                return json.loads(v)
            except json.JSONDecodeError:
                return []
        return v or []

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

Deck.model_rebuild()