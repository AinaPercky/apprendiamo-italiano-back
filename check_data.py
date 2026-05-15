"""Script pour vérifier les données existantes dans la base de données."""
import asyncio
from app.database import get_db
from app import models
from sqlalchemy import select, func

async def check_existing_data():
    """Vérifie les decks et cartes existants."""
    async for db in get_db():
        # Compter les decks
        result = await db.execute(select(func.count()).select_from(models.Deck))
        deck_count = result.scalar()
        
        # Compter les cartes
        result = await db.execute(select(func.count()).select_from(models.Card))
        card_count = result.scalar()
        
        # Récupérer quelques decks
        result = await db.execute(select(models.Deck).limit(5))
        decks = result.scalars().all()
        
        print("=" * 80)
        print("DONNÉES EXISTANTES DANS LA BASE DE DONNÉES")
        print("=" * 80)
        print(f"\n📦 Total Decks: {deck_count}")
        print(f"🃏 Total Cards: {card_count}")
        
        if decks:
            print(f"\n📋 Premiers decks:")
            for deck in decks:
                # Compter les cartes de ce deck
                result = await db.execute(
                    select(func.count())
                    .select_from(models.Card)
                    .where(models.Card.deck_pk == deck.deck_pk)
                )
                cards_in_deck = result.scalar()
                print(f"  - ID: {deck.deck_pk}, Nom: {deck.name}, Cartes: {cards_in_deck}")
        
        # Compter les utilisateurs
        result = await db.execute(select(func.count()).select_from(models.User))
        user_count = result.scalar()
        print(f"\n👥 Total Utilisateurs: {user_count}")
        
        # Compter les user_decks
        result = await db.execute(select(func.count()).select_from(models.UserDeck))
        user_deck_count = result.scalar()
        print(f"🔗 Total User-Decks: {user_deck_count}")
        
        print("=" * 80)
        break

if __name__ == "__main__":
    asyncio.run(check_existing_data())
