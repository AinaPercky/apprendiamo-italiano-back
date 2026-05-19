"""
Test du fix pour la suppression d'un deck (Erreur 404)
Vérifie que la suppression d'un deck non commencé retourne 200 OK au lieu de 404
"""

import requests
import json
from datetime import datetime

API_BASE_URL = "http://127.0.0.1:8000"

def test_delete_deck_fix():
    """
    Test du fix pour la suppression d'un deck
    """
    print("=" * 80)
    print("🧪 TEST: DELETE /api/users/decks/{deck_pk} (Fix 404)")
    print("=" * 80)
    print()

    # 1. Créer un nouveau compte utilisateur
    print("📝 Étape 1: Création d'un nouveau compte utilisateur")
    print("-" * 80)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    test_email = f"test_delete_{timestamp}@example.com"

    register_data = {
        "email": test_email,
        "username": f"test_user_{timestamp}",
        "password": "TestPassword123!"
    }

    try:
        response = requests.post(
            f"{API_BASE_URL}/api/users/register",
            json=register_data,
            headers={"Content-Type": "application/json"}
        )

        if response.status_code != 201:
            print(f"❌ Erreur lors de la création du compte: {response.status_code}")
            print(f"   Réponse: {response.text}")
            return

        data = response.json()
        token = data["access_token"]
        user_pk = data["user"]["user_pk"]

        print(f"✅ Compte créé avec succès!")
        print(f"   Email: {test_email}")
        print(f"   User PK: {user_pk}")
        print()

    except Exception as e:
        print(f"❌ Erreur: {e}")
        return

    # 2. Récupérer un deck à supprimer (par exemple le deck ID 1)
    # On s'assure d'abord qu'il existe dans la liste "all"
    print("📝 Étape 2: Vérification de l'existence du deck ID 1 via /all")
    print("-" * 80)

    deck_pk_to_delete = 1

    try:
        response = requests.get(
            f"{API_BASE_URL}/api/users/decks/all",
            headers={"Authorization": f"Bearer {token}"}
        )

        if response.status_code != 200:
            print(f"❌ Erreur lors de la récupération des decks: {response.status_code}")
            return

        all_decks = response.json()
        target_deck = next((d for d in all_decks if d['deck_pk'] == deck_pk_to_delete), None)

        if not target_deck:
            print(f"❌ Le deck ID {deck_pk_to_delete} n'existe pas dans le système.")
            return

        print(f"✅ Deck ID {deck_pk_to_delete} trouvé: {target_deck['deck']['name']}")
        print(f"   User Deck PK: {target_deck['user_deck_pk']} (devrait être None ou 0 si non commencé)")
        print()

    except Exception as e:
        print(f"❌ Erreur: {e}")
        return

    # 3. Tenter de supprimer le deck
    print(f"📝 Étape 3: Tentative de suppression du deck ID {deck_pk_to_delete}")
    print("-" * 80)
    print("   C'est ici que l'erreur 404 se produisait avant le fix.")

    try:
        response = requests.delete(
            f"{API_BASE_URL}/api/users/decks/{deck_pk_to_delete}",
            headers={"Authorization": f"Bearer {token}"}
        )

        print(f"   Status Code: {response.status_code}")
        print(f"   Response: {response.text}")

        if response.status_code == 200:
            print()
            print("✅ SUCCÈS! Le deck a été supprimé sans erreur.")
            print("   Le fix fonctionne correctement.")
        elif response.status_code == 404:
            print()
            print("❌ ÉCHEC! Erreur 404 toujours présente.")
            print("   Le fix ne fonctionne pas.")
        else:
            print()
            print(f"⚠️  RÉSULTAT INATTENDU: {response.status_code}")

    except Exception as e:
        print(f"❌ Erreur lors de l'appel API: {e}")

if __name__ == "__main__":
    test_delete_deck_fix()
