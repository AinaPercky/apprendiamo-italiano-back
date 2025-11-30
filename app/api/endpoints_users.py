from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import timedelta

from ..database import get_db
from .. import schemas, crud_users
from ..security import (
    create_access_token,
    create_refresh_token,
    get_current_user,
    get_current_active_user,
    ACCESS_TOKEN_EXPIRE_MINUTES,
)

router = APIRouter(prefix="/api/users", tags=["users"])


# ============================================================================
# AUTHENTIFICATION - ENREGISTREMENT ET CONNEXION
# ============================================================================

@router.post("/register", response_model=schemas.TokenResponse, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: schemas.UserRegister,
    db: AsyncSession = Depends(get_db)
):
    """
    Enregistre un nouvel utilisateur avec email et mot de passe.
    
    - **email**: Email unique de l'utilisateur
    - **username**: Nom d'utilisateur unique
    - **password**: Mot de passe (sera haché)
    - **first_name**: Prénom (optionnel)
    - **last_name**: Nom de famille (optionnel)
    """
    try:
        user = await crud_users.create_user(db, user_data)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    
    # Mettre à jour la dernière connexion
    await crud_users.update_last_login(db, user)
    
    # Créer les tokens
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.user_pk},
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": schemas.UserResponse.model_validate(user)
    }


@router.post("/login", response_model=schemas.TokenResponse)
async def login(
    credentials: schemas.UserLogin,
    db: AsyncSession = Depends(get_db)
):
    """
    Authentifie un utilisateur avec email et mot de passe.
    
    - **email**: Email de l'utilisateur
    - **password**: Mot de passe
    """
    user = await crud_users.authenticate_user(db, credentials.email, credentials.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive"
        )
    
    # Mettre à jour la dernière connexion
    await crud_users.update_last_login(db, user)
    
    # Créer les tokens
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.user_pk},
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": schemas.UserResponse.model_validate(user)
    }


@router.post("/google-login", response_model=schemas.TokenResponse)
async def google_login(
    user_data: schemas.UserGoogleLogin,
    db: AsyncSession = Depends(get_db)
):
    """
    Authentifie ou crée un utilisateur via Google OAuth.
    
    - **google_id**: ID unique Google
    - **google_email**: Email Google
    - **first_name**: Prénom (optionnel)
    - **last_name**: Nom de famille (optionnel)
    - **google_picture**: URL de la photo de profil (optionnel)
    """
    try:
        user = await crud_users.create_or_update_google_user(db, user_data)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    
    # Mettre à jour la dernière connexion
    await crud_users.update_last_login(db, user)
    
    # Créer les tokens
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.user_pk},
        expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": schemas.UserResponse.model_validate(user)
    }


# ============================================================================
# GESTION DU PROFIL UTILISATEUR
# ============================================================================

@router.get("/me", response_model=schemas.UserDetailResponse)
async def get_current_user_profile(
    current_user = Depends(get_current_active_user)
):
    """Récupère le profil de l'utilisateur actuel."""
    return schemas.UserDetailResponse.model_validate(current_user)


