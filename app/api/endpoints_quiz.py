# app/api/endpoints_quiz.py
"""
Endpoints API pour le système de quiz adaptatif.

Fonctionnalités:
- Configuration d'un nouveau quiz avec sélection du nombre de cartes
- Sélection intelligente des cartes (aléatoire puis pondérée)
- Mise à jour des performances après chaque réponse
- Historique des sessions
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime

from ..database import get_db
from .. import schemas, crud_quiz
from ..security import get_current_active_user


router = APIRouter(prefix="/api/quiz", tags=["quiz"])


# ============================================================================
# CONFIGURATION ET LANCEMENT D'UN QUIZ
# ============================================================================

@router.post("/start", response_model=schemas.QuizCardSelection, status_code=status.HTTP_201_CREATED)
async def start_quiz(
    config: schemas.QuizConfigRequest,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Démarre un nouveau quiz avec sélection intelligente des cartes.
    
    **Algorithme:**
    1. Premier cycle : sélection aléatoire sans répétition
    2. Exclusion des cartes déjà vues jusqu'à épuisement du deck
    3. Nouveau cycle : réinitialisation avec priorisation basée sur les performances
    
    **Paramètres:**
    - **deck_pk**: ID du deck à réviser
    - **card_count**: Nombre de cartes demandées pour le quiz
    - **quiz_type**: Type de quiz (classique, frappe, association, qcm)
    
    **Retourne:**
    - Liste des cartes sélectionnées
    - Informations sur le cycle en cours
    - Message descriptif
    """
    try:
        # Sélectionner les cartes intelligemment
        selected_cards, cycle_number, message = await crud_quiz.select_cards_for_quiz(
            db,
            current_user.user_pk,
            config.deck_pk,
            config.card_count
        )
        
        # Préparer les données des cartes AVANT commit pour éviter MissingGreenlet
        selected_card_pks = [card.card_pk for card in selected_cards]
        selected_cards_payload = [
            schemas.QuizCardPublic(
                card_pk=card.card_pk,
                front=card.front,
                back=card.back,
                pronunciation=getattr(card, "pronunciation", None),
                image=getattr(card, "image", None),
                box=card.box,
                tags=getattr(card, "tags", [])
            )
            for card in selected_cards
        ]

        # Créer une session de quiz
        session = await crud_quiz.create_quiz_session(
            db,
            current_user.user_pk,
            config.deck_pk,
            config.card_count,
            config.quiz_type,
            selected_card_pks,
            cycle_number
        )
        
        # Compter le total de cartes dans le deck
        from sqlalchemy import select, func
        from ..models import Card
        stmt = select(func.count(Card.card_pk)).where(Card.deck_pk == config.deck_pk)
        result = await db.execute(stmt)
        total_cards = result.scalar() or 0
        
        # Retourner la réponse
        return schemas.QuizCardSelection(
            session_pk=session.session_pk,
            deck_pk=config.deck_pk,
            cycle_number=cycle_number,
            total_cards_in_deck=total_cards,
            requested_card_count=config.card_count,
            selected_cards=selected_cards_payload,
            message=message
        )
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la création du quiz: {str(e)}"
        )


# ============================================================================
# MISE À JOUR DES PERFORMANCES
# ============================================================================

@router.post("/answer", response_model=schemas.CardPerformanceResponse)
async def record_answer(
    card_pk: int,
    deck_pk: int,
    is_correct: bool,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Enregistre une réponse et met à jour les performances de la carte.
    
    **Algorithme de scoring:**
    - `priority_score = (incorrect_count * 2) - correct_count`
    - Plus le score est élevé, plus la carte sera priorisée dans les prochains quiz
    
    **Paramètres:**
    - **card_pk**: ID de la carte
    - **deck_pk**: ID du deck
    - **is_correct**: True si la réponse est correcte, False sinon
    """
    try:
        performance = await crud_quiz.update_card_performance(
            db,
            current_user.user_pk,
            card_pk,
            deck_pk,
            is_correct
        )
        
        return schemas.CardPerformanceResponse.model_validate(performance)
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de l'enregistrement de la réponse: {str(e)}"
        )


# ============================================================================
# FINALISATION D'UNE SESSION
# ============================================================================

@router.post("/complete/{session_pk}", response_model=schemas.QuizSessionResponse)
async def complete_quiz(
    session_pk: int,
    correct_count: int,
    total_questions: int,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Marque une session de quiz comme terminée et enregistre les résultats finaux.
    
    **Paramètres:**
    - **session_pk**: ID de la session
    - **correct_count**: Nombre de réponses correctes
    - **total_questions**: Nombre total de questions posées
    """
    session = await crud_quiz.complete_quiz_session(
        db,
        session_pk,
        correct_count,
        total_questions
    )
    
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session de quiz introuvable"
        )
    
    return schemas.QuizSessionResponse.model_validate(session)


# ============================================================================
# HISTORIQUE ET STATISTIQUES
# ============================================================================

@router.get("/sessions", response_model=list[schemas.QuizSessionResponse])
async def get_quiz_sessions(
    deck_pk: int = None,
    limit: int = 50,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Récupère l'historique des sessions de quiz de l'utilisateur.
    
    **Paramètres:**
    - **deck_pk**: (Optionnel) Filtrer par deck spécifique
    - **limit**: Nombre maximum de sessions à retourner
    """
    sessions = await crud_quiz.get_user_quiz_sessions(
        db,
        current_user.user_pk,
        deck_pk,
        limit
    )
    
    return [schemas.QuizSessionResponse.model_validate(s) for s in sessions]


@router.get("/performances/{deck_pk}", response_model=list[schemas.CardPerformanceResponse])
async def get_deck_performances(
    deck_pk: int,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Récupère les performances de toutes les cartes d'un deck pour l'utilisateur actuel.
    
    Permet de voir quelles cartes sont difficiles et seront priorisées.
    """
    performances = await crud_quiz.get_deck_performances(
        db,
        current_user.user_pk,
        deck_pk
    )
    
    return [schemas.CardPerformanceResponse.model_validate(p) for p in performances]


# ============================================================================
# VÉRIFICATION : CARTE DÉJÀ VUE PAR L'UTILISATEUR
# ============================================================================

@router.get("/has-seen")
async def has_seen_card(
    deck_pk: int,
    card_pk: int,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Indique si l'utilisateur a déjà effectué un quiz sur une carte donnée d'un deck donné.
    Basé sur la table `card_performance`.
    """
    from sqlalchemy import select, and_
    from ..models import CardPerformance

    result = await db.execute(
        select(CardPerformance).where(
            and_(
                CardPerformance.user_pk == current_user.user_pk,
                CardPerformance.deck_pk == deck_pk,
                CardPerformance.card_pk == card_pk,
            )
        )
    )
    perf = result.scalar_one_or_none()
    attempts = perf.total_attempts if perf else 0
    return {"has_seen": attempts > 0, "total_attempts": attempts}
