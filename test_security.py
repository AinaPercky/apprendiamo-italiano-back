from datetime import datetime, timedelta

import pytest
from fastapi import HTTPException
from jose import jwt

from app import security


def test_access_token_is_explicitly_typed():
    token = security.create_access_token({"sub": 123})
    payload = jwt.decode(token, security.SECRET_KEY, algorithms=[security.ALGORITHM])

    assert payload["sub"] == "123"
    assert payload["type"] == "access"


def test_refresh_token_is_rejected_by_access_token_verifier():
    token = security.create_refresh_token({"sub": 123})

    with pytest.raises(HTTPException) as error:
        security.verify_token(token)

    assert error.value.status_code == 401
    assert error.value.detail == "Type de token non autorisé"


def test_legacy_access_token_without_type_remains_accepted():
    token = jwt.encode(
        {"sub": "123", "exp": datetime.utcnow() + timedelta(minutes=5)},
        security.SECRET_KEY,
        algorithm=security.ALGORITHM,
    )

    assert security.verify_token(token)["sub"] == "123"


def test_unknown_token_type_is_rejected():
    token = jwt.encode(
        {
            "sub": "123",
            "type": "password_reset",
            "exp": datetime.utcnow() + timedelta(minutes=5),
        },
        security.SECRET_KEY,
        algorithm=security.ALGORITHM,
    )

    with pytest.raises(HTTPException) as error:
        security.verify_token(token)

    assert error.value.status_code == 401


def test_invalid_signature_is_rejected_without_leaking_jwt_error():
    token = jwt.encode(
        {
            "sub": "123",
            "type": "access",
            "exp": datetime.utcnow() + timedelta(minutes=5),
        },
        "a-different-test-secret",
        algorithm=security.ALGORITHM,
    )

    with pytest.raises(HTTPException) as error:
        security.verify_token(token)

    assert error.value.status_code == 401
    assert error.value.detail == "Token invalide ou expiré"


def test_missing_secret_is_a_configuration_error(monkeypatch):
    monkeypatch.delenv("SECRET_KEY", raising=False)

    with pytest.raises(RuntimeError, match="SECRET_KEY est obligatoire"):
        security._load_secret_key()
