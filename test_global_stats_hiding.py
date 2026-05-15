"""
Test de vérification du masquage des stats globales
"""

import requests
import json
from datetime import datetime
import time

API_BASE_URL = "http://127.0.0.1:8000"

def test_global_stats_hiding():
    print("=" * 80)
    print("🧪 TEST: Masquage des stats globales")
    print("=" * 80)
    
    # 1. Créer un utilisateur pour générer des stats globales
    print("\n1. Génération de stats globales...")
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Créer User 1
    resp1 = requests.post(f"{API_BASE_URL}/api/users/register", json={
        "email": f"user1_{timestamp}@test.com", "full_name": "User One", "password": "Password123!"
    })
    token1 = resp1.json()["access_token"]
    
    # Trouver un deck
    decks = requests.get(f"{API_BASE_URL}/api/users/decks/all", headers={"Authorization": f"Bearer {token1}"}).json()
    target_deck = decks[0]
    deck_pk = target_deck["deck_pk"]
    
    print(f"   Cible: Deck {target_deck['deck']['name']} (ID: {deck_pk})")
    
    # Faire un quiz pour augmenter les stats globales
    # Note: Le backend met à jour les stats globales du deck lors de la soumission d'un score
    # Il faut trouver une carte
    cards = requests.get(f"{API_BASE_URL}/cards/?deck_pk={deck_pk}&limit=1", headers={"Authorization": f"Bearer {token1}"}).json()
    if not cards:
        print("❌ Pas de cartes dans ce deck")
        return

    card_pk = cards[0]["card_pk"]
    
    # Soumettre plusieurs scores
    for _ in range(5):
        requests.post(f"{API_BASE_URL}/api/users/scores", json={
            "deck_pk": deck_pk, "card_pk": card_pk, "score": 100, 
            "is_correct": True, "time_spent": 5, "quiz_type": "classique"
        }, headers={"Authorization": f"Bearer {token1}"})
        
    print("   Stats globales générées (5 succès)")
    
    # 2. Créer un NOUVEL utilisateur
    print("\n2. Création d'un nouvel utilisateur...")
    resp2 = requests.post(f"{API_BASE_URL}/api/users/register", json={
        "email": f"newuser_{timestamp}@test.com", "full_name": "New User", "password": "Password123!"
    })
    token2 = resp2.json()["access_token"]
    
    # 3. Vérifier les stats vues par le nouvel utilisateur
    print("\n3. Vérification des stats...")
    response = requests.get(f"{API_BASE_URL}/api/users/decks/all", headers={"Authorization": f"Bearer {token2}"})
    
    my_decks = response.json()
    my_target_deck = next(d for d in my_decks if d["deck_pk"] == deck_pk)
    
    print("\n🔍 Analyse de la réponse JSON :")
    print(json.dumps(my_target_deck, indent=2))
    
    # Vérifications
    deck_obj = my_target_deck["deck"]
    
    global_correct = deck_obj.get("total_correct", -1)
    global_attempts = deck_obj.get("total_attempts", -1)
    
    print(f"\n   Stats dans l'objet 'deck' (Globales masquées ?) :")
    print(f"   - total_correct: {global_correct}")
    print(f"   - total_attempts: {global_attempts}")
    
    user_correct = my_target_deck.get("successful_attempts", -1)
    user_attempts = my_target_deck.get("total_attempts", -1)
    user_rate = my_target_deck.get("success_rate", -1)
    
    print(f"\n   Stats utilisateur (Racine) :")
    print(f"   - successful_attempts: {user_correct}")
    print(f"   - total_attempts: {user_attempts}")
    print(f"   - success_rate: {user_rate}%")
    
    if global_correct == 0 and global_attempts == 0:
        print("\n✅ SUCCÈS : Les stats globales sont bien masquées (0) !")
    else:
        print(f"\n❌ ÉCHEC : Les stats globales sont visibles ({global_correct}/{global_attempts})")
        print("   Le frontend risque d'afficher ces valeurs incorrectes.")

if __name__ == "__main__":
    try:
        test_global_stats_hiding()
    except Exception as e:
        print(f"❌ Erreur: {e}")
