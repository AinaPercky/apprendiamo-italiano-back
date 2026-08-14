"""
routers/italian_conjugation.py
Router FastAPI pour l'API de conjugaison italienne (préfixe /api/italian).
Utilise SQLAlchemy Core (`text()`) pour toutes les requêtes SQL.
"""

import os
from typing import Generator, List, Dict, Any

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://postgres:password@localhost/italian_verbs')

engine: Engine = create_engine(DATABASE_URL)


def get_db() -> Generator:
    conn = engine.connect()
    try:
        yield conn
    finally:
        conn.close()


router = APIRouter(prefix='/api/italian', tags=['Italian Conjugation'])


@router.get('/verbs')
def list_verbs(
    verb_class: str | None = Query(None),
    auxiliary: str | None = Query(None),
    irregular: bool | None = Query(None),
    pronominal: bool | None = Query(None),
    search: str | None = Query(None),
    limit: int = Query(50, gt=0),
    offset: int = Query(0, ge=0),
    db=Depends(get_db)
):
    # Construire filtre dynamique
    filters = []
    params: Dict[str, Any] = {}
    if verb_class:
        filters.append('verb_class = :verb_class')
        params['verb_class'] = verb_class
    if auxiliary:
        filters.append('auxiliary = :auxiliary')
        params['auxiliary'] = auxiliary
    if irregular is not None:
        filters.append('is_irregular = :irregular')
        params['irregular'] = irregular
    if pronominal is not None:
        filters.append('is_pronominal = :pronominal')
        params['pronominal'] = pronominal
    if search:
        filters.append('infinitive ILIKE :search')
        params['search'] = f"{search}%"

    where = ('WHERE ' + ' AND '.join(filters)) if filters else ''

    count_sql = text(f"SELECT COUNT(*) AS total FROM verbs {where}")
    total = db.execute(count_sql, params).scalar()

    sql = text(f"SELECT * FROM verbs {where} ORDER BY frequency_rank NULLS LAST, infinitive LIMIT :limit OFFSET :offset")
    params.update({'limit': limit, 'offset': offset})
    rows = db.execute(sql, params).fetchall()
    verbs = [dict(r._mapping) for r in rows]

    return {'total': int(total or 0), 'offset': offset, 'limit': limit, 'verbs': verbs}


@router.get('/verbs/{infinitive}/info')
def verb_info(infinitive: str, db=Depends(get_db)):
    sql = text('SELECT * FROM verbs WHERE infinitive = :infinitive')
    row = db.execute(sql, {'infinitive': infinitive}).fetchone()
    if not row:
        raise HTTPException(status_code=404, detail='Verb not found')
    return dict(row._mapping)


def _ordered_forms(forms: Dict[str, str]) -> Dict[str, str]:
    order = ["io","tu","lui","lei","Lei","noi","voi","loro","—"]
    out: Dict[str, str] = {}
    for p in order:
        if p in forms:
            out[p] = forms[p]
    # include any remaining
    for k, v in forms.items():
        if k not in out:
            out[k] = v
    return out


@router.get('/conjugate/{infinitive}')
def conjugate(infinitive: str, mood: str | None = Query(None), tense: str | None = Query(None), tense_type: str | None = Query(None), db=Depends(get_db)):
    params = {'infinitive': infinitive}
    where = 'WHERE v.infinitive = :infinitive'
    if mood:
        where += ' AND t.mood = :mood'
        params['mood'] = mood
    if tense:
        where += ' AND t.name = :tense'
        params['tense'] = tense
    if tense_type:
        where += ' AND t.tense_type = :tense_type'
        params['tense_type'] = tense_type

    sql = text(
        'SELECT v.infinitive, v.verb_class, v.auxiliary, v.is_irregular, '
        't.name AS tense_name, t.mood, t.tense_type, t.label_fr, t.sort_order, '
        'c.person, c.form '
        'FROM conjugations c '
        'JOIN tenses t ON c.tense_id = t.id '
        'JOIN verbs v ON c.verb_id = v.id '
        f'{where} '
        'ORDER BY t.sort_order'
    )

    rows = db.execute(sql, params).fetchall()
    if not rows:
        # check verb exists
        vcheck = db.execute(text('SELECT 1 FROM verbs WHERE infinitive = :infinitive'), {'infinitive': infinitive}).fetchone()
        if not vcheck:
            raise HTTPException(status_code=404, detail='Verb not found')
        return {'infinitive': infinitive, 'conjugations': {}}

    first = rows[0]
    result = {
        'infinitive': first._mapping['infinitive'],
        'verb_class': first._mapping['verb_class'],
        'auxiliary': first._mapping['auxiliary'],
        'is_irregular': bool(first._mapping['is_irregular']),
        'conjugations': {}
    }

    for row in rows:
        r = dict(row._mapping)
        tense_name = r['tense_name']
        if tense_name not in result['conjugations']:
            result['conjugations'][tense_name] = {
                'mood': r['mood'], 'tense_type': r['tense_type'], 'label_fr': r['label_fr'], 'sort_order': r['sort_order'], 'forms': {}
            }
        result['conjugations'][tense_name]['forms'][r['person']] = r['form']

    # Order forms inside each tense
    for tname, data in result['conjugations'].items():
        data['forms'] = _ordered_forms(data['forms'])

    return result


