import asyncio
import httpx
import random
import string
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000"

def generate_random_string(length=10):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

async def test_deck_lifecycle():
    print("🚀 Démarrage du test de cycle de vie du deck...")
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        # 1. Création d'un utilisateur
        print("\n1️⃣ Création de l'utilisateur...")
        email = f"test_user_{generate_random_string()}@example.com"
        password = "password123"
        user_data = {
            "email": email,
            "password": password,
            "username": f"user_{generate_random_string()}",
            "full_name": "Test User"
        }
        
        response = await client.post(f"{BASE_URL}/api/users/register", json=user_data)
        if response.status_code != 201:
            print(f"❌ Erreur création utilisateur: {response.text}")
            return
        print(f"✅ Utilisateur créé: {email}")

        # 2. Connexion pour obtenir le token
        print("\n2️⃣ Connexion...")
        response = await client.post(f"{BASE_URL}/api/users/login", json={"email": email, "password": password})
        if response.status_code != 200:
            print(f"❌ Erreur connexion: {response.text}")
            return
        token = response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        print("✅ Connecté")

        # 3. Création d'un deck
        print("\n3️⃣ Création du deck...")
        deck_data = {
            "name": f"Test Deck {generate_random_string()}",
            "id_json": f"test_{generate_random_string()}"
        }
        
        deck_id = None
        try:
            response = await client.post(f"{BASE_URL}/decks/", json=deck_data)
            if response.status_code != 200:
                print(f"❌ Erreur création deck: {response.text}")
                return
            deck = response.json()
            deck_id = deck["deck_pk"]
            print(f"✅ Deck créé: {deck['name']} (ID: {deck_id})")

            # 4. Ajout de cartes au deck
            print("\n4️⃣ Ajout de cartes...")
            for i in range(3):
                card_data = {
                    "deck_pk": deck_id,
                    "front": f"Front {i}",
                    "back": f"Back {i}",
                    "card_type": "flashcard",
                    "created_at": datetime.now().isoformat(),
                    "next_review": datetime.now().isoformat()
                }
                response = await client.post(f"{BASE_URL}/cards/", json=card_data)
                if response.status_code != 200:
                    print(f"❌ Erreur création carte {i}: {response.text}")
                    # On ne return pas ici pour laisser le finally nettoyer
                    raise Exception("Erreur création carte")
                print(f"   - Carte {i} ajoutée")
            print("✅ 3 cartes ajoutées")

            # 5. Vérification que le deck existe
            print("\n5️⃣ Vérification existence deck...")
            response = await client.get(f"{BASE_URL}/decks/{deck_id}")
            if response.status_code != 200:
                print(f"❌ Le deck devrait exister: {response.status_code}")
                return
            print("✅ Le deck est bien présent en base")

            # 6. Suppression du deck
            print("\n6️⃣ Suppression du deck...")
            response = await client.delete(f"{BASE_URL}/decks/{deck_id}")
            if response.status_code != 200:
                print(f"❌ Erreur suppression deck: {response.text}")
                return
            print("✅ Deck supprimé via API")

            # 7. Vérification de la disparition
            print("\n7️⃣ Vérification de la suppression...")
            response = await client.get(f"{BASE_URL}/decks/{deck_id}")
            if response.status_code == 404:
                print("✅ SUCCÈS: Le deck n'existe plus (404 Not Found)")
                deck_id = None # Marquer comme supprimé pour ne pas retenter dans le finally
            else:
                print(f"❌ ÉCHEC: Le deck existe toujours ou autre erreur (Status: {response.status_code})")

        except Exception as e:
            print(f"\n❌ UNE ERREUR EST SURVENUE: {str(e)}")
        finally:
            # Nettoyage de sécurité
            if deck_id:
                print(f"\n🧹 Nettoyage de sécurité (finally block)...")
                # Vérifier s'il existe encore
                check = await client.get(f"{BASE_URL}/decks/{deck_id}")
                if check.status_code == 200:
                    print(f"   Le deck {deck_id} existe encore, suppression forcée...")
                    await client.delete(f"{BASE_URL}/decks/{deck_id}")
                    print("   ✅ Deck supprimé.")
                else:
                    print("   Rien à nettoyer.")

if __name__ == "__main__":
    asyncio.run(test_deck_lifecycle())
