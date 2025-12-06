"""Script simple pour vérifier le deck 8"""
import asyncio
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, func
from app.database import DATABASE_URL
from app.models import Deck, Card

async def check_deck():
    engine = create_async_engine(DATABASE_URL, echo=False)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    async with async_session() as db:
        # Récupérer le deck
        stmt = select(Deck).where(Deck.deck_pk == 8)
        result = await db.execute(stmt)
        deck = result.scalar_one_or_none()
        
        if deck:
            print(f"Deck trouvé: {deck.name} (ID: {deck.deck_pk})")
            
            # Compter les cartes
            stmt_count = select(func.count(Card.card_pk)).where(Card.deck_pk == 8)
            result_count = await db.execute(stmt_count)
            card_count = result_count.scalar()
            
            print(f"Nombre de cartes: {card_count}")
        else:
            print("Deck 8 introuvable!")
    
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(check_deck())
