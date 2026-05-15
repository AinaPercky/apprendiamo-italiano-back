import asyncio
from sqlalchemy import select
from app.database import get_db
from app import models
from datetime import datetime

async def inspect_deck_cards():
    async for db in get_db():
        # Deck 8 (Verbi riflessivi)
        deck_pk = 8
        print(f"--- Inspecting Cards for Deck {deck_pk} ---")
        
        stmt = select(models.Card).where(models.Card.deck_pk == deck_pk)
        cards = (await db.execute(stmt)).scalars().all()
        
        now = datetime.utcnow()
        print(f"Current UTC Time: {now}")
        
        mastered = 0
        learning = 0
        review = 0
        
        for c in cards:
            status = "UNKNOWN"
            if c.interval > 0 and c.next_review > now:
                status = "MASTERED"
                mastered += 1
            elif c.next_review <= now:
                status = "REVIEW"
                review += 1
            else:
                status = "LEARNING"
                learning += 1
                
            # Print only interesting cards (not default ones if too many)
            # Default: interval=0, next_review ~ created_at (past)
            if c.interval > 0 or c.priority_score > 0 if hasattr(c, 'priority_score') else False or status != "REVIEW":
                print(f"Card {c.card_pk}: Interval={c.interval}, NextRev={c.next_review}, Status={status}")
        
        print(f"\nCalculated: Mastered={mastered}, Learning={learning}, Review={review}")
        print(f"Total Cards: {len(cards)}")

if __name__ == "__main__":
    asyncio.run(inspect_deck_cards())
