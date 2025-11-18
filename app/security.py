import os
from datetime import datetime, timedelta
from typing import Optional
from passlib.context import CryptContext
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from .database import get_db
from . import models

# Configuration de sécurité
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Clés secrètes (à mettre dans les variables d'environnement en production)
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production-12345")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
REFRESH_TOKEN_EXPIRE_DAYS = 7

# Schéma de sécurité HTTP Bearer
security = HTTPBearer()


# ============================================================================
# GESTION DES MOTS DE PASSE
# ============================================================================

def hash_password(password: str) -> str:
    """Hache un mot de passe avec bcrypt."""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifie un mot de passe contre son hash."""
    return pwd_context.verify(plain_password, hashed_password)


# ============================================================================
# GESTION DES TOKENS JWT
# ============================================================================

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Crée un token JWT d'accès."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(data: dict) -> str:
    """Crée un token JWT de rafraîchissement."""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(token: str) -> dict:
    """Vérifie et décode un token JWT."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )


# ============================================================================
# DÉPENDANCES D'AUTHENTIFICATION
# ============================================================================

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> models.User:
    """
    Récupère l'utilisateur actuel à partir du token JWT.
    Dépendance à utiliser pour sécuriser les endpoints.
    """
    token = credentials.credentials
    payload = verify_token(token)
    
    user_pk: int = payload.get("sub")
    if user_pk is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Récupérer l'utilisateur de la base de données
    from sqlalchemy import select
    result = await db.execute(select(models.User).where(models.User.user_pk == user_pk))
    user = result.scalars().first()
    
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive",
        )
    
    return user


async def get_current_active_user(
    current_user: models.User = Depends(get_current_user),
) -> models.User:
    """Vérifie que l'utilisateur actuel est actif."""
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user
