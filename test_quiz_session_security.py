from datetime import datetime
from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest
from fastapi import HTTPException
from sqlalchemy.dialects import postgresql

from app import crud_quiz
from app.api import endpoints_quiz


class FakeResult:
    def __init__(self, value=None, values=None):
        self.value = value
        self.values = values if values is not None else []

    def scalar_one_or_none(self):
        return self.value

    def scalars(self):
        return self

    def all(self):
        return self.values


class FakeDatabase:
    def __init__(self, results):
        self.results = iter(results)
        self.statements = []
        self.commits = 0
        self.added = []

    async def execute(self, statement):
        self.statements.append(statement)
        return next(self.results)

    def add(self, value):
        self.added.append(value)

    async def commit(self):
        self.commits += 1

    async def refresh(self, _value):
        return None


def compiled(statement):
    return str(statement.compile(dialect=postgresql.dialect()))


@pytest.mark.asyncio
async def test_completion_query_is_scoped_to_session_and_authenticated_owner():
    db = FakeDatabase([FakeResult(None)])

    result = await crud_quiz.complete_quiz_session(
        db,
        session_pk=91,
        correct_count=2,
        total_questions=3,
        user_pk=12,
    )

    sql = compiled(db.statements[0])
    assert result is None
    assert "quiz_sessions.user_pk" in sql
    assert "quiz_sessions.session_pk" in sql
    assert "FOR UPDATE" in sql
    assert db.commits == 0


@pytest.mark.asyncio
async def test_completion_updates_owner_statistics_once():
    session = SimpleNamespace(
        session_pk=91,
        user_pk=12,
        deck_pk=7,
        completed_at=None,
        correct_count=0,
        total_questions=0,
    )
    user_deck = SimpleNamespace(
        user_pk=12,
        deck_pk=7,
        attempt_count=4,
        correct_count=2,
        total_attempts=4,
        successful_attempts=2,
        last_studied=None,
    )
    db = FakeDatabase([FakeResult(session), FakeResult(user_deck), FakeResult(session)])

    completed = await crud_quiz.complete_quiz_session(
        db,
        session_pk=91,
        correct_count=3,
        total_questions=5,
        user_pk=12,
    )

    assert completed is session
    assert session.correct_count == 3
    assert session.total_questions == 5
    assert session.completed_at is not None
    assert user_deck.attempt_count == 9
    assert user_deck.correct_count == 5
    assert user_deck.total_attempts == 9
    assert user_deck.successful_attempts == 5
    assert db.commits == 1

    with pytest.raises(crud_quiz.QuizSessionAlreadyCompletedError):
        await crud_quiz.complete_quiz_session(
            db,
            session_pk=91,
            correct_count=3,
            total_questions=5,
            user_pk=12,
        )

    assert db.commits == 1


@pytest.mark.asyncio
async def test_completion_rejects_invalid_result_counters_before_database_access():
    db = FakeDatabase([])

    with pytest.raises(ValueError, match="ne peut pas dépasser"):
        await crud_quiz.complete_quiz_session(
            db,
            session_pk=91,
            correct_count=4,
            total_questions=3,
            user_pk=12,
        )

    with pytest.raises(ValueError, match="négatifs"):
        await crud_quiz.complete_quiz_session(
            db,
            session_pk=91,
            correct_count=-1,
            total_questions=3,
            user_pk=12,
        )

    assert db.statements == []
    assert db.commits == 0


@pytest.mark.asyncio
async def test_session_history_query_is_scoped_to_authenticated_owner():
    db = FakeDatabase([FakeResult(values=[])])

    result = await crud_quiz.get_user_quiz_sessions(
        db,
        user_pk=12,
        deck_pk=None,
        limit=50,
    )

    sql = compiled(db.statements[0])
    assert result == []
    assert "quiz_sessions.user_pk" in sql


@pytest.mark.asyncio
async def test_complete_endpoint_passes_authenticated_owner_to_crud(monkeypatch):
    session = SimpleNamespace(
        session_pk=91,
        deck_pk=7,
        card_count=5,
        quiz_type="classique",
        cycle_number=1,
        correct_count=3,
        total_questions=5,
        started_at=datetime.utcnow(),
        completed_at=datetime.utcnow(),
    )
    complete = AsyncMock(return_value=session)
    db = object()
    monkeypatch.setattr(endpoints_quiz.crud_quiz, "complete_quiz_session", complete)

    response = await endpoints_quiz.complete_quiz(
        session_pk=91,
        correct_count=3,
        total_questions=5,
        current_user=SimpleNamespace(user_pk=12),
        db=db,
    )

    assert response.session_pk == 91
    complete.assert_awaited_once_with(
        db,
        91,
        3,
        5,
        user_pk=12,
    )


@pytest.mark.asyncio
async def test_complete_endpoint_rejects_correct_count_above_total(monkeypatch):
    complete = AsyncMock()
    monkeypatch.setattr(endpoints_quiz.crud_quiz, "complete_quiz_session", complete)

    with pytest.raises(HTTPException) as error:
        await endpoints_quiz.complete_quiz(
            session_pk=91,
            correct_count=4,
            total_questions=3,
            current_user=SimpleNamespace(user_pk=12),
            db=object(),
        )

    assert error.value.status_code == 422
    complete.assert_not_awaited()


@pytest.mark.asyncio
async def test_complete_endpoint_returns_conflict_for_replayed_completion(monkeypatch):
    async def already_completed(*_args, **_kwargs):
        raise crud_quiz.QuizSessionAlreadyCompletedError()

    monkeypatch.setattr(
        endpoints_quiz.crud_quiz,
        "complete_quiz_session",
        already_completed,
    )

    with pytest.raises(HTTPException) as error:
        await endpoints_quiz.complete_quiz(
            session_pk=91,
            correct_count=3,
            total_questions=5,
            current_user=SimpleNamespace(user_pk=12),
            db=object(),
        )

    assert error.value.status_code == 409
