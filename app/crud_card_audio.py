"""Gestion temporaire des prononciations MP3 stockées en Data URI dans Neon."""

import base64
import binascii
import os
from datetime import datetime
from pathlib import PurePath
from typing import Optional

from fastapi import UploadFile
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from . import models

MAX_CARD_AUDIO_BYTES = int(os.getenv("MAX_CARD_AUDIO_BYTES", str(10 * 1024 * 1024)))
AUDIO_CONTENT_TYPE = "audio/mpeg"
AUDIO_DATA_URI_PREFIX = f"data:{AUDIO_CONTENT_TYPE};base64,"


class CardAudioValidationError(ValueError):
    """Erreur de validation d’un fichier de prononciation."""


def _looks_like_mp3(payload: bytes) -> bool:
    """Accepte les MP3 avec en-tête ID3 ou une trame MPEG valide courante."""
    if payload.startswith(b"ID3"):
        return True
    if len(payload) < 2 or payload[0] != 0xFF:
        return False
    return (payload[1] & 0xE0) == 0xE0 and (payload[1] & 0x06) != 0x00


def _normalise_filename(filename: Optional[str]) -> Optional[str]:
    if not filename:
        return None
    name = PurePath(filename).name.strip()
    return name[:255] or None


def _decode_audio_data_uri(audio_data: str) -> bytes:
    if not audio_data.startswith(AUDIO_DATA_URI_PREFIX):
        raise CardAudioValidationError("Le contenu audio enregistré n’est pas un Data URI MP3 valide")
    encoded = audio_data[len(AUDIO_DATA_URI_PREFIX):]
    try:
        return base64.b64decode(encoded, validate=True)
    except (ValueError, binascii.Error) as exc:
        raise CardAudioValidationError("Le contenu audio base64 est invalide") from exc


async def _read_and_validate_upload(audio_file: UploadFile) -> tuple[bytes, str, Optional[str]]:
    content_type = (audio_file.content_type or "").split(";", 1)[0].strip().lower()
    if content_type not in {AUDIO_CONTENT_TYPE, "audio/mp3", "application/octet-stream"}:
        raise CardAudioValidationError("Le fichier doit être un MP3 (audio/mpeg)")

    payload = await audio_file.read(MAX_CARD_AUDIO_BYTES + 1)
    if not payload:
        raise CardAudioValidationError("Le fichier audio est vide")
    if len(payload) > MAX_CARD_AUDIO_BYTES:
        raise CardAudioValidationError(
            f"Le fichier audio dépasse la limite de {MAX_CARD_AUDIO_BYTES // (1024 * 1024)} Mo"
        )
    if not _looks_like_mp3(payload):
        raise CardAudioValidationError("Le contenu du fichier ne ressemble pas à un MP3 valide")

    return payload, AUDIO_CONTENT_TYPE, _normalise_filename(audio_file.filename)


def _public_audio(audio: models.CardAudio) -> dict:
    return {
        "audio_pk": audio.audio_pk,
        "card_pk": audio.card_pk,
        "filename": audio.filename,
        "content_type": audio.content_type,
        "size_bytes": audio.size_bytes,
        "audio_url": f"/cards/{audio.card_pk}/audio",
        "created_at": audio.created_at,
        "updated_at": audio.updated_at,
    }


async def _get_card(db: AsyncSession, card_pk: int) -> Optional[models.Card]:
    result = await db.execute(select(models.Card).where(models.Card.card_pk == card_pk))
    return result.scalar_one_or_none()


async def upsert_card_audio(
    db: AsyncSession,
    card_pk: int,
    audio_file: UploadFile,
) -> dict:
    card = await _get_card(db, card_pk)
    if card is None:
        return None

    payload, content_type, filename = await _read_and_validate_upload(audio_file)
    audio_data = AUDIO_DATA_URI_PREFIX + base64.b64encode(payload).decode("ascii")

    result = await db.execute(
        select(models.CardAudio).where(models.CardAudio.card_pk == card_pk)
    )
    audio = result.scalar_one_or_none()
    if audio is None:
        audio = models.CardAudio(card_pk=card_pk)
        db.add(audio)

    audio.filename = filename
    audio.content_type = content_type
    audio.size_bytes = len(payload)
    audio.audio_data = audio_data
    audio.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(audio)
    return _public_audio(audio)


async def get_card_audio(db: AsyncSession, card_pk: int) -> Optional[models.CardAudio]:
    result = await db.execute(
        select(models.CardAudio).where(models.CardAudio.card_pk == card_pk)
    )
    return result.scalar_one_or_none()


async def get_card_audio_bytes(db: AsyncSession, card_pk: int) -> Optional[tuple[bytes, str]]:
    audio = await get_card_audio(db, card_pk)
    if audio is None:
        return None
    return _decode_audio_data_uri(audio.audio_data), audio.content_type


async def delete_card_audio(db: AsyncSession, card_pk: int) -> bool:
    audio = await get_card_audio(db, card_pk)
    if audio is None:
        return False
    await db.delete(audio)
    await db.commit()
    return True
