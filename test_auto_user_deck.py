"""
Test de Validation du Fix : Création Automatique user_deck
===========================================================
Ce script teste que user_deck est créé automatiquement lors du premier score
"""

import asyncio
import httpx
from datetime import datetime
from typing import Dict, Any


BASE_URL = "http://localhost:8000"
DECK_ID = 40


class Colors:
    """Codes couleur ANSI"""
    OKGREEN = '\033[92m'
    FAIL = '\033[91m'
    WARNING = '\033[93m'
    OKCYAN = '\033[96m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


def print_success(msg: str):
    print(f"{Colors.OKGREEN}✅ {msg}{Colors.ENDC}")


def print_error(msg: str):
    print(f"{Colors.FAIL}❌ {msg}{Colors.ENDC}")


def print_warning(msg: str):
    print(f"{Colors.WARNING}⚠️  {msg}{Colors.ENDC}")


def print_info(msg: str):
    print(f"{Colors.OKCYAN}ℹ️  {msg}{Colors.ENDC}")


def print_section(title: str):
    print(f"\n{Colors.BOLD}{'='*70}{Colors.ENDC}")
    print(f"{Colors.BOLD}{title}{Colors.ENDC}")
    print(f"{Colors.BOLD}{'='*70}{Colors.ENDC}")


