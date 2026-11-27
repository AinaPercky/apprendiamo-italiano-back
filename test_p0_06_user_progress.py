from datetime import datetime
from types import SimpleNamespace

import pytest
from sqlalchemy.dialects import postgresql

from app import crud_cards, crud_quiz, models


class FakeResult:
    def __init__(self, value):
        self.value = value

    def scalar_one_or_none(self):
        return self.value


class FakeDatabase:
    def __init__(self, performance):
        self.performance = performance
        self.statements = []
        self.commits = 0
        self.added = []

    async def execute(self, statement):
        self.statements.append(statement)
        return FakeResult(self.performance)

    def add(self, value):
        self.added.append(value)

    async def commit(self):
        self.commits += 1

    async def refresh(self, _value):
        return None


def make_performance(user_pk: int):
    return SimpleNamespace(
        user_pk=user_pk,
        card_pk=77,
        deck_pk=9,
        correct_count=0,
        incorrect_count=0,
        total_attempts=0,
        priority_score=0.0,
        easiness=2.5,
        interval=0,
        consecutive_correct=0,
        next_review=datetime.utcnow(),
        box=0,
        last_reviewed_at=None,
    )


@pytest.mark.asyncio
async def test_quiz_anki_state_is_updated_on_the_user_performance_not_the_shared_card():
    first_user = make_performance(11)
    second_user = make_performance(22)
    first_db = FakeDatabase(first_user)
    second_db = FakeDatabase(second_user)

    await crud_quiz.update_card_performance(first_db, 11, 77, 9, False)
    await crud_quiz.update_card_performance(second_db, 22, 77, 9, True)

    first_sql = str(first_db.statements[0].compile(dialect=postgresql.dialect()))
    second_sql = str(second_db.statements[0].compile(dialect=postgresql.dialect()))

    assert "card_performance.user_pk" in first_sql
    assert "card_performance.card_pk" in first_sql
    assert "card_performance.user_pk" in second_sql
    assert first_user.incorrect_count == 1
    assert first_user.consecutive_correct == 0
    assert first_user.box == 0
    assert second_user.correct_count == 1
    assert second_user.consecutive_correct == 1
    assert second_user.box == 1
    assert first_user.next_review != second_user.next_review or first_user.interval != second_user.interval
    assert first_db.commits == 1
    assert second_db.commits == 1


def test_card_performance_model_contains_user_scoped_anki_fields():
    columns = models.CardPerformance.__table__.columns

    for column_name in (
        "easiness",
        "interval",
        "consecutive_correct",
        "next_review",
        "box",
    ):
        assert column_name in columns

    constraints = {
        constraint.name
        for constraint in models.CardPerformance.__table__.constraints
    }
    assert "uq_card_performance_user_card" in constraints



@pytest.mark.asyncio
async def test_student_card_due_filter_uses_the_authenticated_users_progress():
    class QueryResult:
        def all(self):
            return []

    class QueryDatabase:
        def __init__(self):
            self.statement = None

        async def execute(self, statement):
            self.statement = statement
            return QueryResult()

    db = QueryDatabase()
    await crud_cards.get_cards(db, deck_pk=9, due_only=True, user_pk=11)

    sql = str(db.statement.compile(dialect=postgresql.dialect()))
    assert "card_performance.user_pk" in sql
    assert "card_performance.next_review" in sql
    assert "cards.next_review" not in sql
