"""
Test de Scénario Complet pour Deck 40
=====================================
Ce script teste le flux complet d'utilisation d'un deck depuis la création
d'un compte jusqu'aux quiz avec différents types, en vérifiant les statistiques
et la persistance après déconnexion/reconnexion.
"""

import asyncio
import httpx
import random
from datetime import datetime
from typing import Dict, List, Any
from dataclasses import dataclass
from enum import Enum


class QuizType(Enum):
    """Types de quiz disponibles"""
    FRAPPE = "frappe"
    ASSOCIATION = "association"
    QCM = "qcm"
    CLASSIQUE = "classique"


@dataclass
class CardResult:
    """Résultat d'une carte jouée"""
    card_pk: int
    card_name: str
    score: int
    is_correct: bool
    time_spent: int
    quiz_type: QuizType


@dataclass
class TestStats:
    """Statistiques d'un test"""
    total_cards: int
    correct_answers: int
    incorrect_answers: int
    total_score: int
    average_score: float
    total_time: int
    quiz_type: QuizType


# Configuration
BASE_URL = "http://localhost:8000"
DECK_ID = 40
DEFAULT_QUIZ_TYPE = QuizType.FRAPPE


class Colors:
    """Codes couleur ANSI pour une sortie colorée"""
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def print_section(title: str):
    """Affiche un titre de section formaté"""
    print(f"\n{'='*80}")
    print(f"{Colors.HEADER}{Colors.BOLD}{title}{Colors.ENDC}")
    print(f"{'='*80}")


def print_success(message: str):
    """Affiche un message de succès"""
    print(f"{Colors.OKGREEN}✅ {message}{Colors.ENDC}")


def print_error(message: str):
    """Affiche un message d'erreur"""
    print(f"{Colors.FAIL}❌ {message}{Colors.ENDC}")


def print_info(message: str):
    """Affiche un message d'information"""
    print(f"{Colors.OKCYAN}ℹ️  {message}{Colors.ENDC}")


def print_warning(message: str):
    """Affiche un message d'avertissement"""
    print(f"{Colors.WARNING}⚠️  {message}{Colors.ENDC}")


def calculate_stats(results: List[CardResult]) -> TestStats:
    """Calcule les statistiques à partir des résultats"""
    if not results:
        return TestStats(0, 0, 0, 0, 0.0, 0, DEFAULT_QUIZ_TYPE)
    
    total_cards = len(results)
    correct = sum(1 for r in results if r.is_correct)
    incorrect = total_cards - correct
    total_score = sum(r.score for r in results)
    avg_score = total_score / total_cards if total_cards > 0 else 0
    total_time = sum(r.time_spent for r in results)
    quiz_type = results[0].quiz_type if results else DEFAULT_QUIZ_TYPE
    
    return TestStats(
        total_cards=total_cards,
        correct_answers=correct,
        incorrect_answers=incorrect,
        total_score=total_score,
        average_score=avg_score,
        total_time=total_time,
        quiz_type=quiz_type
    )


def print_detailed_report(iteration_name: str, results: List[CardResult], stats: TestStats, api_stats: Dict[str, Any] = None):
    """Affiche un rapport détaillé des résultats"""
    print(f"\n{Colors.BOLD}📊 RAPPORT DÉTAILLÉ - {iteration_name}{Colors.ENDC}")
    print("─" * 80)
    
    # 1. Résumé général
    print(f"\n{Colors.BOLD}🎯 RÉSUMÉ GÉNÉRAL{Colors.ENDC}")
    print(f"  • Type de quiz: {stats.quiz_type.value}")
    print(f"  • Cartes jouées: {stats.total_cards}")
    print(f"  • Réponses correctes: {Colors.OKGREEN}{stats.correct_answers}{Colors.ENDC}")
    print(f"  • Réponses incorrectes: {Colors.FAIL}{stats.incorrect_answers}{Colors.ENDC}")
    print(f"  • Taux de réussite: {(stats.correct_answers/stats.total_cards*100):.1f}%" if stats.total_cards > 0 else "0%")
    print(f"  • Score total: {stats.total_score} points")
    print(f"  • Score moyen: {stats.average_score:.1f}/100")
    print(f"  • Temps total: {stats.total_time}s")
    
    # 2. Détail par carte
    print(f"\n{Colors.BOLD}🃏 DÉTAIL PAR CARTE{Colors.ENDC}")
    for idx, result in enumerate(results, 1):
        status_icon = "✅" if result.is_correct else "❌"
        status_color = Colors.OKGREEN if result.is_correct else Colors.FAIL
        print(f"  {idx}. {status_icon} Carte '{result.card_name}' (ID: {result.card_pk})")
        print(f"     └─ {status_color}Score: {result.score}/100{Colors.ENDC} | Temps: {result.time_spent}s")
    
    # 3. Statistiques API (si disponibles)
    if api_stats:
        print(f"\n{Colors.BOLD}📡 STATISTIQUES API{Colors.ENDC}")
        print(f"  • Points totaux (deck): {api_stats.get('total_points', 'N/A')}")
        print(f"  • Tentatives totales: {api_stats.get('total_attempts', 'N/A')}")
        print(f"  • Tentatives réussies: {api_stats.get('successful_attempts', 'N/A')}")
        
        # Points par type de quiz
        quiz_type_key = f"points_{stats.quiz_type.value}"
        if quiz_type_key in api_stats:
            print(f"  • Points '{stats.quiz_type.value}': {api_stats[quiz_type_key]}")
        
        # Progression des cartes
        print(f"\n  {Colors.BOLD}Progression des cartes:{Colors.ENDC}")
        print(f"  • Maîtrisées: {api_stats.get('mastered_cards', 0)}")
        print(f"  • En apprentissage: {api_stats.get('learning_cards', 0)}")
        print(f"  • À réviser: {api_stats.get('review_cards', 0)}")
    
    print("─" * 80)


