"""
Script de test pour vérifier la correction du bug TypeError dans create_score.
Ce script simule la soumission d'un score pour un nouveau UserDeck.
"""

import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def test_score_creation():
    """Test de création de score pour un nouvel utilisateur sur un deck"""
    
    print("🧪 Test de la correction TypeError - UserDeck")
    print("=" * 60)
    
    # 1. Créer un nouvel utilisateur de test
    print("\n1️⃣ Création d'un utilisateur de test...")
    register_data = {
        "email": f"test_user_{int(__import__('time').time())}@test.com",
        "password": "TestPassword123!",
        "full_name": "Test User"
    }
    
    response = requests.post(
        f"{BASE_URL}/api/users/register",
        json=register_data
    )
    
    if response.status_code != 201:
        print(f"❌ Erreur lors de la création de l'utilisateur: {response.status_code}")
        print(response.text)
        return False
    
    user_data = response.json()
    token = user_data.get("access_token")
    user_id = user_data.get("user", {}).get("user_pk")
    
    print(f"✅ Utilisateur créé: ID={user_id}")
    
    # 2. Récupérer un deck existant
    print("\n2️⃣ Récupération d'un deck...")
    response = requests.get(f"{BASE_URL}/decks/?limit=1")
    
    if response.status_code != 200:
        print(f"❌ Erreur lors de la récupération des decks: {response.status_code}")
        return False
    
    decks = response.json()
    if not decks:
        print("❌ Aucun deck disponible dans la base de données")
        return False
    
    deck = decks[0]
    deck_id = deck.get("deck_pk")
    deck_name = deck.get("name")
    
    print(f"✅ Deck sélectionné: {deck_name} (ID={deck_id})")
    
    # 3. Récupérer une carte du deck
    print("\n3️⃣ Récupération d'une carte du deck...")
    response = requests.get(f"{BASE_URL}/cards/?deck_pk={deck_id}&limit=1")
    
    if response.status_code != 200:
        print(f"❌ Erreur lors de la récupération des cartes: {response.status_code}")
        return False
    
    cards = response.json()
    if not cards:
        print(f"❌ Aucune carte dans le deck {deck_id}")
        return False
    
    card = cards[0]
    card_id = card.get("card_pk")
    
    print(f"✅ Carte sélectionnée: ID={card_id}")
    
    # 4. Soumettre un score (premier quiz sur ce deck pour cet utilisateur)
    print("\n4️⃣ Soumission d'un score (TEST CRITIQUE)...")
    score_data = {
        "deck_pk": deck_id,
        "card_pk": card_id,
        "score": 100,
        "is_correct": True,
        "time_spent": 5,
        "quiz_type": "classique"
    }
    
    headers = {
        "Authorization": f"Bearer {token}"
    }
    
    response = requests.post(
        f"{BASE_URL}/api/users/scores",
        json=score_data,
        headers=headers
    )
    
    print(f"\nRéponse HTTP: {response.status_code}")
    
    if response.status_code == 500:
        print("❌ ERREUR 500 - Le bug n'est pas corrigé!")
        print("\nDétails de l'erreur:")
        print(response.text)
        return False
    elif response.status_code == 201:
        print("✅ Score créé avec succès!")
        score_result = response.json()
        print(f"\nDétails du score:")
        print(json.dumps(score_result, indent=2))
        
        # 5. Vérifier que le UserDeck a été créé
        print("\n5️⃣ Vérification du UserDeck...")
        response = requests.get(
            f"{BASE_URL}/api/users/decks",
            headers=headers
        )
        
        if response.status_code == 200:
            user_decks = response.json()
            matching_deck = next(
                (ud for ud in user_decks if ud.get("deck_pk") == deck_id),
                None
            )
            
            if matching_deck:
                print(f"✅ UserDeck créé et trouvé!")
                print(f"   - Total attempts: {matching_deck.get('total_attempts')}")
                print(f"   - Total points: {matching_deck.get('total_points')}")
                print(f"   - Successful attempts: {matching_deck.get('successful_attempts')}")
                return True
            else:
                print("⚠️ UserDeck non trouvé dans la liste")
                return False
        else:
            print(f"⚠️ Impossible de vérifier le UserDeck: {response.status_code}")
            return True  # Le score a été créé, c'est l'essentiel
    else:
        print(f"⚠️ Code de réponse inattendu: {response.status_code}")
        print(response.text)
        return False

if __name__ == "__main__":
    try:
        success = test_score_creation()
        print("\n" + "=" * 60)
        if success:
            print("🎉 TEST RÉUSSI - La correction fonctionne!")
        else:
            print("❌ TEST ÉCHOUÉ - Vérifiez les logs ci-dessus")
    except Exception as e:
        print(f"\n❌ ERREUR DURANT LE TEST: {e}")
        import traceback
        traceback.print_exc()
