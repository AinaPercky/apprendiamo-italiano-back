"""
Test pour vérifier que le champ success_rate est bien inclus dans la réponse API
"""

import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def test_success_rate_in_response():
    print("🧪 Test de la présence du champ success_rate dans l'API")
    print("=" * 70)
    
    # 1. Créer un utilisateur de test
    print("\n1️⃣ Création d'un utilisateur...")
    register_data = {
        "email": f"test_sr_{int(__import__('time').time())}@test.com",
        "password": "TestPassword123!",
        "full_name": "Test Success Rate"
    }
    
    response = requests.post(f"{BASE_URL}/api/users/register", json=register_data)
    if response.status_code != 201:
        print(f"❌ Erreur: {response.status_code}")
        return False
    
    user_data = response.json()
    token = user_data.get("access_token")
    user_id = user_data.get("user", {}).get("user_pk")
    print(f"✅ Utilisateur créé: ID={user_id}")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # 2. Récupérer un deck
    print("\n2️⃣ Récupération d'un deck...")
    response = requests.get(f"{BASE_URL}/decks/?limit=1")
    decks = response.json()
    deck_id = decks[0]["deck_pk"]
    print(f"✅ Deck ID: {deck_id}")
    
    # 3. Récupérer une carte
    response = requests.get(f"{BASE_URL}/cards/?deck_pk={deck_id}&limit=1")
    cards = response.json()
    card_id = cards[0]["card_pk"]
    print(f"✅ Carte ID: {card_id}")
    
    # 4. Soumettre 3 scores (2 corrects, 1 incorrect)
    print("\n3️⃣ Soumission de 3 scores...")
    scores_data = [
        {"deck_pk": deck_id, "card_pk": card_id, "score": 100, "is_correct": True, "time_spent": 5, "quiz_type": "classique"},
        {"deck_pk": deck_id, "card_pk": card_id, "score": 100, "is_correct": True, "time_spent": 4, "quiz_type": "classique"},
        {"deck_pk": deck_id, "card_pk": card_id, "score": 0, "is_correct": False, "time_spent": 6, "quiz_type": "classique"},
    ]
    
    for i, score_data in enumerate(scores_data, 1):
        response = requests.post(f"{BASE_URL}/api/users/scores", json=score_data, headers=headers)
        if response.status_code == 201:
            print(f"  ✅ Score {i}/3 créé")
        else:
            print(f"  ❌ Erreur score {i}: {response.status_code}")
            return False
    
    # 5. Récupérer les decks de l'utilisateur et vérifier success_rate
    print("\n4️⃣ Vérification du champ success_rate...")
    response = requests.get(f"{BASE_URL}/api/users/decks", headers=headers)
    
    if response.status_code != 200:
        print(f"❌ Erreur lors de la récupération des decks: {response.status_code}")
        return False
    
    user_decks = response.json()
    
    if not user_decks:
        print("❌ Aucun deck trouvé")
        return False
    
    deck = user_decks[0]
    
    print(f"\n📊 Réponse API pour le deck:")
    print(json.dumps(deck, indent=2, default=str))
    
    # Vérifier la présence de success_rate
    if "success_rate" in deck:
        success_rate = deck["success_rate"]
        expected_rate = round(2/3 * 100, 2)  # 2 corrects sur 3 = 66.67%
        
        print(f"\n✅ Champ 'success_rate' trouvé: {success_rate}%")
        print(f"   Taux attendu: {expected_rate}%")
        
        if abs(success_rate - expected_rate) < 0.1:
            print("✅ Le calcul est correct!")
            return True
        else:
            print(f"⚠️ Le calcul ne correspond pas (attendu: {expected_rate}%, reçu: {success_rate}%)")
            return False
    else:
        print("❌ Champ 'success_rate' ABSENT de la réponse!")
        print(f"\nChamps disponibles: {list(deck.keys())}")
        return False

if __name__ == "__main__":
    try:
        success = test_success_rate_in_response()
        print("\n" + "=" * 70)
        if success:
            print("🎉 TEST RÉUSSI - Le champ success_rate est présent et correct!")
        else:
            print("❌ TEST ÉCHOUÉ - Vérifiez les logs ci-dessus")
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
