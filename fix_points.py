import asyncio
from sqlalchemy import select
from app.database import get_db
from app import models

POINTS_PER_SUCCESS = 10

async def fix_user_points():
    """
    Recalcule les points (total_points) pour tous les user_decks
    basé sur le nombre de succès (successful_attempts).
    Assumption: 1 succès = 10 points.
    """
    async for db in get_db():
        print("🔧 Recalculating UserDeck points...")
        
        result = await db.execute(select(models.UserDeck))
        user_decks = result.scalars().all()
        
        updated_count = 0
        
        for ud in user_decks:
            # Calcul théorique basé sur successful_attempts
            theoretical_points = ud.successful_attempts * POINTS_PER_SUCCESS
            
            if ud.total_points == 0 and theoretical_points > 0:
                print(f"  - Deck {ud.deck_pk} (User {ud.user_pk}): Update points {ud.total_points} -> {theoretical_points}")
                ud.total_points = theoretical_points
                updated_count += 1
            elif ud.total_points != theoretical_points:
                # Optionnel : Forcer la synchro même si pas 0 ?
                # Pour l'instant on fixe surtout les Zéros.
                print(f"  - Deck {ud.deck_pk} (User {ud.user_pk}): Points discrepancy ({ud.total_points} vs {theoretical_points}). Updating.")
                ud.total_points = theoretical_points
                updated_count += 1
        
        if updated_count > 0:
            await db.commit()
            print(f"✅ Updated points for {updated_count} decks.")
        else:
            print("✨ No points updates needed.")

if __name__ == "__main__":
    asyncio.run(fix_user_points())
