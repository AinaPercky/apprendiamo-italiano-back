"""
Test automatique complet de tous les endpoints de l'API
Focus sur flashcards, decks, et scores avec quiz
Génère un rapport détaillé et identifie les bugs
"""

import asyncio
import httpx
import json
from datetime import datetime, timedelta
from typing import Dict, List, Any
from dataclasses import dataclass, field
from enum import Enum


class TestStatus(Enum):
    SUCCESS = "✅ SUCCESS"
    FAILED = "❌ FAILED"
    WARNING = "⚠️ WARNING"
    SKIPPED = "⏭️ SKIPPED"


@dataclass
class TestResult:
    name: str
    status: TestStatus
    duration: float
    details: str = ""
    error: str = ""
    response_data: Any = None


@dataclass
class TestReport:
    total_tests: int = 0
    passed: int = 0
    failed: int = 0
    warnings: int = 0
    skipped: int = 0
    results: List[TestResult] = field(default_factory=list)
    bugs_found: List[str] = field(default_factory=list)
    start_time: datetime = field(default_factory=datetime.now)
    end_time: datetime = None

    def add_result(self, result: TestResult):
        self.results.append(result)
        self.total_tests += 1
        if result.status == TestStatus.SUCCESS:
            self.passed += 1
        elif result.status == TestStatus.FAILED:
            self.failed += 1
        elif result.status == TestStatus.WARNING:
            self.warnings += 1
        elif result.status == TestStatus.SKIPPED:
            self.skipped += 1

    def add_bug(self, bug: str):
        if bug not in self.bugs_found:
            self.bugs_found.append(bug)

    def generate_report(self) -> str:
        self.end_time = datetime.now()
        duration = (self.end_time - self.start_time).total_seconds()
        
        report = f"""
{'='*80}
                    RAPPORT DE TESTS AUTOMATIQUES
{'='*80}
Date: {self.start_time.strftime('%Y-%m-%d %H:%M:%S')}
Durée totale: {duration:.2f}s

RÉSUMÉ:
--------
Total de tests: {self.total_tests}
✅ Réussis: {self.passed}
❌ Échoués: {self.failed}
⚠️ Avertissements: {self.warnings}
⏭️ Ignorés: {self.skipped}

Taux de réussite: {(self.passed/self.total_tests*100) if self.total_tests > 0 else 0:.1f}%

{'='*80}
DÉTAILS DES TESTS:
{'='*80}
"""
        for i, result in enumerate(self.results, 1):
            report += f"\n{i}. {result.status.value} - {result.name} ({result.duration:.3f}s)\n"
            if result.details:
                report += f"   📝 {result.details}\n"
            if result.error:
                report += f"   ⚠️ Erreur: {result.error}\n"

        if self.bugs_found:
            report += f"\n{'='*80}\n"
            report += "🐛 BUGS IDENTIFIÉS:\n"
            report += f"{'='*80}\n"
            for i, bug in enumerate(self.bugs_found, 1):
                report += f"{i}. {bug}\n"
        else:
            report += f"\n{'='*80}\n"
            report += "✨ Aucun bug identifié!\n"

        report += f"\n{'='*80}\n"
        return report


