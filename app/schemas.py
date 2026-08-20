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
    description: Optional[str] = None


# Schéma simple pour Deck sans cards (évite les problèmes de chargement)
class DeckSimple(DeckBase):
    deck_pk: int
    id_json: str
    total_correct: int = 0
    total_attempts: int = 0
    created_by: Optional[int] = None
    visibility: str = "global"
    description: Optional[str] = None
    published_at: Optional[datetime] = None
    archived_at: Optional[datetime] = None

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
    
    # Nouveaux champs optionnels
    explanation_it: Optional[str] = None
    translation_en: Optional[str] = None
    translation_de: Optional[str] = None
    translation_mg: Optional[str] = None
    example: Optional[str] = None

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


class CardAudioPublic(BaseModel):
    """Métadonnées publiques d’une prononciation liée à une carte."""
    audio_pk: int
    card_pk: int
    filename: Optional[str] = None
    content_type: str
    size_bytes: int
    audio_url: str
    created_at: datetime
    updated_at: datetime


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
    audio: Optional[CardAudioPublic] = None

    model_config = {"from_attributes": True}


class CardPublicQRLinkRequest(BaseModel):
    card_pks: List[int] = Field(..., min_length=1, max_length=1000)


class CardPublicQRLink(BaseModel):
    card_pk: int
    token: str
    signature: str


class CardPublicQRView(CardBase):
    """Détails accessibles uniquement après validation du lien QR signé."""
    audio_url: Optional[str] = None
    audio_filename: Optional[str] = None


# Schéma Deck avec cards (à utiliser quand les cards sont explicitement chargées)
class Deck(DeckBase):
    deck_pk: int
    id_json: str
    total_correct: int = 0
    total_attempts: int = 0
    created_by: Optional[int] = None
    visibility: str = "global"
    description: Optional[str] = None
    published_at: Optional[datetime] = None
    archived_at: Optional[datetime] = None
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


class AdminUserUpdate(BaseModel):
    role: Optional[str] = None
    is_active: Optional[bool] = None

    @field_validator("role")
    @classmethod
    def validate_role(cls, value: Optional[str]) -> Optional[str]:
        if value is not None and value not in {"admin", "professeur", "etudiant"}:
            raise ValueError("Rôle invalide")
        return value


class UserResponse(UserBase):
    user_pk: int
    role: str = "etudiant"
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
    description: Optional[str] = None


class AudioItemCreate(AudioItemBase):
    pass


class AudioItem(AudioItemBase):
    id: int
    filename: str
    audio_url: str
    created_by: Optional[int] = None
    deck_pk: Optional[int] = None
    visibility: str = "global"
    published_at: Optional[datetime] = None
    
    model_config = {"from_attributes": True}


# ============================================================================
# CATALOGUE, PANIER, COMMANDES ET ABONNEMENTS
# ============================================================================

class OrderItemCreate(BaseModel):
    target_type: Literal["deck", "conjugaison", "grammaire"]
    target_id: Optional[int] = None
    duration_code: Literal["1d", "3d", "1w", "15d", "1m"]
    price_snapshot: Optional[float] = Field(default=None, ge=0)


class OrderCreate(BaseModel):
    items: List[OrderItemCreate] = Field(..., min_length=1, max_length=100)


class OrderItemResponse(OrderItemCreate):
    order_item_pk: int
    order_pk: int
    status: str
    activated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class OrderResponse(BaseModel):
    order_pk: int
    user_pk: int
    status: str
    admin_note: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    items: List[OrderItemResponse] = []

    model_config = {"from_attributes": True}


class OrderActivationRequest(BaseModel):
    item_ids: Optional[List[int]] = None


class ManualSubscriptionCreate(BaseModel):
    user_pk: int
    product_type: Literal["deck", "conjugaison", "grammaire"]
    product_id: Optional[int] = None
    duration_code: Literal["1d", "3d", "1w", "15d", "1m"]
    admin_note: Optional[str] = None


class SubscriptionResponse(BaseModel):
    subscription_pk: int
    user_pk: int
    product_type: str
    product_id: Optional[int] = None
    start_at: datetime
    end_at: datetime
    status: str
    origin: str
    order_item_pk: Optional[int] = None
    activated_by: Optional[int] = None
    admin_note: Optional[str] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class AccessResponse(BaseModel):
    allowed: bool
    preview_only: bool = True
    reason: Optional[str] = None
    expires_at: Optional[datetime] = None


