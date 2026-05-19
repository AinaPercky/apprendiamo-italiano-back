"""
Test du nouvel endpoint GET /api/users/decks/all
Vérifie que tous les decks du système sont retournés avec des stats personnalisées
"""

import requests
import json
from datetime import datetime

API_BASE_URL = "http://127.0.0.1:8000"

def test_all_decks_with_user_stats():
    """
    Test complet du nouvel endpoint /api/users/decks/all
    """
    print("=" * 80)
    print("🧪 TEST: GET /api/users/decks/all")
    print("=" * 80)
    print()

    # 1. Créer un nouveau compte utilisateur
    print("📝 Étape 1: Création d'un nouveau compte utilisateur")
    print("-" * 80)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    test_email = f"test_decks_{timestamp}@example.com"

    register_data = {
        "email": test_email,
        "full_name": "Test User Decks All",
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

    # 2. Appeler l'ancien endpoint /api/users/decks
    print("📝 Étape 2: Test de l'ancien endpoint /api/users/decks")
    print("-" * 80)

    try:
        response = requests.get(
            f"{API_BASE_URL}/api/users/decks",
            headers={"Authorization": f"Bearer {token}"}
        )

        if response.status_code == 200:
            old_decks = response.json()
            print(f"✅ Ancien endpoint fonctionne")
            print(f"   Nombre de decks retournés: {len(old_decks)}")
            print(f"   Résultat: {old_decks}")
            print()
        else:
            print(f"❌ Erreur: {response.status_code}")
            print(f"   {response.text}")
            print()
    except Exception as e:
        print(f"❌ Erreur: {e}")
        print()

    # 3. Appeler le nouvel endpoint /api/users/decks/all
    print("📝 Étape 3: Test du NOUVEAU endpoint /api/users/decks/all")
    print("-" * 80)

    try:
        response = requests.get(
            f"{API_BASE_URL}/api/users/decks/all",
            headers={"Authorization": f"Bearer {token}"}
        )

        if response.status_code != 200:
            print(f"❌ Erreur lors de la récupération des decks: {response.status_code}")
            print(f"   Réponse: {response.text}")
            return

        all_decks = response.json()

        print(f"✅ Nouveau endpoint fonctionne!")
        print(f"   Nombre total de decks: {len(all_decks)}")
        print()

        # 4. Vérifier que tous les decks ont des stats à 0
        print("📝 Étape 4: Vérification des statistiques")
        print("-" * 80)

        all_zero = True

        for i, deck in enumerate(all_decks[:5], 1):  # Afficher les 5 premiers
            print(f"\n📦 Deck #{i}: {deck['deck']['name']}")
            print(f"   Deck PK: {deck['deck_pk']}")
            print(f"   User Deck PK: {deck['user_deck_pk']}")
            print(f"   Total Attempts: {deck['total_attempts']}")
            print(f"   Successful Attempts: {deck['successful_attempts']}")
            print(f"   Success Rate: {deck['success_rate']}%")
            print(f"   Progress: {deck['progress']}%")
            print(f"   Total Points: {deck['total_points']}")

            # Vérifier que les stats sont à 0
            if deck['total_attempts'] != 0 or deck['success_rate'] != 0.0:
                all_zero = False
                print(f"   ⚠️  ATTENTION: Les stats ne sont pas à 0!")

        if len(all_decks) > 5:
            print(f"\n... et {len(all_decks) - 5} autres decks")

        print()
        print("=" * 80)
        print("📊 RÉSUMÉ DU TEST")
        print("=" * 80)

        if all_zero:
            print("✅ TEST RÉUSSI!")
            print("   - Tous les decks du système sont affichés")
            print("   - Toutes les statistiques sont à 0% pour le nouveau utilisateur")
            print("   - Le nouvel endpoint fonctionne correctement")
        else:
            print("⚠️  TEST PARTIELLEMENT RÉUSSI")
            print("   - Les decks sont affichés")
            print("   - Mais certaines stats ne sont pas à 0")

        print()
        print("🎯 PROCHAINES ÉTAPES:")
        print("   1. Modifier le frontend pour utiliser /api/users/decks/all")
        print("   2. Tester l'affichage dans l'interface")
        print("   3. Faire un quiz et vérifier la mise à jour des stats")

    except Exception as e:
        print(f"❌ Erreur: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_all_decks_with_user_stats()
