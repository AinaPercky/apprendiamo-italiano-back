"""Accès autonome au corpus de conjugaisons italiennes empaqueté avec le backend.

Le module ne contacte aucun service externe : il lit seulement le fichier JSON
MIT versionné dans ``data/coniugazione`` et conserve une structure relationnelle
adaptée aux parcours de recherche et d’apprentissage côté client.
"""

from __future__ import annotations

from typing import Any

from sqlalchemy import delete, func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from . import models, schemas
from .conjugation_corpus import CORPUS_PATH, SOURCE_LICENSE, SOURCE_NAME, SOURCE_URL, clean_source_text, normalize_infinitive, parse_source_dataset



def serialize_verb(verb: models.ItalianVerb) -> dict[str, Any]:
    blocks = sorted(verb.conjugations, key=lambda block: (block.mood_order, block.tense_order, block.tense))
    return {
        "verb_pk": verb.verb_pk,
        "infinitive": verb.infinitive,
        "source_record_id": verb.source_record_id,
        "source_name": verb.source_name,
        "source_url": verb.source_url,
        "source_license": verb.source_license,
        "conjugations": [
            {
                "conjugation_pk": block.conjugation_pk,
                "mood": block.mood,
                "tense": block.tense,
                "mood_order": block.mood_order,
                "tense_order": block.tense_order,
                "raw_italian": block.raw_italian,
                "raw_portuguese": block.raw_portuguese,
                "is_featured": block.is_featured,
                "forms": [
                    {
                        "form_pk": form.form_pk,
                        "person_order": form.person_order,
                        "person_label": form.person_label,
                        "form_text": form.form_text,
                        "raw_line": form.raw_line,
                    }
                    for form in sorted(block.forms, key=lambda form: form.person_order)
                ],
            }
            for block in blocks
        ],
    }


async def get_verb_detail(db: AsyncSession, infinitive: str) -> models.ItalianVerb | None:
    statement = (
        select(models.ItalianVerb)
        .where(models.ItalianVerb.normalized_infinitive == normalize_infinitive(infinitive))
        .options(selectinload(models.ItalianVerb.conjugations).selectinload(models.ItalianConjugation.forms))
    )
    return (await db.execute(statement)).scalar_one_or_none()


async def list_verbs(
    db: AsyncSession,
    search: str | None = None,
    mood: str | None = None,
    tense: str | None = None,
    skip: int = 0,
    limit: int = 50,
) -> list[models.ItalianVerb]:
    statement = select(models.ItalianVerb).options(selectinload(models.ItalianVerb.conjugations))
    if search:
        statement = statement.where(models.ItalianVerb.normalized_infinitive.ilike(f"%{normalize_infinitive(search)}%"))
    if mood or tense:
        statement = statement.join(models.ItalianConjugation)
        if mood:
            statement = statement.where(models.ItalianConjugation.mood == mood)
        if tense:
            statement = statement.where(models.ItalianConjugation.tense == tense)
    statement = statement.order_by(models.ItalianVerb.infinitive).offset(skip).limit(limit)
    return list((await db.execute(statement)).scalars().unique().all())


async def search_forms(db: AsyncSession, query: str, limit: int = 30) -> list[dict[str, Any]]:
    term = clean_source_text(query)
    if not term:
        return []
    statement = (
        select(models.ItalianConjugationForm, models.ItalianConjugation, models.ItalianVerb)
        .join(models.ItalianConjugation, models.ItalianConjugationForm.conjugation_pk == models.ItalianConjugation.conjugation_pk)
        .join(models.ItalianVerb, models.ItalianConjugation.verb_pk == models.ItalianVerb.verb_pk)
        .where(or_(models.ItalianConjugationForm.form_text.ilike(f"%{term}%"), models.ItalianVerb.infinitive.ilike(f"%{term}%")))
        .order_by(models.ItalianVerb.infinitive, models.ItalianConjugation.mood_order, models.ItalianConjugation.tense_order, models.ItalianConjugationForm.person_order)
        .limit(limit)
    )
    return [
        {
            "infinitive": verb.infinitive,
            "mood": conjugation.mood,
            "tense": conjugation.tense,
            "person_label": form.person_label,
            "form_text": form.form_text,
        }
        for form, conjugation, verb in (await db.execute(statement)).all()
    ]


