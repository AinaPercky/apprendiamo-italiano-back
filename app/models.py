from sqlalchemy import Column, ForeignKey, Integer, Text, TIMESTAMP, String, inspect
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import relationship
from .database import Base
import os

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

    # === Gestion intelligente du type tags selon le dialecte ===
    # PostgreSQL → ARRAY(Text) (vrai tableau, indexable, rapide)
    # SQLite → Text avec JSON sérialisé (compatibilité tests)
    if os.getenv("TESTING") or (hasattr(inspect, 'current_engine') and inspect.current_engine.dialect.name == "sqlite"):
        tags = Column(Text, nullable=False, server_default="[]")  # SQLite
    else:
        tags = Column(ARRAY(Text), nullable=False, server_default="{}")  # PostgreSQL

    deck = relationship("Deck", back_populates="cards")


class AudioItem(Base):
    __tablename__ = "audio_items"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True, nullable=False)
    text = Column(String, nullable=False)
    filename = Column(String, nullable=False)
    category = Column(String, index=True, nullable=False)
    language = Column(String, default='it')
    ipa = Column(String, nullable=True)