from sqlalchemy import Column, ForeignKey, Integer, Text,Float, TIMESTAMP, String, inspect, Boolean, DateTime
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import relationship
from .database import Base
import os
from datetime import datetime

class Deck(Base):
    __tablename__ = "decks"

    deck_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_json = Column(Text, unique=True, nullable=False)
    name = Column(Text, nullable=False)
    total_correct = Column(Integer, default=0)
    total_attempts = Column(Integer, default=0)

    cards = relationship("Card", back_populates="deck", cascade="all, delete-orphan")


class Card(Base):
    __tablename__ = "cards"

    card_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_json = Column(Text, unique=True, nullable=False)
    deck_pk = Column(Integer, ForeignKey("decks.deck_pk", ondelete="CASCADE"), nullable=False)
    front = Column(Text, nullable=False)
    back = Column(Text, nullable=False)
    pronunciation = Column(Text, nullable=True)
    image = Column(Text, nullable=True)
    created_at = Column(TIMESTAMP(timezone=True), nullable=False)
    next_review = Column(TIMESTAMP(timezone=True), nullable=False)
    box = Column(Integer, default=0)
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

    deck = relationship("Deck", back_populates="cards")


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