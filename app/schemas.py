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

# ============================================================================
# SCHEMAS UTILISATEUR
# ============================================================================

class UserBase(BaseModel):
    email: str
    full_name: str

class UserRegister(UserBase):
    password: str

class UserLogin(BaseModel):
    email: str
    password: str

class UserGoogleLogin(BaseModel):
    google_id: str
    google_email: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    google_picture: Optional[str] = None

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    bio: Optional[str] = None
    profile_picture: Optional[str] = None

class UserResponse(UserBase):
    user_pk: int
    is_active: bool
    is_verified: bool
    total_score: int
    total_cards_learned: int
    total_cards_reviewed: int
    profile_picture: Optional[str] = None
    bio: Optional[str] = None
    created_at: datetime
    last_login: Optional[datetime] = None
    email: str
    full_name: str
    
    model_config = {"from_attributes": True}

class UserDetailResponse(UserResponse):
    google_id: Optional[str] = None
    google_picture: Optional[str] = None
    updated_at: datetime

class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse

class UserScoreBase(BaseModel):
    score: int
    is_correct: bool
    time_spent: Optional[int] = None

class UserScoreCreate(UserScoreBase):
    deck_pk: Optional[int] = None
    card_pk: Optional[int] = None

class UserScore(UserScoreBase):
    score_pk: int
    user_pk: int
    deck_pk: Optional[int] = None
    card_pk: Optional[int] = None
    created_at: datetime
    
    model_config = {"from_attributes": True}

class UserAudioBase(BaseModel):
    duration: Optional[int] = None
    quality_score: Optional[int] = None
    notes: Optional[str] = None

class UserAudioCreate(UserAudioBase):
    filename: str
    audio_url: str
    card_pk: Optional[int] = None

class UserAudio(UserAudioBase):
    audio_pk: int
    user_pk: int
    filename: str
    audio_url: str
    card_pk: Optional[int] = None
    created_at: datetime
    
    model_config = {"from_attributes": True}

class UserDeckBase(BaseModel):
    deck_pk: int

class UserDeckCreate(UserDeckBase):
    pass

class UserDeckResponse(BaseModel):
    user_deck_pk: int
    user_pk: int
    deck_pk: int
    correct_count: int
    attempt_count: int
    cards_mastered: int
    added_at: datetime
    last_studied: Optional[datetime] = None
    
    model_config = {"from_attributes": True}

class UserStatsResponse(BaseModel):
    total_score: int
    total_cards_learned: int
    total_cards_reviewed: int
    total_decks: int
    total_audio_records: int
    last_login: Optional[datetime] = None
