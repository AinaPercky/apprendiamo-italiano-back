import pytest
from pydantic import ValidationError

from app import google_oauth
from app.schemas_google_oauth import GoogleLoginRequest


VALID_CLAIMS = {
    "iss": "https://accounts.google.com",
    "sub": "google-subject-123",
    "email": "learner@example.com",
    "email_verified": True,
    "given_name": "Ada",
    "family_name": "Lovelace",
    "picture": "https://example.com/avatar.png",
    "exp": 4_102_444_800,
    "aud": "studio-client-id",
}


@pytest.mark.asyncio
async def test_google_token_is_verified_against_configured_audience(monkeypatch):
    monkeypatch.setattr(google_oauth, "GOOGLE_CLIENT_ID", "studio-client-id")
    calls = {}

    def fake_verify(token, request, audience):
        calls["token"] = token
        calls["audience"] = audience
        return dict(VALID_CLAIMS)

    monkeypatch.setattr(
        google_oauth.id_token,
        "verify_oauth2_token",
        fake_verify,
    )

    claims = await google_oauth.verify_google_token("signed-google-token")

    assert claims["sub"] == "google-subject-123"
    assert calls == {
        "token": "signed-google-token",
        "audience": "studio-client-id",
    }


@pytest.mark.asyncio
async def test_google_token_rejects_untrusted_issuer(monkeypatch):
    monkeypatch.setattr(google_oauth, "GOOGLE_CLIENT_ID", "studio-client-id")
    monkeypatch.setattr(
        google_oauth.id_token,
        "verify_oauth2_token",
        lambda *_args: {**VALID_CLAIMS, "iss": "https://attacker.example"},
    )

    with pytest.raises(google_oauth.GoogleOAuthError, match="issuer"):
        await google_oauth.verify_google_token("signed-google-token")


@pytest.mark.asyncio
async def test_google_token_rejects_unverified_email(monkeypatch):
    monkeypatch.setattr(google_oauth, "GOOGLE_CLIENT_ID", "studio-client-id")
    monkeypatch.setattr(
        google_oauth.id_token,
        "verify_oauth2_token",
        lambda *_args: {**VALID_CLAIMS, "email_verified": False},
    )

    with pytest.raises(google_oauth.GoogleOAuthError, match="not verified"):
        await google_oauth.verify_google_token("signed-google-token")


@pytest.mark.asyncio
async def test_google_token_rejects_missing_subject(monkeypatch):
    monkeypatch.setattr(google_oauth, "GOOGLE_CLIENT_ID", "studio-client-id")
    monkeypatch.setattr(
        google_oauth.id_token,
        "verify_oauth2_token",
        lambda *_args: {**VALID_CLAIMS, "sub": ""},
    )

    with pytest.raises(google_oauth.GoogleOAuthError, match="missing"):
        await google_oauth.verify_google_token("signed-google-token")


@pytest.mark.asyncio
async def test_google_token_fails_closed_without_client_id(monkeypatch):
    monkeypatch.setattr(google_oauth, "GOOGLE_CLIENT_ID", "")

    def should_not_be_called(*_args):
        raise AssertionError("Google verifier must not run without a client ID")

    monkeypatch.setattr(
        google_oauth.id_token,
        "verify_oauth2_token",
        should_not_be_called,
    )

    with pytest.raises(google_oauth.GoogleOAuthConfigurationError):
        await google_oauth.verify_google_token("signed-google-token")


@pytest.mark.asyncio
async def test_google_token_hides_verifier_error_details(monkeypatch):
    monkeypatch.setattr(google_oauth, "GOOGLE_CLIENT_ID", "studio-client-id")

    def invalid_signature(*_args):
        raise ValueError("internal verifier detail")

    monkeypatch.setattr(
        google_oauth.id_token,
        "verify_oauth2_token",
        invalid_signature,
    )

    with pytest.raises(google_oauth.GoogleOAuthError) as error:
        await google_oauth.verify_google_token("signed-google-token")

    assert "internal verifier detail" not in str(error.value)


def test_studio_contract_accepts_google_credential_token():
    request = GoogleLoginRequest.model_validate({"token": "google-id-token"})
    assert request.token == "google-id-token"


def test_old_unverified_identity_payload_is_rejected():
    with pytest.raises(ValidationError):
        GoogleLoginRequest.model_validate({
            "google_id": "attacker-controlled-subject",
            "google_email": "attacker@example.com",
            "first_name": "Attacker",
        })


def test_google_config_requires_client_id(monkeypatch):
    monkeypatch.setattr(google_oauth, "GOOGLE_CLIENT_ID", "")

    with pytest.raises(google_oauth.GoogleOAuthConfigurationError):
        google_oauth.get_google_oauth_config()


@pytest.mark.asyncio
async def test_google_token_rejects_expired_claim(monkeypatch):
    monkeypatch.setattr(google_oauth, "GOOGLE_CLIENT_ID", "studio-client-id")
    monkeypatch.setattr(
        google_oauth.id_token,
        "verify_oauth2_token",
        lambda *_args: {**VALID_CLAIMS, "exp": 1},
    )

    with pytest.raises(google_oauth.GoogleOAuthError, match="expired"):
        await google_oauth.verify_google_token("signed-google-token")


@pytest.mark.asyncio
async def test_existing_local_account_is_not_linked_by_email():
    from app.crud_google_users import (
        GoogleAccountConflictError,
        create_or_update_google_user,
    )
    from app.schemas_google_oauth import VerifiedGoogleIdentity

    class FakeResult:
        def __init__(self, value):
            self.value = value

        def scalar_one_or_none(self):
            return self.value

    class FakeDatabase:
        def __init__(self, results):
            self.results = iter(results)
            self.committed = False

        async def execute(self, _statement):
            return next(self.results)

        async def commit(self):
            self.committed = True

    existing_local_user = object()
    db = FakeDatabase([FakeResult(None), FakeResult(existing_local_user)])
    identity = VerifiedGoogleIdentity(
        google_id="new-google-subject",
        google_email="learner@example.com",
    )

    with pytest.raises(GoogleAccountConflictError):
        await create_or_update_google_user(db, identity)

    assert db.committed is False
