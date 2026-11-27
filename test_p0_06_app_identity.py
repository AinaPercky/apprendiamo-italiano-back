import hashlib
from datetime import datetime, timedelta, timezone
from types import SimpleNamespace
from urllib.parse import parse_qs, urlsplit

import pytest
from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials

from app.api import endpoints_oauth
from app.api.endpoints_oauth import (
    _pkce_challenge,
    _origin_from_uri,
    authorize_studio,
    exchange_authorization_code,
)
from app.security import create_access_token, get_current_studio_user


class FakeResult:
    def __init__(self, value=None):
        self.value = value

    def mappings(self):
        return self

    def scalars(self):
        return self

    def first(self):
        return self.value

    def scalar_one_or_none(self):
        return self.value


class FakeDatabase:
    def __init__(self, *results):
        self.results = list(results)
        self.statements = []
        self.added = []
        self.commits = 0
        self.rollbacks = 0

    async def execute(self, statement):
        self.statements.append(statement)
        if not self.results:
            return FakeResult()
        value = self.results.pop(0)
        return value if isinstance(value, FakeResult) else FakeResult(value)

    def add(self, value):
        self.added.append(value)

    async def commit(self):
        self.commits += 1

    async def rollback(self):
        self.rollbacks += 1


def studio_client(**overrides):
    row = {
        "code": "studio",
        "is_active": True,
        "client_type": "public_web",
        "allowed_origins": '["https://bella-design-lab.vercel.app"]',
        "allowed_redirect_uris": '["https://bella-design-lab.vercel.app/oauth/callback"]',
    }
    row.update(overrides)
    return row


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
async def test_authorize_rejects_unregistered_origin_before_issuing_code(monkeypatch):
    monkeypatch.setattr(endpoints_oauth, "verify_token", lambda _token: {"sub": "12"})
    db = FakeDatabase(studio_client())
    with pytest.raises(HTTPException) as exc:
        await authorize_studio(
            authorization_token="legacy-token",
            client_id="studio",
            redirect_uri="https://bella-design-lab.vercel.app/oauth/callback",
            code_challenge="A" * 43,
            code_challenge_method="S256",
            state="s" * 32,
            origin="https://attacker.example",
            db=db,
        )
    assert exc.value.status_code == 403
    assert db.added == []
    assert db.commits == 0


@pytest.mark.asyncio
async def test_authorize_rejects_callback_not_in_exact_allowlist(monkeypatch):
    monkeypatch.setattr(endpoints_oauth, "verify_token", lambda _token: {"sub": "12"})
    db = FakeDatabase(studio_client())
    with pytest.raises(HTTPException) as exc:
        await authorize_studio(
            authorization_token="legacy-token",
            client_id="studio",
            redirect_uri="https://bella-design-lab.vercel.app.evil.example/oauth/callback",
            code_challenge="A" * 43,
            code_challenge_method="S256",
            state="s" * 32,
            origin="https://bella-design-lab.vercel.app",
            db=db,
        )
    assert exc.value.status_code == 400
    assert db.added == []


@pytest.mark.asyncio
async def test_authorize_stores_only_code_hash_and_returns_code_in_fragment(monkeypatch):
    user = SimpleNamespace(user_pk=12, is_active=True)
    monkeypatch.setattr(endpoints_oauth, "verify_token", lambda _token: {"sub": "12"})
    db = FakeDatabase(studio_client(), user, None)
    response = await authorize_studio(
        authorization_token="legacy-token",
        client_id="studio",
        redirect_uri="https://bella-design-lab.vercel.app/oauth/callback",
        code_challenge="A" * 43,
        code_challenge_method="S256",
        state="s" * 32,
        origin="https://bella-design-lab.vercel.app",
        db=db,
    )
    location = response.headers["location"]
    parsed = urlsplit(location)
    fragment = parse_qs(parsed.fragment)
    raw_code = fragment["code"][0]
    assert parsed.query == ""
    assert fragment["state"] == ["s" * 32]
    assert len(raw_code) == 43
    assert db.added[0].code_hash == hashlib.sha256(raw_code.encode("ascii")).hexdigest()
    assert not hasattr(db.added[0], "code")
    assert db.added[0].expires_at - db.added[0].created_at == timedelta(seconds=90)
    assert db.commits == 1


@pytest.mark.asyncio
async def test_token_exchange_rejects_wrong_pkce_verifier_without_consuming_code():
    verifier = "v" * 43
    authorization = SimpleNamespace(
        code_pk=7,
        code_challenge=_pkce_challenge("c" * 43),
        user_pk=12,
    )
    db = FakeDatabase(studio_client(), authorization)
    with pytest.raises(HTTPException) as exc:
        await exchange_authorization_code(
            grant_type="authorization_code",
            code="A" * 43,
            client_id="studio",
            redirect_uri="https://bella-design-lab.vercel.app/oauth/callback",
            code_verifier=verifier,
            db=db,
        )
    assert exc.value.status_code == 400
    assert len(db.statements) == 2
    assert db.commits == 0


