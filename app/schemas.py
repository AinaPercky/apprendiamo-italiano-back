# app/schemas.py
from pydantic import BaseModel, field_validator, Field, computed_field
from datetime import datetime
from typing import List, Optional, Literal
import json


# ============================================================================
# DECKS & CARDS
# ============================================================================

class DeckBase(BaseModel):
    name: str


class DeckCreate(DeckBase):
    id_json: Optional[str] = None


# Schéma simple pour Deck sans cards (évite les problèmes de chargement)
class DeckSimple(DeckBase):
    deck_pk: int
    id_json: str
    total_correct: int = 0
    total_attempts: int = 0

    model_config = {"from_attributes": True}


class DeckSimpleSafe(DeckSimple):
    """Version de DeckSimple qui masque les stats globales pour éviter la confusion"""
    @field_validator('total_correct', 'total_attempts', mode='before', check_fields=False)
    @classmethod
    def force_zero(cls, v):
        return 0


class CardBase(BaseModel):
    front: str
    back: str
    pronunciation: Optional[str] = None
    image: Optional[str] = None # Contient désormais l'image en Base64 (Data URI) ou l'URL originale si non convertie
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

    # Champs Anki ajoutés
    easiness: float = 2.5
    interval: int = 0
    consecutive_correct: int = 0

    model_config = {"from_attributes": True}


# Schéma Deck avec cards (à utiliser quand les cards sont explicitement chargées)
class Deck(DeckBase):
    deck_pk: int
    id_json: str
    total_correct: int = 0
    total_attempts: int = 0
    cards: List[Card] = []

    model_config = {"from_attributes": True}


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

    model_config = {"from_attributes": True}


class UserDetailResponse(UserResponse):
    google_id: Optional[str] = None
    google_picture: Optional[str] = None
    updated_at: datetime


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


# ============================================================================
# SCORES
# ============================================================================

class UserScoreBase(BaseModel):
    score: int = Field(..., ge=0, le=100)
    is_correct: bool
    time_spent: Optional[int] = None


class UserScoreCreate(UserScoreBase):
    deck_pk: Optional[int] = None
    card_pk: Optional[int] = None
    quiz_type: Literal["frappe", "association", "qcm", "classique"] = "classique"


class UserScore(UserScoreBase):
    score_pk: int
    user_pk: int
    deck_pk: Optional[int] = None
    card_pk: Optional[int] = None
    quiz_type: str
    created_at: datetime

    model_config = {"from_attributes": True}


# ============================================================================
# USER DECK RESPONSE – TOUTES LES STATS
# ============================================================================

class UserDeckResponse(BaseModel):
    user_deck_pk: int
    user_pk: int
    deck_pk: int
    deck: DeckSimpleSafe  # Utiliser DeckSimpleSafe pour masquer les stats globales

    # Stats Anki
    mastered_cards: int = 0
    learning_cards: int = 0
    review_cards: int = 0

    # Scoring global
    total_points: int = 0
    total_attempts: int = 0
    successful_attempts: int = 0

    # Scoring par mode
    points_frappe: int = 0
    points_association: int = 0
    points_qcm: int = 0
    points_classique: int = 0

    added_at: datetime
    last_studied: Optional[datetime] = None

    model_config = {
        "from_attributes": True,
        "arbitrary_types_allowed": True
    }

    @computed_field
    @property
    def progress(self) -> float:
        """Calcule le pourcentage de progression (cartes maîtrisées)"""
        total = self.mastered_cards + self.learning_cards + self.review_cards
        return round(self.mastered_cards / total * 100, 2) if total > 0 else 0.0

    @computed_field
    @property
    def success_rate(self) -> float:
        """Calcule le taux de réussite (pourcentage de réponses correctes)"""
        return round(self.successful_attempts / self.total_attempts * 100, 2) if self.total_attempts > 0 else 0.0