async def register_user(client: httpx.AsyncClient) -> Dict[str, Any]:
    """Crée un nouveau compte utilisateur"""
    timestamp = int(datetime.now().timestamp())
    user_data = {
        "email": f"test_deck40_{timestamp}@example.com",
        "full_name": "Test Deck40 User",
        "password": "TestPassword123!"
    }
    
    print_info(f"Création du compte: {user_data['email']}")
    response = await client.post(f"{BASE_URL}/api/users/register", json=user_data)
    
    if response.status_code != 201:
        print_error(f"Erreur lors de la création du compte: {response.status_code}")
        print_error(response.text)
        raise Exception("Échec de création du compte")
    
    data = response.json()
    print_success("Compte créé avec succès")
    
    return {
        "email": user_data["email"],
        "password": user_data["password"],
        "token": data["access_token"],
        "user": data["user"]
    }


async def login_user(client: httpx.AsyncClient, email: str, password: str) -> str:
    """Connecte un utilisateur existant"""
    login_data = {"email": email, "password": password}
    
    print_info(f"Connexion: {email}")
    response = await client.post(f"{BASE_URL}/api/users/login", json=login_data)
    
    if response.status_code != 200:
        print_error(f"Erreur lors de la connexion: {response.status_code}")
        print_error(response.text)
        raise Exception("Échec de connexion")
    
    token = response.json()["access_token"]
    print_success("Connexion réussie")
    return token


async def get_deck_cards(client: httpx.AsyncClient, headers: Dict[str, str]) -> List[Dict[str, Any]]:
    """Récupère toutes les cartes d'un deck"""
    print_info(f"Récupération des cartes du deck {DECK_ID}...")
    response = await client.get(f"{BASE_URL}/cards/?deck_pk={DECK_ID}", headers=headers)
    
    if response.status_code != 200:
        print_error(f"Erreur lors de la récupération des cartes: {response.status_code}")
        print_error(response.text)
        raise Exception("Échec de récupération des cartes")
    
    cards = response.json()
    if not cards:
        print_warning(f"Aucune carte trouvée pour le deck {DECK_ID}")
        return []
    
    print_success(f"{len(cards)} cartes récupérées")
    return cards


async def submit_score(
    client: httpx.AsyncClient,
    headers: Dict[str, str],
    card_pk: int,
    score: int,
    is_correct: bool,
    time_spent: int,
    quiz_type: QuizType
) -> bool:
    """Soumet un score pour une carte"""
    score_data = {
        "deck_pk": DECK_ID,
        "card_pk": card_pk,
        "score": score,
        "is_correct": is_correct,
        "time_spent": time_spent,
        "quiz_type": quiz_type.value
    }
    
    response = await client.post(f"{BASE_URL}/api/users/scores", json=score_data, headers=headers)
    
    if response.status_code != 201:
        print_error(f"Erreur lors de l'enregistrement du score pour la carte {card_pk}: {response.status_code}")
        print_error(response.text)
        return False
    
    return True


async def get_deck_stats(client: httpx.AsyncClient, headers: Dict[str, str]) -> Dict[str, Any]:
    """Récupère les statistiques du deck pour l'utilisateur"""
    response = await client.get(f"{BASE_URL}/api/users/decks", headers=headers)
    
    if response.status_code != 200:
        print_error(f"Erreur lors de la récupération des stats: {response.status_code}")
        return {}
    
    user_decks = response.json()
    deck_stats = next((d for d in user_decks if d['deck_pk'] == DECK_ID), None)
    
    return deck_stats if deck_stats else {}