@pytest.mark.asyncio
async def test_token_exchange_rejects_expired_or_replayed_code():
    db = FakeDatabase(studio_client(), None)
    with pytest.raises(HTTPException) as exc:
        await exchange_authorization_code(
            grant_type="authorization_code",
            code="A" * 43,
            client_id="studio",
            redirect_uri="https://bella-design-lab.vercel.app/oauth/callback",
            code_verifier="v" * 43,
            db=db,
        )
    assert exc.value.status_code == 400
    assert db.commits == 0


@pytest.mark.asyncio
async def test_token_exchange_rejects_atomic_consumption_race(monkeypatch):
    verifier = "v" * 43
    authorization = SimpleNamespace(
        code_pk=7,
        code_challenge=_pkce_challenge(verifier),
        user_pk=12,
    )
    db = FakeDatabase(studio_client(), authorization, None)
    with pytest.raises(HTTPException) as exc:
        await exchange_authorization_code(
            grant_type="authorization_code",
            code="A" * 43,
            client_id="studio",
            redirect_uri="https://bella-design-lab.vercel.app/oauth/callback",
            code_verifier=verifier,
            db=db,
        )
    assert exc.value.status_code == 400
    assert db.rollbacks == 1
    assert db.commits == 0


@pytest.mark.asyncio
async def test_token_exchange_issues_app_scoped_token_only_after_code_consumption(monkeypatch):
    verifier = "v" * 43
    authorization = SimpleNamespace(
        code_pk=7,
        code_challenge=_pkce_challenge(verifier),
        user_pk=12,
    )
    user = SimpleNamespace(user_pk=12, is_active=True)
    issued = {}
    monkeypatch.setattr(
        endpoints_oauth,
        "create_access_token",
        lambda claims: issued.update(claims) or "signed-studio-token",
    )
    db = FakeDatabase(studio_client(), authorization, 12, user)
    response = await exchange_authorization_code(
        grant_type="authorization_code",
        code="A" * 43,
        client_id="studio",
        redirect_uri="https://bella-design-lab.vercel.app/oauth/callback",
        code_verifier=verifier,
        db=db,
    )
    assert response["access_token"] == "signed-studio-token"
    assert response["client_app"] == "studio"
    assert issued["aud"] == "studio"
    assert issued["client_app"] == "studio"
    assert issued["token_use"] == "app_access"
    assert db.commits == 1


@pytest.mark.asyncio
async def test_token_exchange_rejects_inactive_user_after_consuming_code(monkeypatch):
    verifier = "v" * 43
    authorization = SimpleNamespace(
        code_pk=7,
        code_challenge=_pkce_challenge(verifier),
        user_pk=12,
    )
    inactive_user = SimpleNamespace(user_pk=12, is_active=False)
    db = FakeDatabase(studio_client(), authorization, 12, inactive_user)
    with pytest.raises(HTTPException) as exc:
        await exchange_authorization_code(
            grant_type="authorization_code",
            code="A" * 43,
            client_id="studio",
            redirect_uri="https://bella-design-lab.vercel.app/oauth/callback",
            code_verifier=verifier,
            db=db,
        )
    assert exc.value.status_code == 401
    assert db.commits == 1


@pytest.mark.asyncio
async def test_studio_dependency_accepts_only_studio_scoped_access_token(monkeypatch):
    monkeypatch.setenv("REQUIRE_STUDIO_APP_TOKEN", "true")
    user = SimpleNamespace(user_pk=12)
    token = create_access_token({
        "sub": 12, "aud": "studio", "client_app": "studio", "token_use": "app_access"
    })
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    assert await get_current_studio_user(credentials=credentials, current_user=user) is user


@pytest.mark.asyncio
@pytest.mark.parametrize("claims", [
    {"sub": 12},
    {"sub": 12, "aud": "perckylingua", "client_app": "perckylingua", "token_use": "app_access"},
    {"sub": 12, "aud": "studio", "client_app": "studio", "token_use": "access"},
])
async def test_studio_dependency_rejects_generic_or_other_app_tokens(claims, monkeypatch):
    monkeypatch.setenv("REQUIRE_STUDIO_APP_TOKEN", "true")
    user = SimpleNamespace(user_pk=12)
    token = create_access_token(claims)
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    with pytest.raises(HTTPException) as exc:
        await get_current_studio_user(credentials=credentials, current_user=user)
    assert exc.value.status_code == 403


@pytest.mark.asyncio
async def test_legacy_token_is_accepted_during_compatibility_rollout(monkeypatch):
    monkeypatch.setenv("REQUIRE_STUDIO_APP_TOKEN", "false")
    user = SimpleNamespace(user_pk=12)
    token = create_access_token({"sub": 12})
    credentials = HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)
    assert await get_current_studio_user(credentials=credentials, current_user=user) is user
