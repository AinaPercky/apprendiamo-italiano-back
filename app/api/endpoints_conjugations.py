"""Routes FastAPI du module autonome de conjugaison italienne."""

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from .. import crud_conjugations, models, schemas
from ..database import get_db
from ..security import get_current_active_user

router = APIRouter(prefix="/italian-conjugations", tags=["italian conjugations"])


@router.get("/metadata", response_model=schemas.ItalianConjugationMetadata)
async def read_conjugation_metadata(db: AsyncSession = Depends(get_db)):
    """Retourne les modes et temps disponibles pour construire les filtres côté client."""
    return await crud_conjugations.get_metadata(db)


@router.get("/verbs", response_model=list[schemas.ItalianVerbListItem])
async def read_verbs(
    search: str | None = Query(default=None, max_length=160),
    mood: str | None = Query(default=None, max_length=64),
    tense: str | None = Query(default=None, max_length=80),
    skip: int = Query(default=0, ge=0),
    limit: int = Query(default=50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
):
    verbs = await crud_conjugations.list_verbs(db, search, mood, tense, skip, limit)
    return [
        {
            "verb_pk": verb.verb_pk,
            "infinitive": verb.infinitive,
            "source_name": verb.source_name,
            "conjugation_count": len(verb.conjugations),
        }
        for verb in verbs
    ]


@router.get("/verbs/{infinitive}", response_model=schemas.ItalianVerbDetail)
async def read_verb(infinitive: str, db: AsyncSession = Depends(get_db)):
    verb = await crud_conjugations.get_verb_detail(db, infinitive)
    if verb is None:
        raise HTTPException(status_code=404, detail="Verbe italien introuvable")
    return crud_conjugations.serialize_verb(verb)


@router.get("/search", response_model=list[schemas.ItalianConjugationSearchResult])
async def search_conjugation_forms(
    query: str = Query(..., min_length=1, max_length=160),
    limit: int = Query(default=30, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    """Recherche par forme conjuguée ou infinitif, sans aucun appel externe."""
    return await crud_conjugations.search_forms(db, query, limit)


@router.post("/verbs", response_model=schemas.ItalianVerbDetail, status_code=status.HTTP_201_CREATED)
async def create_italian_verb(
    payload: schemas.ItalianVerbCreate,
    db: AsyncSession = Depends(get_db),
    _user: models.User = Depends(get_current_active_user),
):
    try:
        return crud_conjugations.serialize_verb(await crud_conjugations.create_verb(db, payload))
    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc)) from exc


@router.put("/verbs/{infinitive}", response_model=schemas.ItalianVerbDetail)
async def update_italian_verb(
    infinitive: str,
    payload: schemas.ItalianVerbUpdate,
    db: AsyncSession = Depends(get_db),
    _user: models.User = Depends(get_current_active_user),
):
    try:
        verb = await crud_conjugations.update_verb(db, infinitive, payload)
    except ValueError as exc:
        raise HTTPException(status_code=409, detail=str(exc)) from exc
    if verb is None:
        raise HTTPException(status_code=404, detail="Verbe italien introuvable")
    return crud_conjugations.serialize_verb(verb)


@router.delete("/verbs/{infinitive}")
async def delete_italian_verb(
    infinitive: str,
    db: AsyncSession = Depends(get_db),
    _user: models.User = Depends(get_current_active_user),
):
    if not await crud_conjugations.delete_verb(db, infinitive):
        raise HTTPException(status_code=404, detail="Verbe italien introuvable")
    return {"detail": "Verbe et conjugaisons supprimés"}


@router.post("/admin/import", response_model=schemas.ItalianConjugationImportReport)
async def import_packaged_corpus(
    db: AsyncSession = Depends(get_db),
    _user: models.User = Depends(get_current_active_user),
):
    """Réimporte le corpus local versionné de façon idempotente, sans API tierce."""
    return await crud_conjugations.import_packaged_conjugations(db)
