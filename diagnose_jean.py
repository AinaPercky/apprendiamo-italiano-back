import asyncio
from sqlalchemy import select, and_
from app.database import get_db
from app import models
from datetime import datetime

async def diagnose_jean_deck_8():
    async for db in get_db():
        # Find Jean
        stmt_user = select(models.User).where(models.User.email.ilike('%jean%'))
        user = (await db.execute(stmt_user)).scalar_one_or_none()
        if not user:
            print("❌ User Jean not found")
            return
        
        print(f"👤 User: {user.username} (ID: {user.user_pk})")
        deck_pk = 8
        
        # 1. Check UserDeck aggregates
        stmt_ud = select(models.UserDeck).where(
            and_(models.UserDeck.user_pk == user.user_pk, models.UserDeck.deck_pk == deck_pk)
        )
        ud = (await db.execute(stmt_ud)).scalar_one_or_none()
        
        if ud:
            print(f"\n📊 UserDeck Stats (Aggregates stored in DB):")
            print(f"   - Total Attempts: {ud.total_attempts} (Legacy: {ud.attempt_count})")
            print(f"   - Successful: {ud.successful_attempts} (Legacy: {ud.correct_count})")
            print(f"   - Mastered/Learning/Review (Snapshot): {ud.mastered_cards} / {ud.learning_cards} / {ud.review_cards}")
        else:
            print(f"❌ No UserDeck found for deck {deck_pk}")

        # 2. Check Real-time Card Status (Global Cards)
        # NOTE: Current system uses GLOBAL Card state for Anki (as per CRUD logic seen in Step 78)
        # This is strictly true only if cards are personal OR we modified the system to be UserCard based.
        # But wait, Step 78 modified `crud_quiz.py` to update `models.Card`.
        # `models.Card` is shared.
        # So if Jean updates a card, it updates for everyone?
        # My docs in Step 86 said: "Global vs User... Actuellement... stocké sur l'objet Card global."
        
        stmt_cards = select(models.Card).where(models.Card.deck_pk == deck_pk)
        cards = (await db.execute(stmt_cards)).scalars().all()
        
        now = datetime.utcnow()
        real_mastered = 0
        real_learning = 0
        real_review = 0
        
        print(f"\n🃏 Real-time Card Analysis (Total {len(cards)}):")
        for c in cards:
            if c.interval > 0 and c.next_review > now:
                real_mastered += 1
            elif c.next_review <= now:
                real_review += 1
            else:
                real_learning += 1
                
        print(f"   - Calculated Mastered: {real_mastered}")
        print(f"   - Calculated Learning: {real_learning}")
        print(f"   - Calculated Review:   {real_review}")

        # 3. Check Performances
        stmt_perf = select(models.CardPerformance).where(
            and_(models.CardPerformance.user_pk == user.user_pk, models.CardPerformance.deck_pk == deck_pk)
        )
        perfs = (await db.execute(stmt_perf)).scalars().all()
        correct_perfs = [p for p in perfs if p.correct_count > 0]
        print(f"\n📝 Card Performances (History):")
        print(f"   - Total cards played at least once: {len(perfs)}")
        print(f"   - Total cards answered correctly at least once: {len(correct_perfs)}")

if __name__ == "__main__":
    asyncio.run(diagnose_jean_deck_8())
