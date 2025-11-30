"""
Script de diagnostic pour vérifier les données envoyées par le backend
pour un utilisateur spécifique
"""

import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def diagnose_user_decks():
    print("🔍 DIAGNOSTIC - Vérification des données backend")
    print("=" * 70)
    
    # Demander les identifiants de l'utilisateur
    print("\nEntrez vos identifiants pour tester:")
    email = input("Email: ").strip()
    password = input("Mot de passe: ").strip()
    
    # 1. Se connecter
    print(f"\n1️⃣ Connexion avec {email}...")
    response = requests.post(
        f"{BASE_URL}/api/users/login",
        json={"email": email, "password": password}
    )
    
    if response.status_code != 200:
        print(f"❌ Erreur de connexion: {response.status_code}")
        print(response.text)
        return
    
    login_data = response.json()
    token = login_data.get("access_token")
    user = login_data.get("user", {})
    user_id = user.get("user_pk")
    
    print(f"✅ Connecté: {user.get('email')} (ID: {user_id})")
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # 2. Récupérer les decks de l'utilisateur
    print(f"\n2️⃣ Récupération des decks de l'utilisateur {user_id}...")
    response = requests.get(f"{BASE_URL}/api/users/decks", headers=headers)
    
    if response.status_code != 200:
        print(f"❌ Erreur: {response.status_code}")
        print(response.text)
        return
    
    user_decks = response.json()
    
    print(f"✅ {len(user_decks)} deck(s) trouvé(s)")
    
    # 3. Afficher les détails de chaque deck
    print("\n" + "=" * 70)
    print("📊 DÉTAILS DES DECKS")
    print("=" * 70)
    
    for i, deck in enumerate(user_decks, 1):
        print(f"\n🎴 DECK {i}: {deck.get('deck', {}).get('name', 'N/A')}")
        print(f"   ID: {deck.get('deck_pk')}")
        print(f"   {'─' * 66}")
        
        # Statistiques
        print(f"   📈 Statistiques:")
        print(f"      • Total tentatives: {deck.get('total_attempts', 0)}")
        print(f"      • Tentatives réussies: {deck.get('successful_attempts', 0)}")
        print(f"      • Total points: {deck.get('total_points', 0)}")
        
        # Vérifier la présence de success_rate
        if "success_rate" in deck:
            success_rate = deck.get("success_rate")
            print(f"      • ✅ SUCCESS_RATE: {success_rate}%")
        else:
            print(f"      • ❌ SUCCESS_RATE: ABSENT!")
        
        # Vérifier la présence de progress
        if "progress" in deck:
            progress = deck.get("progress")
            print(f"      • ✅ PROGRESS: {progress}%")
        else:
            print(f"      • ❌ PROGRESS: ABSENT!")
        
        # Cartes Anki
        print(f"\n   🎯 Cartes Anki:")
        print(f"      • Maîtrisées: {deck.get('mastered_cards', 0)}")
        print(f"      • En apprentissage: {deck.get('learning_cards', 0)}")
        print(f"      • À revoir: {deck.get('review_cards', 0)}")
        
        # Points par type de quiz
        print(f"\n   🎮 Points par type:")
        print(f"      • Frappe: {deck.get('points_frappe', 0)}")
        print(f"      • Association: {deck.get('points_association', 0)}")
        print(f"      • QCM: {deck.get('points_qcm', 0)}")
        print(f"      • Classique: {deck.get('points_classique', 0)}")
    
    # 4. Afficher la réponse JSON brute
    print("\n" + "=" * 70)
    print("📄 RÉPONSE JSON BRUTE (pour le frontend)")
    print("=" * 70)
    print(json.dumps(user_decks, indent=2, default=str))
    
    # 5. Résumé
    print("\n" + "=" * 70)
    print("📋 RÉSUMÉ DU DIAGNOSTIC")
    print("=" * 70)
    
    has_success_rate = all("success_rate" in deck for deck in user_decks)
    has_progress = all("progress" in deck for deck in user_decks)
    
    if has_success_rate and has_progress:
        print("✅ Tous les decks contiennent 'success_rate' et 'progress'")
        print("✅ Le backend fonctionne correctement!")
        print("\n⚠️ Si le frontend n'affiche pas ces valeurs, le problème vient du frontend.")
        print("   Vérifiez:")
        print("   1. Le code TypeScript qui lit 'success_rate'")
        print("   2. Le cache du navigateur (Ctrl+Shift+R pour hard refresh)")
        print("   3. Les interfaces TypeScript (UserDeck doit avoir success_rate)")
    else:
        print("❌ Certains decks ne contiennent pas tous les champs calculés")
        print("   Le problème vient du backend")
        
        if not has_success_rate:
            print("   ❌ 'success_rate' manquant")
        if not has_progress:
            print("   ❌ 'progress' manquant")

if __name__ == "__main__":
    try:
        diagnose_user_decks()
    except KeyboardInterrupt:
        print("\n\n⚠️ Diagnostic interrompu par l'utilisateur")
    except Exception as e:
        print(f"\n❌ ERREUR: {e}")
        import traceback
        traceback.print_exc()
