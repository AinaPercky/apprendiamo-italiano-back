"""
Test Complet - Vérification de la Précision Personnalisée des Decks

Ce test simule deux utilisateurs :
1. ALPHA : Utilisateur qui fait des quiz → certains decks avec précision > 0%
2. BETA : Nouvel utilisateur sans quiz → tous les decks à 0%

Le test vérifie que chaque utilisateur voit TOUS les decks du système,
mais avec ses propres statistiques personnalisées.
"""

import requests
import json
from datetime import datetime
from typing import Dict, List, Any

API_BASE_URL = "http://127.0.0.1:8000"

class Colors:
    """Codes couleur pour l'affichage terminal"""
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    MAGENTA = '\033[95m'
    BOLD = '\033[1m'
    END = '\033[0m'

def print_header(text: str):
    """Affiche un en-tête formaté"""
    print(f"\n{Colors.BOLD}{Colors.CYAN}{'=' * 80}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.CYAN}{text.center(80)}{Colors.END}")
    print(f"{Colors.BOLD}{Colors.CYAN}{'=' * 80}{Colors.END}\n")

def print_section(text: str):
    """Affiche une section formatée"""
    print(f"\n{Colors.BOLD}{Colors.BLUE}{text}{Colors.END}")
    print(f"{Colors.BLUE}{'-' * 80}{Colors.END}\n")

def print_success(text: str):
    """Affiche un message de succès"""
    print(f"{Colors.GREEN}✅ {text}{Colors.END}")

def print_error(text: str):
    """Affiche un message d'erreur"""
    print(f"{Colors.RED}❌ {text}{Colors.END}")

def print_warning(text: str):
    """Affiche un avertissement"""
    print(f"{Colors.YELLOW}⚠️  {text}{Colors.END}")

def print_info(text: str):
    """Affiche une information"""
    print(f"{Colors.CYAN}ℹ️  {text}{Colors.END}")


