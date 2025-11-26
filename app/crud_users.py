from sqlalchemy import select
from sqlalchemy.orm import joinedload
from sqlalchemy.ext.asyncio import AsyncSession
from . import models, schemas
from .security import hash_password, verify_password
from datetime import datetime


# ============================================================================
# OPÉRATIONS UTILISATEUR
# ============================================================================

async def create_user(
    db: AsyncSession,
    user_data: schemas.UserRegister
) -> models.User:
    """Crée un nouvel utilisateur avec authentification standard."""
    # Vérifier que l'email n'existe pas déjà
    result = await db.execute(
        select(models.User).where(models.User.email == user_data.email)
    )
    if result.scalars().first():
        raise ValueError("Email already registered")
    
    # Générer un username unique à partir de l'email
    username = user_data.email.split('@')[0]
    counter = 1
    original_username = username
    while True:
        result = await db.execute(
            select(models.User).where(models.User.username == username)
        )
        if not result.scalars().first():
            break
        username = f"{original_username}{counter}"
        counter += 1
    
    # Séparer full_name en first_name et last_name
    name_parts = user_data.full_name.split(' ', 1)
    first_name = name_parts[0] if name_parts else ""
    last_name = name_parts[1] if len(name_parts) > 1 else ""
    
    # Créer l'utilisateur
    db_user = models.User(
        email=user_data.email,
        username=username,
        hashed_password=hash_password(user_data.password),
        first_name=first_name,
        last_name=last_name,
        is_active=True,
        is_verified=False,
    )
    
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user


async def get_user_by_email(
    db: AsyncSession,
    email: str
) -> models.User | None:
    """Récupère un utilisateur par son email."""
    result = await db.execute(
        select(models.User).where(models.User.email == email)
    )
    return result.scalars().first()


async def get_user_by_username(
    db: AsyncSession,
    username: str
) -> models.User | None:
    """Récupère un utilisateur par son username."""
    result = await db.execute(
        select(models.User).where(models.User.username == username)
    )
    return result.scalars().first()


async def get_user_by_id(
    db: AsyncSession,
    user_pk: int
) -> models.User | None:
    """Récupère un utilisateur par son ID."""
    result = await db.execute(
        select(models.User).where(models.User.user_pk == user_pk)
    )
    return result.scalars().first()


async def get_user_by_google_id(
    db: AsyncSession,
    google_id: str
) -> models.User | None:
    """Récupère un utilisateur par son Google ID."""
    result = await db.execute(
        select(models.User).where(models.User.google_id == google_id)
    )
    return result.scalars().first()


async def authenticate_user(
    db: AsyncSession,
    email: str,
    password: str
) -> models.User | None:
    """Authentifie un utilisateur avec email et mot de passe."""
    user = await get_user_by_email(db, email)
    if not user:
        return None
    if not verify_password(password, user.hashed_password):
        return None
    return user


async def update_user(
    db: AsyncSession,
    user: models.User,
    user_data: schemas.UserUpdate
) -> models.User:
    """Met à jour les informations d'un utilisateur."""
    if user_data.first_name is not None:
        user.first_name = user_data.first_name
    if user_data.last_name is not None:
        user.last_name = user_data.last_name
    if user_data.bio is not None:
        user.bio = user_data.bio
    if user_data.profile_picture is not None:
        user.profile_picture = user_data.profile_picture
    
    user.updated_at = datetime.utcnow()
    
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def update_last_login(
    db: AsyncSession,
    user: models.User
) -> models.User:
    """Met à jour la date de dernière connexion."""
    user.last_login = datetime.utcnow()
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def deactivate_user(
    db: AsyncSession,
    user: models.User
) -> models.User:
    """Désactive un compte utilisateur."""
    user.is_active = False
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


# ============================================================================
# OPÉRATIONS GOOGLE OAUTH
# ============================================================================