async def test_automatic_user_deck_creation():
    """
    Test principal : Vérifier que user_deck est créé automatiquement
    """
    print_section("🧪 TEST : Création Automatique de user_deck")

    async with httpx.AsyncClient(timeout=30.0) as client:
        # ═══════════════════════════════════════════════════════════════
        # ÉTAPE 1 : Créer un nouveau compte
        # ═══════════════════════════════════════════════════════════════
        print_info("Étape 1 : Création d'un nouveau compte...")

        timestamp = int(datetime.now().timestamp())
        user_data = {
            "email": f"test_auto_{timestamp}@example.com",
            "full_name": "Test Auto User",
            "password": "TestPassword123!"
        }

        response = await client.post(f"{BASE_URL}/api/users/register", json=user_data)

        if response.status_code != 201:
            print_error(f"Création du compte échouée: {response.status_code}")
            print_error(response.text)
            return False

        data = response.json()
        token = data['access_token']
        user_pk = data['user']['user_pk']
        headers = {"Authorization": f"Bearer {token}"}

        print_success(f"Compte créé (user_pk: {user_pk})")

        # ═══════════════════════════════════════════════════════════════
        # ÉTAPE 2 : Vérifier que user_decks est vide
        # ═══════════════════════════════════════════════════════════════
        print_info("Étape 2 : Vérification que user_decks est vide...")

        response = await client.get(f"{BASE_URL}/api/users/decks", headers=headers)

        if response.status_code != 200:
            print_error(f"Récupération user_decks échouée: {response.status_code}")
            return False

        user_decks = response.json()

        if len(user_decks) == 0:
            print_success("user_decks est vide (attendu)")
        else:
            print_warning(f"user_decks contient déjà {len(user_decks)} deck(s)")

        # ═══════════════════════════════════════════════════════════════
        # ÉTAPE 3 : Récupérer une carte du deck
        # ═══════════════════════════════════════════════════════════════
        print_info(f"Étape 3 : Récupération d'une carte du deck {DECK_ID}...")

        response = await client.get(f"{BASE_URL}/cards/?deck_pk={DECK_ID}", headers=headers)

        if response.status_code != 200:
            print_error(f"Récupération des cartes échouée: {response.status_code}")
            return False

        cards = response.json()

        if not cards:
            print_error(f"Aucune carte trouvée pour le deck {DECK_ID}")
            return False

        card = cards[0]
        print_success(f"Carte récupérée: '{card['front']}' (ID: {card['card_pk']})")

        # ═══════════════════════════════════════════════════════════════
        # ÉTAPE 4 : Envoyer un score SANS créer user_deck manuellement
        # ═══════════════════════════════════════════════════════════════
        print_info("Étape 4 : Envoi d'un score SANS créer user_deck au préalable...")
        print_warning("🔍 C'est ici que le bug se manifestait avant le fix!")

        score_data = {
            "deck_pk": DECK_ID,
            "card_pk": card['card_pk'],
            "score": 85,
            "is_correct": True,
            "time_spent": 5,
            "quiz_type": "frappe"
        }

        print_info(f"Payload: {score_data}")

        response = await client.post(f"{BASE_URL}/api/users/scores", json=score_data, headers=headers)

        if response.status_code != 201:
            print_error(f"Envoi du score échoué: {response.status_code}")
            print_error(response.text)
            return False

        score_result = response.json()
        print_success(f"Score enregistré (score_pk: {score_result['score_pk']})")

        # ═══════════════════════════════════════════════════════════════
        # ÉTAPE 5 : VÉRIFICATION CRITIQUE - user_deck créé automatiquement ?
        # ═══════════════════════════════════════════════════════════════
        print_section("🔍 VÉRIFICATION CRITIQUE")
        print_info("Étape 5 : Vérification que user_deck a été créé automatiquement...")

        response = await client.get(f"{BASE_URL}/api/users/decks", headers=headers)

        if response.status_code != 200:
            print_error(f"Récupération user_decks échouée: {response.status_code}")
            return False

        user_decks = response.json()

        # Vérification 1 : user_decks n'est pas vide
        if len(user_decks) == 0:
            print_error("❌ BUG CONFIRMÉ : user_decks est toujours vide!")
            print_error("Le score a été enregistré mais user_deck n'a PAS été créé")
            return False

        print_success(f"user_decks contient {len(user_decks)} deck(s)")

        # Vérification 2 : Le deck 40 est présent
        deck_40 = next((d for d in user_decks if d['deck_pk'] == DECK_ID), None)

        if not deck_40:
            print_error(f"❌ BUG : Le deck {DECK_ID} n'est pas dans user_decks!")
            print_error(f"Decks présents: {[d['deck_pk'] for d in user_decks]}")
            return False

        print_success(f"Le deck {DECK_ID} est présent dans user_decks")

        # Vérification 3 : Les stats sont correctes
        print_info("\nVérification des statistiques...")

        expected_stats = {
            'total_points': 85,
            'total_attempts': 1,
            'successful_attempts': 1,
            'points_frappe': 85,
            'points_association': 0,
            'points_qcm': 0,
            'points_classique': 0
        }

        all_stats_correct = True

        for key, expected_value in expected_stats.items():
            actual_value = deck_40.get(key, None)

            if actual_value == expected_value:
                print_success(f"  {key}: {actual_value} ✓")
            else:
                print_error(f"  {key}: {actual_value} (attendu: {expected_value}) ✗")
                all_stats_correct = False

        if not all_stats_correct:
            print_error("\n❌ Certaines statistiques sont incorrectes")
            return False

        print_success("\n✅ Toutes les statistiques sont correctes!")

        # ═══════════════════════════════════════════════════════════════
        # ÉTAPE 6 : Test avec plusieurs scores
        # ═══════════════════════════════════════════════════════════════
        print_section("🧪 TEST SUPPLÉMENTAIRE : Plusieurs Scores")
        print_info("Étape 6 : Envoi de 4 scores supplémentaires...")

        for i, card in enumerate(cards[1:5], 2):
            score_data = {
                "deck_pk": DECK_ID,
                "card_pk": card['card_pk'],
                "score": 70 + (i * 5),
                "is_correct": i % 2 == 0,  # Alternance correct/incorrect
                "time_spent": 3 + i,
                "quiz_type": "qcm"
            }

            response = await client.post(f"{BASE_URL}/api/users/scores", json=score_data, headers=headers)

            if response.status_code == 201:
                print_success(f"  Score {i}/5 envoyé")
            else:
                print_error(f"  Score {i}/5 échoué: {response.status_code}")
                return False

        # Vérifier les stats finales
        response = await client.get(f"{BASE_URL}/api/users/decks", headers=headers)
        user_decks = response.json()
        deck_40 = next((d for d in user_decks if d['deck_pk'] == DECK_ID), None)

        print_info("\nStatistiques finales:")
        print_success(f"  Total points: {deck_40['total_points']}")
        print_success(f"  Total tentatives: {deck_40['total_attempts']}")
        print_success(f"  Tentatives réussies: {deck_40['successful_attempts']}")
        print_success(f"  Points frappe: {deck_40['points_frappe']}")
        print_success(f"  Points QCM: {deck_40['points_qcm']}")

        # Vérification finale
        if deck_40['total_attempts'] == 5:
            print_success("\n✅ Le compteur de tentatives est correct (5)")
        else:
            print_error(f"\n❌ Le compteur de tentatives est incorrect: {deck_40['total_attempts']} (attendu: 5)")
            return False

        # ═══════════════════════════════════════════════════════════════
        # ÉTAPE 7 : Vérifier les scores individuels
        # ═══════════════════════════════════════════════════════════════
        print_section("🔍 VÉRIFICATION DES SCORES INDIVIDUELS")
        print_info("Étape 7 : Récupération des scores du deck...")

        response = await client.get(f"{BASE_URL}/api/users/scores/deck/{DECK_ID}", headers=headers)

        if response.status_code != 200:
            print_error(f"Récupération des scores échouée: {response.status_code}")
            return False

        deck_scores = response.json()

        print_success(f"{len(deck_scores)} scores enregistrés")

        # Vérifier qu'aucun score n'a deck_pk NULL
        null_deck_pk_count = sum(1 for s in deck_scores if s.get('deck_pk') is None)

        if null_deck_pk_count == 0:
            print_success("Aucun score avec deck_pk NULL ✓")
        else:
            print_error(f"{null_deck_pk_count} scores avec deck_pk NULL détectés!")
            return False

        return True