class UserTestSession:
    """Classe pour gérer une session utilisateur de test"""
    
    def __init__(self, name: str, email: str, password: str):
        self.name = name
        self.email = email
        self.password = password
        self.token = None
        self.user_pk = None
        self.decks = []
    
    def register(self) -> bool:
        """Enregistre un nouveau compte utilisateur"""
        try:
            response = requests.post(
                f"{API_BASE_URL}/api/users/register",
                json={
                    "email": self.email,
                    "full_name": f"Test User {self.name}",
                    "password": self.password
                },
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 201:
                data = response.json()
                self.token = data["access_token"]
                self.user_pk = data["user"]["user_pk"]
                print_success(f"Utilisateur {self.name} créé avec succès")
                print_info(f"   Email: {self.email}")
                print_info(f"   User PK: {self.user_pk}")
                return True
            else:
                print_error(f"Erreur lors de la création de {self.name}: {response.status_code}")
                print_error(f"   Réponse: {response.text}")
                return False
                
        except Exception as e:
            print_error(f"Exception lors de la création de {self.name}: {e}")
            return False
    
    def login(self) -> bool:
        """Se connecte avec un compte existant"""
        try:
            response = requests.post(
                f"{API_BASE_URL}/api/users/login",
                json={
                    "email": self.email,
                    "password": self.password
                },
                headers={"Content-Type": "application/json"}
            )
            
            if response.status_code == 200:
                data = response.json()
                self.token = data["access_token"]
                self.user_pk = data["user"]["user_pk"]
                print_success(f"Utilisateur {self.name} connecté avec succès")
                print_info(f"   User PK: {self.user_pk}")
                return True
            else:
                print_error(f"Erreur lors de la connexion de {self.name}: {response.status_code}")
                return False
                
        except Exception as e:
            print_error(f"Exception lors de la connexion de {self.name}: {e}")
            return False
    
    def get_all_decks(self) -> bool:
        """Récupère tous les decks avec stats personnalisées"""
        try:
            response = requests.get(
                f"{API_BASE_URL}/api/users/decks/all",
                headers={"Authorization": f"Bearer {self.token}"}
            )
            
            if response.status_code == 200:
                self.decks = response.json()
                print_success(f"Decks récupérés pour {self.name}")
                print_info(f"   Nombre total de decks: {len(self.decks)}")
                return True
            else:
                print_error(f"Erreur lors de la récupération des decks pour {self.name}: {response.status_code}")
                print_error(f"   Réponse: {response.text}")
                return False
                
        except Exception as e:
            print_error(f"Exception lors de la récupération des decks pour {self.name}: {e}")
            return False
    
    def get_available_cards(self, deck_pk: int) -> List[Dict]:
        """Récupère les cartes disponibles d'un deck"""
        try:
            response = requests.get(
                f"{API_BASE_URL}/cards/?deck_pk={deck_pk}&limit=10",
                headers={"Authorization": f"Bearer {self.token}"}
            )
            
            if response.status_code == 200:
                return response.json()
            else:
                print_warning(f"Impossible de récupérer les cartes du deck {deck_pk}")
                return []
                
        except Exception as e:
            print_warning(f"Exception lors de la récupération des cartes: {e}")
            return []
    
    def submit_quiz_score(self, deck_pk: int, card_pk: int, is_correct: bool, score: int) -> bool:
        """Soumet un score de quiz"""
        try:
            response = requests.post(
                f"{API_BASE_URL}/api/users/scores",
                json={
                    "deck_pk": deck_pk,
                    "card_pk": card_pk,
                    "score": score,
                    "is_correct": is_correct,
                    "time_spent": 5,
                    "quiz_type": "classique"
                },
                headers={
                    "Authorization": f"Bearer {self.token}",
                    "Content-Type": "application/json"
                }
            )
            
            return response.status_code == 201
            
        except Exception as e:
            print_warning(f"Exception lors de la soumission du score: {e}")
            return False
    
    def do_quiz_on_deck(self, deck_pk: int, deck_name: str, num_cards: int = 5) -> bool:
        """Fait un quiz sur un deck"""
        print_info(f"   Quiz sur le deck '{deck_name}' (ID: {deck_pk})...")
        
        # Récupérer les cartes
        cards = self.get_available_cards(deck_pk)
        
        if not cards:
            print_warning(f"      Aucune carte disponible pour le deck {deck_pk}")
            return False
        
        # Limiter le nombre de cartes
        cards_to_quiz = cards[:min(num_cards, len(cards))]
        
        # Simuler des réponses (alternance correct/incorrect)
        correct_count = 0
        for i, card in enumerate(cards_to_quiz):
            is_correct = (i % 2 == 0)  # Alternance
            score = 85 if is_correct else 30
            
            if self.submit_quiz_score(deck_pk, card["card_pk"], is_correct, score):
                if is_correct:
                    correct_count += 1
        
        success_rate = (correct_count / len(cards_to_quiz)) * 100
        print_success(f"      Quiz terminé: {correct_count}/{len(cards_to_quiz)} correctes ({success_rate:.1f}%)")
        return True
    
    def display_deck_stats(self, max_display: int = 10):
        """Affiche les statistiques des decks"""
        print(f"\n{Colors.BOLD}📊 Statistiques des Decks pour {self.name}{Colors.END}")
        print(f"{Colors.MAGENTA}{'─' * 80}{Colors.END}")
        
        # Séparer les decks en deux catégories
        decks_with_stats = [d for d in self.decks if d['total_attempts'] > 0]
        decks_without_stats = [d for d in self.decks if d['total_attempts'] == 0]
        
        # Afficher les decks avec stats
        if decks_with_stats:
            print(f"\n{Colors.BOLD}{Colors.GREEN}Decks avec activité ({len(decks_with_stats)}):{Colors.END}")
            for deck in decks_with_stats[:max_display]:
                precision_color = Colors.GREEN if deck['success_rate'] >= 50 else Colors.YELLOW if deck['success_rate'] > 0 else Colors.RED
                print(f"  📦 {deck['deck']['name']}")
                print(f"     Précision: {precision_color}{deck['success_rate']:.1f}%{Colors.END} | "
                      f"Tentatives: {deck['total_attempts']} | "
                      f"Points: {deck['total_points']}")
        
        # Afficher les decks sans stats
        if decks_without_stats:
            print(f"\n{Colors.BOLD}{Colors.CYAN}Decks sans activité ({len(decks_without_stats)}):{Colors.END}")
            for deck in decks_without_stats[:max_display]:
                print(f"  📦 {deck['deck']['name']}")
                print(f"     Précision: {Colors.CYAN}0.0%{Colors.END} | "
                      f"Tentatives: 0 | "
                      f"Points: 0")
            
            if len(decks_without_stats) > max_display:
                print(f"\n  ... et {len(decks_without_stats) - max_display} autres decks à 0%")
        
        print(f"\n{Colors.MAGENTA}{'─' * 80}{Colors.END}")


def run_complete_test():
    """Exécute le test complet avec deux utilisateurs"""
    
    print_header("🧪 TEST COMPLET - PRÉCISION PERSONNALISÉE DES DECKS")
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # ========================================================================
    # PARTIE 1 : UTILISATEUR ALPHA (avec quiz)
    # ========================================================================
    
    print_section("👤 PARTIE 1 : UTILISATEUR ALPHA (avec quiz)")
    
    alpha = UserTestSession(
        name="ALPHA",
        email=f"alpha_{timestamp}@test.com",
        password="AlphaTest123!"
    )
    
    # Créer le compte Alpha
    if not alpha.register():
        print_error("Impossible de créer l'utilisateur Alpha. Test arrêté.")
        return
    
    # Récupérer tous les decks pour Alpha (avant quiz)
    print_info("\n📋 Récupération des decks AVANT quiz...")
    if not alpha.get_all_decks():
        print_error("Impossible de récupérer les decks pour Alpha. Test arrêté.")
        return
    
    total_decks = len(alpha.decks)
    print_success(f"   {total_decks} decks disponibles pour Alpha")
    
    # Faire des quiz sur quelques decks
    print_info("\n🎯 Alpha fait des quiz sur plusieurs decks...")
    
    # Sélectionner 3-5 decks aléatoires pour faire des quiz
    import random
    decks_to_quiz = random.sample(alpha.decks, min(5, len(alpha.decks)))
    
    for deck in decks_to_quiz:
        alpha.do_quiz_on_deck(deck['deck_pk'], deck['deck']['name'], num_cards=5)
    
    # Récupérer à nouveau tous les decks (après quiz)
    print_info("\n📋 Récupération des decks APRÈS quiz...")
    if not alpha.get_all_decks():
        print_error("Impossible de récupérer les decks mis à jour pour Alpha.")
        return
    
    # Afficher les stats d'Alpha
    alpha.display_deck_stats(max_display=15)
    
    # Vérifier qu'Alpha a toujours TOUS les decks
    if len(alpha.decks) != total_decks:
        print_error(f"ERREUR: Alpha devrait avoir {total_decks} decks, mais en a {len(alpha.decks)}")
    else:
        print_success(f"✓ Alpha voit bien TOUS les {total_decks} decks du système")
    
    # Vérifier qu'au moins un deck a une précision > 0%
    decks_with_activity = [d for d in alpha.decks if d['success_rate'] > 0]
    if len(decks_with_activity) > 0:
        print_success(f"✓ Alpha a {len(decks_with_activity)} deck(s) avec précision > 0%")
    else:
        print_warning("⚠️  Aucun deck avec précision > 0% pour Alpha")
    
    # ========================================================================
    # PARTIE 2 : UTILISATEUR BETA (sans quiz)
    # ========================================================================
    
    print_section("👤 PARTIE 2 : UTILISATEUR BETA (nouveau, sans quiz)")
    
    beta = UserTestSession(
        name="BETA",
        email=f"beta_{timestamp}@test.com",
        password="BetaTest123!"
    )
    
    # Créer le compte Beta
    if not beta.register():
        print_error("Impossible de créer l'utilisateur Beta. Test arrêté.")
        return
    
    # Récupérer tous les decks pour Beta (sans faire de quiz)
    print_info("\n📋 Récupération des decks pour Beta (nouveau utilisateur)...")
    if not beta.get_all_decks():
        print_error("Impossible de récupérer les decks pour Beta. Test arrêté.")
        return
    
    # Afficher les stats de Beta
    beta.display_deck_stats(max_display=15)
    
    # ========================================================================
    # PARTIE 3 : VÉRIFICATIONS FINALES
    # ========================================================================
    
    print_section("🔍 VÉRIFICATIONS FINALES")
    
    # Vérification 1 : Beta a TOUS les decks
    if len(beta.decks) == total_decks:
        print_success(f"✓ Beta voit bien TOUS les {total_decks} decks du système")
    else:
        print_error(f"✗ Beta devrait avoir {total_decks} decks, mais en a {len(beta.decks)}")
    
    # Vérification 2 : Tous les decks de Beta sont à 0%
    all_zero = all(d['success_rate'] == 0.0 for d in beta.decks)
    if all_zero:
        print_success(f"✓ TOUS les decks de Beta sont à 0% (nouveau utilisateur)")
    else:
        print_error("✗ Certains decks de Beta ne sont pas à 0%")
        non_zero = [d for d in beta.decks if d['success_rate'] != 0.0]
        for deck in non_zero[:5]:
            print_error(f"   - {deck['deck']['name']}: {deck['success_rate']}%")
    
    # Vérification 3 : Alpha et Beta voient le même nombre de decks
    if len(alpha.decks) == len(beta.decks):
        print_success(f"✓ Alpha et Beta voient le même nombre de decks ({len(alpha.decks)})")
    else:
        print_error(f"✗ Alpha ({len(alpha.decks)} decks) et Beta ({len(beta.decks)} decks) ne voient pas le même nombre")
    
    # Vérification 4 : Les stats sont différentes entre Alpha et Beta
    alpha_total_attempts = sum(d['total_attempts'] for d in alpha.decks)
    beta_total_attempts = sum(d['total_attempts'] for d in beta.decks)
    
    if alpha_total_attempts > 0 and beta_total_attempts == 0:
        print_success(f"✓ Les statistiques sont bien personnalisées (Alpha: {alpha_total_attempts} tentatives, Beta: 0)")
    else:
        print_warning(f"⚠️  Alpha: {alpha_total_attempts} tentatives, Beta: {beta_total_attempts} tentatives")
    
    # ========================================================================
    # RÉSUMÉ FINAL
    # ========================================================================
    
    print_header("📊 RÉSUMÉ DU TEST")
    
    print(f"\n{Colors.BOLD}Utilisateur ALPHA (avec quiz):{Colors.END}")
    print(f"  • Decks totaux: {len(alpha.decks)}")
    print(f"  • Decks avec activité: {len([d for d in alpha.decks if d['total_attempts'] > 0])}")
    print(f"  • Decks sans activité: {len([d for d in alpha.decks if d['total_attempts'] == 0])}")
    print(f"  • Tentatives totales: {sum(d['total_attempts'] for d in alpha.decks)}")
    print(f"  • Points totaux: {sum(d['total_points'] for d in alpha.decks)}")
    
    print(f"\n{Colors.BOLD}Utilisateur BETA (nouveau, sans quiz):{Colors.END}")
    print(f"  • Decks totaux: {len(beta.decks)}")
    print(f"  • Decks avec activité: {len([d for d in beta.decks if d['total_attempts'] > 0])}")
    print(f"  • Decks sans activité: {len([d for d in beta.decks if d['total_attempts'] == 0])}")
    print(f"  • Tentatives totales: {sum(d['total_attempts'] for d in beta.decks)}")
    print(f"  • Points totaux: {sum(d['total_points'] for d in beta.decks)}")
    
    # Verdict final
    print(f"\n{Colors.BOLD}{'=' * 80}{Colors.END}")
    
    success_conditions = [
        len(alpha.decks) == total_decks,
        len(beta.decks) == total_decks,
        all(d['success_rate'] == 0.0 for d in beta.decks),
        len([d for d in alpha.decks if d['success_rate'] > 0]) > 0,
        len(alpha.decks) == len(beta.decks)
    ]
    
    if all(success_conditions):
        print(f"{Colors.BOLD}{Colors.GREEN}✅ TEST RÉUSSI !{Colors.END}")
        print(f"{Colors.GREEN}   • Tous les decks du système sont affichés pour les deux utilisateurs{Colors.END}")
        print(f"{Colors.GREEN}   • Beta (nouveau) a tous ses decks à 0%{Colors.END}")
        print(f"{Colors.GREEN}   • Alpha (actif) a des précisions personnalisées{Colors.END}")
        print(f"{Colors.GREEN}   • Les statistiques sont bien isolées par utilisateur{Colors.END}")
    else:
        print(f"{Colors.BOLD}{Colors.RED}❌ TEST ÉCHOUÉ{Colors.END}")
        print(f"{Colors.RED}   Certaines conditions ne sont pas remplies{Colors.END}")
    
    print(f"{Colors.BOLD}{'=' * 80}{Colors.END}\n")


if __name__ == "__main__":
    try:
        run_complete_test()
    except KeyboardInterrupt:
        print(f"\n\n{Colors.YELLOW}Test interrompu par l'utilisateur{Colors.END}\n")
    except Exception as e:
        print(f"\n\n{Colors.RED}Erreur inattendue: {e}{Colors.END}\n")
        import traceback
        traceback.print_exc()
