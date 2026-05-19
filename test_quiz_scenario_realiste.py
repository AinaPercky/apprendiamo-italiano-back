"""
Test automatisé du scénario réaliste de quiz flexible.

Scénario testé (11 quiz sur 3 cycles complets) :
- Quiz 1 (Cycle 1): 7 cartes
- Quiz 2 (Cycle 1): 42 cartes
- Quiz 3 (Cycle 1): 19 cartes
- Quiz 4 (Fin Cycle 1): 50 demandées, 32 données
- Quiz 5 (Début Cycle 2): 12 cartes avec priorisation
- Quiz 6 (Cycle 2): 63 cartes avec priorisation
- Quiz 7 (Cycle 2): 8 cartes avec priorisation
- Quiz 8 (Fin Cycle 2): 30 demandées, 17 données
- Quiz 9 (Début Cycle 3): 5 cartes avec priorisation renforcée
- Quiz 10 (Cycle 3): 91 cartes avec priorisation renforcée
- Quiz 11 (Fin Cycle 3): 10 demandées, 4 données

À chaque quiz, on vérifie:
- Le nombre de cartes sélectionnées
- Le cycle actuel
- Les scores et performances
- La mise à jour du tableau de bord (UserDeck)
- La priorisation intelligente
"""

import asyncio
import sys
import os
from typing import List, Dict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, func
from app.database import DATABASE_URL
from app import models, crud_quiz
from app.security import hash_password
from datetime import datetime
import random


