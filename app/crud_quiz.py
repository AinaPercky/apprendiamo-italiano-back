# app/crud_quiz.py
"""
CRUD pour le système de quiz adaptatif intelligent.

Implémente:
1. Sélection aléatoire sans répétition pour le premier cycle
2. Exclusion des cartes déjà vues jusqu'à épuisement du deck
3. Réinitialisation intelligente avec priorisation basée sur les performances
4. Système de scoring: (incorrect_count * 2) - correct_count
"""

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func, or_
from sqlalchemy.orm import joinedload
from . import models
from .core.anki import anki_review
from typing import List, Tuple, Optional
from datetime import datetime
import json
import random


# ============================================================================
# GESTION DES PERFORMANCES PAR CARTE
# ============================================================================

async def get_or_create_card_performance(
    db: AsyncSession,
    user_pk: int,
    card_pk: int,
    deck_pk: int
) -> models.CardPerformance:
    """Récupère ou crée un enregistrement de performance pour une carte"""
    stmt = select(models.CardPerformance).where(
        and_(
            models.CardPerformance.user_pk == user_pk,
            models.CardPerformance.card_pk == card_pk
        )
    )
    result = await db.execute(stmt)
    performance = result.scalar_one_or_none()
    
    if not performance:
        performance = models.CardPerformance(
            user_pk=user_pk,
            card_pk=card_pk,
            deck_pk=deck_pk,
            correct_count=0,
            incorrect_count=0,
            total_attempts=0,
            priority_score=0.0
        )
        db.add(performance)
        await db.commit()
        await db.refresh(performance)
    
    return performance


async def update_card_performance(
    db: AsyncSession,
    user_pk: int,
    card_pk: int,
    deck_pk: int,
    is_correct: bool
) -> models.CardPerformance:
    """
    Met à jour les performances d'une carte après une réponse.
    Calcule le priority_score selon la formule: (incorrect * 2) - correct
    """
    performance = await get_or_create_card_performance(db, user_pk, card_pk, deck_pk)
    
    performance.total_attempts += 1
    if is_correct:
        performance.correct_count += 1
    else:
        performance.incorrect_count += 1
    
    # Calcul du score de priorisation
    performance.priority_score = (performance.incorrect_count * 2) - performance.correct_count
    performance.last_reviewed_at = datetime.utcnow()

    # === UPDATE ANKI STATS (Global Card) ===
    # Permet de mettre à jour les compteurs (Mastered/Learning/Review) pour le dashboard
    stmt_card = select(models.Card).where(models.Card.card_pk == card_pk)
    result_card = await db.execute(stmt_card)
    card = result_card.scalar_one_or_none()

    if card:
        # Mapping simple: Correct -> Good (3), Incorrect -> Again (0)
        grade = 3 if is_correct else 0
        
        anki_stats = anki_review(
            easiness=card.easiness,
            interval=card.interval,
            consecutive_correct=card.consecutive_correct,
            grade=grade
        )
        
        card.easiness = anki_stats["easiness"]
        card.interval = anki_stats["interval"]
        card.consecutive_correct = anki_stats["consecutive_correct"]
        card.next_review = anki_stats["next_review"]
        
        # Mise à jour de la boîte (Leitner system simplifié)
        if grade >= 2:
            card.box += 1
        elif grade == 0:
            card.box = 0
            
        db.add(card)

    # === UPDATE USER SCORE (POINTS) ===
    # Mise à jour des points dans UserDeck (10 points par bonne réponse)
    if is_correct:
        stmt_ud = select(models.UserDeck).where(
            and_(models.UserDeck.user_pk == user_pk, models.UserDeck.deck_pk == deck_pk)
        )
        result_ud = await db.execute(stmt_ud)
        user_deck = result_ud.scalar_one_or_none()
        
        if user_deck:
            user_deck.total_points += 10
            db.add(user_deck)
        else:
            # Créer le UserDeck s'il n'existe pas encore (cas rare mais possible)
            user_deck = models.UserDeck(
                user_pk=user_pk,
                deck_pk=deck_pk,
                total_points=10,
                attempt_count=1,
                correct_count=1,
                successful_attempts=1,
                total_attempts=1
            )
            db.add(user_deck)

    await db.commit()
    await db.refresh(performance)
    return performance


async def get_deck_performances(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int
) -> List[models.CardPerformance]:
    """Récupère toutes les performances pour un deck donné"""
    stmt = select(models.CardPerformance).options(joinedload(models.CardPerformance.card)).where(
        and_(
            models.CardPerformance.user_pk == user_pk,
            models.CardPerformance.deck_pk == deck_pk
        )
    )
    result = await db.execute(stmt)
    return result.unique().scalars().all()


