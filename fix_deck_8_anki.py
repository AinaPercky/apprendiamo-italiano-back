import asyncio
from sqlalchemy import select, and_
from app.database import get_db
from app import models
from app.core.anki import anki_review

async def fix_anki_stats():
    async for db in get_db():
        # User Jean
        stmt_user = select(models.User).where(models.User.email.ilike('%jean%'))
        user = (await db.execute(stmt_user)).scalar_one_or_none()
        if not user:
            print("User Jean not found")
            return

        deck_pk = 8 # Verbi riflessivi
        
        # Get Performances
        stmt_perf = select(models.CardPerformance).where(
            and_(
                models.CardPerformance.user_pk == user.user_pk,
                models.CardPerformance.deck_pk == deck_pk
            )
        )
        perfs = (await db.execute(stmt_perf)).scalars().all()
        
        print(f"Found {len(perfs)} performances for deck {deck_pk}.")
        
        updated = 0
        for p in perfs:
            if p.correct_count > 0:
                # Retrieve Card
                stmt_card = select(models.Card).where(models.Card.card_pk == p.card_pk)
                card = (await db.execute(stmt_card)).scalar_one_or_none()
                
                if card:
                    print(f"Updating Card {card.card_pk} (Correct={p.correct_count}) to 'Good' status...")
                    # Simulate a "Good" review
                    anki_stats = anki_review(
                        easiness=card.easiness, # usage default or current if updated
                        interval=0, # Reset to 0 then apply good to ensure graduation
                        consecutive_correct=0,
                        grade=3 # Good
                    )
                    
                    card.easiness = anki_stats["easiness"]
                    card.interval = anki_stats["interval"]
                    card.consecutive_correct = anki_stats["consecutive_correct"]
                    card.next_review = anki_stats["next_review"]
                    
                    db.add(card)
                    updated += 1
        
        if updated > 0:
            await db.commit()
            print(f"✅ Updated {updated} cards to Anki 'Good' state.")
        else:
            print("No cards found with correct answers to update.")

if __name__ == "__main__":
    asyncio.run(fix_anki_stats())
