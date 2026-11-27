"""Règles d'accès aux audios système et ressources audio du Studio."""

from . import models
from sqlalchemy.ext.asyncio import AsyncSession


async def can_read_audio_item(
    db: AsyncSession,
    audio_item: models.AudioItem,
    user: models.User | None,
) -> bool:
    """Les audios globaux publiés sont publics ; les brouillons/privés sont protégés.

    Un audio privé n'est visible que par son créateur (professeur) ou un admin.
    Les routes d'écriture restent soumises à require_teacher_or_admin.
    """
    if audio_item.visibility == "global" and audio_item.published_at is not None:
        return True

    if user is None:
        return False
    if user.role == "admin":
        return True
    return (
        user.role == "professeur"
        and audio_item.created_by is not None
        and audio_item.created_by == user.user_pk
    )