async def create_or_update_google_user(
    db: AsyncSession,
    user_data: schemas.UserGoogleLogin
) -> models.User:
    """Crée ou met à jour un utilisateur Google."""
    # Vérifier si l'utilisateur existe déjà
    user = await get_user_by_google_id(db, user_data.google_id)
    
    if user:
        # Mettre à jour les informations
        user.google_email = user_data.google_email
        user.google_picture = user_data.google_picture
        if user_data.first_name:
            user.first_name = user_data.first_name
        if user_data.last_name:
            user.last_name = user_data.last_name
        user.updated_at = datetime.utcnow()
    else:
        # Créer un nouvel utilisateur
        # Générer un username unique à partir de l'email
        base_username = user_data.google_email.split("@")[0]
        username = base_username
        counter = 1
        
        while await get_user_by_username(db, username):
            username = f"{base_username}{counter}"
            counter += 1
        
        user = models.User(
            email=user_data.google_email,
            username=username,
            google_id=user_data.google_id,
            google_email=user_data.google_email,
            google_picture=user_data.google_picture,
            first_name=user_data.first_name,
            last_name=user_data.last_name,
            is_active=True,
            is_verified=True,  # Les utilisateurs Google sont automatiquement vérifiés
        )
    
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


# ============================================================================
# OPÉRATIONS SCORES
# ============================================================================

from .core.anki import anki_review

async def create_score(
    db: AsyncSession,
    user_pk: int,
    score_data: schemas.UserScoreCreate
) -> models.UserScore:
    """Crée un nouvel enregistrement de score et met à jour l'algorithme Anki."""
    # 1. Créer le score
    db_score = models.UserScore(
        user_pk=user_pk,
        deck_pk=score_data.deck_pk,
        card_pk=score_data.card_pk,
        score=score_data.score,
        is_correct=score_data.is_correct,
        time_spent=score_data.time_spent,
        quiz_type=score_data.quiz_type  # Ajout du champ manquant
    )
    
    db.add(db_score)
    
    # 2. Mettre à jour les statistiques de l'utilisateur
    user = await get_user_by_id(db, user_pk)
    if user:
        user.total_score += score_data.score
        if score_data.is_correct:
            user.total_cards_learned += 1
        user.total_cards_reviewed += 1
        db.add(user)
        
    # 3. Algorithme Anki & Mise à jour de la carte
    if score_data.card_pk:
        # Récupérer la carte
        result = await db.execute(select(models.Card).where(models.Card.card_pk == score_data.card_pk))
        card = result.scalar_one_or_none()
        
        if card:
            # Calculer le grade Anki (0-3) basé sur le score (0-100)
            if score_data.score < 50:
                grade = 0  # Again
            elif score_data.score < 75:
                grade = 1  # Hard
            elif score_data.score < 90:
                grade = 2  # Good
            else:
                grade = 3  # Easy
            
            # Appliquer l'algorithme
            anki_stats = anki_review(
                easiness=card.easiness,
                interval=card.interval,
                consecutive_correct=card.consecutive_correct,
                grade=grade
            )
            
            # Mettre à jour la carte
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
            
            # Mettre à jour les stats du UserDeck si possible
            if score_data.deck_pk:
                ud_result = await db.execute(
                    select(models.UserDeck).where(
                        (models.UserDeck.user_pk == user_pk) & 
                        (models.UserDeck.deck_pk == score_data.deck_pk)
                    )
                )
                user_deck = ud_result.scalar_one_or_none()
                if user_deck:
                    user_deck.total_attempts += 1
                    user_deck.total_points += score_data.score
                    if score_data.is_correct:
                        user_deck.successful_attempts += 1
                    
                    # Stats par type
                    if score_data.quiz_type == "frappe":
                        user_deck.points_frappe += score_data.score
                    elif score_data.quiz_type == "association":
                        user_deck.points_association += score_data.score
                    elif score_data.quiz_type == "qcm":
                        user_deck.points_qcm += score_data.score
                    elif score_data.quiz_type == "classique":
                        user_deck.points_classique += score_data.score
                        
                    # Mise à jour des compteurs de cartes maîtrisées/en cours/à revoir
                    await update_user_deck_anki_stats(db, user_deck)
    
    await db.commit()
    await db.refresh(db_score)
    return db_score


