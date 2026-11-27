import pytest
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials
from types import SimpleNamespace

from app.api.endpoints_oauth import _pkce_challenge, _origin_from_uri
from app.security import create_access_token, get_current_studio_user


def test_pkce_s256_rfc7636_vector():
    verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
    assert _pkce_challenge(verifier) == "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"


def test_redirect_uri_origin_is_exact_and_safe():
    assert _origin_from_uri("https://bella-design-lab.vercel.app/oauth/callback") == "https://bella-design-lab.vercel.app"
    assert _origin_from_uri("http://localhost:8081/oauth/callback") == "http://localhost:8081"
    with pytest.raises(HTTPException):
        _origin_from_uri("http://example.com/oauth/callback")
    with pytest.raises(HTTPException):
        _origin_from_uri("https://user:password@example.com/callback")


@pytest.mark.asyncio
async def test_studio_dependency_accepts_only_studio_scoped_access_token():
    user = SimpleNamespace(user_pk=12)
    token = create_access_token({
        "sub": 12, "aud": "studio", "client_app": "studio", "token_use": "app_access"
    })
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    assert await get_current_studio_user(credentials=credentials, current_user=user) is user


@pytest.mark.asyncio
@pytest.mark.parametrize("claims", [
    {"sub": 12},
    {"sub": 12, "aud": "perckyl-ingua", "client_app": "perckyl-ingua", "token_use": "app_access"},
    {"sub": 12, "aud": "studio", "client_app": "studio", "token_use": "access"},
])
async def test_studio_dependency_rejects_generic_or_other_app_tokens(claims):
    user = SimpleNamespace(user_pk=12)
    token = create_access_token(claims)
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    with pytest.raises(HTTPException) as exc:
        await get_current_studio_user(credentials=credentials, current_user=user)
    assert exc.value.status_code == 403
