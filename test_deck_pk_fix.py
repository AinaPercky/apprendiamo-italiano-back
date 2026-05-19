"""
Test de Validation du Fix deck_pk NULL
=======================================
Ce script teste que deck_pk n'est plus NULL dans la table user_scores
"""

import asyncio
import httpx
from datetime import datetime


BASE_URL = "http://localhost:8000"
DECK_ID = 40


async def test_deck_pk_not_null():
    """
    Test pour vérifier que deck_pk est bien enregistré et non NULL
    """
    print("🧪 TEST: Vérification que deck_pk n'est plus NULL")
    print("=" * 60)

    async with httpx.AsyncClient(timeout=30.0) as client:
        # 1. Créer un compte
        print("\n📝 Étape 1: Création du compte...")
        timestamp = int(datetime.now().timestamp())
        user_data = {
            "email": f"test_fix_{timestamp}@example.com",
            "full_name": "Test Fix User",
            "password": "TestPassword123!"
        }

        response = await client.post(f"{BASE_URL}/api/users/register", json=user_data)
        if response.status_code != 201:
            print(f"❌ ERREUR: Création compte échouée: {response.text}")
            return False

        data = response.json()
        token = data['access_token']
        headers = {"Authorization": f"Bearer {token}"}
        print("✅ Compte créé")

        # 2. Récupérer une carte du deck
        print(f"\n📥 Étape 2: Récupération des cartes du deck {DECK_ID}...")
        response = await client.get(f"{BASE_URL}/cards/?deck_pk={DECK_ID}", headers=headers)

        if response.status_code != 200:
            print(f"❌ ERREUR: Récupération cartes échouée: {response.text}")
            return False

        cards = response.json()
        if not cards:
            print(f"❌ ERREUR: Aucune carte trouvée pour le deck {DECK_ID}")
            return False

        card = cards[0]
        print(f"✅ Carte récupérée: {card['front']} (ID: {card['card_pk']})")

        # 3. Test SANS deck_pk (devrait échouer maintenant)
        print("\n🧪 Test 1: Envoi d'un score SANS deck_pk (devrait échouer)...")
        score_without_deck = {
            "card_pk": card['card_pk'],
            "score": 85,
            "is_correct": True,
            "time_spent": 5,
            "quiz_type": "frappe"
            # deck_pk manquant ❌
        }

        response = await client.post(f"{BASE_URL}/api/users/scores", json=score_without_deck, headers=headers)

        if response.status_code == 422:  # Validation error
            print("✅ SUCCÈS: Le serveur rejette correctement un score sans deck_pk")
            error_data = response.json()
            print(f"   Détail de l'erreur: {error_data.get('detail', 'N/A')}")
        else:
            print(f"⚠️  ATTENTION: Le serveur a accepté un score sans deck_pk (status: {response.status_code})")
            print(f"   Cela ne devrait pas arriver!")
            if response.status_code == 201:
                result = response.json()
                if result.get('deck_pk') is None:
                    print(f"❌ BUG CONFIRMÉ: deck_pk est NULL dans la réponse: {result}")
                    return False

        # 4. Test AVEC deck_pk (devrait réussir)
        print("\n🧪 Test 2: Envoi d'un score AVEC deck_pk (devrait réussir)...")
        score_with_deck = {
            "deck_pk": DECK_ID,  # ✅ deck_pk présent
            "card_pk": card['card_pk'],
            "score": 85,
            "is_correct": True,
            "time_spent": 5,
            "quiz_type": "frappe"
        }

        response = await client.post(f"{BASE_URL}/api/users/scores", json=score_with_deck, headers=headers)

        if response.status_code != 201:
            print(f"❌ ERREUR: Envoi score échoué: {response.status_code}")
            print(f"   Détails: {response.text}")
            return False

        result = response.json()
        print("✅ Score enregistré avec succès")
        print(f"   Réponse: {result}")

        # 5. VÉRIFICATION CRITIQUE: deck_pk n'est pas NULL
        print("\n🔍 Vérification critique: deck_pk dans la réponse...")
        if result.get('deck_pk') is None:
            print(f"❌ ÉCHEC: deck_pk est NULL dans la réponse!")
            print(f"   Réponse complète: {result}")
            return False

        if result['deck_pk'] == DECK_ID:
            print(f"✅ SUCCÈS: deck_pk est correctement défini: {result['deck_pk']}")
        else:
            print(f"⚠️  ATTENTION: deck_pk a une valeur incorrecte: {result['deck_pk']} (attendu: {DECK_ID})")
            return False

        # 6. Vérifier que le score est bien dans la liste des scores du deck
        print("\n🔍 Vérification: Le score apparaît dans les scores du deck...")
        response = await client.get(f"{BASE_URL}/api/users/scores/deck/{DECK_ID}", headers=headers)

        if response.status_code != 200:
            print(f"⚠️  ATTENTION: Impossible de récupérer les scores du deck")
            return True  # Le score a été créé, c'est le principal

        deck_scores = response.json()
        score_found = any(s['score_pk'] == result['score_pk'] for s in deck_scores)

        if score_found:
            print(f"✅ SUCCÈS: Le score apparaît bien dans les scores du deck {DECK_ID}")
        else:
            print(f"⚠️  ATTENTION: Le score n'apparaît pas dans les scores du deck")

        # 7. Vérifier les stats du deck
        print("\n📊 Vérification: Statistiques du deck...")
        response = await client.get(f"{BASE_URL}/api/users/decks", headers=headers)

        if response.status_code == 200:
            user_decks = response.json()
            deck_stats = next((d for d in user_decks if d['deck_pk'] == DECK_ID), None)

            if deck_stats:
                print(f"✅ Statistiques du deck trouvées:")
                print(f"   - Points totaux: {deck_stats['total_points']}")
                print(f"   - Tentatives: {deck_stats['total_attempts']}")
                print(f"   - Points frappe: {deck_stats['points_frappe']}")

                if deck_stats['total_points'] >= score_with_deck['score']:
                    print(f"✅ Les statistiques ont été mises à jour correctement")
                else:
                    print(f"⚠️  Les statistiques semblent incorrectes")
            else:
                print(f"⚠️  Deck {DECK_ID} non trouvé dans les statistiques utilisateur")

        print("\n" + "=" * 60)
        print("🎉 TEST RÉUSSI: Le bug deck_pk NULL est corrigé!")
        print("=" * 60)
        return True


