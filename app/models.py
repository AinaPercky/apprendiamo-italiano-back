from sqlalchemy import Column, ForeignKey, Integer, Text,Float, TIMESTAMP, String, inspect, Boolean, DateTime, Table
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import relationship
from .database import Base
import os
from datetime import datetime

# Table d'association Many-to-Many entre Decks et Cards
deck_cards = Table(
    'deck_cards',
    Base.metadata,
    Column('deck_pk', Integer, ForeignKey('decks.deck_pk', ondelete='CASCADE'), primary_key=True),
    Column('card_pk', Integer, ForeignKey('cards.card_pk', ondelete='CASCADE'), primary_key=True)
)

class Deck(Base):
    __tablename__ = "decks"

    deck_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_json = Column(Text, unique=True, nullable=False)
    name = Column(Text, nullable=False)
    total_correct = Column(Integer, default=0)
    total_attempts = Column(Integer, default=0)

    # Relation Many-to-Many
    cards = relationship("Card", secondary=deck_cards, back_populates="decks")


class Card(Base):
    __tablename__ = "cards"

    card_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_json = Column(Text, unique=True, nullable=False)
    
    # deck_pk devient optionnel car la relation est gérée par deck_cards
    # On le garde pour compatibilité temporaire
    deck_pk = Column(Integer, ForeignKey("decks.deck_pk", ondelete="CASCADE"), nullable=True)
    
    front = Column(Text, nullable=False)
    back = Column(Text, nullable=False)
    pronunciation = Column(Text, nullable=True)
    image = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), nullable=False)
    next_review = Column(TIMESTAMP(timezone=True), nullable=False)
    box = Column(Integer, default=0)
    
    # === NOUVEAUX CHAMPS (2026-02-11) ===
    explanation_it = Column(Text, nullable=True)
    translation_en = Column(Text, nullable=True)
    translation_de = Column(Text, nullable=True)
    translation_mg = Column(Text, nullable=True)
    example = Column(Text, nullable=True)
    
    # === NOUVEAU : Algorithme Anki ===
    easiness = Column(Float, nullable=False, default=2.5)
    interval = Column(Integer, nullable=False, default=0)
    consecutive_correct = Column(Integer, nullable=False, default=0)
    last_reviewed_at = Column(DateTime(timezone=True), nullable=True)

    # === Gestion intelligente du type tags selon le dialecte ===
    # PostgreSQL → ARRAY(Text) (vrai tableau, indexable, rapide)
    # SQLite → Text avec JSON sérialisé (compatibilité tests)
    if os.getenv("TESTING") or (hasattr(inspect, 'current_engine') and inspect.current_engine.dialect.name == "sqlite"):
        tags = Column(Text, nullable=False, server_default="[]")  # SQLite
    else:
        tags = Column(ARRAY(Text), nullable=False, server_default="{}")  # PostgreSQL

    # Relation Many-to-Many
    decks = relationship("Deck", secondary=deck_cards, back_populates="cards")
    
    # Ancienne relation (pour compatibilité, pointe vers le deck "principal" si deck_pk est rempli)
    # Note: cela peut être source de confusion si le deck_pk n'est pas synchronisé avec deck_cards
    # deck = relationship("Deck", back_populates="cards") # On commente ou retire car conflit avec 'decks' et 'cards'



class User(Base):
    __tablename__ = "users"

    user_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    email = Column(String, unique=True, nullable=False, index=True)
    username = Column(String, unique=True, nullable=False, index=True)
    hashed_password = Column(String, nullable=True)  # Nullable pour les utilisateurs Google
    
    # Informations Google OAuth
    google_id = Column(String, unique=True, nullable=True, index=True)
    google_email = Column(String, nullable=True)
    google_picture = Column(String, nullable=True)
    
    # Informations profil
    first_name = Column(String, nullable=True)
    last_name = Column(String, nullable=True)
    profile_picture = Column(String, nullable=True)
    bio = Column(Text, nullable=True)
    
    # Statut et permissions
    is_active = Column(Boolean, default=True, index=True)
    is_verified = Column(Boolean, default=False)
    verification_token = Column(String, nullable=True)
    
    # Données de performance
    total_score = Column(Integer, default=0)
    total_cards_learned = Column(Integer, default=0)
    total_cards_reviewed = Column(Integer, default=0)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    last_login = Column(DateTime, nullable=True)
    
    # Relations
    decks = relationship("UserDeck", back_populates="user", cascade="all, delete-orphan")
    scores = relationship("UserScore", back_populates="user", cascade="all, delete-orphan")
    audio_records = relationship("UserAudio", back_populates="user", cascade="all, delete-orphan")

    @property
    def full_name(self) -> str:
        """Retourne le nom complet de l'utilisateur ou son nom d'utilisateur."""
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        return self.first_name or self.last_name or self.username or ""


