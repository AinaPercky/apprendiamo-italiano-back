"""
Script de Diagnostic : Vérifier l'État Actuel de Votre Base de Données
=======================================================================
Ce script vérifie l'état de vos données pour comprendre le problème
"""

import asyncio
import httpx
from datetime import datetime


BASE_URL = "http://localhost:8000"


async def diagnose_user_data(email: str, password: str):
    """
    Diagnostique les données d'un utilisateur existant
    """
    print("=" * 70)
    print("🔍 DIAGNOSTIC DES DONNÉES UTILISATEUR")
    print("=" * 70)
    
    async with httpx.AsyncClient(timeout=30.0) as client:
        # 1. Se connecter
        print(f"\n1️⃣ Connexion avec {email}...")
        
        try:
            response = await client.post(
                f"{BASE_URL}/api/users/login",
                json={"email": email, "password": password}
            )
            
            if response.status_code != 200:
                print(f"❌ Échec de connexion: {response.status_code}")
                print(f"   Détails: {response.text}")
                return
            
            data = response.json()
            token = data['access_token']
            user = data['user']
            headers = {"Authorization": f"Bearer {token}"}
            
            print(f"✅ Connecté avec succès")
            print(f"   User PK: {user['user_pk']}")
            print(f"   Email: {user['email']}")
            print(f"   Nom: {user['full_name']}")
            
        except Exception as e:
            print(f"❌ Erreur de connexion: {e}")
            return
        
        # 2. Vérifier les scores enregistrés
        print(f"\n2️⃣ Vérification des scores enregistrés...")
        
        try:
            response = await client.get(
                f"{BASE_URL}/api/users/scores?limit=100",
                headers=headers
            )
            
            if response.status_code == 200:
                scores = response.json()
                print(f"✅ {len(scores)} scores trouvés")
                
                if len(scores) > 0:
                    print(f"\n   Détails des 5 derniers scores:")
                    for i, score in enumerate(scores[:5], 1):
                        deck_pk_status = "✅" if score.get('deck_pk') else "❌ NULL"
                        print(f"   {i}. Score PK: {score['score_pk']}")
                        print(f"      - deck_pk: {score.get('deck_pk')} {deck_pk_status}")
                        print(f"      - card_pk: {score.get('card_pk')}")
                        print(f"      - score: {score['score']}")
                        print(f"      - is_correct: {score['is_correct']}")
                        print(f"      - quiz_type: {score.get('quiz_type', 'N/A')}")
                        print(f"      - created_at: {score['created_at']}")
                    
                    # Vérifier les deck_pk NULL
                    null_count = sum(1 for s in scores if s.get('deck_pk') is None)
                    if null_count > 0:
                        print(f"\n   ⚠️  ATTENTION: {null_count} scores avec deck_pk NULL détectés!")
                        print(f"   Ces scores ont été créés AVANT la correction du bug.")
                    else:
                        print(f"\n   ✅ Aucun score avec deck_pk NULL")
                else:
                    print(f"   ℹ️  Aucun score enregistré")
            else:
                print(f"❌ Erreur récupération scores: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Erreur: {e}")
        
        # 3. Vérifier les user_decks
        print(f"\n3️⃣ Vérification des user_decks (statistiques)...")
        
        try:
            response = await client.get(
                f"{BASE_URL}/api/users/decks",
                headers=headers
            )
            
            if response.status_code == 200:
                user_decks = response.json()
                print(f"✅ {len(user_decks)} deck(s) dans la collection")
                
                if len(user_decks) > 0:
                    print(f"\n   Détails des decks:")
                    for deck in user_decks:
                        print(f"\n   📚 Deck {deck['deck_pk']}: {deck['deck']['name']}")
                        print(f"      - Total points: {deck['total_points']}")
                        print(f"      - Total tentatives: {deck['total_attempts']}")
                        print(f"      - Tentatives réussies: {deck['successful_attempts']}")
                        print(f"      - Points frappe: {deck['points_frappe']}")
                        print(f"      - Points association: {deck['points_association']}")
                        print(f"      - Points QCM: {deck['points_qcm']}")
                        print(f"      - Points classique: {deck['points_classique']}")
                        print(f"      - Cartes maîtrisées: {deck['mastered_cards']}")
                        print(f"      - Cartes en apprentissage: {deck['learning_cards']}")
                        print(f"      - Dernière étude: {deck.get('last_studied', 'N/A')}")
                else:
                    print(f"\n   ⚠️  PROBLÈME: Aucun deck dans la collection!")
                    print(f"   Cela signifie que:")
                    print(f"   - Soit vous n'avez jamais fait de quiz")
                    print(f"   - Soit les scores ont été créés AVANT la correction")
            else:
                print(f"❌ Erreur récupération user_decks: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Erreur: {e}")
        
        # 4. Analyse et recommandations
        print(f"\n4️⃣ Analyse et Recommandations")
        print("=" * 70)
        
        # Récupérer à nouveau pour l'analyse
        scores_response = await client.get(f"{BASE_URL}/api/users/scores?limit=100", headers=headers)
        decks_response = await client.get(f"{BASE_URL}/api/users/decks", headers=headers)
        
        scores = scores_response.json() if scores_response.status_code == 200 else []
        user_decks = decks_response.json() if decks_response.status_code == 200 else []
        
        if len(scores) == 0 and len(user_decks) == 0:
            print("\n✅ SITUATION: Compte vierge")
            print("   Recommandation: Faites un nouveau quiz, tout devrait fonctionner!")
            
        elif len(scores) > 0 and len(user_decks) == 0:
            print("\n⚠️  SITUATION: Scores sans user_decks")
            print("   Cause: Les scores ont été créés AVANT la correction du bug")
            print("   Recommandation:")
            print("   1. Faites un NOUVEAU quiz sur n'importe quel deck")
            print("   2. Les stats seront créées automatiquement pour ce nouveau quiz")
            print("   3. Les anciens scores resteront dans l'historique mais sans stats")
            
        elif len(scores) > 0 and len(user_decks) > 0:
            print("\n✅ SITUATION: Tout fonctionne!")
            print("   Vos données sont correctement enregistrées.")
            
            # Vérifier la cohérence
            null_scores = sum(1 for s in scores if s.get('deck_pk') is None)
            if null_scores > 0:
                print(f"\n   ℹ️  Note: {null_scores} anciens scores avec deck_pk NULL")
                print(f"   Ces scores ont été créés avant la correction.")
                print(f"   Les nouveaux scores auront deck_pk correctement défini.")
        
        # 5. Test rapide
        print(f"\n5️⃣ Test Rapide (Optionnel)")
        print("=" * 70)
        print("Voulez-vous faire un test rapide avec une carte du deck 40?")
        print("Cela permettra de vérifier que la correction fonctionne.")
        print("\nPour faire le test, exécutez:")
        print(f"  python test_quick_score.py {email}")