# ============================================================================
# LOGIQUE DE SÉLECTION DES CARTES
# ============================================================================

async def get_current_cycle_info(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int
) -> Tuple[int, List[int]]:
    """
    Détermine le cycle actuel et les cartes déjà utilisées dans ce cycle.
    
    Returns:
        (cycle_number, used_card_pks)
    """
    # Récupérer toutes les cartes du deck
    stmt_total = select(func.count(models.Card.card_pk)).where(
        models.Card.deck_pk == deck_pk
    )
    result_total = await db.execute(stmt_total)
    total_cards = result_total.scalar() or 0
    
    if total_cards == 0:
        return (1, [])
    
    # Récupérer les sessions de quiz pour ce deck
    stmt_sessions = select(models.QuizSession).where(
        and_(
            models.QuizSession.user_pk == user_pk,
            models.QuizSession.deck_pk == deck_pk
        )
    ).order_by(models.QuizSession.session_pk.desc())
    
    result_sessions = await db.execute(stmt_sessions)
    sessions = result_sessions.scalars().all()
    
    if not sessions:
        return (1, [])  # Premier cycle, aucune carte utilisée
    
    # Collecter toutes les cartes utilisées dans toutes les sessions
    all_used_cards = set()
    for session in sessions:
        try:
            used_pks = json.loads(session.used_card_pks)
            all_used_cards.update(used_pks)
        except (json.JSONDecodeError, TypeError):
            continue
    
    # Si toutes les cartes ont été utilisées, on réinitialise pour un nouveau cycle
    if len(all_used_cards) >= total_cards:
        # Calculer le cycle suivant
        max_cycle = max(s.cycle_number for s in sessions) if sessions else 0
        return (max_cycle + 1, [])  # Nouveau cycle, réinitialisation
    
    # Sinon, continuer le cycle actuel
    current_cycle = sessions[0].cycle_number if sessions else 1
    return (current_cycle, list(all_used_cards))


async def select_cards_for_quiz(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int,
    card_count: int
) -> Tuple[List[models.Card], int, str]:
    """
    Sélectionne intelligemment les cartes pour un quiz.
    
    Logique:
    1. Premier cycle : sélection aléatoire sans répétition
    2. Cycles suivants : sélection pondérée basée sur les performances
    
    Returns:
        (selected_cards, cycle_number, message)
    """
    # Obtenir les cartes du deck
    stmt_cards = select(models.Card).where(models.Card.deck_pk == deck_pk)
    result_cards = await db.execute(stmt_cards)
    all_cards = list(result_cards.scalars().all())
    
    if not all_cards:
        return ([], 1, "Ce deck ne contient aucune carte. Ajoutez des cartes pour lancer un quiz.")
    
    total_cards = len(all_cards)
    
    # Vérifier que card_count est valide
    if card_count > total_cards:
        card_count = total_cards
    
    # Déterminer le cycle et les cartes déjà utilisées
    cycle_number, used_card_pks = await get_current_cycle_info(db, user_pk, deck_pk)
    
    # PREMIER CYCLE ou CYCLES INITIAUX : Sélection aléatoire sans répétition
    if cycle_number == 1:
        # Exclure les cartes déjà utilisées
        available_cards = [c for c in all_cards if c.card_pk not in used_card_pks]
        
        if len(available_cards) < card_count:
            # Pas assez de cartes non utilisées, prendre ce qui reste
            selected = available_cards
            remaining = total_cards - len(used_card_pks) - len(selected)
            message = f"Cycle {cycle_number}: {len(selected)} cartes sélectionnées. {remaining} cartes restantes avant fin du cycle."
        else:
            # Sélection aléatoire parmi les cartes disponibles
            selected = random.sample(available_cards, card_count)
            remaining = len(available_cards) - card_count
            message = f"Cycle {cycle_number}: {card_count} cartes sélectionnées aléatoirement. {remaining} cartes restantes."
        
        return (selected, cycle_number, message)
    
    # CYCLES SUIVANTS : Sélection pondérée basée sur les performances
    else:
        # Récupérer les performances de toutes les cartes
        performances = await get_deck_performances(db, user_pk, deck_pk)
        
        # Créer un dictionnaire card_pk -> performance
        perf_dict = {p.card_pk: p for p in performances}
        
        # Calculer les poids pour chaque carte
        card_weights = []
        for card in all_cards:
            perf = perf_dict.get(card.card_pk)
            if perf:
                # Poids = 1 + max(priority_score, 0)
                # Les cartes difficiles ont un poids plus élevé
                weight = 1.0 + max(perf.priority_score, 0)
            else:
                # Cartes jamais vues : poids par défaut
                weight = 1.0
            
            card_weights.append((card, weight))
        
        # Sélection pondérée
        cards_list = [cw[0] for cw in card_weights]
        weights_list = [cw[1] for cw in card_weights]
        
        # Vérifier qu'on ne demande pas plus que ce qui est disponible
        actual_count = min(card_count, len(cards_list))
        
        selected = random.choices(
            cards_list,
            weights=weights_list,
            k=actual_count
        )
        
        # Éviter les doublons (au cas où)
        selected_unique = []
        seen_pks = set()
        for card in selected:
            if card.card_pk not in seen_pks:
                selected_unique.append(card)
                seen_pks.add(card.card_pk)
        
        # Si on n'a pas assez de cartes uniques, compléter
        if len(selected_unique) < actual_count:
            missing = actual_count - len(selected_unique)
            remaining_cards = [c for c in cards_list if c.card_pk not in seen_pks]
            if remaining_cards:
                additional = random.sample(remaining_cards, min(missing, len(remaining_cards)))
                selected_unique.extend(additional)
        
        message = f"Cycle {cycle_number}: {len(selected_unique)} cartes sélectionnées avec priorisation intelligente (cartes difficiles favorisées)."
        
        return (selected_unique, cycle_number, message)