@router.put("/me", response_model=schemas.UserDetailResponse)
async def update_current_user_profile(
    user_data: schemas.UserUpdate,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Met à jour le profil de l'utilisateur actuel."""
    updated_user = await crud_users.update_user(db, current_user, user_data)
    return schemas.UserDetailResponse.model_validate(updated_user)


# Route déplacée à la fin du fichier pour éviter les conflits
# @router.get("/{user_pk}") ...


@router.post("/logout")
async def logout(
    current_user = Depends(get_current_active_user)
):
    """Déconnecte l'utilisateur actuel (côté client: supprimer le token)."""
    return {"message": "Logged out successfully"}


# ============================================================================
# GESTION DES DECKS UTILISATEUR
# ============================================================================

@router.post("/decks/{deck_pk}", response_model=schemas.UserDeckResponse, status_code=status.HTTP_201_CREATED)
async def add_deck_to_user(
    deck_pk: int,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Ajoute un deck à la collection de l'utilisateur actuel."""
    try:
        user_deck = await crud_users.add_user_deck(db, current_user.user_pk, deck_pk)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    
    return schemas.UserDeckResponse.model_validate(user_deck)


@router.get("/decks", response_model=list[schemas.UserDeckResponse])
async def get_user_decks(
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Récupère tous les decks de l'utilisateur actuel."""
    user_decks = await crud_users.get_user_decks(db, current_user.user_pk)
    return [schemas.UserDeckResponse.model_validate(ud) for ud in user_decks]


@router.get("/decks/all", response_model=list[schemas.UserDeckResponse])
async def get_all_decks_with_user_stats(
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Récupère TOUS les decks du système avec les statistiques personnalisées de l'utilisateur.
    
    Pour un nouveau utilisateur :
    - Tous les decks du système sont affichés
    - Les decks non commencés ont une précision de 0%
    - Les decks commencés affichent les vraies statistiques de l'utilisateur
    """
    all_decks = await crud_users.get_all_decks_with_user_stats(db, current_user.user_pk)
    return [schemas.UserDeckResponse.model_validate(ud) for ud in all_decks]


@router.delete("/decks/{deck_pk}")
async def remove_deck_from_user(
    deck_pk: int,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Supprime un deck de la collection de l'utilisateur actuel."""
    success = await crud_users.remove_user_deck(db, current_user.user_pk, deck_pk)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Deck not found in user collection"
        )
    
    return {"message": "Deck removed successfully"}


# ============================================================================
# GESTION DES SCORES
# ============================================================================

@router.post("/scores", response_model=schemas.UserScore, status_code=status.HTTP_201_CREATED)
async def create_user_score(
    score_data: schemas.UserScoreCreate,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Enregistre un nouveau score pour l'utilisateur actuel."""
    score = await crud_users.create_score(db, current_user.user_pk, score_data)
    return schemas.UserScore.model_validate(score)


@router.get("/scores", response_model=list[schemas.UserScore])
async def get_user_scores(
    limit: int = 100,
    offset: int = 0,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Récupère les scores de l'utilisateur actuel."""
    scores = await crud_users.get_user_scores(db, current_user.user_pk, limit, offset)
    return [schemas.UserScore.model_validate(s) for s in scores]


@router.get("/scores/deck/{deck_pk}", response_model=list[schemas.UserScore])
async def get_user_deck_scores(
    deck_pk: int,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Récupère les scores de l'utilisateur actuel pour un deck spécifique."""
    scores = await crud_users.get_user_deck_scores(db, current_user.user_pk, deck_pk)
    return [schemas.UserScore.model_validate(s) for s in scores]


# ============================================================================
# GESTION DES ENREGISTREMENTS AUDIO
# ============================================================================

@router.post("/audio", response_model=schemas.UserAudio, status_code=status.HTTP_201_CREATED)
async def create_user_audio(
    audio_data: schemas.UserAudioCreate,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Crée un nouvel enregistrement audio pour l'utilisateur actuel."""
    audio = await crud_users.create_user_audio(db, current_user.user_pk, audio_data)
    return schemas.UserAudio.model_validate(audio)


@router.get("/audio", response_model=list[schemas.UserAudio])
async def get_user_audio(
    limit: int = 50,
    offset: int = 0,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Récupère les enregistrements audio de l'utilisateur actuel."""
    audio_records = await crud_users.get_user_audio(db, current_user.user_pk, limit, offset)
    return [schemas.UserAudio.model_validate(a) for a in audio_records]


@router.delete("/audio/{audio_pk}")
async def delete_user_audio(
    audio_pk: int,
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Supprime un enregistrement audio de l'utilisateur actuel."""
    success = await crud_users.delete_user_audio(db, audio_pk, current_user.user_pk)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Audio record not found"
        )
    
    return {"message": "Audio deleted successfully"}


# ============================================================================
# STATISTIQUES UTILISATEUR
# ============================================================================

@router.get("/stats", response_model=schemas.UserStatsResponse)
async def get_user_stats(
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Récupère les statistiques complètes de l'utilisateur actuel."""
    stats = await crud_users.get_user_stats(db, current_user.user_pk)
    return stats


# ============================================================================
# CONFIGURATION OAUTH
# ============================================================================

@router.get("/oauth/google-config")
async def get_google_oauth_config():
    """Récupère la configuration Google OAuth pour le frontend."""
    from ..google_oauth import get_google_oauth_config
    return get_google_oauth_config()


# ============================================================================
# RECHERCHE UTILISATEUR (Doit être en dernier pour éviter les conflits)
# ============================================================================

@router.get("/{user_pk}", response_model=schemas.UserResponse)
async def get_user(
    user_pk: int,
    db: AsyncSession = Depends(get_db)
):
    """Récupère les informations publiques d'un utilisateur."""
    user = await crud_users.get_user_by_id(db, user_pk)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return schemas.UserResponse.model_validate(user)