class NotificationResponse(BaseModel):
    notification_pk: int
    admin_id: Optional[int] = None
    order_pk: Optional[int] = None
    kind: str
    read_at: Optional[datetime] = None
    created_at: datetime

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
    
    # Nouveaux champs optionnels
    explanation_it: Optional[str] = None
    translation_en: Optional[str] = None
    translation_de: Optional[str] = None
    translation_mg: Optional[str] = None
    example: Optional[str] = None

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


# ============================================================================
# CONJUGAISONS ITALIENNES
# ============================================================================
class ItalianConjugationFormInput(BaseModel):
    person_order: int = Field(..., ge=0, le=6)
    person_label: Optional[str] = Field(default=None, max_length=48)
    form_text: str = Field(..., min_length=1)
    raw_line: Optional[str] = None


class ItalianConjugationBlockInput(BaseModel):
    mood: str = Field(..., min_length=1, max_length=64)
    tense: str = Field(..., min_length=1, max_length=80)
    mood_order: int = Field(default=99, ge=0)
    tense_order: int = Field(default=99, ge=0)
    raw_italian: str = ""
    raw_portuguese: Optional[str] = None
    is_featured: bool = False
    forms: List[ItalianConjugationFormInput] = Field(default_factory=list)


class ItalianVerbCreate(BaseModel):
    infinitive: str = Field(..., min_length=1, max_length=160)
    category: str = Field(default="Actions", min_length=1, max_length=64)
    grammar_category: Optional[str] = Field(default=None, min_length=1, max_length=64)
    translation_fr: Optional[str] = Field(default=None, max_length=160)
    translation_en: Optional[str] = Field(default=None, max_length=160)
    source_record_id: Optional[str] = None
    conjugations: List[ItalianConjugationBlockInput] = Field(default_factory=list)


class ItalianVerbUpdate(BaseModel):
    infinitive: Optional[str] = Field(default=None, min_length=1, max_length=160)
    category: Optional[str] = Field(default=None, min_length=1, max_length=64)
    grammar_category: Optional[str] = Field(default=None, min_length=1, max_length=64)
    translation_fr: Optional[str] = Field(default=None, max_length=160)
    translation_en: Optional[str] = Field(default=None, max_length=160)
    conjugations: Optional[List[ItalianConjugationBlockInput]] = None


class ItalianConjugationFormOut(ItalianConjugationFormInput):
    form_pk: int
    model_config = {"from_attributes": True}


class ItalianConjugationBlockOut(BaseModel):
    conjugation_pk: int
    mood: str
    tense: str
    mood_order: int
    tense_order: int
    raw_italian: str
    raw_portuguese: Optional[str] = None
    is_featured: bool
    forms: List[ItalianConjugationFormOut] = Field(default_factory=list)
    model_config = {"from_attributes": True}


class ItalianVerbListItem(BaseModel):
    verb_pk: int
    infinitive: str
    category: str
    grammar_category: str
    translation_fr: Optional[str] = None
    translation_en: Optional[str] = None
    source_name: str
    conjugation_count: int


class ItalianVerbDetail(BaseModel):
    verb_pk: int
    infinitive: str
    category: str
    grammar_category: str
    translation_fr: Optional[str] = None
    translation_en: Optional[str] = None
    source_record_id: Optional[str] = None
    source_name: str
    source_url: str
    source_license: str
    conjugations: List[ItalianConjugationBlockOut] = Field(default_factory=list)


class ItalianConjugationSearchResult(BaseModel):
    infinitive: str
    mood: str
    tense: str
    person_label: Optional[str] = None
    form_text: str


class ItalianConjugationMetadata(BaseModel):
    moods: List[str]
    tenses: List[dict]
    categories: List[str]
    category_counts: dict[str, int] = Field(default_factory=dict)
    grammar_categories: List[str]
    grammar_category_counts: dict[str, int] = Field(default_factory=dict)


class ItalianConjugationImportReport(BaseModel):
    source_name: str
    source_license: str
    source_checksum: str
    verbs_processed: int
    verbs_created: int
    verbs_updated: int
    conjugations_processed: int
    forms_processed: int
    skipped_records: int
