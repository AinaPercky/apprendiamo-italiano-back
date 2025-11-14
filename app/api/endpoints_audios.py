from fastapi import APIRouter, Depends, Query, HTTPException, Form
from fastapi.responses import JSONResponse
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from .. import crud_audios, schemas
from ..database import get_db

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
    db: AsyncSession = Depends(get_db)
):
    try:
        return await crud_audios.create_audio_item(db, title, text, category, language)
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erreur interne lors de la création audio: {e}")

@router.get("/", response_model=List[schemas.AudioItem])
async def list_audios(
    skip: int = 0, 
    limit: int = 10, 
    db: AsyncSession = Depends(get_db)
):
    return await crud_audios.list_audio_items(db, skip, limit)

@router.get("/{audio_id}", response_model=schemas.AudioItem)
async def get_audio(audio_id: int, db: AsyncSession = Depends(get_db)):
    audio_item = await crud_audios.get_audio_item(db, audio_id)
    if not audio_item:
        raise HTTPException(status_code=404, detail="Audio not found")
    return audio_item

@router.delete("/{audio_id}")
async def delete_audio(audio_id: int, db: AsyncSession = Depends(get_db)):
    deleted = await crud_audios.delete_audio_item(db, audio_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Audio not found")
    return {"detail": "Audio deleted"}
