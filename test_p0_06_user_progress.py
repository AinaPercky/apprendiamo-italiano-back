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
    def __init__(self, *results):
        self.results = list(results)
        self.statements = []
        self.commits = 0
        self.added = []

    async def execute(self, statement):
        self.statements.append(statement)
        return FakeResult(self.results.pop(0))

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
    user_deck = SimpleNamespace(
        total_points=0,
        attempt_count=0,
        correct_count=0,
        successful_attempts=0,
        total_attempts=0,
    )
    second_db = FakeDatabase(second_user, user_deck)

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
    assert "cards.next_review <=" not in sql


class ScalarRows:
    def __init__(self, rows):
        self.rows = rows

    def all(self):
        return self.rows


class QueryResult:
    def __init__(self, rows=None, scalar_value=None):
        self.rows = rows or []
        self.scalar_value = scalar_value

    def scalar(self):
        return self.scalar_value

    def scalars(self):
        return ScalarRows(self.rows)

    def unique(self):
        return self


class QueryDatabase:
    def __init__(self, *results):
        self.results = list(results)
        self.statements = []

    async def execute(self, statement):
        self.statements.append(statement)
        return self.results.pop(0)


@pytest.mark.asyncio
async def test_deck_performances_follow_many_to_many_membership_not_origin_deck():
    db = QueryDatabase(QueryResult(rows=[]))

    await crud_quiz.get_deck_performances(db, user_pk=11, deck_pk=22)

    sql = str(db.statements[0].compile(dialect=postgresql.dialect()))
    assert "JOIN deck_cards" in sql
    assert "deck_cards.deck_pk" in sql
    assert "card_performance.user_pk" in sql
    assert "card_performance.deck_pk" not in sql


@pytest.mark.asyncio
async def test_cycle_card_count_uses_many_to_many_membership():
    db = QueryDatabase(
        QueryResult(scalar_value=2),
        QueryResult(rows=[]),
    )

    cycle, used_cards = await crud_quiz.get_current_cycle_info(
        db, user_pk=11, deck_pk=22
    )

    sql = str(db.statements[0].compile(dialect=postgresql.dialect()))
    assert "JOIN deck_cards" in sql
    assert "deck_cards.deck_pk" in sql
    assert "cards.deck_pk" not in sql
    assert cycle == 1
    assert used_cards == []


@pytest.mark.asyncio
async def test_quiz_selection_includes_cards_linked_only_through_deck_cards():
    card = SimpleNamespace(
        card_pk=77,
        next_review=datetime.utcnow(),
        front="ciao",
        back="bonjour",
    )
    db = QueryDatabase(
        QueryResult(rows=[card]),
        QueryResult(scalar_value=1),
        QueryResult(rows=[]),
        QueryResult(rows=[]),
    )

    selected, cycle, _message = await crud_quiz.select_cards_for_quiz(
        db, user_pk=11, deck_pk=22, card_count=1
    )

    sql = str(db.statements[0].compile(dialect=postgresql.dialect()))
    assert "JOIN deck_cards" in sql
    assert "deck_cards.deck_pk" in sql
    assert "cards.deck_pk" not in sql
    assert [item.card_pk for item in selected] == [77]
    assert cycle == 1
