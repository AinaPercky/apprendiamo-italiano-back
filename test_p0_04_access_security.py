from datetime import datetime, timedelta
from types import SimpleNamespace

import pytest
from fastapi import HTTPException

from app.audio_access import can_read_audio_item
from app.api import endpoints_users


@pytest.mark.asyncio
async def test_published_global_audio_remains_public():
    audio = SimpleNamespace(visibility="global", published_at=datetime.utcnow(), created_by=7)
    assert await can_read_audio_item(None, audio, None) is True


@pytest.mark.asyncio
async def test_unpublished_global_audio_is_not_public():
    audio = SimpleNamespace(visibility="global", published_at=None, created_by=7)
    assert await can_read_audio_item(None, audio, None) is False


@pytest.mark.asyncio
async def test_private_audio_is_visible_to_its_teacher_creator():
    audio = SimpleNamespace(visibility="private", published_at=None, created_by=7)
    teacher = SimpleNamespace(user_pk=7, role="professeur")
    assert await can_read_audio_item(None, audio, teacher) is True


@pytest.mark.asyncio
async def test_private_audio_is_hidden_from_other_teacher():
    audio = SimpleNamespace(visibility="private", published_at=None, created_by=7)
    teacher = SimpleNamespace(user_pk=8, role="professeur")
    assert await can_read_audio_item(None, audio, teacher) is False


@pytest.mark.asyncio
async def test_private_audio_is_visible_to_admin():
    audio = SimpleNamespace(visibility="private", published_at=None, created_by=7)
    admin = SimpleNamespace(user_pk=99, role="admin")
    assert await can_read_audio_item(None, audio, admin) is True


@pytest.mark.asyncio
async def test_user_profile_endpoint_requires_self_or_admin(monkeypatch):
    async def fake_get_user(_db, user_pk):
        return SimpleNamespace(user_pk=user_pk)

    monkeypatch.setattr(endpoints_users.crud_users, "get_user_by_id", fake_get_user)
    with pytest.raises(HTTPException) as error:
        await endpoints_users.get_user(
            user_pk=22,
            current_user=SimpleNamespace(user_pk=11, role="etudiant"),
            db=object(),
        )
    assert error.value.status_code == 404


@pytest.mark.asyncio
async def test_user_can_read_own_profile():
    async def fake_get_user(_db, user_pk):
        return SimpleNamespace(
            user_pk=user_pk, email="user@example.test", full_name="Test User",
            role="etudiant", is_active=True, is_verified=True,
            total_score=0, total_cards_learned=0, total_cards_reviewed=0,
            profile_picture=None, bio=None, created_at=datetime.utcnow(), last_login=None,
        )

    original = endpoints_users.crud_users.get_user_by_id
    endpoints_users.crud_users.get_user_by_id = fake_get_user
    try:
        result = await endpoints_users.get_user(
            user_pk=11,
            current_user=SimpleNamespace(user_pk=11, role="etudiant"),
            db=object(),
        )
        assert result.user_pk == 11
    finally:
        endpoints_users.crud_users.get_user_by_id = original


@pytest.mark.asyncio
async def test_admin_can_read_another_user_profile():
    async def fake_get_user(_db, user_pk):
        return SimpleNamespace(
            user_pk=user_pk, email="user@example.test", full_name="Test User",
            role="etudiant", is_active=True, is_verified=True,
            total_score=0, total_cards_learned=0, total_cards_reviewed=0,
            profile_picture=None, bio=None, created_at=datetime.utcnow(), last_login=None,
        )

    original = endpoints_users.crud_users.get_user_by_id
    endpoints_users.crud_users.get_user_by_id = fake_get_user
    try:
        result = await endpoints_users.get_user(
            user_pk=22,
            current_user=SimpleNamespace(user_pk=99, role="admin"),
            db=object(),
        )
        assert result.user_pk == 22
    finally:
        endpoints_users.crud_users.get_user_by_id = original