async def main():
    """
    Point d'entrée principal
    """
    print("""
    ╔══════════════════════════════════════════════════════════════════╗
    ║         DIAGNOSTIC DES DONNÉES UTILISATEUR                       ║
    ║              Apprendiamo Italiano Backend                        ║
    ╚══════════════════════════════════════════════════════════════════╝
    """)
    
    # Demander les identifiants
    print("Entrez vos identifiants pour diagnostiquer votre compte:")
    print("(Ou appuyez sur Entrée pour utiliser un compte de test)\n")
    
    email = input("Email: ").strip()
    
    if not email:
        # Utiliser un compte de test
        print("\nUtilisation d'un compte de test...")
        email = "test@example.com"
        password = "Test123!"
        
        # Créer le compte de test
        async with httpx.AsyncClient(timeout=30.0) as client:
            timestamp = int(datetime.now().timestamp())
            test_email = f"diagnostic_{timestamp}@example.com"
            
            response = await client.post(
                f"{BASE_URL}/api/users/register",
                json={
                    "email": test_email,
                    "full_name": "Diagnostic User",
                    "password": "Test123!"
                }
            )
            
            if response.status_code == 201:
                email = test_email
                password = "Test123!"
                print(f"✅ Compte de test créé: {email}")
            else:
                print(f"❌ Impossible de créer un compte de test")
                return
    else:
        password = input("Mot de passe: ").strip()
    
    await diagnose_user_data(email, password)


if __name__ == "__main__":
    asyncio.run(main())
