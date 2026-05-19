"""
Test direct de l'endpoint API GET /api/users/decks
pour vérifier que success_rate est bien dans la réponse
"""
import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from app.database import get_db
from app import models, schemas
from sqlalchemy import select

async def test_api_endpoint():
    """Simule l'appel API complet"""

    async for db in get_db():
        try:
            # Simuler un utilisateur connecté
            user_result = await db.execute(
                select(models.User).where(models.User.user_pk == 52)
            )
            current_user = user_result.scalar_one_or_none()

            if not current_user:
                print("❌ Utilisateur 52 non trouvé")
                return False

            print(f"🧪 Test de l'endpoint GET /api/users/decks")
            print(f"   User: {current_user.email}\n")

            # Appeler la fonction de l'endpoint
            from app import crud_users
            user_decks = await crud_users.get_user_decks(db, current_user.user_pk)

            # Convertir en réponse API (comme FastAPI le fait)
            response_data = [schemas.UserDeckResponse.model_validate(ud) for ud in user_decks]

            print(f"✅ {len(response_data)} deck(s) retourné(s)\n")

            # Afficher chaque deck avec ses données JSON
            for deck_response in response_data:
                # Convertir en dict (comme JSON)
                deck_json = deck_response.model_dump()

                print(f"📦 Deck #{deck_json['deck_pk']}: {deck_json['deck']['name']}")
                print(f"   total_attempts: {deck_json['total_attempts']}")
                print(f"   successful_attempts: {deck_json['successful_attempts']}")

                # Vérifier success_rate
                if 'success_rate' in deck_json:
                    print(f"   ✅ success_rate: {deck_json['success_rate']}%")
                else:
                    print(f"   ❌ success_rate: MANQUANT")

                if 'progress' in deck_json:
                    print(f"   ✅ progress: {deck_json['progress']}%")
                else:
                    print(f"   ❌ progress: MANQUANT")

                print()

            # Afficher le JSON complet du premier deck
            if response_data:
                import json
                print("📄 JSON complet du premier deck:")
                print(json.dumps(response_data[0].model_dump(), indent=2, default=str))

            return True

        except Exception as e:
            print(f"❌ Erreur: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            return False
        finally:
            break

if __name__ == "__main__":
    success = asyncio.run(test_api_endpoint())
    sys.exit(0 if success else 1)
