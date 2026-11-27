"""Browser-mediated OAuth authorization-code flow for the central Studio SPA.

The browser submits the user's short-lived legacy access token in the POST body.
The endpoint validates the real browser Origin, an exact registered redirect URI,
and an S256 PKCE challenge, then redirects only to that registered callback.
No client secret is embedded in the public frontend.
"""
import base64
import hashlib
import json
import re
import secrets
from datetime import datetime, timedelta, timezone
from urllib.parse import urlencode, urlsplit

from fastapi import APIRouter, Depends, Form, Header, HTTPException, status
from fastapi.responses import RedirectResponse
from sqlalchemy import delete, select, update
from sqlalchemy.ext.asyncio import AsyncSession

from .. import models
from ..client_applications import client_applications, validate_app_code
from ..database import get_db
from ..security import create_access_token, verify_token

router = APIRouter(prefix="/api/oauth", tags=["application identity"])
PKCE_CHALLENGE_RE = re.compile(r"^[A-Za-z0-9_-]{43}$")
STATE_RE = re.compile(r"^[A-Za-z0-9._~-]{16,256}$")
PKCE_VERIFIER_RE = re.compile(r"^[A-Za-z0-9._~-]{43,128}$")
CODE_TTL_SECONDS = 90


def _pkce_challenge(verifier: str) -> str:
    digest = hashlib.sha256(verifier.encode("ascii")).digest()
    return base64.urlsafe_b64encode(digest).rstrip(b"=").decode("ascii")


def _origin_from_uri(uri: str) -> str:
    parsed = urlsplit(uri)
    if parsed.scheme not in {"https", "http"} or not parsed.netloc:
        raise HTTPException(status_code=400, detail="URI de redirection invalide")
    if parsed.username or parsed.password or parsed.fragment:
        raise HTTPException(status_code=400, detail="URI de redirection invalide")
    if parsed.scheme != "https" and parsed.hostname not in {"localhost", "127.0.0.1"}:
        raise HTTPException(status_code=400, detail="HTTPS obligatoire")
    return f"{parsed.scheme}://{parsed.netloc}"


@router.post("/authorize")
async def authorize_studio(
    authorization_token: str = Form(...),
    client_id: str = Form(...),
    redirect_uri: str = Form(...),
    code_challenge: str = Form(...),
    code_challenge_method: str = Form(...),
    state: str = Form(...),
    origin: str | None = Header(default=None),
    db: AsyncSession = Depends(get_db),
):
    if not origin or code_challenge_method != "S256":
        raise HTTPException(status_code=400, detail="Requête OAuth invalide")
    if not PKCE_CHALLENGE_RE.fullmatch(code_challenge) or not STATE_RE.fullmatch(state):
        raise HTTPException(status_code=400, detail="Challenge PKCE ou state invalide")
    try:
        client_id = validate_app_code(client_id)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail="Client OAuth invalide") from exc

    result = await db.execute(select(client_applications).where(client_applications.c.code == client_id))
    client = result.mappings().first()
    if not client or not client["is_active"] or client["client_type"] != "public_web":
        raise HTTPException(status_code=403, detail="Client OAuth inconnu ou désactivé")
    allowed_origins = json.loads(client["allowed_origins"] or "[]")
    allowed_redirects = json.loads(client["allowed_redirect_uris"] or "[]")
    normalized_origin = origin.rstrip("/")
    if normalized_origin not in {item.rstrip("/") for item in allowed_origins}:
        raise HTTPException(status_code=403, detail="Origine non autorisée")
    if redirect_uri not in allowed_redirects or _origin_from_uri(redirect_uri) != normalized_origin:
        raise HTTPException(status_code=400, detail="URI de redirection non autorisée")

    payload = verify_token(authorization_token)
    if payload.get("aud") or payload.get("client_app"):
        raise HTTPException(status_code=400, detail="Un jeton utilisateur non applicatif est requis")
    try:
        user_pk = int(payload["sub"])
    except (KeyError, TypeError, ValueError) as exc:
        raise HTTPException(status_code=401, detail="Jeton utilisateur invalide") from exc
    user_result = await db.execute(select(models.User).where(models.User.user_pk == user_pk))
    user = user_result.scalars().first()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="Utilisateur invalide ou inactif")

    now = datetime.now(timezone.utc)
    await db.execute(delete(models.OAuthAuthorizationCode).where(
        models.OAuthAuthorizationCode.expires_at < now - timedelta(days=1)
    ))
    raw_code = secrets.token_urlsafe(32)
    db.add(models.OAuthAuthorizationCode(
        code_hash=hashlib.sha256(raw_code.encode("ascii")).hexdigest(),
        user_pk=user_pk,
        client_code=client_id,
        redirect_uri=redirect_uri,
        code_challenge=code_challenge,
        expires_at=now + timedelta(seconds=CODE_TTL_SECONDS),
        created_at=now,
    ))
    await db.commit()
    return RedirectResponse(
        url=f"{redirect_uri}#{urlencode({'code': raw_code, 'state': state})}",
        status_code=status.HTTP_303_SEE_OTHER,
    )


