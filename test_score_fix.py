"""
Script de test rapide pour vérifier la création de score avec auto-création de UserDeck
"""
import asyncio
import sys
from pathlib import Path

# Ajouter le répertoire parent au path
sys.path.insert(0, str(Path(__file__).parent))

from app.database import get_db
from app import crud_users, schemas

async def test_score_creation():
    """Test de création d'un score qui devrait créer automatiquement un UserDeck"""

    async for db in get_db():
        try:
            # Données de test
            user_pk = 52  # Utilisateur existant d'après les logs

            score_data = schemas.UserScoreCreate(
                deck_pk=9,
                card_pk=141,
                score=85,
                is_correct=True,
                time_spent=12,
                quiz_type="qcm"
            )

            print(f"🧪 Test de création de score pour user_pk={user_pk}, deck_pk={score_data.deck_pk}")
            print(f"   Card: {score_data.card_pk}, Score: {score_data.score}, Type: {score_data.quiz_type}")

            # Créer le score
            result = await crud_users.create_score(db, user_pk, score_data)

            print(f"✅ Score créé avec succès!")
            print(f"   Score PK: {result.score_pk}")
            print(f"   Score: {result.score}")
            print(f"   Is Correct: {result.is_correct}")

            # Vérifier que le UserDeck a été créé
            user_decks = await crud_users.get_user_decks(db, user_pk)
            deck_9 = [ud for ud in user_decks if ud.deck_pk == 9]

            if deck_9:
                ud = deck_9[0]
                print(f"\n📊 UserDeck créé/mis à jour:")
                print(f"   Total Points: {ud.total_points}")
                print(f"   Total Attempts: {ud.total_attempts}")
                print(f"   Successful Attempts: {ud.successful_attempts}")
                print(f"   Points QCM: {ud.points_qcm}")
            else:
                print(f"\n⚠️  UserDeck non trouvé pour deck_pk=9")

            return True

        except Exception as e:
            print(f"❌ Erreur: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            return False
        finally:
            break

if __name__ == "__main__":
    success = asyncio.run(test_score_creation())
    sys.exit(0 if success else 1)