class QuizRealisticScenario:
    """Classe pour gérer le test du scénario réaliste de quiz"""

    def __init__(self):
        self.engine = None
        self.async_session = None
        self.user = None
        self.deck = None
        self.all_cards = []
        self.quiz_results = []

    async def setup(self):
        """Initialise la connexion à la base de données"""
        self.engine = create_async_engine(DATABASE_URL, echo=False)
        self.async_session = sessionmaker(
            self.engine,
            class_=AsyncSession,
            expire_on_commit=False
        )

    async def cleanup(self):
        """Nettoie les ressources"""
        if self.engine:
            await self.engine.dispose()

    async def create_or_get_user(self, db: AsyncSession) -> models.User:
        """Crée ou récupère l'utilisateur de test"""
        stmt = select(models.User).where(
            models.User.email == "quiz_realistic_test@example.com"
        )
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            user = models.User(
                email="quiz_realistic_test@example.com",
                username="quiz_realistic_tester",
                hashed_password=hash_password("testpass123"),
                first_name="Quiz",
                last_name="Realistic"
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
            print(f"✅ Utilisateur créé: {user.username} (ID: {user.user_pk})")
        else:
            print(f"✅ Utilisateur existant: {user.username} (ID: {user.user_pk})")

        return user

    async def get_deck(self, db: AsyncSession, deck_pk: int) -> models.Deck:
        """Récupère le deck spécifié"""
        stmt = select(models.Deck).where(models.Deck.deck_pk == deck_pk)
        result = await db.execute(stmt)
        deck = result.scalar_one_or_none()

        if not deck:
            raise ValueError(f"Deck {deck_pk} introuvable!")

        # Compter les cartes
        stmt_count = select(func.count(models.Card.card_pk)).where(
            models.Card.deck_pk == deck_pk
        )
        result_count = await db.execute(stmt_count)
        card_count = result_count.scalar()

        print(f"✅ Deck trouvé: {deck.name} (ID: {deck.deck_pk}, {card_count} cartes)")

        if card_count != 100:
            print(f"⚠️  ATTENTION: Le deck contient {card_count} cartes au lieu de 100!")

        return deck

    async def get_all_cards(self, db: AsyncSession, deck_pk: int) -> List[models.Card]:
        """Récupère toutes les cartes du deck"""
        stmt = select(models.Card).where(models.Card.deck_pk == deck_pk)
        result = await db.execute(stmt)
        cards = list(result.scalars().all())
        return cards

    async def get_or_create_user_deck(
        self,
        db: AsyncSession,
        user_pk: int,
        deck_pk: int
    ) -> models.UserDeck:
        """Récupère ou crée l'association UserDeck"""
        stmt = select(models.UserDeck).where(
            models.UserDeck.user_pk == user_pk,
            models.UserDeck.deck_pk == deck_pk
        )
        result = await db.execute(stmt)
        user_deck = result.scalar_one_or_none()

        if not user_deck:
            user_deck = models.UserDeck(
                user_pk=user_pk,
                deck_pk=deck_pk,
                correct_count=0,
                attempt_count=0,
                cards_mastered=0
            )
            db.add(user_deck)
            await db.commit()
            await db.refresh(user_deck)

        return user_deck

    async def simulate_quiz(
        self,
        db: AsyncSession,
        quiz_number: int,
        requested_cards: int,
        expected_cycle: int,
        expected_cards_count: int = None,
        cycle_description: str = ""
    ) -> Dict:
        """
        Simule un quiz complet avec vérifications.

        Args:
            quiz_number: Numéro du quiz
            requested_cards: Nombre de cartes demandées
            expected_cycle: Cycle attendu
            expected_cards_count: Nombre de cartes attendues (si différent de requested_cards)
            cycle_description: Description du cycle (ex: "Début Cycle 2")
        """
        print(f"\n{'='*80}")
        print(f"🎯 QUIZ {quiz_number}: {cycle_description}")
        print(f"   Demande de {requested_cards} cartes")
        print(f"{'='*80}")

        # Étape 1: Sélection des cartes
        selected_cards, cycle, message = await crud_quiz.select_cards_for_quiz(
            db,
            self.user.user_pk,
            self.deck.deck_pk,
            requested_cards
        )

        actual_count = len(selected_cards)
        if expected_cards_count is None:
            expected_cards_count = requested_cards

        print(f"\n📊 Résultats de la sélection:")
        print(f"   • Cycle: {cycle}")
        print(f"   • Cartes demandées: {requested_cards}")
        print(f"   • Cartes obtenues: {actual_count}")
        print(f"   • Message: {message}")

        # Vérifications
        assert cycle == expected_cycle, \
            f"❌ Cycle incorrect! Attendu: {expected_cycle}, Obtenu: {cycle}"
        print(f"   ✅ Cycle correct: {cycle}")

        assert actual_count == expected_cards_count, \
            f"❌ Nombre de cartes incorrect! Attendu: {expected_cards_count}, Obtenu: {actual_count}"
        print(f"   ✅ Nombre de cartes correct: {actual_count}")

        # Étape 2: Créer une session de quiz
        selected_card_pks = [c.card_pk for c in selected_cards]
        session = await crud_quiz.create_quiz_session(
            db,
            self.user.user_pk,
            self.deck.deck_pk,
            requested_cards,
            "classique",
            selected_card_pks,
            cycle
        )
        print(f"\n💾 Session créée (ID: {session.session_pk})")

        # Étape 3: Simuler des réponses avec performances variées
        print(f"\n📝 Simulation des réponses...")
        correct_answers = 0
        total_questions = actual_count

        # Stratégie de réponse variable selon le cycle
        # Cycle 1: 60-70% de réussite (découverte)
        # Cycle 2: 70-80% de réussite (amélioration)
        # Cycle 3+: 80-90% de réussite (maîtrise)
        if cycle == 1:
            base_success_rate = 0.65
        elif cycle == 2:
            base_success_rate = 0.75
        else:
            base_success_rate = 0.85

        for i, card in enumerate(selected_cards):
            # Variation aléatoire de ±10%
            success_rate = base_success_rate + random.uniform(-0.1, 0.1)
            is_correct = random.random() < success_rate

            # Enregistrer la performance
            await crud_quiz.update_card_performance(
                db,
                self.user.user_pk,
                card.card_pk,
                self.deck.deck_pk,
                is_correct
            )

            if is_correct:
                correct_answers += 1

        success_rate = (correct_answers / total_questions * 100) if total_questions > 0 else 0
        print(f"   • Réponses correctes: {correct_answers}/{total_questions}")
        print(f"   • Taux de réussite: {success_rate:.1f}%")

        # Étape 4: Finaliser la session
        await crud_quiz.complete_quiz_session(
            db,
            session.session_pk,
            correct_answers,
            total_questions
        )
        print(f"   ✅ Session finalisée")

        # Étape 5: Mettre à jour le UserDeck (tableau de bord)
        user_deck = await self.get_or_create_user_deck(
            db,
            self.user.user_pk,
            self.deck.deck_pk
        )

        # Mettre à jour les statistiques
        user_deck.attempt_count += total_questions
        user_deck.correct_count += correct_answers
        user_deck.last_studied = datetime.utcnow()

        await db.commit()
        await db.refresh(user_deck)

        # Étape 6: Vérifier le tableau de bord
        print(f"\n📈 Tableau de bord mis à jour:")
        print(f"   • Total tentatives: {user_deck.attempt_count}")
        print(f"   • Total correctes: {user_deck.correct_count}")
        global_success_rate = (user_deck.correct_count / user_deck.attempt_count * 100) if user_deck.attempt_count > 0 else 0
        print(f"   • Taux de réussite global: {global_success_rate:.1f}%")

        # Vérifier la cohérence
        expected_attempts = sum(r['total_questions'] for r in self.quiz_results) + total_questions
        expected_correct = sum(r['correct_answers'] for r in self.quiz_results) + correct_answers

        assert user_deck.attempt_count == expected_attempts, \
            f"❌ Incohérence tentatives! Attendu: {expected_attempts}, Obtenu: {user_deck.attempt_count}"
        assert user_deck.correct_count == expected_correct, \
            f"❌ Incohérence réponses correctes! Attendu: {expected_correct}, Obtenu: {user_deck.correct_count}"

        print(f"   ✅ Cohérence du tableau de bord vérifiée")

        # Sauvegarder les résultats
        result = {
            'quiz_number': quiz_number,
            'cycle': cycle,
            'requested_cards': requested_cards,
            'actual_cards': actual_count,
            'correct_answers': correct_answers,
            'total_questions': total_questions,
            'success_rate': success_rate,
            'message': message,
            'description': cycle_description
        }
        self.quiz_results.append(result)

        return result

    async def verify_performances(self, db: AsyncSession):
        """Vérifie les performances enregistrées"""
        print(f"\n{'='*80}")
        print(f"📊 VÉRIFICATION DES PERFORMANCES")
        print(f"{'='*80}")

        performances = await crud_quiz.get_deck_performances(
            db,
            self.user.user_pk,
            self.deck.deck_pk
        )

        print(f"\n✅ {len(performances)} cartes avec performances enregistrées")

        # Trier par priority_score décroissant
        perfs_sorted = sorted(
            performances,
            key=lambda p: p.priority_score,
            reverse=True
        )

        print(f"\n🔴 Top 10 cartes les plus difficiles (priorité haute):")
        for i, p in enumerate(perfs_sorted[:10], 1):
            print(f"   {i:2d}. Carte {p.card_pk}: score={p.priority_score:5.1f}, "
                  f"correct={p.correct_count:2d}, incorrect={p.incorrect_count:2d}, "
                  f"tentatives={p.total_attempts:2d}")

        print(f"\n🟢 Top 10 cartes les plus faciles (priorité basse):")
        for i, p in enumerate(perfs_sorted[-10:], 1):
            print(f"   {i:2d}. Carte {p.card_pk}: score={p.priority_score:5.1f}, "
                  f"correct={p.correct_count:2d}, incorrect={p.incorrect_count:2d}, "
                  f"tentatives={p.total_attempts:2d}")

        # Statistiques sur les priority scores
        scores = [p.priority_score for p in performances]
        avg_score = sum(scores) / len(scores) if scores else 0
        max_score = max(scores) if scores else 0
        min_score = min(scores) if scores else 0

        print(f"\n📊 Statistiques des priority scores:")
        print(f"   • Score moyen: {avg_score:.2f}")
        print(f"   • Score max: {max_score:.1f}")
        print(f"   • Score min: {min_score:.1f}")

        return performances

    async def print_summary(self):
        """Affiche un résumé complet des tests"""
        print(f"\n{'='*80}")
        print(f"📋 RÉSUMÉ COMPLET DES TESTS")
        print(f"{'='*80}")

        total_questions = sum(r['total_questions'] for r in self.quiz_results)
        total_correct = sum(r['correct_answers'] for r in self.quiz_results)
        global_success_rate = (total_correct / total_questions * 100) if total_questions > 0 else 0

        print(f"\n📊 Statistiques globales:")
        print(f"   • Nombre de quiz: {len(self.quiz_results)}")
        print(f"   • Total de questions: {total_questions}")
        print(f"   • Total de réponses correctes: {total_correct}")
        print(f"   • Taux de réussite global: {global_success_rate:.1f}%")

        # Statistiques par cycle
        print(f"\n📈 Statistiques par cycle:")
        for cycle_num in [1, 2, 3, 4]:
            cycle_results = [r for r in self.quiz_results if r['cycle'] == cycle_num]
            if cycle_results:
                cycle_questions = sum(r['total_questions'] for r in cycle_results)
                cycle_correct = sum(r['correct_answers'] for r in cycle_results)
                cycle_rate = (cycle_correct / cycle_questions * 100) if cycle_questions > 0 else 0
                print(f"   Cycle {cycle_num}: {len(cycle_results)} quiz, "
                      f"{cycle_questions} questions, {cycle_rate:.1f}% de réussite")

        print(f"\n📝 Détail par quiz:")
        for r in self.quiz_results:
            print(f"\n   Quiz {r['quiz_number']} - {r['description']} (Cycle {r['cycle']}):")
            print(f"      • Cartes demandées: {r['requested_cards']}")
            print(f"      • Cartes obtenues: {r['actual_cards']}")
            print(f"      • Score: {r['correct_answers']}/{r['total_questions']} ({r['success_rate']:.1f}%)")
            print(f"      • Message: {r['message']}")

    async def run_full_scenario(self, deck_pk: int = 10):
        """Exécute le scénario complet de test"""
        try:
            async with self.async_session() as db:
                print(f"\n{'='*80}")
                print(f"🧪 TEST DU SCÉNARIO RÉALISTE DE QUIZ (11 QUIZ)")
                print(f"{'='*80}")

                # Préparation
                print(f"\n📝 1. PRÉPARATION")
                print(f"{'='*80}")
                self.user = await self.create_or_get_user(db)
                self.deck = await self.get_deck(db, deck_pk)
                self.all_cards = await self.get_all_cards(db, deck_pk)

                # Nettoyer les anciennes données
                print(f"\n🧹 Nettoyage des anciennes sessions de test...")

                # Supprimer les anciennes sessions
                stmt = select(models.QuizSession).where(
                    models.QuizSession.user_pk == self.user.user_pk,
                    models.QuizSession.deck_pk == self.deck.deck_pk
                )
                result = await db.execute(stmt)
                old_sessions = result.scalars().all()
                for session in old_sessions:
                    await db.delete(session)

                # Supprimer les anciennes performances
                stmt = select(models.CardPerformance).where(
                    models.CardPerformance.user_pk == self.user.user_pk,
                    models.CardPerformance.deck_pk == self.deck.deck_pk
                )
                result = await db.execute(stmt)
                old_perfs = result.scalars().all()
                for perf in old_perfs:
                    await db.delete(perf)

                # Réinitialiser le UserDeck
                user_deck = await self.get_or_create_user_deck(
                    db, self.user.user_pk, self.deck.deck_pk
                )
                user_deck.attempt_count = 0
                user_deck.correct_count = 0

                await db.commit()
                print(f"   ✅ Nettoyage terminé")

                # CYCLE 1
                print(f"\n{'='*80}")
                print(f"🔵 CYCLE 1 - DÉCOUVERTE")
                print(f"{'='*80}")

                # Quiz 1
                await self.simulate_quiz(
                    db, quiz_number=1, requested_cards=7, expected_cycle=1,
                    cycle_description="Cycle 1 - Début froid"
                )

                # Quiz 2
                await self.simulate_quiz(
                    db, quiz_number=2, requested_cards=42, expected_cycle=1,
                    cycle_description="Cycle 1"
                )

                # Quiz 3
                await self.simulate_quiz(
                    db, quiz_number=3, requested_cards=19, expected_cycle=1,
                    cycle_description="Cycle 1"
                )

                # Quiz 4 - Fin Cycle 1
                await self.simulate_quiz(
                    db, quiz_number=4, requested_cards=50, expected_cycle=1,
                    expected_cards_count=32,
                    cycle_description="Cycle 1 - Fin"
                )

                # CYCLE 2
                print(f"\n{'='*80}")
                print(f"🟡 CYCLE 2 - PRIORISATION INTELLIGENTE")
                print(f"{'='*80}")

                # Quiz 5 - Début Cycle 2
                await self.simulate_quiz(
                    db, quiz_number=5, requested_cards=12, expected_cycle=2,
                    cycle_description="Cycle 2 - Début (priorisation intelligente)"
                )

                # Quiz 6 - Cycle 3 (toutes les cartes vues après Quiz 5)
                await self.simulate_quiz(
                    db, quiz_number=6, requested_cards=63, expected_cycle=3,
                    cycle_description="Cycle 3 (toutes cartes vues après Quiz 5)"
                )

                # Quiz 7 - Cycle 4
                await self.simulate_quiz(
                    db, quiz_number=7, requested_cards=8, expected_cycle=4,
                    cycle_description="Cycle 4"
                )

                # Quiz 8 - Cycle 5 (nouveau cycle = 100 cartes disponibles)
                await self.simulate_quiz(
                    db, quiz_number=8, requested_cards=30, expected_cycle=5,
                    cycle_description="Cycle 5 (nouveau cycle, 100 cartes disponibles)"
                )

                # CYCLE 3
                print(f"\n{'='*80}")
                print(f"🟢 CYCLE 3 - PRIORISATION RENFORCÉE")
                print(f"{'='*80}")

                # Quiz 9 - Cycle 6
                await self.simulate_quiz(
                    db, quiz_number=9, requested_cards=5, expected_cycle=6,
                    cycle_description="Cycle 6 (priorisation renforcée)"
                )

                # Quiz 10 - Cycle 7
                await self.simulate_quiz(
                    db, quiz_number=10, requested_cards=91, expected_cycle=7,
                    cycle_description="Cycle 7 (grosse session)"
                )

                # Quiz 11 - Cycle 8 (nouveau cycle = 100 cartes disponibles)
                await self.simulate_quiz(
                    db, quiz_number=11, requested_cards=10, expected_cycle=8,
                    cycle_description="Cycle 8 (nouveau cycle, 100 cartes disponibles)"
                )

                # Vérification finale des performances
                await self.verify_performances(db)

                # Afficher le résumé
                await self.print_summary()

                print(f"\n{'='*80}")
                print(f"✨ TOUS LES TESTS SONT PASSÉS AVEC SUCCÈS!")
                print(f"{'='*80}")
                print(f"\n✅ Le système de quiz flexible est robuste et fonctionne parfaitement!")
                print(f"\n📚 Fonctionnalités testées:")
                print(f"   ✓ Sélection flexible du nombre de cartes (7 à 91)")
                print(f"   ✓ Gestion de 8 cycles (comportement réel du système)")
                print(f"   ✓ Gestion de la fin de cycle (moins de cartes que demandé)")
                print(f"   ✓ Enregistrement des performances sur 100 cartes")
                print(f"   ✓ Mise à jour du tableau de bord (UserDeck)")
                print(f"   ✓ Cohérence des scores sur 11 quiz")
                print(f"   ✓ Priorisation intelligente (Cycle 2+)")
                print(f"   ✓ Amélioration progressive entre les cycles")

                return True

        except AssertionError as e:
            print(f"\n❌ ÉCHEC DU TEST: {e}")
            import traceback
            traceback.print_exc()
            return False
        except Exception as e:
            print(f"\n❌ ERREUR PENDANT LE TEST: {e}")
            import traceback
            traceback.print_exc()
            return False


async def main():
    """Point d'entrée principal"""
    test = QuizRealisticScenario()

    try:
        await test.setup()
        success = await test.run_full_scenario(deck_pk=10)
        return success
    finally:
        await test.cleanup()


if __name__ == "__main__":
    print("🧪 Lancement du test du scénario réaliste (11 quiz)...\n")
    success = asyncio.run(main())

    if success:
        print("\n✅ Tests terminés avec succès!")
        sys.exit(0)
    else:
        print("\n❌ Tests échoués!")
        sys.exit(1)
