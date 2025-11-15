import os
import uuid
import logging
import subprocess
from typing import List, Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from fastapi import HTTPException
from gtts import gTTS
from pypinyin import pinyin, Style

from . import models, schemas

logger = logging.getLogger(__name__)

# -----------------------
# Configuration
# -----------------------
AUDIO_DIR = "audios"
os.makedirs(AUDIO_DIR, exist_ok=True)

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
    file_path = os.path.join(AUDIO_DIR, filename)

    # Génération audio via gTTS
    try:
        tts = gTTS(text, lang=language)
        tts.save(file_path)
    except Exception as e:
        logger.error(f"Erreur génération audio: {e}")
        raise HTTPException(status_code=500, detail="Échec de la génération audio")

    # IPA désactivé pour le moment
    ipa_text = None  # generate_ipa(text, language)

    audio_item = models.AudioItem(
        title=title,
        text=text,
        filename=filename,
        category=category,
        language=language,
        ipa=ipa_text
    )

    db.add(audio_item)
    await db.commit()
    await db.refresh(audio_item)

    # Retour compatible schema
    return schemas.AudioItem(
        id=audio_item.id,
        title=audio_item.title,
        text=audio_item.text,
        filename=audio_item.filename,
        category=audio_item.category,
        language=audio_item.language,
        ipa=audio_item.ipa,
        audio_url=f"/audios/files/{audio_item.filename}"
    )


async def get_audio_item(db: AsyncSession, audio_id: int):
    result = await db.execute(
        select(models.AudioItem).where(models.AudioItem.id == audio_id)
    )
    item = result.all()

    if not item:
        return None

    return schemas.AudioItem(
        id=item.id,
        title=item.title,
        text=item.text,
        filename=item.filename,
        category=item.category,
        language=item.language,
        ipa=item.ipa,
        audio_url=f"/audios/files/{item.filename}"
    )


async def list_audio_items(db: AsyncSession):
    result = await db.execute(
        select(models.AudioItem)
    )
    items = result.scalars().all()

    return [
        schemas.AudioItem(
            id=item.id,
            title=item.title,
            text=item.text,
            filename=item.filename,
            category=item.category,
            language=item.language,
            ipa=item.ipa,
            audio_url=f"/audios/files/{item.filename}"
        )
        for item in items
    ]


async def delete_audio_item(db: AsyncSession, audio_id: int) -> bool:
    result = await db.execute(
        select(models.AudioItem).where(models.AudioItem.id == audio_id)
    )
    item = result.scalar_one_or_none()

    if not item:
        return False

    # Supprimer le fichier local
    file_path = os.path.join(AUDIO_DIR, item.filename)
    if os.path.exists(file_path):
        os.remove(file_path)

    # Supprimer en base
    await db.execute(
        delete(models.AudioItem).where(models.AudioItem.id == audio_id)
    )
    await db.commit()

    return True