async def get_metadata(db: AsyncSession) -> dict[str, Any]:
    mood_rows = (await db.execute(
        select(models.ItalianConjugation.mood, func.min(models.ItalianConjugation.mood_order).label("sort_order"))
        .group_by(models.ItalianConjugation.mood)
        .order_by(func.min(models.ItalianConjugation.mood_order), models.ItalianConjugation.mood)
    )).all()
    moods = [mood for mood, _ in mood_rows]
    pairs = (await db.execute(
        select(models.ItalianConjugation.mood, models.ItalianConjugation.tense, models.ItalianConjugation.mood_order, models.ItalianConjugation.tense_order)
        .distinct()
        .order_by(models.ItalianConjugation.mood_order, models.ItalianConjugation.tense_order, models.ItalianConjugation.tense)
    )).all()
    return {"moods": moods, "tenses": [{"mood": mood, "tense": tense} for mood, tense, _, _ in pairs]}


async def _replace_blocks(
    db: AsyncSession,
    verb: models.ItalianVerb,
    blocks: list[schemas.ItalianConjugationBlockInput],
) -> None:
    await db.execute(delete(models.ItalianConjugation).where(models.ItalianConjugation.verb_pk == verb.verb_pk))
    await db.flush()
    for input_block in blocks:
        block = models.ItalianConjugation(
            verb_pk=verb.verb_pk,
            mood=input_block.mood.strip(),
            tense=input_block.tense.strip(),
            mood_order=input_block.mood_order,
            tense_order=input_block.tense_order,
            raw_italian=input_block.raw_italian,
            raw_portuguese=input_block.raw_portuguese,
            is_featured=input_block.is_featured,
        )
        db.add(block)
        await db.flush()
        db.add_all([
            models.ItalianConjugationForm(
                conjugation_pk=block.conjugation_pk,
                person_order=form.person_order,
                person_label=form.person_label,
                form_text=form.form_text.strip(),
                raw_line=form.raw_line,
            )
            for form in input_block.forms
        ])


async def create_verb(db: AsyncSession, payload: schemas.ItalianVerbCreate) -> models.ItalianVerb:
    normalized = normalize_infinitive(payload.infinitive)
    existing = await get_verb_detail(db, normalized)
    if existing:
        raise ValueError("Ce verbe existe déjà")
    verb = models.ItalianVerb(
        infinitive=payload.infinitive.strip(),
        normalized_infinitive=normalized,
        source_record_id=payload.source_record_id,
        source_name="Création manuelle",
        source_url="",
        source_license="User-provided",
    )
    db.add(verb)
    await db.flush()
    await _replace_blocks(db, verb, payload.conjugations)
    await db.commit()
    return (await get_verb_detail(db, verb.infinitive))


async def update_verb(db: AsyncSession, infinitive: str, payload: schemas.ItalianVerbUpdate) -> models.ItalianVerb | None:
    verb = await get_verb_detail(db, infinitive)
    if verb is None:
        return None
    if payload.infinitive is not None:
        normalized = normalize_infinitive(payload.infinitive)
        collision = await get_verb_detail(db, normalized)
        if collision and collision.verb_pk != verb.verb_pk:
            raise ValueError("Un autre verbe utilise déjà cet infinitif")
        verb.infinitive = payload.infinitive.strip()
        verb.normalized_infinitive = normalized
    if payload.conjugations is not None:
        await _replace_blocks(db, verb, payload.conjugations)
    await db.commit()
    return await get_verb_detail(db, verb.infinitive)


