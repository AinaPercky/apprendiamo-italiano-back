from sqlalchemy import select
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
    
    # Vérifier que le username n'existe pas déjà
    result = await db.execute(
        select(models.User).where(models.User.username == user_data.username)
    )
    if result.scalars().first():
        raise ValueError("Username already taken")
    
    # Créer l'utilisateur
    db_user = models.User(
        email=user_data.email,
        username=user_data.username,
        hashed_password=hash_password(user_data.password),
        first_name=user_data.first_name,
        last_name=user_data.last_name,
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

async def create_score(
    db: AsyncSession,
    user_pk: int,
    score_data: schemas.UserScoreCreate
) -> models.UserScore:
    """Crée un nouvel enregistrement de score."""
    db_score = models.UserScore(
        user_pk=user_pk,
        deck_pk=score_data.deck_pk,
        card_pk=score_data.card_pk,
        score=score_data.score,
        is_correct=score_data.is_correct,
        time_spent=score_data.time_spent,
    )
    
    db.add(db_score)
    
    # Mettre à jour les statistiques de l'utilisateur
    user = await get_user_by_id(db, user_pk)
    if user:
        user.total_score += score_data.score
        if score_data.is_correct:
            user.total_cards_learned += 1
        user.total_cards_reviewed += 1
        db.add(user)
    
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
    
    db_user_deck = models.UserDeck(
        user_pk=user_pk,
        deck_pk=deck_pk,
    )
    
    db.add(db_user_deck)
    await db.commit()
    await db.refresh(db_user_deck)
    return db_user_deck


async def get_user_decks(
    db: AsyncSession,
    user_pk: int
) -> list[models.UserDeck]:
    """Récupère tous les decks d'un utilisateur."""
    result = await db.execute(
        select(models.UserDeck)
        .where(models.UserDeck.user_pk == user_pk)
        .order_by(models.UserDeck.added_at.desc())
    )
    return result.scalars().all()


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


async def update_user_deck_stats(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int,
    correct: bool,
    cards_mastered: int = 0
) -> models.UserDeck:
    """Met à jour les statistiques d'un deck pour un utilisateur."""
    result = await db.execute(
        select(models.UserDeck).where(
            (models.UserDeck.user_pk == user_pk) &
            (models.UserDeck.deck_pk == deck_pk)
        )
    )
    user_deck = result.scalars().first()
    
    if not user_deck:
        raise ValueError("User deck not found")
    
    user_deck.attempt_count += 1
    if correct:
        user_deck.correct_count += 1
    if cards_mastered > 0:
        user_deck.cards_mastered = cards_mastered
    user_deck.last_studied = datetime.utcnow()
    
    db.add(user_deck)
    await db.commit()
    await db.refresh(user_deck)
    return user_deck


# ============================================================================
# OPÉRATIONS STATISTIQUES
# ============================================================================

async def get_user_stats(
    db: AsyncSession,
    user_pk: int
) -> dict:
    """Récupère les statistiques complètes d'un utilisateur."""
    user = await get_user_by_id(db, user_pk)
    if not user:
        return None
    
    # Compter les decks
    result = await db.execute(
        select(models.UserDeck).where(models.UserDeck.user_pk == user_pk)
    )
    decks = result.scalars().all()
    
    # Compter les enregistrements audio
    result = await db.execute(
        select(models.UserAudio).where(models.UserAudio.user_pk == user_pk)
    )
    audio_records = result.scalars().all()
    
    return {
        "total_score": user.total_score,
        "total_cards_learned": user.total_cards_learned,
        "total_cards_reviewed": user.total_cards_reviewed,
        "total_decks": len(decks),
        "total_audio_records": len(audio_records),
        "last_login": user.last_login,
    }
