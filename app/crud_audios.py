import base64
import binascii
import logging
import os
import subprocess
import tempfile
import uuid
from pathlib import Path
from typing import List, Optional

from fastapi import HTTPException
from gtts import gTTS
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession
from pypinyin import Style, pinyin

from . import models, schemas

logger = logging.getLogger(__name__)

# -----------------------
# Configuration
# -----------------------
# Le dossier du projet est en lecture seule sur Vercel. Il est conservé
# uniquement pour lire les anciens MP3 éventuellement inclus au déploiement.
AUDIO_DIR = Path(os.getenv("AUDIO_DIR", "audios"))
AUDIO_CONTENT_TYPE = "audio/mpeg"
AUDIO_DATA_URI_PREFIX = f"data:{AUDIO_CONTENT_TYPE};base64,"
MAX_AUDIO_BYTES = int(os.getenv("MAX_AUDIO_BYTES", str(10 * 1024 * 1024)))

VALID_CATEGORIES = {'mot', 'phrase', 'texte', 'poème', 'virelangue'}
VALID_LANGUAGES = {'it', 'en', 'fr', 'de', 'es', 'ru', 'ja', 'zh'}


# -----------------------
# Validations
# -----------------------
def validate_category(category: str):
    if category not in VALID_CATEGORIES:
        raise HTTPException(
            status_code=400,
            detail=f"Catégorie invalide. Valeurs autorisées: {VALID_CATEGORIES}"
        )


def validate_language(lang: str):
    if lang not in VALID_LANGUAGES:
        raise HTTPException(
            status_code=400,
            detail=f"Langue invalide. Valeurs autorisées: {VALID_LANGUAGES}"
        )


# -----------------------
# Génération IPA (espeak-ng ou pinyin)
# -----------------------
def generate_ipa(text: str, language: str) -> Optional[str]:
    try:
        # Chinois → utiliser pypinyin
        if language == 'zh':
            pinyin_list = pinyin(text, style=Style.NORMAL)
            return ' '.join(item[0] for item in pinyin_list)

        # Autres langues → espeak-ng
        lang_map = {
            'it': 'it', 'en': 'en', 'fr': 'fr', 'de': 'de',
            'es': 'es', 'ru': 'ru', 'ja': 'ja'
        }

        espeak_lang = lang_map.get(language)
        if espeak_lang:
            command = ["espeak-ng", "-q", "-v", espeak_lang, "--ipa=3", "--stdin"]
            process = subprocess.run(
                command,
                input=text,
                capture_output=True,
                text=True,
                check=True
            )
            return process.stdout.strip().replace('\n', ' ')

        return None

    except Exception as e:
        logger.error(f"Erreur IPA: {e}")
        return None


# -----------------------
# Stockage audio compatible serverless
# -----------------------
def _encode_audio_data(payload: bytes) -> str:
    return AUDIO_DATA_URI_PREFIX + base64.b64encode(payload).decode("ascii")


def _decode_audio_data(audio_data: str) -> bytes:
    if not audio_data.startswith(AUDIO_DATA_URI_PREFIX):
        raise ValueError("Le contenu audio enregistré n’est pas un Data URI MP3 valide")
    try:
        return base64.b64decode(audio_data[len(AUDIO_DATA_URI_PREFIX):], validate=True)
    except (ValueError, binascii.Error) as exc:
        raise ValueError("Le contenu audio base64 est invalide") from exc


def _generate_tts_bytes(text: str, language: str) -> bytes:
    """Génère le MP3 dans /tmp puis retourne ses octets.

    Vercel autorise l’écriture temporaire dans /tmp, mais pas dans le dossier
    du projet. Les octets sont ensuite persistés dans PostgreSQL.
    """
    temp_path: Optional[str] = None
    try:
        with tempfile.NamedTemporaryFile(
            prefix="apprendiamo-",
            suffix=".mp3",
            dir="/tmp",
            delete=False,
        ) as temp_file:
            temp_path = temp_file.name

        gTTS(text, lang=language).save(temp_path)
        payload = Path(temp_path).read_bytes()
        if not payload:
            raise ValueError("La génération audio a produit un fichier vide")
        if len(payload) > MAX_AUDIO_BYTES:
            raise ValueError(
                f"Le fichier audio dépasse la limite de {MAX_AUDIO_BYTES // (1024 * 1024)} Mo"
            )
        return payload
    finally:
        if temp_path:
            try:
                Path(temp_path).unlink(missing_ok=True)
            except OSError:
                logger.warning("Impossible de supprimer le fichier temporaire audio %s", temp_path)


