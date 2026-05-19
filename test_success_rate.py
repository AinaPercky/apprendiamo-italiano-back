"""
Test pour vérifier que success_rate est bien sérialisé dans UserDeckResponse
"""
import asyncio
import sys
from pathlib import Path
import json

sys.path.insert(0, str(Path(__file__).parent))

from app.database import get_db
from app import crud_users, schemas

async def test_user_deck_serialization():
    """Test de sérialisation des UserDecks avec success_rate"""

    async for db in get_db():
        try:
            user_pk = 52

            print(f"🧪 Test de sérialisation UserDeckResponse pour user_pk={user_pk}\n")

            # Récupérer les decks
            user_decks = await crud_users.get_user_decks(db, user_pk)

            print(f"✅ {len(user_decks)} deck(s) récupéré(s)\n")

            for ud in user_decks:
                # Convertir en schema Pydantic
                response = schemas.UserDeckResponse.model_validate(ud)

                # Sérialiser en JSON
                json_data = response.model_dump()

                print(f"📦 Deck: {response.deck.name}")
                print(f"   Total Attempts: {response.total_attempts}")
                print(f"   Successful Attempts: {response.successful_attempts}")
                print(f"   ✨ Success Rate: {json_data.get('success_rate', 'MISSING')}%")
                print(f"   ✨ Progress: {json_data.get('progress', 'MISSING')}%")

                # Vérifier que les champs sont présents
                if 'success_rate' in json_data:
                    print(f"   ✅ success_rate est dans le JSON")
                else:
                    print(f"   ❌ success_rate MANQUANT dans le JSON")

                if 'progress' in json_data:
                    print(f"   ✅ progress est dans le JSON")
                else:
                    print(f"   ❌ progress MANQUANT dans le JSON")

                print()

            return True

        except Exception as e:
            print(f"❌ Erreur: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
            return False
        finally:
            break

if __name__ == "__main__":
    success = asyncio.run(test_user_deck_serialization())
    sys.exit(0 if success else 1)
