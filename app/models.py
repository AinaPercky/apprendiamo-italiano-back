from sqlalchemy import Column, ForeignKey, Integer, Text, TIMESTAMP, ARRAY, String
from sqlalchemy.orm import relationship
from .database import Base

# --- Modèles pour les Cartes (Flashcards) ---

class Deck(Base):
    __tablename__ = "decks"
    deck_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_json = Column(Text, unique=True, nullable=False)
    name = Column(Text, nullable=False)
    total_correct = Column(Integer, default=0)
    total_attempts = Column(Integer, default=0)

    cards = relationship("Card", back_populates="deck")

class Card(Base):
    __tablename__ = "cards"
    card_pk = Column(Integer, primary_key=True, autoincrement=True, index=True)
    id_json = Column(Text, unique=True, nullable=False)
    deck_pk = Column(Integer, ForeignKey("decks.deck_pk", ondelete="CASCADE"), nullable=False)
    front = Column(Text, nullable=False)
    back = Column(Text, nullable=False)
    pronunciation = Column(Text)
    image = Column(Text)
    created_at = Column(TIMESTAMP, nullable=False)
    box = Column(Integer, default=0)
    next_review = Column(TIMESTAMP, nullable=False)
    tags = Column(Text, default="[]") # Changé de ARRAY(Text) à Text pour la compatibilité SQLite de test

    deck = relationship("Deck", back_populates="cards")

# --- Modèles pour l'Audio (TTS) ---

class AudioItem(Base):
    __tablename__ = "audio_items"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    text = Column(String)
    filename = Column(String)
    category = Column(String, index=True)
    language = Column(String, default='it')
    ipa = Column(String, nullable=True)
