from fastapi import APIRouter, Depends, Query, HTTPException, Form
from fastapi.responses import JSONResponse, Response
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from .. import crud_audios, schemas
from ..database import get_db
from .. import models
from ..security import require_teacher_or_admin

router = APIRouter(
    prefix="/audios",
    tags=["audios"]
)

# --- Audio Endpoints ---

@router.post("/", response_model=schemas.AudioItem)
async def create_audio(
    title: str = Form(...), 
    text: str = Form(...), 
    category: str = Form(...),
    language: str = Form('it'),
    description: str | None = Form(None),
    deck_pk: int | None = Form(None),
    db: AsyncSession = Depends(get_db),
    current_user: models.User = Depends(require_teacher_or_admin),
):
    try:
        return await crud_audios.create_audio_item(
            db, title, text, category, language,
            created_by=current_user.user_pk, deck_pk=deck_pk, description=description,
        )
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur interne lors de la création audio: {e}")

@router.get("/", response_model=List[schemas.AudioItem])
async def list_audios(
    # skip: int = 0, 
    # limit: int = 10, 
    db: AsyncSession = Depends(get_db)
):
    return await crud_audios.list_audio_items(db)

    # return await crud_audios.list_audio_items(db, skip, limit)

@router.get("/{audio_id}/file", response_class=Response)
async def stream_audio(audio_id: int, db: AsyncSession = Depends(get_db)):
    audio = await crud_audios.get_audio_bytes(db, audio_id)
    if audio is None:
        raise HTTPException(status_code=404, detail="Fichier audio introuvable")
    payload, content_type = audio
    return Response(
        content=payload,
        media_type=content_type,
        headers={"Cache-Control": "public, max-age=31536000, immutable"},
    )

@router.get("/{audio_id}", response_model=schemas.AudioItem)
async def get_audio(audio_id: int, db: AsyncSession = Depends(get_db)):
    audio_item = await crud_audios.get_audio_item(db, audio_id)
    if not audio_item:
        raise HTTPException(status_code=404, detail="Audio not found")
    return audio_item

@router.delete("/{audio_id}")
async def delete_audio(
    audio_id: int,
    db: AsyncSession = Depends(get_db),
    _current_user: models.User = Depends(require_teacher_or_admin),
):
    deleted = await crud_audios.delete_audio_item(db, audio_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Audio not found")
    return {"detail": "Audio deleted"}