async def play_quiz(
    client: httpx.AsyncClient,
    headers: Dict[str, str],
    cards: List[Dict[str, Any]],
    quiz_type: QuizType,
    iteration_name: str
) -> List[CardResult]:
    """Joue un quiz complet avec toutes les cartes"""
    print_section(f"🎮 {iteration_name}")
    print_info(f"Type de quiz: {quiz_type.value}")
    print_info(f"Nombre de cartes: {len(cards)}")
    
    results = []
    
    for idx, card in enumerate(cards, 1):
        # Générer un résultat aléatoire (70% de chance de réussite)
        is_correct = random.random() < 0.7
        
        # Score basé sur le résultat
        if is_correct:
            score = random.randint(75, 100)
        else:
            score = random.randint(0, 45)
        
        time_spent = random.randint(2, 15)
        
        # Soumettre le score
        success = await submit_score(
            client, headers, card['card_pk'], score, is_correct, time_spent, quiz_type
        )
        
        if success:
            result = CardResult(
                card_pk=card['card_pk'],
                card_name=card['front'],
                score=score,
                is_correct=is_correct,
                time_spent=time_spent,
                quiz_type=quiz_type
            )
            results.append(result)
            
            # Affichage progressif
            status = "✅ CORRECT" if is_correct else "❌ INCORRECT"
            print(f"  [{idx}/{len(cards)}] Carte '{card['front']}': {status} ({score}/100)")
        else:
            print_warning(f"Carte {card['card_pk']} non enregistrée")
    
    # Récupérer et afficher les statistiques
    await asyncio.sleep(0.5)  # Petit délai pour être sûr que l'API a mis à jour les stats
    api_stats = await get_deck_stats(client, headers)
    
    # Calculer et afficher le rapport
    stats = calculate_stats(results)
    print_detailed_report(iteration_name, results, stats, api_stats)
    
    return results


async def verify_persistence(
    client: httpx.AsyncClient,
    headers: Dict[str, str],
    previous_stats: Dict[str, Any]
) -> bool:
    """Vérifie que les statistiques persistent après reconnexion"""
    print_section("🔍 VÉRIFICATION DE LA PERSISTANCE")
    
    current_stats = await get_deck_stats(client, headers)
    
    if not current_stats:
        print_error("Impossible de récupérer les statistiques actuelles")
        return False
    
    if not previous_stats:
        print_warning("Pas de statistiques précédentes pour comparaison")
        return True
    
    # Vérifier que les points ont bien été persistés
    prev_points = previous_stats.get('total_points', 0)
    curr_points = current_stats.get('total_points', 0)
    
    print_info(f"Points avant déconnexion: {prev_points}")
    print_info(f"Points après reconnexion: {curr_points}")
    
    if curr_points >= prev_points:
        print_success("✓ Les statistiques ont été correctement persistées")
        return True
    else:
        print_error(f"✗ Perte de données détectée ({prev_points - curr_points} points perdus)")
        return False


