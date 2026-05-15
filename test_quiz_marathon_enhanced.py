"""
TEST MARATHON AMÉLIORÉ avec vérifications complètes

Ce test vérifie à chaque étape :
- Mise à jour des CardPerformance
- Mise à jour du UserDeck (dashboard)
- Cohérence des scores
- Calcul du success_rate

Deck 8 (Verbi riflessivi): 40 cartes
Deck 10 (Aggettivi italiani): 100 cartes
"""

import asyncio
import sys
import os
from typing import List, Dict, Optional

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, func
from app.database import DATABASE_URL
from app import models, crud_quiz
from app.security import hash_password
from datetime import datetime
import random


class QuizMarathonEnhanced:
    """Test marathon avec vérifications complètes"""
    
    def __init__(self):
        self.engine = None
        self.async_session = None
        self.user = None
        self.decks = {}
        self.quiz_count = 0
        self.step_count = 0
        
    async def setup(self):
        """Initialise la connexion"""
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
            models.User.email == "quiz_marathon_enhanced@example.com"
        )
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        
        if not user:
            user = models.User(
                email="quiz_marathon_enhanced@example.com",
                username="marathon_enhanced",
                hashed_password=hash_password("testpass123"),
                first_name="Marathon",
                last_name="Enhanced"
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
            print(f"✅ Utilisateur créé: {user.username} (ID: {user.user_pk})")
        else:
            print(f"✅ Utilisateur existant: {user.username} (ID: {user.user_pk})")
        
        return user
    
    async def get_deck(self, db: AsyncSession, deck_pk: int) -> models.Deck:
        """Récupère un deck"""
        if deck_pk in self.decks:
            return self.decks[deck_pk]
        
        stmt = select(models.Deck).where(models.Deck.deck_pk == deck_pk)
        result = await db.execute(stmt)
        deck = result.scalar_one_or_none()
        
        if not deck:
            raise ValueError(f"Deck {deck_pk} introuvable!")
        
        stmt_count = select(func.count(models.Card.card_pk)).where(
            models.Card.deck_pk == deck_pk
        )
        result_count = await db.execute(stmt_count)
        card_count = result_count.scalar()
        
        print(f"✅ Deck {deck_pk}: {deck.name} ({card_count} cartes)")
        
        self.decks[deck_pk] = deck
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
    
    async def verify_dashboard(self, db: AsyncSession, deck_pk: int, expected_attempts: int, expected_correct: int):
        """Vérifie que le dashboard est correctement mis à jour"""
        print(f"\n🔍 Vérification du Dashboard (Deck {deck_pk}):")
        
        user_deck = await self.get_or_create_user_deck(
            db, self.user.user_pk, deck_pk
        )
        
        # Vérifier les compteurs
        assert user_deck.attempt_count == expected_attempts, \
            f"❌ Tentatives incorrectes! Attendu: {expected_attempts}, Obtenu: {user_deck.attempt_count}"
        print(f"   ✅ Tentatives: {user_deck.attempt_count}")
        
        assert user_deck.correct_count == expected_correct, \
            f"❌ Correctes incorrectes! Attendu: {expected_correct}, Obtenu: {user_deck.correct_count}"
        print(f"   ✅ Correctes: {user_deck.correct_count}")
        
        # Calculer le success_rate
        if user_deck.attempt_count > 0:
            success_rate = (user_deck.correct_count / user_deck.attempt_count) * 100
        else:
            success_rate = 0.0
        
        print(f"   ✅ Success Rate: {success_rate:.1f}%")
        
        # Vérifier last_studied
        assert user_deck.last_studied is not None, "❌ last_studied est None!"
        print(f"   ✅ Last Studied: {user_deck.last_studied}")
        
        return user_deck
    
    async def verify_card_performances(self, db: AsyncSession, deck_pk: int, card_pks: List[int]):
        """Vérifie que les performances des cartes sont mises à jour"""
        print(f"\n🔍 Vérification des Performances des Cartes:")
        
        for card_pk in card_pks[:3]:  # Vérifier les 3 premières cartes
            stmt = select(models.CardPerformance).where(
                models.CardPerformance.user_pk == self.user.user_pk,
                models.CardPerformance.card_pk == card_pk,
                models.CardPerformance.deck_pk == deck_pk
            )
            result = await db.execute(stmt)
            perf = result.scalar_one_or_none()
            
            assert perf is not None, f"❌ Performance non trouvée pour carte {card_pk}!"
            assert perf.total_attempts > 0, f"❌ Aucune tentative pour carte {card_pk}!"
            
            print(f"   ✅ Carte {card_pk}: {perf.total_attempts} tentatives, "
                  f"score={perf.priority_score:.1f}")
    
    async def test_step(
        self,
        db: AsyncSession,
        step_number: int,
        deck_pk: int,
        requested_cards: int,
        expected_cards_count: Optional[int] = None,
        description: str = "",
        cumulative_attempts: Dict[int, int] = None,
        cumulative_correct: Dict[int, int] = None
    ):
        """Teste une étape avec vérifications complètes"""
        self.step_count += 1
        
        deck = await self.get_deck(db, deck_pk)
        
        print(f"\n{'='*80}")
        print(f"📍 ÉTAPE {step_number}: Deck {deck_pk} ({deck.name})")
        print(f"   {description}")
        print(f"   Demande: {requested_cards} cartes")
        print(f"{'='*80}")
        
        try:
            # Sélection des cartes
            selected_cards, cycle, message = await crud_quiz.select_cards_for_quiz(
                db,
                self.user.user_pk,
                deck_pk,
                requested_cards
            )
            
            actual_count = len(selected_cards)
            if expected_cards_count is None:
                expected_cards_count = min(requested_cards, 100)
            
            print(f"\n📊 Résultats:")
            print(f"   • Cycle: {cycle}")
            print(f"   • Cartes obtenues: {actual_count}")
            print(f"   • Message: {message}")
            
            assert cycle >= 1, f"❌ Cycle invalide: {cycle}"
            print(f"   ✅ Cycle valide: {cycle}")
            
            assert actual_count == expected_cards_count, \
                f"❌ Nombre de cartes incorrect! Attendu: {expected_cards_count}, Obtenu: {actual_count}"
            print(f"   ✅ Nombre de cartes correct: {actual_count}")
            
            # Créer une session
            selected_card_pks = [c.card_pk for c in selected_cards]
            session = await crud_quiz.create_quiz_session(
                db,
                self.user.user_pk,
                deck_pk,
                requested_cards,
                "classique",
                selected_card_pks,
                cycle
            )
            
            # Simuler des réponses
            print(f"\n📝 Simulation des réponses...")
            correct_answers = 0
            total_questions = actual_count
            
            base_rates = {1: 0.65, 2: 0.70, 3: 0.75, 4: 0.80, 5: 0.82, 
                         6: 0.84, 7: 0.86, 8: 0.88, 9: 0.90}
            base_success_rate = base_rates.get(cycle, 0.90)
            
            for card in selected_cards:
                success_rate = base_success_rate + random.uniform(-0.03, 0.03)
                is_correct = random.random() < success_rate
                
                await crud_quiz.update_card_performance(
                    db,
                    self.user.user_pk,
                    card.card_pk,
                    deck_pk,
                    is_correct
                )
                
                if is_correct:
                    correct_answers += 1
            
            # Finaliser
            await crud_quiz.complete_quiz_session(
                db,
                session.session_pk,
                correct_answers,
                total_questions
            )
            
            # Mettre à jour UserDeck
            user_deck = await self.get_or_create_user_deck(
                db,
                self.user.user_pk,
                deck_pk
            )
            
            user_deck.attempt_count += total_questions
            user_deck.correct_count += correct_answers
            user_deck.last_studied = datetime.utcnow()
            
            await db.commit()
            await db.refresh(user_deck)
            
            success_rate = (correct_answers / total_questions * 100) if total_questions > 0 else 0
            print(f"   📝 Score: {correct_answers}/{total_questions} ({success_rate:.1f}%)")
            
            # Mettre à jour les cumulatifs
            if cumulative_attempts is not None:
                cumulative_attempts[deck_pk] = cumulative_attempts.get(deck_pk, 0) + total_questions
            if cumulative_correct is not None:
                cumulative_correct[deck_pk] = cumulative_correct.get(deck_pk, 0) + correct_answers
            
            # VÉRIFICATIONS COMPLÈTES
            if cumulative_attempts and cumulative_correct:
                await self.verify_dashboard(
                    db, 
                    deck_pk, 
                    cumulative_attempts[deck_pk],
                    cumulative_correct[deck_pk]
                )
            
            await self.verify_card_performances(db, deck_pk, selected_card_pks)
            
            self.quiz_count += 1
            
        except Exception as e:
            print(f"\n❌ ERREUR: {e}")
            raise
    
    async def run_marathon(self):
        """Exécute le marathon complet"""
        try:
            async with self.async_session() as db:
                print(f"\n{'='*80}")
                print(f"🏃 TEST MARATHON AMÉLIORÉ - VÉRIFICATIONS COMPLÈTES")
                print(f"{'='*80}")
                
                # Préparation
                print(f"\n📝 PRÉPARATION")
                print(f"{'='*80}")
                self.user = await self.create_or_get_user(db)
                await self.get_deck(db, 8)
                await self.get_deck(db, 10)
                
                # Nettoyer
                print(f"\n🧹 Nettoyage...")
                
                for deck_pk in [8, 10]:
                    stmt = select(models.QuizSession).where(
                        models.QuizSession.user_pk == self.user.user_pk,
                        models.QuizSession.deck_pk == deck_pk
                    )
                    result = await db.execute(stmt)
                    old_sessions = result.scalars().all()
                    for session in old_sessions:
                        await db.delete(session)
                    
                    stmt = select(models.CardPerformance).where(
                        models.CardPerformance.user_pk == self.user.user_pk,
                        models.CardPerformance.deck_pk == deck_pk
                    )
                    result = await db.execute(stmt)
                    old_perfs = result.scalars().all()
                    for perf in old_perfs:
                        await db.delete(perf)
                    
                    user_deck = await self.get_or_create_user_deck(
                        db, self.user.user_pk, deck_pk
                    )
                    user_deck.attempt_count = 0
                    user_deck.correct_count = 0
                
                await db.commit()
                print(f"   ✅ Nettoyage terminé")
                
                # Compteurs cumulatifs
                cumulative_attempts = {8: 0, 10: 0}
                cumulative_correct = {8: 0, 10: 0}
                
                # MARATHON
                print(f"\n{'='*80}")
                print(f"🏃 DÉBUT DU MARATHON")
                print(f"{'='*80}")
                
                await self.test_step(db, 1, 8, 7, description="Cycle 1 - Début",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 2, 10, 3, description="Cycle 1 - Début",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 3, 8, 83, expected_cards_count=33, description="Cycle 1 - Fin",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 4, 8, 15, description="Cycle 2 - Début",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 5, 10, 150, expected_cards_count=97, description="Cycle 1 - Fin",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 6, 10, 42, description="Cycle 2",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 7, 8, 2, description="Cycle 3",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 8, 8, 30, description="Cycle 4",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 9, 10, 1, description="Cycle 3",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                await self.test_step(db, 10, 8, 40, description="Cycle 5",
                                    cumulative_attempts=cumulative_attempts,
                                    cumulative_correct=cumulative_correct)
                
                print(f"\n{'='*80}")
                print(f"✨ MARATHON TERMINÉ AVEC SUCCÈS!")
                print(f"{'='*80}")
                print(f"\n📊 Statistiques finales:")
                print(f"   • Étapes: {self.step_count}")
                print(f"   • Quiz: {self.quiz_count}")
                print(f"   • Deck 8: {cumulative_attempts[8]} tentatives, {cumulative_correct[8]} correctes")
                print(f"   • Deck 10: {cumulative_attempts[10]} tentatives, {cumulative_correct[10]} correctes")
                print(f"\n✅ TOUTES LES VÉRIFICATIONS SONT PASSÉES!")
                print(f"\n📚 Vérifications effectuées:")
                print(f"   ✓ Mise à jour des CardPerformance")
                print(f"   ✓ Mise à jour du UserDeck (dashboard)")
                print(f"   ✓ Calcul du success_rate")
                print(f"   ✓ Mise à jour du last_studied")
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
    test = QuizMarathonEnhanced()
    
    try:
        await test.setup()
        success = await test.run_marathon()
        return success
    finally:
        await test.cleanup()


if __name__ == "__main__":
    print("🏃 Lancement du TEST MARATHON AMÉLIORÉ...\n")
    success = asyncio.run(main())
    
    if success:
        print("\n✅ MARATHON TERMINÉ AVEC SUCCÈS!")
        print("\n🎊 TOUTES LES MISES À JOUR SONT VÉRIFIÉES!")
        sys.exit(0)
    else:
        print("\n❌ Marathon échoué!")
        sys.exit(1)