async def get_user_scores(
    db: AsyncSession,
    user_pk: int,
    limit: int = 100,
    offset: int = 0
) -> list[models.UserScore]:
    """Récupère les scores d'un utilisateur."""
    result = await db.execute(
        select(models.UserScore)
        .where(models.UserScore.user_pk == user_pk)
        .order_by(models.UserScore.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    return result.scalars().all()


async def get_user_deck_scores(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int
) -> list[models.UserScore]:
    """Récupère les scores d'un utilisateur pour un deck spécifique."""
    result = await db.execute(
        select(models.UserScore)
        .where(
            (models.UserScore.user_pk == user_pk) &
            (models.UserScore.deck_pk == deck_pk)
        )
        .order_by(models.UserScore.created_at.desc())
    )
    return result.scalars().all()


# ============================================================================
# OPÉRATIONS AUDIO
# ============================================================================

async def create_user_audio(
    db: AsyncSession,
    user_pk: int,
    audio_data: schemas.UserAudioCreate
) -> models.UserAudio:
    """Crée un nouvel enregistrement audio utilisateur."""
    db_audio = models.UserAudio(
        user_pk=user_pk,
        card_pk=audio_data.card_pk,
        filename=audio_data.filename,
        audio_url=audio_data.audio_url,
        duration=audio_data.duration,
        quality_score=audio_data.quality_score,
        notes=audio_data.notes,
    )
    
    db.add(db_audio)
    await db.commit()
    await db.refresh(db_audio)
    return db_audio


async def get_user_audio(
    db: AsyncSession,
    user_pk: int,
    limit: int = 50,
    offset: int = 0
) -> list[models.UserAudio]:
    """Récupère les enregistrements audio d'un utilisateur."""
    result = await db.execute(
        select(models.UserAudio)
        .where(models.UserAudio.user_pk == user_pk)
        .order_by(models.UserAudio.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    return result.scalars().all()


async def delete_user_audio(
    db: AsyncSession,
    audio_pk: int,
    user_pk: int
) -> bool:
    """Supprime un enregistrement audio utilisateur."""
    result = await db.execute(
        select(models.UserAudio)
        .where(
            (models.UserAudio.audio_pk == audio_pk) &
            (models.UserAudio.user_pk == user_pk)
        )
    )
    audio = result.scalars().first()
    
    if not audio:
        return False
    
    await db.delete(audio)
    await db.commit()
    return True


# ============================================================================
# OPÉRATIONS DECKS UTILISATEUR
# ============================================================================

async def add_user_deck(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int
) -> models.UserDeck:
    """Ajoute un deck à la collection d'un utilisateur."""
    # Vérifier que le deck n'est pas déjà dans la collection
    result = await db.execute(
        select(models.UserDeck).where(
            (models.UserDeck.user_pk == user_pk) &
            (models.UserDeck.deck_pk == deck_pk)
        )
    )
    if result.scalars().first():
        raise ValueError("Deck already in user collection")
    
    user_deck = models.UserDeck(
        user_pk=user_pk,
        deck_pk=deck_pk,
    )
    
    db.add(user_deck)
    await db.commit()
    await db.refresh(user_deck)
    
    # Charger la relation deck pour la réponse API
    # On utilise une nouvelle requête pour charger l'objet avec sa relation
    stmt = select(models.UserDeck).options(joinedload(models.UserDeck.deck)).where(models.UserDeck.user_deck_pk == user_deck.user_deck_pk)
    result = await db.execute(stmt)
    return result.unique().scalar_one()


async def update_user_deck_anki_stats(
    db: AsyncSession,
    user_deck: models.UserDeck
) -> models.UserDeck:
    """Met à jour les compteurs de cartes maîtrisées/en cours/à revoir pour un UserDeck."""
    
    # 1. Récupérer toutes les cartes du deck de l'utilisateur
    result = await db.execute(
        select(models.Card)
        .where(models.Card.deck_pk == user_deck.deck_pk)
    )
    cards = result.scalars().all()
    
    # 2. Initialiser les compteurs
    mastered_cards = 0
    learning_cards = 0
    review_cards = 0
    
    now = datetime.utcnow()
    
    for card in cards:
        # Si la carte a un intervalle > 0 et next_review est dans le futur, elle est maîtrisée (vert)
        if card.interval > 0 and card.next_review > now:
            mastered_cards += 1
        # Si la carte est à revoir (next_review est dans le passé ou aujourd'hui) (rouge)
        elif card.next_review <= now:
            review_cards += 1
        # Sinon, elle est en cours d'apprentissage (orange)
        else:
            learning_cards += 1
            
    # 3. Mettre à jour le UserDeck
    user_deck.mastered_cards = mastered_cards
    user_deck.learning_cards = learning_cards
    user_deck.review_cards = review_cards
    
    db.add(user_deck)
    await db.commit()
    await db.refresh(user_deck)
    
    return user_deck


async def get_user_decks(
    db: AsyncSession,
    user_pk: int
) -> list[models.UserDeck]:
    """Récupère tous les decks de l'utilisateur avec les stats Anki à jour."""
    result = await db.execute(
        select(models.UserDeck)
        .options(joinedload(models.UserDeck.deck))
        .where(models.UserDeck.user_pk == user_pk)
        .order_by(models.UserDeck.added_at.desc())
    )
    user_decks = result.unique().scalars().all()
    
    # Mettre à jour les stats Anki pour chaque deck
    for user_deck in user_decks:
        await update_user_deck_anki_stats(db, user_deck)
        
    return user_decks


async def remove_user_deck(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int
) -> bool:
    """Supprime un deck de la collection d'un utilisateur."""
    result = await db.execute(
        select(models.UserDeck).where(
            (models.UserDeck.user_pk == user_pk) &
            (models.UserDeck.deck_pk == deck_pk)
        )
    )
    user_deck = result.scalars().first()
    
    if not user_deck:
        return False
    
    await db.delete(user_deck)
    await db.commit()
    return True


# ============================================================================
# STATISTIQUES UTILISATEUR
# ============================================================================

async def get_user_stats(
    db: AsyncSession,
    user_pk: int
) -> schemas.UserStatsResponse:
    """Récupère les statistiques complètes d'un utilisateur."""
    user = await get_user_by_id(db, user_pk)
    
    if not user:
        raise ValueError("User not found")
    
    # Compter les enregistrements audio
    audio_result = await db.execute(
        select(models.UserAudio).where(models.UserAudio.user_pk == user_pk)
    )
    audio_count = len(audio_result.scalars().all())
    
    # Compter les decks
    decks_result = await db.execute(
        select(models.UserDeck).where(models.UserDeck.user_pk == user_pk)
    )
    decks_count = len(decks_result.scalars().all())
    
    # Compter les scores
    scores_result = await db.execute(
        select(models.UserScore).where(models.UserScore.user_pk == user_pk)
    )
    scores = scores_result.scalars().all()
    
    # Calculer la moyenne des scores
    average_score = 0
    if scores:
        average_score = sum(s.score for s in scores) / len(scores)
    
    return schemas.UserStatsResponse(
        total_score=user.total_score,
        total_cards_learned=user.total_cards_learned,
        total_cards_reviewed=user.total_cards_reviewed,
        total_decks=decks_count,
        total_audio_records=audio_count,
        last_login=user.last_login,
    )