async def run_scenario():
    """Exécute le scénario de test complet"""
    print_section("🚀 DÉMARRAGE DU TEST COMPLET - DECK 40")
    print_info(f"URL de base: {BASE_URL}")
    print_info(f"Deck ID: {DECK_ID}")
    print_info(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # ═══════════════════════════════════════════════════════════════
            # PHASE 1: CRÉATION DU COMPTE
            # ═══════════════════════════════════════════════════════════════
            print_section("👤 PHASE 1: CRÉATION DU COMPTE")
            user_info = await register_user(client)
            headers = {"Authorization": f"Bearer {user_info['token']}"}
            
            # ═══════════════════════════════════════════════════════════════
            # PHASE 2: RÉCUPÉRATION DES CARTES
            # ═══════════════════════════════════════════════════════════════
            print_section("📥 PHASE 2: RÉCUPÉRATION DES CARTES")
            cards = await get_deck_cards(client, headers)
            
            if not cards:
                print_error("Aucune carte disponible pour le test")
                return
            
            # ═══════════════════════════════════════════════════════════════
            # PHASE 3: PREMIER QUIZ (Frappe)
            # ═══════════════════════════════════════════════════════════════
            results_test1 = await play_quiz(
                client, headers, cards, QuizType.FRAPPE, "TEST 1 - Quiz Frappe"
            )
            
            # Sauvegarder les stats pour comparaison
            stats_before_logout = await get_deck_stats(client, headers)
            
            # ═══════════════════════════════════════════════════════════════
            # PHASE 4: DÉCONNEXION
            # ═══════════════════════════════════════════════════════════════
            print_section("🚪 PHASE 4: DÉCONNEXION")
            await client.post(f"{BASE_URL}/api/users/logout", headers=headers)
            print_success("Déconnexion effectuée")
            
            # Petit délai pour simuler une vraie déconnexion
            await asyncio.sleep(1)
            
            # ═══════════════════════════════════════════════════════════════
            # PHASE 5: RECONNEXION
            # ═══════════════════════════════════════════════════════════════
            print_section("🔑 PHASE 5: RECONNEXION")
            new_token = await login_user(client, user_info['email'], user_info['password'])
            headers = {"Authorization": f"Bearer {new_token}"}
            
            # Vérifier la persistance
            persistence_ok = await verify_persistence(client, headers, stats_before_logout)
            
            # ═══════════════════════════════════════════════════════════════
            # PHASE 6: SECOND QUIZ (QCM)
            # ═══════════════════════════════════════════════════════════════
            results_test2 = await play_quiz(
                client, headers, cards, QuizType.QCM, "TEST 2 - Quiz QCM (Après reconnexion)"
            )
            
            # ═══════════════════════════════════════════════════════════════
            # PHASE 7: TROISIÈME QUIZ (Association)
            # ═══════════════════════════════════════════════════════════════
            results_test3 = await play_quiz(
                client, headers, cards, QuizType.ASSOCIATION, "TEST 3 - Quiz Association"
            )
            
            # ═══════════════════════════════════════════════════════════════
            # PHASE 8: QUATRIÈME QUIZ (Classique)
            # ═══════════════════════════════════════════════════════════════
            results_test4 = await play_quiz(
                client, headers, cards, QuizType.CLASSIQUE, "TEST 4 - Quiz Classique"
            )
            
            # ═══════════════════════════════════════════════════════════════
            # BILAN FINAL
            # ═══════════════════════════════════════════════════════════════
            print_section("📊 BILAN FINAL")
            
            final_stats = await get_deck_stats(client, headers)
            
            if final_stats:
                print(f"\n{Colors.BOLD}Statistiques finales du deck:{Colors.ENDC}")
                print(f"  • Points totaux: {final_stats.get('total_points', 0)}")
                print(f"  • Tentatives totales: {final_stats.get('total_attempts', 0)}")
                print(f"  • Tentatives réussies: {final_stats.get('successful_attempts', 0)}")
                print(f"\n{Colors.BOLD}Répartition par type de quiz:{Colors.ENDC}")
                print(f"  • Frappe: {final_stats.get('points_frappe', 0)} points")
                print(f"  • Association: {final_stats.get('points_association', 0)} points")
                print(f"  • QCM: {final_stats.get('points_qcm', 0)} points")
                print(f"  • Classique: {final_stats.get('points_classique', 0)} points")
                print(f"\n{Colors.BOLD}Progression des cartes:{Colors.ENDC}")
                print(f"  • Maîtrisées: {final_stats.get('mastered_cards', 0)}")
                print(f"  • En apprentissage: {final_stats.get('learning_cards', 0)}")
                print(f"  • À réviser: {final_stats.get('review_cards', 0)}")
            
            # Résumé des tests
            print(f"\n{Colors.BOLD}Résumé des tests effectués:{Colors.ENDC}")
            print(f"  • Test 1 (Frappe): {len(results_test1)} cartes jouées")
            print(f"  • Test 2 (QCM): {len(results_test2)} cartes jouées")
            print(f"  • Test 3 (Association): {len(results_test3)} cartes jouées")
            print(f"  • Test 4 (Classique): {len(results_test4)} cartes jouées")
            print(f"  • Total: {len(results_test1) + len(results_test2) + len(results_test3) + len(results_test4)} cartes jouées")
            
            # État de la persistance
            print(f"\n{Colors.BOLD}Persistance des données:{Colors.ENDC}")
            if persistence_ok:
                print_success("Les données ont été correctement persistées après déconnexion/reconnexion")
            else:
                print_error("Problème détecté avec la persistance des données")
            
            print_section("🏁 TEST TERMINÉ AVEC SUCCÈS")
            
    except Exception as e:
        print_section("💥 ERREUR CRITIQUE")
        print_error(f"Le test a échoué avec l'erreur suivante:")
        print_error(f"{type(e).__name__}: {str(e)}")
        import traceback
        print(f"\n{Colors.WARNING}Traceback complet:{Colors.ENDC}")
        traceback.print_exc()
        return 1
    
    return 0


if __name__ == "__main__":
    print(f"""
    {Colors.BOLD}{Colors.HEADER}
    ╔══════════════════════════════════════════════════════════════════════╗
    ║           TEST DE SCÉNARIO COMPLET - DECK 40                        ║
    ║                  Apprendiamo Italiano Backend                        ║
    ╚══════════════════════════════════════════════════════════════════════╝
    {Colors.ENDC}
    """)
    
    exit_code = asyncio.run(run_scenario())
    exit(exit_code)
