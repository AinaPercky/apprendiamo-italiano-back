"""
Test Rapide : Vérifier que la Correction Fonctionne pour Votre Compte
======================================================================
Ce script teste rapidement avec votre compte existant
"""

import asyncio
import httpx
import sys


BASE_URL = "http://localhost:8000"
DECK_ID = 40


async def quick_test(email: str, password: str):
    """
    Test rapide avec un compte existant
    """
    print("=" * 70)
    print("🧪 TEST RAPIDE DE LA CORRECTION")
    print("=" * 70)
    
    async with httpx.AsyncClient(timeout=30.0) as client:
        # 1. Connexion
        print(f"\n1️⃣ Connexion...")
        
        response = await client.post(
            f"{BASE_URL}/api/users/login",
            json={"email": email, "password": password}
        )
        
        if response.status_code != 200:
            print(f"❌ Échec de connexion: {response.status_code}")
            return False
        
        data = response.json()
        token = data['access_token']
        user_pk = data['user']['user_pk']
        headers = {"Authorization": f"Bearer {token}"}
        
        print(f"✅ Connecté (user_pk: {user_pk})")
        
        # 2. Récupérer une carte
        print(f"\n2️⃣ Récupération d'une carte du deck {DECK_ID}...")
        
        response = await client.get(f"{BASE_URL}/cards/?deck_pk={DECK_ID}", headers=headers)
        
        if response.status_code != 200:
            print(f"❌ Erreur: {response.status_code}")
            return False
        
        cards = response.json()
        if not cards:
            print(f"❌ Aucune carte trouvée")
            return False
        
        card = cards[0]
        print(f"✅ Carte: '{card['front']}' (ID: {card['card_pk']})")
        
        # 3. Vérifier l'état AVANT
        print(f"\n3️⃣ État AVANT le score...")
        
        response = await client.get(f"{BASE_URL}/api/users/decks", headers=headers)
        decks_before = response.json() if response.status_code == 200 else []
        deck_before = next((d for d in decks_before if d['deck_pk'] == DECK_ID), None)
        
        if deck_before:
            print(f"   Deck {DECK_ID} existe déjà:")
            print(f"   - Points: {deck_before['total_points']}")
            print(f"   - Tentatives: {deck_before['total_attempts']}")
            attempts_before = deck_before['total_attempts']
            points_before = deck_before['total_points']
        else:
            print(f"   Deck {DECK_ID} n'existe pas encore (sera créé)")
            attempts_before = 0
            points_before = 0
        
        # 4. Envoyer un score
        print(f"\n4️⃣ Envoi d'un score de test...")
        
        score_data = {
            "deck_pk": DECK_ID,
            "card_pk": card['card_pk'],
            "score": 95,
            "is_correct": True,
            "time_spent": 3,
            "quiz_type": "frappe"
        }
        
        print(f"   Payload: {score_data}")
        
        response = await client.post(
            f"{BASE_URL}/api/users/scores",
            json=score_data,
            headers=headers
        )
        
        if response.status_code != 201:
            print(f"❌ Échec: {response.status_code}")
            print(f"   Détails: {response.text}")
            return False
        
        score_result = response.json()
        print(f"✅ Score enregistré (score_pk: {score_result['score_pk']})")
        
        # Vérifier deck_pk dans la réponse
        if score_result.get('deck_pk') is None:
            print(f"   ⚠️  ATTENTION: deck_pk est NULL dans la réponse!")
        else:
            print(f"   ✅ deck_pk dans la réponse: {score_result['deck_pk']}")
        
        # 5. Vérifier l'état APRÈS
        print(f"\n5️⃣ État APRÈS le score...")
        
        await asyncio.sleep(0.5)  # Petit délai pour la mise à jour
        
        response = await client.get(f"{BASE_URL}/api/users/decks", headers=headers)
        
        if response.status_code != 200:
            print(f"❌ Erreur: {response.status_code}")
            return False
        
        decks_after = response.json()
        deck_after = next((d for d in decks_after if d['deck_pk'] == DECK_ID), None)
        
        if not deck_after:
            print(f"❌ PROBLÈME: Le deck {DECK_ID} n'apparaît toujours pas!")
            print(f"   La correction ne fonctionne pas.")
            return False
        
        print(f"✅ Deck {DECK_ID} trouvé:")
        print(f"   - Points: {deck_after['total_points']} (avant: {points_before})")
        print(f"   - Tentatives: {deck_after['total_attempts']} (avant: {attempts_before})")
        
        # 6. Validation
        print(f"\n6️⃣ Validation...")
        
        expected_attempts = attempts_before + 1
        expected_points = points_before + 95
        
        success = True
        
        if deck_after['total_attempts'] == expected_attempts:
            print(f"✅ Tentatives correctes: {deck_after['total_attempts']}")
        else:
            print(f"❌ Tentatives incorrectes: {deck_after['total_attempts']} (attendu: {expected_attempts})")
            success = False
        
        if deck_after['total_points'] == expected_points:
            print(f"✅ Points corrects: {deck_after['total_points']}")
        else:
            print(f"❌ Points incorrects: {deck_after['total_points']} (attendu: {expected_points})")
            success = False
        
        print("\n" + "=" * 70)
        if success:
            print("🎉 SUCCÈS: La correction fonctionne parfaitement!")
            print("=" * 70)
            print("\n✅ Vos quiz seront maintenant enregistrés correctement.")
            print("✅ Le dashboard affichera les bonnes statistiques.")
        else:
            print("⚠️  ATTENTION: Il y a encore un problème")
            print("=" * 70)
        
        return success


async def main():
    """
    Point d'entrée
    """
    print("""
    ╔══════════════════════════════════════════════════════════════════╗
    ║              TEST RAPIDE DE LA CORRECTION                        ║
    ║              Apprendiamo Italiano Backend                        ║
    ╚══════════════════════════════════════════════════════════════════╝
    """)
    
    if len(sys.argv) > 1:
        email = sys.argv[1]
        password = input(f"Mot de passe pour {email}: ").strip()
    else:
        email = input("Email: ").strip()
        password = input("Mot de passe: ").strip()
    
    if not email or not password:
        print("❌ Email et mot de passe requis")
        return
    
    success = await quick_test(email, password)
    
    if not success:
        print("\n💡 Suggestions:")
        print("1. Vérifiez que le serveur a bien été redémarré")
        print("2. Vérifiez les logs du serveur pour des erreurs")
        print("3. Exécutez: python diagnose_user.py")


if __name__ == "__main__":
    asyncio.run(main())