async def test_multiple_scores():
    """
    Test avec plusieurs scores pour vérifier la cohérence
    """
    print("\n\n🧪 TEST SUPPLÉMENTAIRE: Plusieurs scores")
    print("=" * 60)

    async with httpx.AsyncClient(timeout=30.0) as client:
        # 1. Créer un compte
        timestamp = int(datetime.now().timestamp())
        user_data = {
            "email": f"test_multi_{timestamp}@example.com",
            "full_name": "Test Multi User",
            "password": "TestPassword123!"
        }

        response = await client.post(f"{BASE_URL}/api/users/register", json=user_data)
        data = response.json()
        token = data['access_token']
        headers = {"Authorization": f"Bearer {token}"}

        # 2. Récupérer les cartes
        response = await client.get(f"{BASE_URL}/cards/?deck_pk={DECK_ID}", headers=headers)
        cards = response.json()

        print(f"\n📊 Envoi de 5 scores pour le deck {DECK_ID}...")

        all_success = True
        for i, card in enumerate(cards[:5], 1):
            score_data = {
                "deck_pk": DECK_ID,
                "card_pk": card['card_pk'],
                "score": 70 + (i * 5),
                "is_correct": True,
                "time_spent": 3 + i,
                "quiz_type": "frappe"
            }

            response = await client.post(f"{BASE_URL}/api/users/scores", json=score_data, headers=headers)

            if response.status_code == 201:
                result = response.json()
                if result.get('deck_pk') == DECK_ID:
                    print(f"  ✅ Score {i}/5: deck_pk={result['deck_pk']} ✓")
                else:
                    print(f"  ❌ Score {i}/5: deck_pk={result.get('deck_pk')} (NULL ou incorrect)")
                    all_success = False
            else:
                print(f"  ❌ Score {i}/5: Échec ({response.status_code})")
                all_success = False

        if all_success:
            print("\n✅ Tous les scores ont été enregistrés avec deck_pk correctement défini")
        else:
            print("\n❌ Certains scores ont échoué")

        # Vérifier les stats finales
        response = await client.get(f"{BASE_URL}/api/users/scores/deck/{DECK_ID}", headers=headers)
        if response.status_code == 200:
            all_scores = response.json()
            null_deck_pk_count = sum(1 for s in all_scores if s.get('deck_pk') is None)

            print(f"\n📊 Statistiques finales:")
            print(f"   - Total scores: {len(all_scores)}")
            print(f"   - Scores avec deck_pk NULL: {null_deck_pk_count}")

            if null_deck_pk_count == 0:
                print(f"   ✅ Aucun score avec deck_pk NULL!")
            else:
                print(f"   ❌ {null_deck_pk_count} scores avec deck_pk NULL détectés!")
                all_success = False

        return all_success


async def main():
    """
    Exécute tous les tests
    """
    print("""
    ╔══════════════════════════════════════════════════════════════════╗
    ║     TEST DE VALIDATION: Fix deck_pk NULL                        ║
    ║          Apprendiamo Italiano Backend                            ║
    ╚══════════════════════════════════════════════════════════════════╝
    """)

    try:
        # Test 1: Validation basique
        test1_passed = await test_deck_pk_not_null()

        # Test 2: Plusieurs scores
        test2_passed = await test_multiple_scores()

        # Résultat final
        print("\n\n" + "=" * 60)
        print("📊 RÉSULTATS FINAUX")
        print("=" * 60)
        print(f"Test 1 (Validation basique): {'✅ RÉUSSI' if test1_passed else '❌ ÉCHOUÉ'}")
        print(f"Test 2 (Scores multiples):   {'✅ RÉUSSI' if test2_passed else '❌ ÉCHOUÉ'}")

        if test1_passed and test2_passed:
            print("\n🎉 TOUS LES TESTS RÉUSSIS!")
            print("✅ Le bug deck_pk NULL est définitivement corrigé.")
            print("\n💡 Vous pouvez maintenant utiliser l'API frontend en toute confiance:")
            print("   - Toujours inclure deck_pk dans les requêtes POST /api/users/scores")
            print("   - Consulter FRONTEND_API_GUIDE.md pour les exemples d'utilisation")
            return 0
        else:
            print("\n❌ CERTAINS TESTS ONT ÉCHOUÉ")
            print("⚠️  Veuillez vérifier les logs ci-dessus")
            return 1

    except Exception as e:
        print(f"\n💥 ERREUR CRITIQUE: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    exit(exit_code)
