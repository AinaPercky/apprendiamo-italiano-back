"""
Script de test pour reproduire l'erreur GET /api/users/decks
"""
import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from app.database import get_db
from app import crud_users

async def test_get_user_decks():
    """Test de récupération des decks utilisateur"""
    
    async for db in get_db():
        try:
            user_pk = 52  # Utilisateur d'après les logs
            
            print(f"🧪 Test de récupération des decks pour user_pk={user_pk}")
            
            # Récupérer les decks
            user_decks = await crud_users.get_user_decks(db, user_pk)
            
            print(f"✅ Récupération réussie!")
            print(f"   Nombre de decks: {len(user_decks)}")
            
            for ud in user_decks:
                print(f"\n📦 Deck PK: {ud.deck_pk}")
                print(f"   Nom: {ud.deck.name if ud.deck else 'N/A'}")
                print(f"   Total Points: {ud.total_points}")
                print(f"   Total Attempts: {ud.total_attempts}")
                print(f"   Mastered: {ud.mastered_cards}, Learning: {ud.learning_cards}, Review: {ud.review_cards}")
            
            return True
            
        except Exception as e:
            print(f"❌ Erreur: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            return False
        finally:
            break

if __name__ == "__main__":
    success = asyncio.run(test_get_user_decks())
    sys.exit(0 if success else 1)