class APITester:
    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.client = None
        self.token = None
        self.user_data = None
        self.report = TestReport()
        
        # Données de test
        self.test_user = {
            "email": f"test_{datetime.now().timestamp()}@example.com",
            "full_name": "Test User",
            "password": "TestPassword123!"
        }
        
        self.created_deck_id = None
        self.created_card_ids = []
        self.user_deck_ids = []

    async def __aenter__(self):
        self.client = httpx.AsyncClient(timeout=30.0)
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.client:
            await self.client.aclose()

    async def _make_request(self, method: str, endpoint: str, **kwargs) -> httpx.Response:
        """Fait une requête HTTP avec gestion des headers d'authentification"""
        headers = kwargs.pop('headers', {})
        if self.token:
            headers['Authorization'] = f'Bearer {self.token}'
        
        url = f"{self.base_url}{endpoint}"
        return await self.client.request(method, url, headers=headers, **kwargs)

    async def run_test(self, name: str, test_func):
        """Exécute un test et enregistre le résultat"""
        print(f"\n🧪 Test: {name}")
        start = datetime.now()
        
        try:
            result = await test_func()
            duration = (datetime.now() - start).total_seconds()
            
            if result is True or (isinstance(result, dict) and result.get('success')):
                status = TestStatus.SUCCESS
                details = result.get('details', '') if isinstance(result, dict) else ''
                error = ''
                response_data = result.get('data') if isinstance(result, dict) else None
            else:
                status = TestStatus.FAILED
                details = result.get('details', '') if isinstance(result, dict) else ''
                error = result.get('error', 'Test failed') if isinstance(result, dict) else 'Test failed'
                response_data = None
                self.report.add_bug(f"{name}: {error}")
            
            test_result = TestResult(
                name=name,
                status=status,
                duration=duration,
                details=details,
                error=error,
                response_data=response_data
            )
            self.report.add_result(test_result)
            print(f"   {status.value} ({duration:.3f}s)")
            
        except Exception as e:
            duration = (datetime.now() - start).total_seconds()
            error_msg = str(e)
            test_result = TestResult(
                name=name,
                status=TestStatus.FAILED,
                duration=duration,
                error=error_msg
            )
            self.report.add_result(test_result)
            self.report.add_bug(f"{name}: {error_msg}")
            print(f"   ❌ FAILED ({duration:.3f}s): {error_msg}")

    # ============================================================================
    # TESTS D'AUTHENTIFICATION
    # ============================================================================

    async def test_register_user(self):
        """Test de création d'utilisateur"""
        response = await self._make_request(
            'POST',
            '/api/users/register',
            json=self.test_user
        )
        
        if response.status_code == 201:
            data = response.json()
            self.token = data.get('access_token')
            self.user_data = data.get('user')
            return {
                'success': True,
                'details': f"Utilisateur créé: {self.user_data.get('email')}",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}",
                'details': response.text
            }

    async def test_login_user(self):
        """Test de connexion utilisateur"""
        # On crée un nouvel utilisateur pour le login
        login_user = {
            "email": f"login_{datetime.now().timestamp()}@example.com",
            "full_name": "Login Test User",
            "password": "LoginPass123!"
        }
        
        # Créer l'utilisateur
        reg_response = await self._make_request(
            'POST',
            '/api/users/register',
            json=login_user
        )
        
        if reg_response.status_code != 201:
            return {
                'success': False,
                'error': f"Impossible de créer l'utilisateur pour le test de login: {reg_response.status_code}"
            }
        
        # Tenter de se connecter
        login_data = {
            "email": login_user["email"],
            "password": login_user["password"]
        }
        
        response = await self._make_request(
            'POST',
            '/api/users/login',
            json=login_data
        )
        
        if response.status_code == 200:
            data = response.json()
            if 'access_token' in data:
                return {
                    'success': True,
                    'details': f"Connexion réussie pour {login_user['email']}",
                    'data': data
                }
            else:
                return {
                    'success': False,
                    'error': "Token manquant dans la réponse"
                }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_create_deck(self):
        """Test de création d'un deck"""
        deck_data = {
            "name": f"Test Deck {datetime.now().timestamp()}",
            "id_json": f"test_deck_{datetime.now().timestamp()}"
        }
        
        response = await self._make_request(
            'POST',
            '/decks/',
            json=deck_data
        )
        
        if response.status_code == 200:
            data = response.json()
            self.created_deck_id = data.get('deck_pk')
            return {
                'success': True,
                'details': f"Deck créé avec ID: {self.created_deck_id}",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_get_decks(self):
        """Test de récupération de la liste des decks"""
        response = await self._make_request('GET', '/decks/')
        
        if response.status_code == 200:
            data = response.json()
            return {
                'success': True,
                'details': f"Nombre de decks récupérés: {len(data)}",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_get_deck_by_id(self):
        """Test de récupération d'un deck par ID"""
        if not self.created_deck_id:
            return {
                'success': False,
                'error': "Aucun deck créé pour ce test"
            }
        
        response = await self._make_request('GET', f'/decks/{self.created_deck_id}')
        
        if response.status_code == 200:
            data = response.json()
            return {
                'success': True,
                'details': f"Deck récupéré: {data.get('name')}",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    # ============================================================================
    # TESTS CARDS
    # ============================================================================

    async def test_create_cards(self):
        """Test de création de plusieurs cartes"""
        if not self.created_deck_id:
            return {
                'success': False,
                'error': "Aucun deck créé pour ajouter des cartes"
            }
        
        cards_data = [
            {
                "front": "Ciao",
                "back": "Bonjour",
                "pronunciation": "tchao",
                "deck_pk": self.created_deck_id,
                "id_json": f"card_1_{datetime.now().timestamp()}",
                "created_at": datetime.utcnow().isoformat(),
                "next_review": datetime.utcnow().isoformat(),
                "tags": ["salutations", "basique"]
            },
            {
                "front": "Grazie",
                "back": "Merci",
                "pronunciation": "gratsié",
                "deck_pk": self.created_deck_id,
                "id_json": f"card_2_{datetime.now().timestamp()}",
                "created_at": datetime.utcnow().isoformat(),
                "next_review": datetime.utcnow().isoformat(),
                "tags": ["politesse"]
            },
            {
                "front": "Arrivederci",
                "back": "Au revoir",
                "pronunciation": "arrivedertchi",
                "deck_pk": self.created_deck_id,
                "id_json": f"card_3_{datetime.now().timestamp()}",
                "created_at": datetime.utcnow().isoformat(),
                "next_review": datetime.utcnow().isoformat(),
                "tags": ["salutations"]
            }
        ]
        
        created_count = 0
        errors = []
        
        for card in cards_data:
            response = await self._make_request('POST', '/cards/', json=card)
            if response.status_code == 200:
                data = response.json()
                self.created_card_ids.append(data.get('card_pk'))
                created_count += 1
            else:
                errors.append(f"Carte '{card['front']}': {response.text}")
        
        if created_count == len(cards_data):
            return {
                'success': True,
                'details': f"{created_count} cartes créées avec succès",
                'data': {'card_ids': self.created_card_ids}
            }
        else:
            return {
                'success': False,
                'error': f"Seulement {created_count}/{len(cards_data)} cartes créées",
                'details': '; '.join(errors)
            }

    async def test_get_cards(self):
        """Test de récupération des cartes"""
        response = await self._make_request('GET', '/cards/')
        
        if response.status_code == 200:
            data = response.json()
            return {
                'success': True,
                'details': f"Nombre de cartes récupérées: {len(data)}",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_get_cards_by_deck(self):
        """Test de récupération des cartes d'un deck spécifique"""
        if not self.created_deck_id:
            return {
                'success': False,
                'error': "Aucun deck créé"
            }
        
        response = await self._make_request(
            'GET',
            f'/cards/?deck_pk={self.created_deck_id}'
        )
        
        if response.status_code == 200:
            data = response.json()
            return {
                'success': True,
                'details': f"Cartes du deck {self.created_deck_id}: {len(data)}",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_update_card(self):
        """Test de mise à jour d'une carte"""
        if not self.created_card_ids:
            return {
                'success': False,
                'error': "Aucune carte créée pour ce test"
            }
        
        card_id = self.created_card_ids[0]
        update_data = {
            "front": "Ciao (Updated)",
            "back": "Bonjour (Mis à jour)",
            "pronunciation": "tchao",
            "tags": ["salutations", "basique", "updated"]
        }
        
        response = await self._make_request(
            'PUT',
            f'/cards/{card_id}',
            json=update_data
        )
        
        if response.status_code == 200:
            data = response.json()
            return {
                'success': True,
                'details': f"Carte {card_id} mise à jour",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    # ============================================================================
    # TESTS USER DECKS
    # ============================================================================

    async def test_add_deck_to_user(self):
        """Test d'ajout d'un deck à l'utilisateur"""
        if not self.created_deck_id:
            return {
                'success': False,
                'error': "Aucun deck créé"
            }
        
        response = await self._make_request(
            'POST',
            f'/api/users/decks/{self.created_deck_id}'
        )
        
        if response.status_code == 201:
            data = response.json()
            self.user_deck_ids.append(data.get('user_deck_pk'))
            return {
                'success': True,
                'details': f"Deck {self.created_deck_id} ajouté à l'utilisateur",
                'data': data
            }
        elif response.status_code == 400 and "already" in response.text.lower():
            # Le deck est déjà ajouté (probablement automatiquement)
            return {
                'success': True,
                'details': "Deck déjà dans la collection de l'utilisateur"
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_get_user_decks(self):
        """Test de récupération des decks de l'utilisateur"""
        response = await self._make_request('GET', '/api/users/decks')
        
        if response.status_code == 200:
            data = response.json()
            return {
                'success': True,
                'details': f"Nombre de decks utilisateur: {len(data)}",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    # ============================================================================
    # TESTS SCORES & QUIZ
    # ============================================================================

    async def test_quiz_frappe(self):
        """Test d'un quiz de type 'frappe' (typing)"""
        if not self.created_card_ids or not self.created_deck_id:
            return {
                'success': False,
                'error': "Pas de cartes ou deck pour le quiz"
            }
        
        score_data = {
            "deck_pk": self.created_deck_id,
            "card_pk": self.created_card_ids[0],
            "score": 85,
            "is_correct": True,
            "time_spent": 5,
            "quiz_type": "frappe"
        }
        
        response = await self._make_request(
            'POST',
            '/api/users/scores',
            json=score_data
        )
        
        if response.status_code == 201:
            data = response.json()
            return {
                'success': True,
                'details': f"Score frappe enregistré: {score_data['score']}/100",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_quiz_association(self):
        """Test d'un quiz de type 'association'"""
        if not self.created_card_ids or not self.created_deck_id:
            return {
                'success': False,
                'error': "Pas de cartes ou deck pour le quiz"
            }
        
        score_data = {
            "deck_pk": self.created_deck_id,
            "card_pk": self.created_card_ids[1],
            "score": 100,
            "is_correct": True,
            "time_spent": 3,
            "quiz_type": "association"
        }
        
        response = await self._make_request(
            'POST',
            '/api/users/scores',
            json=score_data
        )
        
        if response.status_code == 201:
            data = response.json()
            return {
                'success': True,
                'details': f"Score association enregistré: {score_data['score']}/100",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_quiz_qcm(self):
        """Test d'un quiz de type 'QCM' (multiple choice)"""
        if not self.created_card_ids or not self.created_deck_id:
            return {
                'success': False,
                'error': "Pas de cartes ou deck pour le quiz"
            }
        
        score_data = {
            "deck_pk": self.created_deck_id,
            "card_pk": self.created_card_ids[2],
            "score": 75,
            "is_correct": True,
            "time_spent": 4,
            "quiz_type": "qcm"
        }
        
        response = await self._make_request(
            'POST',
            '/api/users/scores',
            json=score_data
        )
        
        if response.status_code == 201:
            data = response.json()
            return {
                'success': True,
                'details': f"Score QCM enregistré: {score_data['score']}/100",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_quiz_classique(self):
        """Test d'un quiz de type 'classique'"""
        if not self.created_card_ids or not self.created_deck_id:
            return {
                'success': False,
                'error': "Pas de cartes ou deck pour le quiz"
            }
        
        score_data = {
            "deck_pk": self.created_deck_id,
            "card_pk": self.created_card_ids[0],
            "score": 90,
            "is_correct": True,
            "time_spent": 6,
            "quiz_type": "classique"
        }
        
        response = await self._make_request(
            'POST',
            '/api/users/scores',
            json=score_data
        )
        
        if response.status_code == 201:
            data = response.json()
            return {
                'success': True,
                'details': f"Score classique enregistré: {score_data['score']}/100",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_quiz_incorrect_answer(self):
        """Test d'une réponse incorrecte (pour tester l'algorithme Anki)"""
        if not self.created_card_ids or not self.created_deck_id:
            return {
                'success': False,
                'error': "Pas de cartes ou deck pour le quiz"
            }
        
        score_data = {
            "deck_pk": self.created_deck_id,
            "card_pk": self.created_card_ids[1],
            "score": 30,
            "is_correct": False,
            "time_spent": 8,
            "quiz_type": "classique"
        }
        
        response = await self._make_request(
            'POST',
            '/api/users/scores',
            json=score_data
        )
        
        if response.status_code == 201:
            data = response.json()
            return {
                'success': True,
                'details': f"Réponse incorrecte enregistrée: {score_data['score']}/100",
                'data': data
            }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    async def test_verify_anki_algorithm(self):
        """Vérifie que l'algorithme Anki a bien mis à jour les cartes"""
        if not self.created_card_ids:
            return {
                'success': False,
                'error': "Pas de cartes pour vérifier"
            }
        
        # Récupérer la première carte qui a eu plusieurs scores
        card_id = self.created_card_ids[0]
        response = await self._make_request('GET', f'/cards/{card_id}')
        
        if response.status_code == 200:
            card = response.json()
            
            # Vérifier que les champs Anki ont été mis à jour
            checks = []
            if card.get('easiness') != 2.5:  # Valeur par défaut
                checks.append(f"easiness modifié: {card.get('easiness')}")
            if card.get('interval') != 0:  # Valeur par défaut
                checks.append(f"interval modifié: {card.get('interval')}")
            if card.get('consecutive_correct') > 0:
                checks.append(f"consecutive_correct: {card.get('consecutive_correct')}")
            
            if checks:
                return {
                    'success': True,
                    'details': f"Algorithme Anki actif: {', '.join(checks)}",
                    'data': card
                }
            else:
                return {
                    'success': False,
                    'error': "Les champs Anki n'ont pas été mis à jour",
                    'details': "BUG: L'algorithme Anki ne semble pas fonctionner"
                }
        else:
            return {
                'success': False,
                'error': f"Impossible de récupérer la carte: {response.text}"
            }

    async def test_verify_user_deck_stats(self):
        """Vérifie que les statistiques du deck utilisateur sont correctes"""
        response = await self._make_request('GET', '/api/users/decks')
        
        if response.status_code == 200:
            user_decks = response.json()
            
            # Trouver notre deck de test
            test_deck = None
            for deck in user_decks:
                if deck.get('deck_pk') == self.created_deck_id:
                    test_deck = deck
                    break
            
            if not test_deck:
                return {
                    'success': False,
                    'error': "Deck de test non trouvé dans les decks utilisateur"
                }
            
            # Vérifier les statistiques
            checks = []
            issues = []
            
            if test_deck.get('total_attempts', 0) > 0:
                checks.append(f"total_attempts: {test_deck['total_attempts']}")
            else:
                issues.append("total_attempts = 0 (devrait être > 0)")
            
            if test_deck.get('total_points', 0) > 0:
                checks.append(f"total_points: {test_deck['total_points']}")
            else:
                issues.append("total_points = 0 (devrait être > 0)")
            
            # Vérifier les points par type de quiz
            quiz_types = ['points_frappe', 'points_association', 'points_qcm', 'points_classique']
            for qt in quiz_types:
                if test_deck.get(qt, 0) > 0:
                    checks.append(f"{qt}: {test_deck[qt]}")
            
            if issues:
                return {
                    'success': False,
                    'error': "Statistiques incorrectes",
                    'details': '; '.join(issues),
                    'data': test_deck
                }
            else:
                return {
                    'success': True,
                    'details': f"Stats correctes: {', '.join(checks)}",
                    'data': test_deck
                }
        else:
            return {
                'success': False,
                'error': f"Status {response.status_code}: {response.text}"
            }

    # ============================================================================
    # TESTS DE NETTOYAGE
    # ============================================================================

    async def test_delete_cards(self):
        """Test de suppression des cartes créées"""
        if not self.created_card_ids:
            return {'success': True, 'details': 'Aucune carte à supprimer'}
        
        deleted_count = 0
        errors = []
        
        for card_id in self.created_card_ids:
            response = await self._make_request('DELETE', f'/cards/{card_id}')
            if response.status_code == 200:
                deleted_count += 1
            else:
                errors.append(f"Carte {card_id}: {response.text}")
        
        if deleted_count == len(self.created_card_ids):
            return {
                'success': True,
                'details': f"{deleted_count} cartes supprimées"
            }
        else:
            return {
                'success': False,
                'error': f"Seulement {deleted_count}/{len(self.created_card_ids)} cartes supprimées",
                'details': '; '.join(errors)
            }

    # ============================================================================
    # EXÉCUTION DE TOUS LES TESTS
    # ============================================================================

    async def run_all_tests(self):
        """Exécute tous les tests dans l'ordre"""
        print("\n" + "="*80)
        print("DÉBUT DES TESTS AUTOMATIQUES")
        print("="*80)
        
        # 1. Tests d'authentification
        print("\n📋 SECTION 1: AUTHENTIFICATION")
        await self.run_test("Création d'utilisateur", self.test_register_user)
        await self.run_test("Connexion utilisateur", self.test_login_user)
        
        # 2. Tests des decks
        print("\n📋 SECTION 2: GESTION DES DECKS")
        await self.run_test("Création d'un deck", self.test_create_deck)
        await self.run_test("Récupération de la liste des decks", self.test_get_decks)
        await self.run_test("Récupération d'un deck par ID", self.test_get_deck_by_id)
        
        # 3. Tests des cartes
        print("\n📋 SECTION 3: GESTION DES CARTES")
        await self.run_test("Création de cartes", self.test_create_cards)
        await self.run_test("Récupération de toutes les cartes", self.test_get_cards)
        await self.run_test("Récupération des cartes d'un deck", self.test_get_cards_by_deck)
        await self.run_test("Mise à jour d'une carte", self.test_update_card)
        
        # 4. Tests des decks utilisateur
        print("\n📋 SECTION 4: DECKS UTILISATEUR")
        await self.run_test("Ajout d'un deck à l'utilisateur", self.test_add_deck_to_user)
        await self.run_test("Récupération des decks utilisateur", self.test_get_user_decks)
        
        # 5. Tests des quiz et scores
        print("\n📋 SECTION 5: QUIZ ET SCORES")
        await self.run_test("Quiz type 'frappe'", self.test_quiz_frappe)
        await self.run_test("Quiz type 'association'", self.test_quiz_association)
        await self.run_test("Quiz type 'QCM'", self.test_quiz_qcm)
        await self.run_test("Quiz type 'classique'", self.test_quiz_classique)
        await self.run_test("Quiz avec réponse incorrecte", self.test_quiz_incorrect_answer)
        
        # 6. Vérifications de l'algorithme Anki et des stats
        print("\n📋 SECTION 6: VÉRIFICATIONS ALGORITHME ANKI & STATS")
        await self.run_test("Vérification algorithme Anki", self.test_verify_anki_algorithm)
        await self.run_test("Vérification statistiques deck utilisateur", self.test_verify_user_deck_stats)
        
        # 7. Nettoyage
        print("\n📋 SECTION 7: NETTOYAGE")
        await self.run_test("Suppression des cartes de test", self.test_delete_cards)
        
        # Génération du rapport
        print("\n" + "="*80)
        print("FIN DES TESTS")
        print("="*80)
        
        return self.report


async def main():
    """Point d'entrée principal"""
    print("""
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║           TEST AUTOMATIQUE COMPLET - APPRENDIAMO ITALIANO API             ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
    """)
    
    # Vérifier que le serveur est accessible
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get("http://localhost:8000/")
            if response.status_code != 200:
                print("❌ Le serveur ne répond pas correctement")
                return
    except Exception as e:
        print(f"❌ Impossible de se connecter au serveur: {e}")
        print("\n💡 Assurez-vous que le serveur est démarré avec:")
        print("   uvicorn app.main:app --reload")
        return
    
    # Exécuter les tests
    async with APITester() as tester:
        report = await tester.run_all_tests()
        
        # Afficher le rapport
        report_text = report.generate_report()
        print(report_text)
        
        # Sauvegarder le rapport
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        report_filename = f"test_report_{timestamp}.txt"
        with open(report_filename, 'w', encoding='utf-8') as f:
            f.write(report_text)
        
        print(f"\n📄 Rapport sauvegardé dans: {report_filename}")
        
        # Sauvegarder les bugs dans un fichier séparé
        if report.bugs_found:
            bugs_filename = f"bugs_found_{timestamp}.txt"
            with open(bugs_filename, 'w', encoding='utf-8') as f:
                f.write("BUGS IDENTIFIÉS\n")
                f.write("="*80 + "\n\n")
                for i, bug in enumerate(report.bugs_found, 1):
                    f.write(f"{i}. {bug}\n")
            print(f"🐛 Liste des bugs sauvegardée dans: {bugs_filename}")


if __name__ == "__main__":
    asyncio.run(main())
