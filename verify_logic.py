import asyncio
from sqlalchemy import select, and_
from app.database import get_db
from app import models, crud_users

async def verify_new_logic():
    async for db in get_db():
        # Get Deck 8 and User Jean (or ID 2)
        user_pk = 2
        deck_pk = 8
        
        # 1. Update stats using the NEW logic
        stmt_ud = select(models.UserDeck).where(
            and_(models.UserDeck.user_pk == user_pk, models.UserDeck.deck_pk == deck_pk)
        )
        ud = (await db.execute(stmt_ud)).scalar_one_or_none()
        
        if ud:
            print("🔄 Running update_user_deck_anki_stats with NEW logic...")
            updated_ud = await crud_users.update_user_deck_anki_stats(db, ud, commit_changes=True)
            
            print(f"\n✅ Result for User {user_pk}, Deck {deck_pk}:")
            print(f"  - Mastered (Interval > 0): {updated_ud.mastered_cards}")
            print(f"  - Learning (En cours / Remaining): {updated_ud.learning_cards}")
            print(f"  - Review (Failed / Retry): {updated_ud.review_cards}")
            
            total = updated_ud.mastered_cards + updated_ud.learning_cards + updated_ud.review_cards
            print(f"  - Total: {total} (Should be 40)")
        else:
            print("UserDeck not found")

if __name__ == "__main__":
    asyncio.run(verify_new_logic())
