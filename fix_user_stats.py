import asyncio
from sqlalchemy import select
from app.database import get_db
from app import models

async def fix_user_stats():
    """
    Synchronise les anciens compteurs (attempt_count, correct_count)
    avec les nouveaux champs (total_attempts, successful_attempts)
    pour corriger l'affichage du dashboard.
    """
    async for db in get_db():
        print("🔍 Checking for UserDecks needing migration...")
        
        # Get all UserDecks
        result = await db.execute(select(models.UserDeck))
        user_decks = result.scalars().all()
        
        updated_count = 0
        
        for ud in user_decks:
            needs_update = False
            
            # 1. Sync Attempts
            if ud.total_attempts == 0 and ud.attempt_count > 0:
                print(f"  - Deck {ud.deck_pk} (User {ud.user_pk}): Syncing Attempts {ud.attempt_count} -> total_attempts")
                ud.total_attempts = ud.attempt_count
                needs_update = True
                
            # 2. Sync Successes
            if ud.successful_attempts == 0 and ud.correct_count > 0:
                print(f"  - Deck {ud.deck_pk} (User {ud.user_pk}): Syncing Correct {ud.correct_count} -> successful_attempts")
                ud.successful_attempts = ud.correct_count
                needs_update = True
            
            # 3. Sanity check: successful shouldn't exceed total (unless data corrupt, but let's allow it for now or clamp)
            if ud.successful_attempts > ud.total_attempts:
                 # In case legacy data was weird, clamp it? No, trust legacy for now.
                 pass

            if needs_update:
                db.add(ud)
                updated_count += 1
        
        if updated_count > 0:
            await db.commit()
            print(f"✅ Successfully updated {updated_count} UserDecks.")
        else:
            print("✨ No UserDecks needed updates.")

if __name__ == "__main__":
    asyncio.run(fix_user_stats())
