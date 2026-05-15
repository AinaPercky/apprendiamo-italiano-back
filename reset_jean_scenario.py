import asyncio
from sqlalchemy import select, and_
from app.database import get_db
from app import models

async def reset_user_jean_deck_8():
    async for db in get_db():
        user_pk = 2
        deck_pk = 8
        
        # 1. Reset all card performances for this user/deck to have correct count = 0 except 1
        stmt_perf = select(models.CardPerformance).where(
            and_(models.CardPerformance.user_pk == user_pk, models.CardPerformance.deck_pk == deck_pk)
        )
        perfs = (await db.execute(stmt_perf)).scalars().all()
        
        # We need to simulate:
        # 1 mastered (correct > 0, Anki stats OK)
        # 9 review (correct = 0, attempted > 0, Card stats last_review NOT NULL)
        # 30 learning (Card stats last_review NULL)
        
        # NOTE: `update_user_deck_anki_stats` uses models.Card (Global)
        # We must modify models.Card to match the desired state.
        
        stmt_cards = select(models.Card).where(models.Card.deck_pk == deck_pk)
        cards = (await db.execute(stmt_cards)).scalars().all()
        cards = list(cards) # 40 cards
        
        # Card 0: Mastered
        cards[0].interval = 1
        cards[0].last_reviewed_at = datetime.utcnow()
        db.add(cards[0])
        print(f"Card {cards[0].card_pk}: SET TO MASTERED")
        
        # Cards 1-9: Review (Failed)
        for i in range(1, 10):
            cards[i].interval = 0
            cards[i].last_reviewed_at = datetime.utcnow()
            db.add(cards[i])
        print(f"Cards {cards[1].card_pk}...{cards[9].card_pk}: SET TO REVIEW (FAILED)")
            
        # Cards 10-39: Learning (New)
        for i in range(10, 40):
            cards[i].interval = 0
            cards[i].last_reviewed_at = None
            db.add(cards[i])
        print(f"Cards {cards[10].card_pk}...{cards[39].card_pk}: SET TO LEARNING (NEW)")
            
        await db.commit()
        print("✅ Database RESET to simulate user scenario.")

from datetime import datetime
if __name__ == "__main__":
    asyncio.run(reset_user_jean_deck_8())
