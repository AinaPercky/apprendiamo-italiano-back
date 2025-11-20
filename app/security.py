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

# ============================================================================
# CONFIGURATION DE SÉCURITÉ
# ============================================================================

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Clé secrète – EN PROD, TOUJOURS via .env ! Le fallback est là uniquement pour dev local
SECRET_KEY = os.getenv(
    "SECRET_KEY",
    "dev-only-fallback-change-me-in-production-12345678901234567890"
)
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30  # 30 minutes (ajustable)
REFRESH_TOKEN_EXPIRE_DAYS = 7

# Schéma Bearer Token
security = HTTPBearer()


# ============================================================================
# GESTION DES MOTS DE PASSE
# ============================================================================

def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


# ============================================================================
# GESTION DES TOKENS JWT
# ============================================================================

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Crée un token JWT d'accès.
    Force toujours le champ 'sub' en string → conforme aux specs JWT et évite les 401.
    """
    to_encode = data.copy()

    expire = datetime.utcnow() + (
        expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    # On s'assure que 'sub' existe et est une string
    sub = to_encode.get("sub")
    if sub is not None:
        to_encode["sub"] = str(sub)  # ← LA LIGNE QUI RÉSOUT TON PROBLÈME À 100%
    else:
        raise ValueError("Le champ 'sub' est obligatoire pour créer un token")

    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def create_refresh_token(data: dict) -> str:
    """Crée un token de rafraîchissement (7 jours par défaut)."""
    to_encode = data.copy()
    sub = to_encode.get("sub")
    if sub is not None:
        to_encode["sub"] = str(sub)

    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def verify_token(token: str) -> dict:
    """Vérifie et décode un token JWT."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token invalide ou expiré: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )


# ============================================================================
# DÉPENDANCES D'AUTHENTIFICATION
# ============================================================================

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> models.User:
    """
    Dépendance FastAPI : récupère l'utilisateur à partir du token Bearer.
    Robuste même si 'sub' était un int dans un ancien token.
    """
    token = credentials.credentials
    payload = verify_token(token)

    sub = payload.get("sub")
    if not sub:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide : champ 'sub' manquant",
            headers={"WWW-Authenticate": "Bearer"},
        )

    try:
        user_pk = int(sub)  # Conversion sécurisée (accepte string ou int)
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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Compte utilisateur inactif",
        )

    return user


async def get_current_active_user(
    current_user: models.User = Depends(get_current_user),
) -> models.User:
    """Wrapper simple pour vérifier que l'utilisateur est actif."""
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Utilisateur inactif")
    return current_user