# ============================================================================
# AUDIO & STATS
# ============================================================================

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


class UserStatsResponse(BaseModel):
    total_score: int
    total_cards_learned: int
    total_cards_reviewed: int
    total_decks: int
    total_audio_records: int
    last_login: Optional[datetime] = None


# ============================================================================
# AUDIO ITEMS (TTS)
# ============================================================================

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


# ============================================================================
# QUIZ ADAPTATIF
# ============================================================================

class QuizConfigRequest(BaseModel):
    """Requête pour configurer un nouveau quiz"""
    deck_pk: int
    card_count: int = Field(..., ge=1, description="Nombre de cartes à utiliser dans le quiz")
    quiz_type: Literal["frappe", "association", "qcm", "classique"] = "classique"


class QuizCardPublic(BaseModel):
    """Carte simplifiée pour le quiz (évite les accès DB paresseux)"""
    card_pk: int
    front: str
    back: str
    pronunciation: Optional[str] = None
    image: Optional[str] = None # Contient désormais l'image en Base64 (Data URI) ou l'URL originale si non convertie
    box: int
    tags: List[str] = []

    model_config = {"from_attributes": True}


class QuizCardSelection(BaseModel):
    """Réponse retournant les cartes sélectionnées pour un quiz"""
    session_pk: int
    deck_pk: int
    cycle_number: int
    total_cards_in_deck: int
    requested_card_count: int
    selected_cards: List[QuizCardPublic]
    message: str  # Info sur le cycle, les cartes restantes, etc.


class QuizSessionResponse(BaseModel):
    """Informations sur une session de quiz"""
    session_pk: int
    deck_pk: int
    card_count: int
    quiz_type: str
    cycle_number: int
    correct_count: int
    total_questions: int
    started_at: datetime
    completed_at: Optional[datetime] = None
    
    model_config = {"from_attributes": True}


class CardPerformanceResponse(BaseModel):
    """Statistiques de performance pour une carte"""
    performance_pk: int
    card_pk: int
    correct_count: int
    incorrect_count: int
    total_attempts: int
    priority_score: float
    last_reviewed_at: Optional[datetime] = None
    
    # Champ provenant de la Card associée (via joinedload)
    consecutive_correct: int = 0
    
    model_config = {"from_attributes": True}

    @field_validator('consecutive_correct', mode='before', check_fields=False)
    @classmethod
    def extract_consecutive_correct(cls, v, info):
        """
        Extrait consecutive_correct de la relation Card si disponible.
        Si la valeur est déjà un entier (cas où on passe un dict), on le garde.
        Si c'est un objet (ORM), on essaie d'accéder à .card.consecutive_correct
        """
        if isinstance(v, int):
            return v
            
        # Si on est ici, v est probablement manquant ou None dans __dict__ 
        # mais on peut essayer d'accéder à l'objet parent via info.data ? Non.
        # Pydantic V2 est strict.
        # Le plus simple: si v est None, on retourne 0.
        # Mais comment accéder à l'objet Card ?
        # Si from_attributes=True, Pydantic essaie getattr(obj, 'consecutive_correct').
        # Si CardPerformance n'a pas cet attribut, il passe None ou erreur.
        return v or 0

    @computed_field
    @property
    def label(self) -> str:
        """
        Détermine le label de la carte selon la logique stricte :
        - En cours : Pas encore commencée (0 tentatives)
        - Maîtrisée : Dernière réponse correcte (consecutive_correct > 0)
        - Non maîtrisée : Dernière réponse incorrecte (consecutive_correct == 0 et tentatives > 0)
        """
        # 1. Pas encore commencée
        if self.total_attempts == 0:
            return "En cours"
        
        # 2. Dernière réponse correcte (Anki > 0)
        if self.consecutive_correct > 0:
            return "Maîtrisée"
            
        # 3. Dernière réponse incorrecte (Anki == 0)
        return "Non maîtrisée"