@router.post("/token")
async def exchange_authorization_code(
    grant_type: str = Form(...),
    code: str = Form(...),
    client_id: str = Form(...),
    redirect_uri: str = Form(...),
    code_verifier: str = Form(...),
    db: AsyncSession = Depends(get_db),
):
    if grant_type != "authorization_code" or not PKCE_VERIFIER_RE.fullmatch(code_verifier):
        raise HTTPException(status_code=400, detail="Échange OAuth invalide")
    try:
        client_id = validate_app_code(client_id)
    except (ValueError, UnicodeEncodeError) as exc:
        raise HTTPException(status_code=400, detail="Client ou vérificateur PKCE invalide") from exc

    app_result = await db.execute(select(client_applications).where(client_applications.c.code == client_id))
    app_row = app_result.mappings().first()
    if not app_row or not app_row["is_active"] or app_row["client_type"] != "public_web":
        raise HTTPException(status_code=400, detail="Client OAuth désactivé ou inconnu")
    current_redirects = json.loads(app_row["allowed_redirect_uris"] or "[]")
    if redirect_uri not in current_redirects:
        raise HTTPException(status_code=400, detail="URI de redirection non autorisée")

    code_hash = hashlib.sha256(code.encode("ascii", errors="ignore")).hexdigest()
    now = datetime.now(timezone.utc)
    result = await db.execute(select(models.OAuthAuthorizationCode).where(
        models.OAuthAuthorizationCode.code_hash == code_hash,
        models.OAuthAuthorizationCode.client_code == client_id,
        models.OAuthAuthorizationCode.redirect_uri == redirect_uri,
        models.OAuthAuthorizationCode.expires_at > now,
        models.OAuthAuthorizationCode.consumed_at.is_(None),
    ))
    authorization = result.scalars().first()
    if not authorization or not secrets.compare_digest(
        authorization.code_challenge, _pkce_challenge(code_verifier)
    ):
        raise HTTPException(status_code=400, detail="Code OAuth invalide, expiré ou déjà utilisé")

    consumed = await db.execute(
        update(models.OAuthAuthorizationCode)
        .where(
            models.OAuthAuthorizationCode.code_pk == authorization.code_pk,
            models.OAuthAuthorizationCode.consumed_at.is_(None),
            models.OAuthAuthorizationCode.expires_at > now,
        )
        .values(consumed_at=now)
        .returning(models.OAuthAuthorizationCode.user_pk)
    )
    user_pk = consumed.scalar_one_or_none()
    if user_pk is None:
        await db.rollback()
        raise HTTPException(status_code=400, detail="Code OAuth déjà utilisé")
    user_result = await db.execute(select(models.User).where(models.User.user_pk == user_pk))
    user = user_result.scalars().first()
    if not user or not user.is_active:
        await db.commit()
        raise HTTPException(status_code=401, detail="Utilisateur invalide ou inactif")
    await db.commit()

    token = create_access_token({
        "sub": user.user_pk,
        "aud": client_id,
        "client_app": client_id,
        "token_use": "app_access",
    })
    return {"access_token": token, "token_type": "bearer", "expires_in": 1800, "client_app": client_id}
