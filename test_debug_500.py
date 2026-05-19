"""
Test Simplifié - Debug de l'erreur 500
"""

import requests
import json
from datetime import datetime

API_BASE_URL = "http://127.0.0.1:8000"

def test_simple():
    print("=" * 80)
    print("🧪 TEST SIMPLIFIÉ - Debug Erreur 500")
    print("=" * 80)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    # 1. Créer un utilisateur
    print("\n1. Création utilisateur...")
    response = requests.post(
        f"{API_BASE_URL}/api/users/register",
        json={
            "email": f"debug_{timestamp}@test.com",
            "full_name": "Debug User",
            "password": "Debug123!"
        }
    )

    if response.status_code != 201:
        print(f"❌ Erreur création: {response.status_code}")
        print(response.text)
        return

    data = response.json()
    token = data["access_token"]
    user_pk = data["user"]["user_pk"]
    print(f"✅ Utilisateur créé (PK: {user_pk})")

    # 2. Récupérer les decks AVANT quiz
    print("\n2. Récupération decks AVANT quiz...")
    response = requests.get(
        f"{API_BASE_URL}/api/users/decks/all",
        headers={"Authorization": f"Bearer {token}"}
    )

    if response.status_code != 200:
        print(f"❌ Erreur: {response.status_code}")
        print(response.text)
        return

    decks_before = response.json()
    print(f"✅ {len(decks_before)} decks récupérés")

    # 3. Trouver un deck avec des cartes
    print("\n3. Recherche d'un deck avec cartes...")
    deck_with_cards = None

    for deck in decks_before[:10]:  # Tester les 10 premiers
        response = requests.get(
            f"{API_BASE_URL}/cards/?deck_pk={deck['deck_pk']}&limit=1",
            headers={"Authorization": f"Bearer {token}"}
        )

        if response.status_code == 200:
            cards = response.json()
            if len(cards) > 0:
                deck_with_cards = deck
                card = cards[0]
                print(f"✅ Deck trouvé: {deck['deck']['name']} (ID: {deck['deck_pk']})")
                print(f"   Carte: {card['front']} (ID: {card['card_pk']})")
                break

    if not deck_with_cards:
        print("❌ Aucun deck avec cartes trouvé")
        return

    # 4. Soumettre UN score
    print("\n4. Soumission d'un score...")
    response = requests.post(
        f"{API_BASE_URL}/api/users/scores",
        json={
            "deck_pk": deck_with_cards['deck_pk'],
            "card_pk": card['card_pk'],
            "score": 85,
            "is_correct": True,
            "time_spent": 5,
            "quiz_type": "classique"
        },
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
    )

    if response.status_code != 201:
        print(f"❌ Erreur soumission score: {response.status_code}")
        print(response.text)
        return

    print("✅ Score soumis avec succès")

    # 5. Récupérer les decks APRÈS quiz
    print("\n5. Récupération decks APRÈS quiz...")
    response = requests.get(
        f"{API_BASE_URL}/api/users/decks/all",
        headers={"Authorization": f"Bearer {token}"}
    )

    if response.status_code != 200:
        print(f"❌ ERREUR 500: {response.status_code}")
        print(f"Réponse: {response.text}")
        print("\n⚠️  C'est ici que le problème se produit!")
        print("   Le serveur rencontre une erreur lors de la récupération des decks")
        print("   après qu'un score ait été soumis.")
        return

    decks_after = response.json()
    print(f"✅ {len(decks_after)} decks récupérés")

    # 6. Vérifier les stats
    print("\n6. Vérification des stats...")
    deck_updated = next((d for d in decks_after if d['deck_pk'] == deck_with_cards['deck_pk']), None)

    if deck_updated:
        print(f"✅ Deck mis à jour trouvé:")
        print(f"   Nom: {deck_updated['deck']['name']}")
        print(f"   Tentatives: {deck_updated['total_attempts']}")
        print(f"   Précision: {deck_updated['success_rate']}%")
        print(f"   Points: {deck_updated['total_points']}")
    else:
        print("❌ Deck mis à jour non trouvé")

    print("\n" + "=" * 80)
    print("✅ TEST TERMINÉ AVEC SUCCÈS")
    print("=" * 80)

if __name__ == "__main__":
    try:
        test_simple()
    except Exception as e:
        print(f"\n❌ Exception: {e}")
        import traceback
        traceback.print_exc()
