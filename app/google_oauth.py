"""
Validation des identifiants Google Identity Services (ID tokens).

Le navigateur transmet uniquement response.credential. Le backend vérifie
la signature, l'audience et l'expiration auprès des bibliothèques Google
avant d'utiliser les claims d'identité.
"""
import logging
import os
import time

from google.auth.transport import requests
from google.oauth2 import id_token

logger = logging.getLogger(__name__)

# Le Client ID est public et peut être communiqué au Studio.
# Aucun identifiant de remplacement ne doit être accepté en production.
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "").strip()


class GoogleOAuthError(Exception):
    """Jeton Google absent, invalide ou ne contenant pas une identité fiable."""


class GoogleOAuthConfigurationError(GoogleOAuthError):
    """Configuration serveur Google OAuth absente ou incorrecte."""


async def verify_google_token(token: str) -> dict:
    """Vérifie cryptographiquement un Google ID token et ses claims essentiels."""
    if not isinstance(token, str) or not token.strip():
        raise GoogleOAuthError("Google credential is required")

    if not GOOGLE_CLIENT_ID:
        raise GoogleOAuthConfigurationError("Google OAuth is not configured")

    try:
        claims = id_token.verify_oauth2_token(
            token.strip(),
            requests.Request(),
            GOOGLE_CLIENT_ID,
        )
    except Exception as exc:
        # Ne jamais renvoyer au client les détails du validateur ou le jeton.
        logger.warning(
            "Google ID token verification failed (%s)",
            type(exc).__name__,
        )
        raise GoogleOAuthError("Google credential is invalid or expired") from exc

    # verify_oauth2_token vérifie la signature, l'audience et l'expiration.
    # On verrouille aussi explicitement l'émetteur et les claims utilisés.
    if claims.get("iss") not in {
        "accounts.google.com",
        "https://accounts.google.com",
    }:
        raise GoogleOAuthError("Google credential has an invalid issuer")

    if not claims.get("sub") or not claims.get("email"):
        raise GoogleOAuthError("Google credential is missing required identity claims")

    if claims.get("email_verified") is not True:
        raise GoogleOAuthError("Google email address is not verified")

    expiration = claims.get("exp")
    if not isinstance(expiration, (int, float)) or expiration <= time.time():
        raise GoogleOAuthError("Google credential is expired")

    return claims


def extract_user_info(claims: dict) -> dict:
    """Extrait uniquement les informations issues du jeton Google vérifié."""
    return {
        "google_id": claims["sub"],
        "email": claims["email"].strip().lower(),
        "first_name": claims.get("given_name"),
        "last_name": claims.get("family_name"),
        "picture": claims.get("picture"),
        "email_verified": claims["email_verified"],
    }


async def validate_and_extract_google_user(token: str) -> dict:
    claims = await verify_google_token(token)
    return extract_user_info(claims)


def get_google_oauth_config() -> dict:
    """Expose au Studio le Client ID public, jamais un secret serveur."""
    if not GOOGLE_CLIENT_ID:
        raise GoogleOAuthConfigurationError("Google OAuth is not configured")

    return {"client_id": GOOGLE_CLIENT_ID}
