import asyncio
from sqlalchemy import select
from app.database import get_db, init_db
from app import models

async def check_stats():
    async for db in get_db():
        # Find user Jean
        stmt = select(models.User).where(models.User.email.ilike('%jean%')) # Assuming email contains jean or username
        result = await db.execute(stmt)
        user = result.scalars().first()
        
        if not user:
            print("User Jean not found")
            return

        print(f"User found: {user.username} (ID: {user.user_pk})")

        # Get User Decks
        stmt_decks = select(models.UserDeck).where(models.UserDeck.user_pk == user.user_pk)
        result_decks = await db.execute(stmt_decks)
        user_decks = result_decks.scalars().all()

        print(f"\nUser Decks ({len(user_decks)}):")
        for ud in user_decks:
            # Fetch deck name
            deck_stmt = select(models.Deck).where(models.Deck.deck_pk == ud.deck_pk)
            deck_res = await db.execute(deck_stmt)
            deck = deck_res.scalar_one_or_none()
            deck_name = deck.name if deck else "Unknown Deck"

            print(f"\nDeck: {deck_name} (PK: {ud.deck_pk})")
            print(f"  Legacy attempt_count: {ud.attempt_count}")
            print(f"  Legacy correct_count: {ud.correct_count}")
            print(f"  New total_attempts:   {ud.total_attempts}")
            print(f"  New successful_attempts: {ud.successful_attempts}")
            
            if ud.attempt_count > ud.total_attempts:
                print("  ⚠️ Only Legacy counts present? Mismatch detected.")
            if ud.correct_count > ud.successful_attempts:
                print("  ⚠️ Only Legacy correct present? Mismatch detected.")

if __name__ == "__main__":
    asyncio.run(check_stats())
