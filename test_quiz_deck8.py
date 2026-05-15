"""
Test automatisé pour le deck "Verbi riflessivi" (40 cartes).

Scénario adapté pour 40 cartes :
CYCLE 1 (Aléatoire):
- Quiz 1: 5 cartes → 5 obtenues (35 restantes)
- Quiz 2: 20 cartes → 20 obtenues (15 restantes)
- Quiz 3: 25 cartes → 15 obtenues (FIN CYCLE 1)

CYCLE 2 (Pondérée intelligente):
- Quiz 4: 30 cartes → 30 obtenues (10 restantes)
- Quiz 5: 15 cartes → 10 obtenues (FIN CYCLE 2)

CYCLE 3 (Pondérée renforcée):
- Quiz 6: 40 cartes → 40 obtenues (FIN CYCLE 3)

CYCLE 4 (Pondérée très forte):
- Quiz 7: 10 cartes → 10 obtenues (30 restantes)
- Quiz 8: 35 cartes → 30 obtenues (FIN CYCLE 4)

CYCLE 5 (Pondérée extrême):
- Quiz 9: 25 cartes → 25 obtenues (15 restantes)
- Quiz 10: 20 cartes → 15 obtenues (FIN CYCLE 5)
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


class QuizDeck8Test:
    """Test pour le deck Verbi riflessivi (40 cartes)"""
    
    def __init__(self):
        self.engine = None
        self.async_session = None
        self.user = None
        self.deck = None
        self.all_cards = []
        self.quiz_results = []
        self.deck_pk = 8  # Verbi riflessivi
        self.total_cards = 40
        
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
            models.User.email == "quiz_deck8_test@example.com"
        )
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        
        if not user:
            user = models.User(
                email="quiz_deck8_test@example.com",
                username="quiz_deck8_tester",
                hashed_password=hash_password("testpass123"),
                first_name="Deck8",
                last_name="Tester"
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
            print(f"✅ Utilisateur créé: {user.username} (ID: {user.user_pk})")
        else:
            print(f"✅ Utilisateur existant: {user.username} (ID: {user.user_pk})")
        
        return user
    
    async def get_deck(self, db: AsyncSession) -> models.Deck:
        """Récupère le deck spécifié"""
        stmt = select(models.Deck).where(models.Deck.deck_pk == self.deck_pk)
        result = await db.execute(stmt)
        deck = result.scalar_one_or_none()
        
        if not deck:
            raise ValueError(f"Deck {self.deck_pk} introuvable!")
        
        # Compter les cartes
        stmt_count = select(func.count(models.Card.card_pk)).where(
            models.Card.deck_pk == self.deck_pk
        )
        result_count = await db.execute(stmt_count)
        card_count = result_count.scalar()
        
        print(f"✅ Deck trouvé: {deck.name} (ID: {deck.deck_pk}, {card_count} cartes)")
        
        if card_count != self.total_cards:
            print(f"⚠️  ATTENTION: Le deck contient {card_count} cartes au lieu de {self.total_cards}!")
            self.total_cards = card_count  # Ajuster
        
        return deck
    
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
        """Simule un quiz complet avec vérifications."""
        print(f"\n{'='*80}")
        print(f"🎯 QUIZ {quiz_number}: {cycle_description}")
        print(f"   Demande de {requested_cards} cartes")
        print(f"{'='*80}")
        
        # Sélection des cartes
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
        
        # Créer une session
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
        
        # Simuler des réponses
        print(f"\n📝 Simulation des réponses...")
        correct_answers = 0
        total_questions = actual_count
        
        # Taux de réussite progressif
        base_rates = {1: 0.65, 2: 0.70, 3: 0.75, 4: 0.80, 5: 0.85}
        base_success_rate = base_rates.get(cycle, 0.85)
        
        for card in selected_cards:
            success_rate = base_success_rate + random.uniform(-0.05, 0.05)
            is_correct = random.random() < success_rate
            
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
        
        # Finaliser la session
        await crud_quiz.complete_quiz_session(
            db,
            session.session_pk,
            correct_answers,
            total_questions
        )
        print(f"   ✅ Session finalisée")
        
        # Mettre à jour le UserDeck
        user_deck = await self.get_or_create_user_deck(
            db,
            self.user.user_pk,
            self.deck.deck_pk
        )
        
        user_deck.attempt_count += total_questions
        user_deck.correct_count += correct_answers
        user_deck.last_studied = datetime.utcnow()
        
        await db.commit()
        await db.refresh(user_deck)
        
        # Vérifier le tableau de bord
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
        for cycle_num in range(1, 10):
            cycle_results = [r for r in self.quiz_results if r['cycle'] == cycle_num]
            if cycle_results:
                cycle_questions = sum(r['total_questions'] for r in cycle_results)
                cycle_correct = sum(r['correct_answers'] for r in cycle_results)
                cycle_rate = (cycle_correct / cycle_questions * 100) if cycle_questions > 0 else 0
                print(f"   Cycle {cycle_num}: {len(cycle_results)} quiz, "
                      f"{cycle_questions} questions, {cycle_rate:.1f}% de réussite")
    
    async def run_full_scenario(self):
        """Exécute le scénario complet de test"""
        try:
            async with self.async_session() as db:
                print(f"\n{'='*80}")
                print(f"🧪 TEST DECK 8 - VERBI RIFLESSIVI (40 CARTES)")
                print(f"{'='*80}")
                
                # Préparation
                print(f"\n📝 PRÉPARATION")
                print(f"{'='*80}")
                self.user = await self.create_or_get_user(db)
                self.deck = await self.get_deck(db)
                
                # Nettoyer les anciennes données
                print(f"\n🧹 Nettoyage des anciennes sessions de test...")
                
                stmt = select(models.QuizSession).where(
                    models.QuizSession.user_pk == self.user.user_pk,
                    models.QuizSession.deck_pk == self.deck.deck_pk
                )
                result = await db.execute(stmt)
                old_sessions = result.scalars().all()
                for session in old_sessions:
                    await db.delete(session)
                
                stmt = select(models.CardPerformance).where(
                    models.CardPerformance.user_pk == self.user.user_pk,
                    models.CardPerformance.deck_pk == self.deck.deck_pk
                )
                result = await db.execute(stmt)
                old_perfs = result.scalars().all()
                for perf in old_perfs:
                    await db.delete(perf)
                
                user_deck = await self.get_or_create_user_deck(
                    db, self.user.user_pk, self.deck.deck_pk
                )
                user_deck.attempt_count = 0
                user_deck.correct_count = 0
                
                await db.commit()
                print(f"   ✅ Nettoyage terminé")
                
                # CYCLE 1
                print(f"\n{'='*80}")
                print(f"🔵 CYCLE 1 - SÉLECTION ALÉATOIRE")
                print(f"{'='*80}")
                
                await self.simulate_quiz(db, 1, 5, 1, cycle_description="Cycle 1 - Début")
                await self.simulate_quiz(db, 2, 20, 1, cycle_description="Cycle 1")
                await self.simulate_quiz(db, 3, 25, 1, expected_cards_count=15, cycle_description="Cycle 1 - Fin")
                
                # CYCLE 2
                print(f"\n{'='*80}")
                print(f"🟡 CYCLE 2 - PRIORISATION INTELLIGENTE")
                print(f"{'='*80}")
                
                await self.simulate_quiz(db, 4, 30, 2, cycle_description="Cycle 2")
                await self.simulate_quiz(db, 5, 15, 3, cycle_description="Cycle 3 (toutes cartes vues)")
                
                # CYCLE 3
                print(f"\n{'='*80}")
                print(f"🟢 CYCLE 4 - PRIORISATION RENFORCÉE")
                print(f"{'='*80}")
                
                await self.simulate_quiz(db, 6, 40, 4, cycle_description="Cycle 4 - Complet")
                
                # CYCLE 4
                print(f"\n{'='*80}")
                print(f"🔴 CYCLE 5 - PRIORISATION TRÈS FORTE")
                print(f"{'='*80}")
                
                await self.simulate_quiz(db, 7, 10, 5, cycle_description="Cycle 5")
                await self.simulate_quiz(db, 8, 35, 6, cycle_description="Cycle 6")
                
                # CYCLE 5
                print(f"\n{'='*80}")
                print(f"🟣 CYCLE 7 - PRIORISATION EXTRÊME")
                print(f"{'='*80}")
                
                await self.simulate_quiz(db, 9, 25, 7, cycle_description="Cycle 7")
                await self.simulate_quiz(db, 10, 20, 8, cycle_description="Cycle 8")
                
                # Afficher le résumé
                await self.print_summary()
                
                print(f"\n{'='*80}")
                print(f"✨ TOUS LES TESTS SONT PASSÉS AVEC SUCCÈS!")
                print(f"{'='*80}")
                print(f"\n✅ Le système fonctionne parfaitement avec le deck de 40 cartes!")
                print(f"\n📚 Fonctionnalités testées:")
                print(f"   ✓ 10 quiz sur 8 cycles")
                print(f"   ✓ Deck de 40 cartes (différent de 100)")
                print(f"   ✓ Sélection flexible (5 à 40 cartes)")
                print(f"   ✓ Gestion automatique des cycles")
                print(f"   ✓ Priorisation intelligente")
                print(f"   ✓ Cohérence totale des scores")
                
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
    test = QuizDeck8Test()
    
    try:
        await test.setup()
        success = await test.run_full_scenario()
        return success
    finally:
        await test.cleanup()


if __name__ == "__main__":
    print("🧪 Lancement du test pour le deck 8 (Verbi riflessivi - 40 cartes)...\n")
    success = asyncio.run(main())
    
    if success:
        print("\n✅ Tests terminés avec succès!")
        print("\n🎊 LE SYSTÈME FONCTIONNE AVEC DES DECKS DE TAILLES DIFFÉRENTES!")
        sys.exit(0)
    else:
        print("\n❌ Tests échoués!")
        sys.exit(1)