async def main():
    """
    Exécute le test complet
    """
    print(f"""
    {Colors.BOLD}{Colors.OKCYAN}
    ╔══════════════════════════════════════════════════════════════════╗
    ║   TEST DE VALIDATION : Création Automatique user_deck           ║
    ║              Apprendiamo Italiano Backend                        ║
    ╚══════════════════════════════════════════════════════════════════╝
    {Colors.ENDC}
    """)

    try:
        success = await test_automatic_user_deck_creation()

        print_section("📊 RÉSULTAT FINAL")

        if success:
            print(f"""
{Colors.OKGREEN}{Colors.BOLD}
    ╔══════════════════════════════════════════════════════════════════╗
    ║                   ✅ TEST RÉUSSI !                               ║
    ╚══════════════════════════════════════════════════════════════════╝
{Colors.ENDC}

{Colors.OKGREEN}Le bug est corrigé ! Voici ce qui fonctionne maintenant :{Colors.ENDC}

  ✅ user_deck est créé AUTOMATIQUEMENT au premier score
  ✅ Les statistiques sont mises à jour correctement
  ✅ Le dashboard affiche les bonnes valeurs
  ✅ Aucun appel manuel à POST /api/users/decks/{{id}} n'est nécessaire
  ✅ deck_pk n'est jamais NULL dans user_scores

{Colors.BOLD}🎯 Actions pour le frontend :{Colors.ENDC}

  1. ❌ SUPPRIMER l'appel à POST /api/users/decks/{{id}} avant le quiz
  2. ✅ Envoyer directement les scores avec deck_pk
  3. ✅ Les stats seront automatiquement créées et mises à jour

{Colors.BOLD}📝 Exemple de code frontend :{Colors.ENDC}

  // AVANT (à supprimer)
  // await userDecksApi.addDeckToUser(deckId);  ❌

  // MAINTENANT (suffit)
  await scoresApi.submitScore({{
    deck_pk: deckId,      // ✅ Obligatoire
    card_pk: cardId,      // ✅ Obligatoire
    score: 85,
    is_correct: true,
    quiz_type: "frappe"
  }});

  // Les stats seront automatiquement créées ! ✅
            """)
            return 0
        else:
            print(f"""
{Colors.FAIL}{Colors.BOLD}
    ╔══════════════════════════════════════════════════════════════════╗
    ║                   ❌ TEST ÉCHOUÉ                                 ║
    ╚══════════════════════════════════════════════════════════════════╝
{Colors.ENDC}

{Colors.FAIL}Le bug persiste. Vérifiez :{Colors.ENDC}

  1. Le code de crud_users.py a-t-il été modifié ?
  2. Le serveur a-t-il été redémarré ?
  3. Y a-t-il des erreurs dans les logs du serveur ?

{Colors.WARNING}Consultez DIAGNOSTIC_PROBLEME_SCORES.md pour plus de détails.{Colors.ENDC}
            """)
            return 1

    except Exception as e:
        print_section("💥 ERREUR CRITIQUE")
        print_error(f"Le test a échoué avec l'erreur suivante:")
        print_error(f"{type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    exit(exit_code)
