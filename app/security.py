import os
from datetime import datetime, timedelta
from typing import Optional

from passlib.context import CryptContext
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from .database import get_db
from . import models
from .client_applications import get_client_application

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def _load_secret_key() -> str:
    """Charge la clé JWT obligatoire depuis l'environnement."""
    secret_key = os.getenv("SECRET_KEY")
    if not secret_key or not secret_key.strip():
        raise RuntimeError(
            "SECRET_KEY est obligatoire. Configurez un secret aléatoire "
            "dans l'environnement avant de démarrer le backend."
        )
    return secret_key


SECRET_KEY = _load_secret_key()
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

security = HTTPBearer()
optional_security = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Crée un token JWT d'accès avec un type explicite."""
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    sub = to_encode.get("sub")
    if sub is None:
        raise ValueError("Le champ 'sub' est obligatoire pour créer un token")
    to_encode["sub"] = str(sub)
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(data: dict) -> str:
    """Crée un token de rafraîchissement (7 jours par défaut)."""
    to_encode = data.copy()
    sub = to_encode.get("sub")
    if sub is None:
        raise ValueError("Le champ 'sub' est obligatoire pour créer un token")
    to_encode["sub"] = str(sub)
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def verify_token(token: str) -> dict:
    """Vérifie un JWT et refuse les tokens qui ne sont pas des tokens d'accès."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM], options={"verify_aud": False})
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide ou expiré",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token_type = payload.get("type")
    if token_type not in (None, "access"):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Type de token non autorisé",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> models.User:
    """Récupère l'utilisateur à partir du token Bearer."""
    payload = verify_token(credentials.credentials)
    sub = payload.get("sub")
    if not sub:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide : champ 'sub' manquant",
            headers={"WWW-Authenticate": "Bearer"},
        )
    try:
        user_pk = int(sub)
    except (ValueError, TypeError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide : 'sub' doit être un entier",
            headers={"WWW-Authenticate": "Bearer"},
        )
    result = await db.execute(select(models.User).where(models.User.user_pk == user_pk))
    user = result.scalars().first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Utilisateur non trouvé",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Compte utilisateur inactif")
    return user


async def get_optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(optional_security),
    db: AsyncSession = Depends(get_db),
) -> Optional[models.User]:
    """Retourne l'utilisateur authentifié, ou None pour un accès public anonyme."""
    if credentials is None:
        return None
    return await get_current_user(credentials=credentials, db=db)


ROLE_ADMIN = "admin"
ROLE_PROFESSEUR = "professeur"
ROLE_ETUDIANT = "etudiant"


async def get_current_active_user(
    current_user: models.User = Depends(get_current_user),
    _client_application: Optional[dict] = Depends(get_client_application),
) -> models.User:
    """Vérifie le compte et valide l'identifiant applicatif optionnel.

    L'absence de X-Client-App reste autorisée pour préserver les clients existants.
    L'identifiant enregistré ne confère aucun privilège supplémentaire.
    """
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Utilisateur inactif")
    return current_user


def require_roles(*allowed_roles: str):
    async def dependency(current_user: models.User = Depends(get_current_active_user)) -> models.User:
        if current_user.role not in allowed_roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Droits insuffisants")
        return current_user
    return dependency


async def require_admin(current_user: models.User = Depends(get_current_studio_user)) -> models.User:
    from .permissions import has_permission
    if not has_permission(current_user, "client_apps:manage"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Droits administrateur requis")
    return current_user


async def require_teacher_or_admin(current_user: models.User = Depends(get_current_studio_user)) -> models.User:
    from .permissions import has_permission
    if not has_permission(current_user, "content:create"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Droits professeur ou administrateur requis")
    return current_user


async def require_student_or_above(current_user: models.User = Depends(get_current_active_user)) -> models.User:
    from .permissions import has_permission
    if not has_permission(current_user, "content:read"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Rôle utilisateur invalide")
    return current_user
