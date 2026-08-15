"""Liens QR publics et sécurisés pour la consultation d'une seule flashcard."""

import hashlib
import hmac
import os
import secrets
from typing import Iterable, Optional

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from . import models
from .security import SECRET_KEY


_QR_SIGNATURE_KEY = os.getenv("QR_LINK_SECRET", SECRET_KEY).encode("utf-8")


def _token_hash(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def _sign_token(token: str) -> str:
    return hmac.new(_QR_SIGNATURE_KEY, token.encode("utf-8"), hashlib.sha256).hexdigest()


def _valid_signature(token: str, signature: str) -> bool:
    return hmac.compare_digest(_sign_token(token), signature)


async def create_public_qr_links(
    db: AsyncSession,
    card_pks: Iterable[int],
) -> list[dict]:
    requested = list(dict.fromkeys(card_pks))
    cards_result = await db.execute(
        select(models.Card.card_pk).where(models.Card.card_pk.in_(requested))
    )
    found = set(cards_result.scalars().all())
    missing = sorted(set(requested) - found)
    if missing:
        raise ValueError(f"Cartes introuvables : {', '.join(map(str, missing))}")

    links: list[dict] = []
    for card_pk in requested:
        token = secrets.token_urlsafe(32)
        link = models.CardPublicQRLink(card_pk=card_pk, token_hash=_token_hash(token))
        db.add(link)
        links.append({
            "card_pk": card_pk,
            "token": token,
            "signature": _sign_token(token),
        })

    await db.commit()
    return links


async def get_public_card_from_qr(
    db: AsyncSession,
    token: str,
    signature: str,
) -> Optional[models.Card]:
    if not _valid_signature(token, signature):
        return None

    result = await db.execute(
        select(models.CardPublicQRLink)
        .options(selectinload(models.CardPublicQRLink.card).selectinload(models.Card.audio))
        .where(
            models.CardPublicQRLink.token_hash == _token_hash(token),
            models.CardPublicQRLink.revoked_at.is_(None),
        )
    )
    link = result.scalar_one_or_none()
    return link.card if link else None


def public_card_payload(card: models.Card, token: str, signature: str) -> dict:
    audio = card.audio
    audio_url = f"/public/cards/qr/{token}/{signature}/audio" if audio else None
    return {
        "front": card.front,
        "back": card.back,
        "pronunciation": card.pronunciation,
        "image": card.image,
        "explanation_it": card.explanation_it,
        "translation_en": card.translation_en,
        "translation_de": card.translation_de,
        "translation_mg": card.translation_mg,
        "example": card.example,
        "tags": card.tags or [],
        "audio_url": audio_url,
        "audio_filename": audio.filename if audio else None,
    }