async def delete_verb(db: AsyncSession, infinitive: str) -> bool:
    verb = await get_verb_detail(db, infinitive)
    if verb is None:
        return False
    await db.delete(verb)
    await db.commit()
    return True


async def import_packaged_conjugations(db: AsyncSession, source_path: Path = CORPUS_PATH) -> dict[str, Any]:
    parsed_verbs, checksum, skipped = parse_source_dataset(source_path)
    existing_verbs = {
        verb.normalized_infinitive: verb
        for verb in (await db.execute(select(models.ItalianVerb))).scalars().all()
    }
    existing_blocks = {
        (block.verb_pk, block.mood, block.tense): block
        for block in (await db.execute(select(models.ItalianConjugation))).scalars().all()
    }
    created = 0
    updated = 0
    blocks_to_refresh: list[tuple[models.ItalianConjugation, dict[str, Any]]] = []

    for source_verb in parsed_verbs:
        verb = existing_verbs.get(source_verb["normalized_infinitive"])
        if verb is None:
            verb = models.ItalianVerb(
                infinitive=source_verb["infinitive"],
                normalized_infinitive=source_verb["normalized_infinitive"],
                source_record_id=source_verb["source_record_id"],
                source_name=SOURCE_NAME,
                source_url=SOURCE_URL,
                source_license=SOURCE_LICENSE,
                source_checksum=checksum,
            )
            db.add(verb)
            existing_verbs[verb.normalized_infinitive] = verb
            created += 1
        else:
            verb.infinitive = source_verb["infinitive"]
            verb.source_record_id = source_verb["source_record_id"]
            verb.source_name = SOURCE_NAME
            verb.source_url = SOURCE_URL
            verb.source_license = SOURCE_LICENSE
            verb.source_checksum = checksum
            updated += 1
    await db.flush()

    for source_verb in parsed_verbs:
        verb = existing_verbs[source_verb["normalized_infinitive"]]
        for block_data in source_verb["blocks"].values():
            key = (verb.verb_pk, block_data["mood"], block_data["tense"])
            block = existing_blocks.get(key)
            if block is None:
                block = models.ItalianConjugation(
                    verb_pk=verb.verb_pk,
                    mood=block_data["mood"],
                    tense=block_data["tense"],
                )
                db.add(block)
                existing_blocks[key] = block
            block.mood_order = block_data["mood_order"]
            block.tense_order = block_data["tense_order"]
            block.source_conjugation_id = block_data["source_conjugation_id"]
            block.raw_italian = block_data["raw_italian"]
            block.raw_portuguese = block_data["raw_portuguese"]
            block.is_featured = block_data["is_featured"]
            blocks_to_refresh.append((block, block_data))
    await db.flush()

    refresh_ids = [block.conjugation_pk for block, _ in blocks_to_refresh]
    if refresh_ids:
        await db.execute(delete(models.ItalianConjugationForm).where(models.ItalianConjugationForm.conjugation_pk.in_(refresh_ids)))
    imported_forms = 0
    for block, block_data in blocks_to_refresh:
        parsed_forms = block_data["forms"]
        imported_forms += len(parsed_forms)
        db.add_all([
            models.ItalianConjugationForm(
                conjugation_pk=block.conjugation_pk,
                person_order=form["person_order"],
                person_label=form["person_label"],
                form_text=form["form_text"],
                raw_line=form["raw_line"],
            )
            for form in parsed_forms
        ])
    await db.commit()
    return {
        "source_name": SOURCE_NAME,
        "source_license": SOURCE_LICENSE,
        "source_checksum": checksum,
        "verbs_processed": len(parsed_verbs),
        "verbs_created": created,
        "verbs_updated": updated,
        "conjugations_processed": len(blocks_to_refresh),
        "forms_processed": imported_forms,
        "skipped_records": skipped,
    }
