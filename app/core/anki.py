# app/core/anki.py
from datetime import datetime, timedelta
import random
from typing import Literal

Grade = Literal[0, 1, 2, 3]  # Again, Hard, Good, Easy

def anki_review(
    easiness: float,
    interval: int,
    consecutive_correct: int,
    grade: Grade,
    last_reviewed_at: datetime | None = None,
) -> dict:
    now = datetime.utcnow()
    last_reviewed_at = last_reviewed_at or now

    if grade == 0:  # Again
        return {
            "easiness": max(1.3, easiness - 0.20),
            "interval": 0,
            "consecutive_correct": 0,
            "next_review": now + timedelta(minutes=10),
        }

    # Easiness factor
    new_easiness = easiness + (0.1 - (3 - grade) * (0.08 + (3 - grade) * 0.02))
    new_easiness = max(1.3, new_easiness)

    # Intervalle
    if consecutive_correct < 1:
        interval = 1
    elif consecutive_correct == 1:
        interval = 6
    else:
        multiplier = 1.2 if grade == 1 else (1.3 if grade == 3 else 1.0)
        interval = max(1, int(interval * new_easiness * multiplier))

    # Fuzz
    if interval >= 7:
        fuzz = random.uniform(0.925, 1.075)
        interval = max(1, int(interval * fuzz + 0.5))

    return {
        "easiness": round(new_easiness, 4),
        "interval": interval,
        "consecutive_correct": consecutive_correct + 1,
        "next_review": now + timedelta(days=interval),
    }