"""
Gestion de l'authentification Google OAuth 2.0

Ce module fournit les fonctionnalités pour :
- Valider les tokens Google ID
- Extraire les informations utilisateur du token
- Gérer le flux d'authentification OAuth
"""

import os
from typing import Optional
from google.auth.transport import requests
from google.oauth2 import id_token
import logging

logger = logging.getLogger(__name__)

# Configuration Google OAuth
GOOGLE_CLIENT_ID = os.getenv(
    "GOOGLE_CLIENT_ID",
    "your-google-client-id.apps.googleusercontent.com"
)

GOOGLE_CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET", "your-google-client-secret")


class GoogleOAuthError(Exception):
    """Exception levée lors d'une erreur d'authentification Google."""
    pass


async def verify_google_token(token: str) -> dict:
    """
    Vérifie et décode un token Google ID.
    
    Args:
        token: Le token Google ID à vérifier
        
    Returns:
        dict: Les informations utilisateur contenues dans le token
        
    Raises:
        GoogleOAuthError: Si le token est invalide
    """
    try:
        # Vérifier le token avec Google
        idinfo = id_token.verify_oauth2_token(
            token,
            requests.Request(),
            GOOGLE_CLIENT_ID
        )
        
        # Vérifier que le token n'a pas expiré
        if idinfo.get("exp") is None:
            raise GoogleOAuthError("Token has no expiration")
        
        return idinfo
        
    except Exception as e:
        logger.error(f"Google token verification failed: {str(e)}")
        raise GoogleOAuthError(f"Invalid Google token: {str(e)}")


def extract_user_info(token_info: dict) -> dict:
    """
    Extrait les informations utilisateur d'un token Google.
    
    Args:
        token_info: Les informations décodées du token
        
    Returns:
        dict: Les informations utilisateur structurées
    """
    return {
        "google_id": token_info.get("sub"),
        "email": token_info.get("email"),
        "first_name": token_info.get("given_name"),
        "last_name": token_info.get("family_name"),
        "picture": token_info.get("picture"),
        "email_verified": token_info.get("email_verified", False),
    }


async def validate_and_extract_google_user(token: str) -> dict:
    """
    Valide un token Google et extrait les informations utilisateur.
    
    Args:
        token: Le token Google ID
        
    Returns:
        dict: Les informations utilisateur
        
    Raises:
        GoogleOAuthError: Si le token est invalide
    """
    token_info = await verify_google_token(token)
    return extract_user_info(token_info)


# ============================================================================
# CONFIGURATION POUR LE FRONTEND
# ============================================================================

def get_google_oauth_config() -> dict:
    """
    Retourne la configuration Google OAuth pour le frontend.
    
    Cette configuration doit être utilisée par le frontend pour initialiser
    le bouton Google Sign-In.
    """
    return {
        "client_id": GOOGLE_CLIENT_ID,
        "scope": "profile email",
        "discovery_docs": [
            "https://www.googleapis.com/discovery/v1/apis/drive/v3/rest"
        ],
    }
