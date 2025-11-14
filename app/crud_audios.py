import os
import uuid
import logging
import subprocess
from typing import List, Optional

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from sqlalchemy.orm import selectinload
from fastapi import HTTPException, Form
from gtts import gTTS
from pypinyin import pinyin, Style

from . import models, schemas

logger = logging.getLogger(__name__)

# -----------------------
# Configuration
# -----------------------
AUDIO_DIR = "audios"
if not os.path.exists(AUDIO_DIR):
    os.makedirs(AUDIO_DIR)

VALID_CATEGORIES = {'mot', 'phrase', 'texte', 'poème', 'virelangue'}
VALID_LANGUAGES = {'it', 'en', 'fr', 'de', 'es', 'ru', 'ja', 'zh'}

# -----------------------
# Validations
# -----------------------
def validate_category(category: str):
    if category not in VALID_CATEGORIES:
        raise HTTPException(status_code=400, detail=f"Catégorie invalide. Valeurs autorisées: {VALID_CATEGORIES}")

def validate_language(lang: str):
    if lang not in VALID_LANGUAGES:
        raise HTTPException(status_code=400, detail=f"Langue invalide. Valeurs autorisées: {VALID_LANGUAGES}")

# -----------------------
# Génération IPA avec espeak-ng (ou pinyin pour le chinois)
# -----------------------
def generate_ipa(text: str, language: str) -> str | None:
    try:
        if language == 'zh':
            # Utilisation de pypinyin pour le chinois
            pinyin_list = pinyin(text, style=Style.NORMAL)
            ipa_result = ' '.join(word[0] for word in pinyin_list)
            return ipa_result
        
        # Utilisation de espeak-ng pour les autres langues (si installé)
        # Le projet original utilisait subprocess, nous le conservons pour la compatibilité
        # Note: espeak-ng doit être installé dans l'environnement d'exécution
        
        # Mapping des langues pour espeak-ng
        lang_map = {
            'it': 'it', 'en': 'en', 'fr': 'fr', 'de': 'de', 'es': 'es', 'ru': 'ru', 'ja': 'ja'
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
            # Nettoyage de la sortie
            ipa_result = process.stdout.strip().replace('\n', ' ')
            return ipa_result
        
        return None # Pas de support IPA pour cette langue ou espeak-ng non disponible

    except subprocess.CalledProcessError as e:
        logger.error(f"Erreur lors de la génération IPA avec espeak-ng: {e.stderr}")
        return None
    except FileNotFoundError:
        logger.warning("espeak-ng non trouvé. La génération IPA sera ignorée.")
        return None
    except Exception as e:
        logger.error(f"Erreur inattendue lors de la génération IPA: {e}")
        return None

# -----------------------
# CRUD Audio (Asynchrone)
# -----------------------

async def create_audio_item(db: AsyncSession, title: str, text: str, category: str, language: str) -> schemas.AudioItem:
    validate_category(category)
    validate_language(language)
    
    filename = f"{uuid.uuid4().hex}.mp3"
    file_path = os.path.join(AUDIO_DIR, filename)
    
    try:
        # Génération de l'audio avec gTTS
        tts = gTTS(text, lang=language)
        tts.save(file_path)
    except Exception as e:
        logger.error(f"Échec de la génération audio: {e}")
        raise HTTPException(status_code=500, detail="Échec de la génération audio")
    
    # Génération IPA (Temporairement désactivé pour le test)
    ipa_text = None # generate_ipa(text, language)
    
    # Création de l'objet en base de données
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
    
    return schemas.AudioItem(
        id=audio_item.id,
        title=audio_item.title,
        text=audio_item.text,
        filename=audio_item.filename,
        category=audio_item.category,
        language=audio_item.language,
        ipa=audio_item.ipa,
        audio_url=f"/audios/files/{filename}"
    )

async def get_audio_item(db: AsyncSession, audio_id: int) -> Optional[schemas.AudioItem]:
    stmt = select(models.AudioItem).where(models.AudioItem.id == audio_id)
    result = await db.execute(stmt)
    audio_item = result.scalar_one_or_none()
    
    if audio_item:
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
    return None

async def list_audio_items(db: AsyncSession, skip: int = 0, limit: int = 10) -> List[schemas.AudioItem]:
    stmt = select(models.AudioItem).offset(skip).limit(limit)
    result = await db.execute(stmt)
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
        ) for item in items
    ]

async def delete_audio_item(db: AsyncSession, audio_id: int) -> bool:
    # Récupérer l'élément pour supprimer le fichier
    audio_item = await get_audio_item(db, audio_id)
    if not audio_item:
        return False
        
    # Suppression du fichier
    file_path = os.path.join(AUDIO_DIR, audio_item.filename)
    if os.path.exists(file_path):
        os.remove(file_path)
        
    # Suppression de l'entrée en base de données
    stmt = delete(models.AudioItem).where(models.AudioItem.id == audio_id)
    await db.execute(stmt)
    await db.commit()
    
    return True