# ============================================================================
# GESTION DES SESSIONS DE QUIZ
# ============================================================================

async def create_quiz_session(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int,
    card_count: int,
    quiz_type: str,
    selected_card_pks: List[int],
    cycle_number: int
) -> models.QuizSession:
    """Crée une nouvelle session de quiz"""
    session = models.QuizSession(
        user_pk=user_pk,
        deck_pk=deck_pk,
        card_count=card_count,
        quiz_type=quiz_type,
        cycle_number=cycle_number,
        used_card_pks=json.dumps(selected_card_pks),
        correct_count=0,
        total_questions=0,
        started_at=datetime.utcnow(),
        completed_at=None
    )
    
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return session


async def complete_quiz_session(
    db: AsyncSession,
    session_pk: int,
    correct_count: int,
    total_questions: int
) -> Optional[models.QuizSession]:
    """Marque une session de quiz comme terminée ET met à jour le UserDeck"""
    stmt = select(models.QuizSession).where(models.QuizSession.session_pk == session_pk)
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    
    if not session:
        return None
    
    # Mettre à jour la session
    session.correct_count = correct_count
    session.total_questions = total_questions
    session.completed_at = datetime.utcnow()
    
    # ⭐ IMPORTANT : Mettre à jour le UserDeck pour le dashboard
    # Récupérer ou créer le UserDeck
    stmt_user_deck = select(models.UserDeck).where(
        models.UserDeck.user_pk == session.user_pk,
        models.UserDeck.deck_pk == session.deck_pk
    )
    result_user_deck = await db.execute(stmt_user_deck)
    user_deck = result_user_deck.scalar_one_or_none()
    
    if not user_deck:
        # Créer le UserDeck s'il n'existe pas
        user_deck = models.UserDeck(
            user_pk=session.user_pk,
            deck_pk=session.deck_pk,
            correct_count=0,
            attempt_count=0,
            cards_mastered=0
        )
        db.add(user_deck)
    
    # Mettre à jour les compteurs (doublons historiques maintenus pour compatibilité)
    user_deck.attempt_count += total_questions
    user_deck.correct_count += correct_count
    
    # Mettre à jour les champs utilisés par le frontend (UserDeckResponse)
    user_deck.total_attempts += total_questions
    user_deck.successful_attempts += correct_count
    user_deck.last_studied = datetime.utcnow()
    
    await db.commit()
    await db.refresh(session)
    await db.refresh(user_deck)
    
    return session


async def get_user_quiz_sessions(
    db: AsyncSession,
    user_pk: int,
    deck_pk: Optional[int] = None,
    limit: int = 50
) -> List[models.QuizSession]:
    """Récupère l'historique des sessions de quiz d'un utilisateur"""
    stmt = select(models.QuizSession).where(
        models.QuizSession.user_pk == user_pk
    )
    
    if deck_pk:
        stmt = stmt.where(models.QuizSession.deck_pk == deck_pk)
    
    stmt = stmt.order_by(models.QuizSession.started_at.desc()).limit(limit)
    
    result = await db.execute(stmt)
    return result.scalars().all()