class UserDeck(Base):
    """Association entre utilisateurs et decks (flashcards)"""
    __tablename__ = "user_decks"

    user_deck_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_pk = Column(Integer, ForeignKey("users.user_pk", ondelete="CASCADE"), nullable=False, index=True)
    deck_pk = Column(Integer, ForeignKey("decks.deck_pk", ondelete="CASCADE"), nullable=False, index=True)
    
    # Statistiques utilisateur pour ce deck
    correct_count = Column(Integer, default=0)
    attempt_count = Column(Integer, default=0)
    cards_mastered = Column(Integer, default=0)
    
    # Timestamps
    added_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    last_studied = Column(DateTime, nullable=True)
    
    mastered_cards = Column(Integer, nullable=False, default=0)
    learning_cards = Column(Integer, nullable=False, default=0)
    review_cards = Column(Integer, nullable=False, default=0)

    total_points = Column(Integer, nullable=False, default=0)
    total_attempts = Column(Integer, nullable=False, default=0)
    successful_attempts = Column(Integer, nullable=False, default=0)

    points_frappe = Column(Integer, nullable=False, default=0)
    points_association = Column(Integer, nullable=False, default=0)
    points_qcm = Column(Integer, nullable=False, default=0)
    points_classique = Column(Integer, nullable=False, default=0)  # Jusqu'à 100%
    
    user = relationship("User", back_populates="decks")
    deck = relationship("Deck")


class UserScore(Base):
    """Historique des scores utilisateur"""
    __tablename__ = "user_scores"

    score_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_pk = Column(Integer, ForeignKey("users.user_pk", ondelete="CASCADE"), nullable=False, index=True)
    deck_pk = Column(Integer, ForeignKey("decks.deck_pk", ondelete="CASCADE"), nullable=True, index=True)
    card_pk = Column(Integer, ForeignKey("cards.card_pk", ondelete="CASCADE"), nullable=True, index=True)
    
    # Score et performance
    score = Column(Integer, nullable=False)
    is_correct = Column(Boolean, nullable=False)
    time_spent = Column(Integer, nullable=True)  # en secondes
    quiz_type = Column(String, nullable=False, default="classique")  # Type de quiz: frappe, association, qcm, classique
    
    # Timestamp
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    
    user = relationship("User", back_populates="scores")
    deck = relationship("Deck")
    card = relationship("Card")


class UserAudio(Base):
    """Enregistrements audio des utilisateurs"""
    __tablename__ = "user_audio"

    audio_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_pk = Column(Integer, ForeignKey("users.user_pk", ondelete="CASCADE"), nullable=False, index=True)
    card_pk = Column(Integer, ForeignKey("cards.card_pk", ondelete="CASCADE"), nullable=True, index=True)
    
    # Informations audio
    filename = Column(String, nullable=False)
    audio_url = Column(String, nullable=False)
    duration = Column(Integer, nullable=True)  # en secondes
    quality_score = Column(Integer, nullable=True)  # Score de qualité (0-100)
    
    # Metadata
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    
    user = relationship("User", back_populates="audio_records")
    card = relationship("Card")


class AudioItem(Base):
    __tablename__ = "audio_items"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True, nullable=False)
    text = Column(String, nullable=False)
    filename = Column(String, nullable=False)
    category = Column(String, index=True, nullable=False)
    language = Column(String, default='it')
    ipa = Column(String, nullable=True)


class CardPerformance(Base):
    """Suivi des performances utilisateur par carte pour l'algorithme de sélection intelligente"""
    __tablename__ = "card_performance"

    performance_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_pk = Column(Integer, ForeignKey("users.user_pk", ondelete="CASCADE"), nullable=False, index=True)
    card_pk = Column(Integer, ForeignKey("cards.card_pk", ondelete="CASCADE"), nullable=False, index=True)
    deck_pk = Column(Integer, ForeignKey("decks.deck_pk", ondelete="CASCADE"), nullable=False, index=True)
    
    # Statistiques de performance
    correct_count = Column(Integer, default=0, nullable=False)
    incorrect_count = Column(Integer, default=0, nullable=False)
    total_attempts = Column(Integer, default=0, nullable=False)
    
    # Score pour la priorisation : (incorrect_count * 2) - correct_count
    # Plus le score est élevé, plus la carte doit être révisée
    priority_score = Column(Float, default=0.0, nullable=False)
    
    # Timestamps
    last_reviewed_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relations
    user = relationship("User")
    card = relationship("Card")
    deck = relationship("Deck")


class QuizSession(Base):
    """Historique des sessions de quiz pour éviter les répétitions jusqu'à ce que toutes les cartes soient vues"""
    __tablename__ = "quiz_sessions"

    session_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    user_pk = Column(Integer, ForeignKey("users.user_pk", ondelete="CASCADE"), nullable=False, index=True)
    deck_pk = Column(Integer, ForeignKey("decks.deck_pk", ondelete="CASCADE"), nullable=False, index=True)
    
    # Configuration du quiz
    card_count = Column(Integer, nullable=False)  # Nombre de cartes dans ce quiz
    quiz_type = Column(String, nullable=False, default="classique")
    
    # État du cycle
    cycle_number = Column(Integer, default=1, nullable=False)  # Quel cycle de révision (1, 2, 3...)
    
    # Cartes utilisées (stockées en JSON array d'IDs)
    used_card_pks = Column(Text, nullable=False)  # JSON array: [1, 5, 12, ...]
    
    # Résultats
    correct_count = Column(Integer, default=0)
    total_questions = Column(Integer, default=0)
    
    # Timestamps
    started_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    completed_at = Column(DateTime, nullable=True)
    
    # Relations
    user = relationship("User")
    deck = relationship("Deck")