def _legacy_audio_bytes(filename: str) -> Optional[bytes]:
    file_path = AUDIO_DIR / Path(filename).name
    try:
        if file_path.is_file():
            return file_path.read_bytes()
    except OSError:
        logger.warning("Impossible de lire l’ancien fichier audio %s", file_path)
    return None


def _audio_url(audio_item: models.AudioItem) -> str:
    # Cette route fonctionne pour les nouveaux objets persistés en base et
    # peut aussi servir les anciens MP3 encore présents dans le package.
    return f"/audios/{audio_item.id}/file"


def _serialize_audio_item(audio_item: models.AudioItem) -> schemas.AudioItem:
    return schemas.AudioItem(
        id=audio_item.id,
        title=audio_item.title,
        text=audio_item.text,
        filename=audio_item.filename,
        category=audio_item.category,
        language=audio_item.language,
        ipa=audio_item.ipa,
        audio_url=_audio_url(audio_item),
    )


# -----------------------
# CRUD Audio (Async)
# -----------------------
async def create_audio_item(
    db: AsyncSession,
    title: str,
    text: str,
    category: str,
    language: str
):
    validate_category(category)
    validate_language(language)

    filename = f"{uuid.uuid4().hex}.mp3"

    # Génération audio via gTTS dans /tmp, seul emplacement inscriptible sur Vercel.
    try:
        audio_payload = _generate_tts_bytes(text, language)
    except Exception as e:
        logger.error(f"Erreur génération audio: {e}")
        raise HTTPException(status_code=500, detail="Échec de la génération audio") from e

    # IPA désactivé pour le moment
    ipa_text = None  # generate_ipa(text, language)

    audio_item = models.AudioItem(
        title=title,
        text=text,
        filename=filename,
        audio_data=_encode_audio_data(audio_payload),
        category=category,
        language=language,
        ipa=ipa_text
    )

    db.add(audio_item)
    await db.commit()
    await db.refresh(audio_item)

    return _serialize_audio_item(audio_item)


async def get_audio_item(db: AsyncSession, audio_id: int):
    result = await db.execute(
        select(models.AudioItem).where(models.AudioItem.id == audio_id)
    )
    item = result.scalar_one_or_none()

    if not item:
        return None

    return _serialize_audio_item(item)


async def list_audio_items(db: AsyncSession):
    result = await db.execute(select(models.AudioItem))
    items = result.scalars().all()
    return [_serialize_audio_item(item) for item in items]


async def get_audio_bytes(db: AsyncSession, audio_id: int) -> Optional[tuple[bytes, str]]:
    result = await db.execute(
        select(models.AudioItem).where(models.AudioItem.id == audio_id)
    )
    item = result.scalar_one_or_none()
    if item is None:
        return None

    if item.audio_data:
        try:
            return _decode_audio_data(item.audio_data), AUDIO_CONTENT_TYPE
        except ValueError as exc:
            logger.error("Données audio invalides pour l’élément %s: %s", audio_id, exc)
            raise HTTPException(status_code=500, detail="Données audio persistées invalides") from exc

    legacy_payload = _legacy_audio_bytes(item.filename)
    return (legacy_payload, AUDIO_CONTENT_TYPE) if legacy_payload else None


async def delete_audio_item(db: AsyncSession, audio_id: int) -> bool:
    result = await db.execute(
        select(models.AudioItem).where(models.AudioItem.id == audio_id)
    )
    item = result.scalar_one_or_none()

    if not item:
        return False

    # Les nouveaux octets sont dans PostgreSQL ; aucun fichier persistant
    # local ne doit être supprimé sur le runtime serverless.
    await db.execute(
        delete(models.AudioItem).where(models.AudioItem.id == audio_id)
    )
    await db.commit()

    return True