@router.get('/conjugate/{infinitive}/tense/{tense_name}')
def conjugate_tense(infinitive: str, tense_name: str, db=Depends(get_db)):
    sql = text(
        'SELECT v.infinitive, t.name AS tense_name, t.mood, t.tense_type, t.label_fr, c.person, c.form '
        'FROM conjugations c '
        'JOIN tenses t ON c.tense_id = t.id '
        'JOIN verbs v ON c.verb_id = v.id '
        'WHERE v.infinitive = :infinitive AND t.name = :tense_name '
        'ORDER BY c.person'
    )
    rows = db.execute(sql, {'infinitive': infinitive, 'tense_name': tense_name}).fetchall()
    if not rows:
        raise HTTPException(status_code=404, detail='Tense not found for this verb')

    forms = {r._mapping['person']: r._mapping['form'] for r in rows}
    return {
        'infinitive': infinitive,
        'tense': tense_name,
        'mood': rows[0]._mapping['mood'],
        'label_fr': rows[0]._mapping['label_fr'],
        'tense_type': rows[0]._mapping['tense_type'],
        'forms': _ordered_forms(forms)
    }


@router.get('/search/form')
def search_form(q: str = Query(..., min_length=1), limit: int = Query(10, gt=0), db=Depends(get_db)):
    sql = text(
        'SELECT c.form, v.infinitive, v.verb_class, v.is_irregular, v.auxiliary, t.name AS tense_name, t.label_fr, t.mood, c.person '
        'FROM conjugations c '
        'JOIN tenses t ON c.tense_id = t.id '
        'JOIN verbs v ON c.verb_id = v.id '
        'WHERE LOWER(c.form) = LOWER(:q) '
        'LIMIT :limit'
    )
    rows = db.execute(sql, {'q': q, 'limit': limit}).fetchall()
    if not rows:
        raise HTTPException(status_code=404, detail='No matches')
    matches = [dict(r._mapping) for r in rows]
    return {'query': q, 'matches': matches}


@router.get('/search/prefix')
def search_prefix(q: str = Query(..., min_length=2), limit: int = Query(20, gt=0), db=Depends(get_db)):
    sql = text(
        'SELECT DISTINCT c.form, v.infinitive, t.name AS tense_name, t.label_fr, c.person '
        'FROM conjugations c '
        'JOIN tenses t ON c.tense_id = t.id '
        'JOIN verbs v ON c.verb_id = v.id '
        "WHERE LOWER(c.form) LIKE LOWER(:q) || '%' "
        'LIMIT :limit'
    )
    rows = db.execute(sql, {'q': q, 'limit': limit}).fetchall()
    results = [dict(r._mapping) for r in rows]
    count = len(results)
    return {'query': q, 'count': count, 'results': results}


@router.get('/tenses')
def list_tenses(mood: str | None = Query(None), db=Depends(get_db)):
    params = {}
    where = ''
    if mood:
        where = 'WHERE mood = :mood'
        params['mood'] = mood
    rows = db.execute(text(f'SELECT * FROM tenses {where} ORDER BY sort_order'), params).fetchall()
    tenses = [dict(r._mapping) for r in rows]
    return {'tenses': tenses}


@router.get('/compare')
def compare(v1: str = Query(...), v2: str = Query(...), tense: str = Query('Indicativo Presente'), db=Depends(get_db)):
    # Vérifier existence
    exists = db.execute(text('SELECT infinitive FROM verbs WHERE infinitive IN (:v1, :v2)'), {'v1': v1, 'v2': v2}).fetchall()
    found = [r._mapping['infinitive'] for r in exists]
    if v1 not in found or v2 not in found:
        raise HTTPException(status_code=404, detail='One or both verbs not found')

    sql = text(
        'SELECT v.infinitive, c.person, c.form '
        'FROM conjugations c '
        'JOIN tenses t ON c.tense_id = t.id '
        'JOIN verbs v ON c.verb_id = v.id '
        'WHERE t.name = :tense AND v.infinitive IN (:v1, :v2)'
    )
    rows = db.execute(sql, {'tense': tense, 'v1': v1, 'v2': v2}).fetchall()
    comparison: Dict[str, Dict[str, str]] = {v1: {}, v2: {}}
    for r in rows:
        infinitive = r._mapping['infinitive']
        comparison[infinitive][r._mapping['person']] = r._mapping['form']

    # Order forms
    for verb in [v1, v2]:
        comparison[verb] = _ordered_forms(comparison[verb])

    return {'tense': tense, 'verbs': [v1, v2], 'comparison': comparison}


@router.get('/stats')
def stats(db=Depends(get_db)):
    total_verbs = db.execute(text('SELECT COUNT(*) FROM verbs')).scalar() or 0
    total_conjugations = db.execute(text('SELECT COUNT(*) FROM conjugations')).scalar() or 0
    total_tenses = db.execute(text('SELECT COUNT(*) FROM tenses')).scalar() or 0

    by_class_rows = db.execute(text('SELECT verb_class, COUNT(*) AS cnt FROM verbs GROUP BY verb_class')).fetchall()
    by_aux_rows = db.execute(text('SELECT auxiliary, COUNT(*) AS cnt FROM verbs GROUP BY auxiliary')).fetchall()

    by_class = {r._mapping['verb_class']: r._mapping['cnt'] for r in by_class_rows}
    by_auxiliary = {r._mapping['auxiliary']: r._mapping['cnt'] for r in by_aux_rows}

    irregular_count = db.execute(text('SELECT COUNT(*) FROM verbs WHERE is_irregular = true')).scalar() or 0
    pronominal_count = db.execute(text('SELECT COUNT(*) FROM verbs WHERE is_pronominal = true')).scalar() or 0

    return {
        'total_verbs': int(total_verbs),
        'total_conjugations': int(total_conjugations),
        'total_tenses': int(total_tenses),
        'by_class': by_class,
        'by_auxiliary': by_auxiliary,
        'irregular_count': int(irregular_count),
        'pronominal_count': int(pronominal_count)
    }
