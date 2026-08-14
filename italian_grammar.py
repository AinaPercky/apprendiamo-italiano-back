"""
italian_grammar.py
Module de grammaire italien (pur Python, aucune dépendance externe)
- Constantes: listes de pronoms, verbes prenant `essere`, participes irréguliers, formes de `avere` et `essere`.
- Fonctions utilitaires pour classer les verbes, obtenir auxiliaire, participe passé,
  construire temps composés et étendre la sortie de mlconjug3.
"""

from typing import Dict, Optional

PERSONS_ORDER = ["io", "tu", "lui", "noi", "voi", "loro"]
ALL_PERSONS = ["io", "tu", "lui", "lei", "Lei", "noi", "voi", "loro"]
IMPERSONAL_KEY = "—"

PERSON_LABELS_FR: Dict[str, str] = {
    "io": "je",
    "tu": "tu",
    "lui": "il/elle",
    "lei": "elle",
    "Lei": "vous (politesse)",
    "noi": "nous",
    "voi": "vous",
    "loro": "ils/elles",
    IMPERSONAL_KEY: "invariable"
}

# Verbes qui prennent typiquement 'essere' comme auxiliaire (mouvements, changements d'état, naître/mourir, verbes pronominaux, météorologie...)
ESSERE_VERBS = {
    'andare','venire','tornare','partire','arrivare','uscire','entrare','rientrare',
    'ritornare','ripartire','riuscire','salire','scendere','cadere','correre','fuggire',
    'volare','passare','avanzare','procedere','essere','stare','restare','rimanere',
    'diventare','divenire','nascere','morire','crescere','invecchiare','ingrassare',
    'dimagrire','guarire','peggiorare','migliorare','apparire','sparire','comparire',
    'scomparire','sembrare','parere','piovere','nevicare','grandinare'
}

# Verbes qui peuvent prendre les deux auxiliaires selon sens
BOTH_AUX_VERBS = {
    'correre': 'Peut se conjuguer avec avere ou essere selon usage (transitif/intransitif).',
    'salire': 'Both: avec essere (monter) ou avere (faire monter qqch).',
    'scendere': 'Both selon transitivité.',
    'passare': 'Both selon sens (passer du temps vs traverser).',
    'finire': 'Parfois avere/essere selon usage idiomatique.',
    'iniziare': 'Souvent avere mais certains contextes usare essere.',
    'cominciare': 'Similaire à iniziare.',
    'aumentare': 'Both selon construction.',
    'diminuire': 'Both selon construction.'
}

# Participes passés irréguliers (liste non exhaustive mais 70+ entrées)
IRREGULAR_PAST_PARTICIPLES: Dict[str, str] = {
    'essere': 'stato', 'avere': 'avuto', 'fare': 'fatto', 'dire': 'detto', 'andare': 'andato',
    'dare': 'dato', 'stare': 'stato', 'vedere': 'visto', 'venire': 'venuto', 'sapere': 'saputo',
    'potere': 'potuto', 'volere': 'voluto', 'dovere': 'dovuto', 'bere': 'bevuto', 'rimanere': 'rimasto',
    'prendere': 'preso', 'mettere': 'messo', 'chiedere': 'chiesto', 'rispondere': 'risposto',
    'chiudere': 'chiuso', 'aprire': 'aperto', 'coprire': 'coperto', 'offrire': 'offerto',
    'soffrire': 'sofferto', 'scoprire': 'scoperto', 'leggere': 'letto', 'scrivere': 'scritto',
    'vivere': 'vissuto', 'correre': 'corso', 'perdere': 'perso', 'vincere': 'vinto', 'spendere': 'speso',
    'rompere': 'rotto', 'decidere': 'deciso', 'dividere': 'diviso', 'accendere': 'acceso',
    'dipendere': 'dipeso', 'offendere': 'offeso', 'scendere': 'sceso', 'nascere': 'nato',
    'morire': 'morto', 'crescere': 'cresciuto', 'cadere': 'caduto', 'scegliere': 'scelto',
    'togliere': 'tolto', 'raccogliere': 'raccolto', 'cogliere': 'colto', 'cuocere': 'cotto',
    'tradurre': 'tradotto', 'condurre': 'condotto', 'ridurre': 'ridotto', 'produrre': 'prodotto',
    'muovere': 'mosso', 'piangere': 'pianto', 'ridere': 'riso', 'sorridere': 'sorriso',
    'aggiungere': 'aggiunto', 'giungere': 'giunto', 'spingere': 'spinto', 'dipingere': 'dipinto',
    'stringere': 'stretto', 'nascondere': 'nascosto', 'discutere': 'discusso', 'succedere': 'successo',
    'esprimere': 'espresso', 'comprendere': 'compreso', 'permettere': 'permesso', 'promettere': 'promesso',
    'convincere': 'convinto', 'apparire': 'apparso', 'uscire': 'uscito', 'tenere': 'tenuto',
    'salire': 'salito', 'fingere': 'finto', 'assumere': 'assunto', 'concludere': 'concluso',
    'escludere': 'escluso'
}

# Accord du participe passé avec 'essere'
PP_AGREEMENT: Dict[str, str] = {
    'io': 'o', 'tu': 'o', 'lui': 'o', 'lei': 'a', 'Lei': 'o', 'noi': 'i', 'voi': 'i', 'loro': 'i'
}

# Formes complètes de 'avere' et 'essere' nécessaires pour construire les temps composés.
# Structure: {tense_name: {person: form}} pour les temps personnels, ou string pour infinitif/gerundio

AVERE_FORMS: Dict[str, object] = {
    'Indicativo Presente': {
        'io': 'ho', 'tu': 'hai', 'lui': 'ha', 'lei': 'ha', 'Lei': 'ha', 'noi': 'abbiamo', 'voi': 'avete', 'loro': 'hanno'
    },
    'Indicativo Imperfetto': {
        'io': 'avevo', 'tu': 'avevi', 'lui': 'aveva', 'lei': 'aveva', 'Lei': 'aveva', 'noi': 'avevamo', 'voi': 'avevate', 'loro': 'avevano'
    },
    'Indicativo Passato Remoto': {
        'io': 'ebbi', 'tu': 'avesti', 'lui': 'ebbe', 'lei': 'ebbe', 'Lei': 'ebbe', 'noi': 'avemmo', 'voi': 'aveste', 'loro': 'ebbero'
    },
    'Indicativo Futuro Semplice': {
        'io': 'avrò', 'tu': 'avrai', 'lui': 'avrà', 'lei': 'avrà', 'Lei': 'avrà', 'noi': 'avremo', 'voi': 'avrete', 'loro': 'avranno'
    },
    'Congiuntivo Presente': {
        'io': 'abbia', 'tu': 'abbia', 'lui': 'abbia', 'lei': 'abbia', 'Lei': 'abbia', 'noi': 'abbiamo', 'voi': 'abbiate', 'loro': 'abbiano'
    },
    'Congiuntivo Imperfetto': {
        'io': 'avessi', 'tu': 'avessi', 'lui': 'avesse', 'lei': 'avesse', 'Lei': 'avesse', 'noi': 'avessimo', 'voi': 'aveste', 'loro': 'avessero'
    },
    'Condizionale Presente': {
        'io': 'avrei', 'tu': 'avresti', 'lui': 'avrebbe', 'lei': 'avrebbe', 'Lei': 'avrebbe', 'noi': 'avremmo', 'voi': 'avreste', 'loro': 'avrebbero'
    },
    'Infinito Presente': 'avere',
    'Gerundio Presente': 'avendo'
}

ESSERE_FORMS: Dict[str, object] = {
    'Indicativo Presente': {
        'io': 'sono', 'tu': 'sei', 'lui': 'è', 'lei': 'è', 'Lei': 'è', 'noi': 'siamo', 'voi': 'siete', 'loro': 'sono'
    },
    'Indicativo Imperfetto': {
        'io': 'ero', 'tu': 'eri', 'lui': 'era', 'lei': 'era', 'Lei': 'era', 'noi': 'eravamo', 'voi': 'eravate', 'loro': 'erano'
    },
    'Indicativo Passato Remoto': {
        'io': 'fui', 'tu': 'fosti', 'lui': 'fu', 'lei': 'fu', 'Lei': 'fu', 'noi': 'fummo', 'voi': 'foste', 'loro': 'furono'
    },
    'Indicativo Futuro Semplice': {
        'io': 'sarò', 'tu': 'sarai', 'lui': 'sarà', 'lei': 'sarà', 'Lei': 'sarà', 'noi': 'saremo', 'voi': 'sarete', 'loro': 'saranno'
    },
    'Congiuntivo Presente': {
        'io': 'sia', 'tu': 'sia', 'lui': 'sia', 'lei': 'sia', 'Lei': 'sia', 'noi': 'siamo', 'voi': 'siate', 'loro': 'siano'
    },
    'Congiuntivo Imperfetto': {
        'io': 'fossi', 'tu': 'fossi', 'lui': 'fosse', 'lei': 'fosse', 'Lei': 'fosse', 'noi': 'fossimo', 'voi': 'foste', 'loro': 'fossero'
    },
    'Condizionale Presente': {
        'io': 'sarei', 'tu': 'saresti', 'lui': 'sarebbe', 'lei': 'sarebbe', 'Lei': 'sarebbe', 'noi': 'saremmo', 'voi': 'sareste', 'loro': 'sarebbero'
    },
    'Infinito Presente': 'essere',
    'Gerundio Presente': 'essendo'
}


def get_verb_class(infinitive: str) -> str:
    """Retourne 'are','ere','ire' ou 'unknown' selon la terminaison."""
    if not infinitive:
        return 'unknown'
    inf = infinitive.strip().lower()
    if inf.endswith('arsi') or inf.endswith('ersi') or inf.endswith('irsi'):
        # pronominale -> enlever 'si' pour la classification
        inf = inf[:-2]
    if inf.endswith('are'):
        return 'are'
    if inf.endswith('ere'):
        return 'ere'
    if inf.endswith('ire'):
        return 'ire'
    return 'unknown'


def get_auxiliary(infinitive: str, is_pronominal: bool = False) -> str:
    """Retourne 'avere','essere' ou 'both'."""
    if is_pronominal:
        return 'essere'
    if not infinitive:
        return 'avere'
    inf = infinitive.strip().lower()
    base = inf[:-2] if inf.endswith('si') else inf
    if base in BOTH_AUX_VERBS:
        return 'both'
    if base in ESSERE_VERBS:
        return 'essere'
    return 'avere'


def get_past_participle(infinitive: str, mlconjug_obj: Optional[object] = None) -> str:
    """
    Obtient le participe passé pour un infinitif.
    Priorités : IRREGULAR_PAST_PARTICIPLES > mlconjug_obj.conjug_info > règle régulière.
    """
    if not infinitive:
        return ''
    inf = infinitive.strip().lower()
    if inf.endswith('si'):
        base_inf = inf[:-2]
    else:
        base_inf = inf

    # 1. irréguliers
    if base_inf in IRREGULAR_PAST_PARTICIPLES:
        return IRREGULAR_PAST_PARTICIPLES[base_inf]

    # 2. mlconjug3 output (sécurisé)
    try:
        info = getattr(mlconjug_obj, 'conjug_info', None) or getattr(mlconjug_obj, 'conjug', None)
        if info and isinstance(info, dict):
            # navigation sûre : Participio -> Participio Passato
            partic_info = info.get('Participio') or info.get('Participio', {})
            if isinstance(partic_info, dict):
                pp = partic_info.get('Participio Passato') or partic_info.get('Participio passato')
                if pp:
                    # si pp est dict/personal or string, normaliser
                    if isinstance(pp, dict):
                        # prendre forme impersonal key si présente
                        return pp.get(IMPERSONAL_KEY) or next(iter(pp.values()))
                    if isinstance(pp, str):
                        return pp
    except Exception:
        pass

    # 3. règle régulière
    if base_inf.endswith('are'):
        return base_inf[:-3] + 'ato'
    if base_inf.endswith('ere'):
        return base_inf[:-3] + 'uto'
    if base_inf.endswith('ire'):
        return base_inf[:-3] + 'ito'

    # fallback
    return base_inf


def agree_participle(base_pp: str, person: str) -> str:
    """Accorde le participe passé (terminaison en 'o') selon PP_AGREEMENT."""
    if not base_pp:
        return ''
    if not person:
        return base_pp
    if not base_pp.endswith('o'):
        return base_pp
    suf = PP_AGREEMENT.get(person, 'o')
    return base_pp[:-1] + suf


def get_auxiliary_forms(uses_essere: bool) -> Dict[str, object]:
    """Retourne le dictionnaire de formes pour l'auxiliaire choisi."""
    return ESSERE_FORMS if uses_essere else AVERE_FORMS


def build_compound_tense(aux_forms: Dict[str, str], past_participle: str, uses_essere: bool) -> Dict[str, str]:
    """
    Construit un tense composé à partir des formes de l'auxiliaire et du participe passé.
    aux_forms : dict person -> forme
    """
    result: Dict[str, str] = {}
    # Si aux_forms est une string (infinitif/gerundio), traiter invariable
    if isinstance(aux_forms, str):
        result[IMPERSONAL_KEY] = f"{aux_forms} {past_participle}"
        return result

    for person in ALL_PERSONS:
        aux = aux_forms.get(person) or aux_forms.get(person.lower())
        if not aux:
            continue
        if uses_essere:
            pp_agreed = agree_participle(past_participle, person)
            result[person] = f"{aux} {pp_agreed}"
        else:
            result[person] = f"{aux} {past_participle}"

    return result


def build_all_compound_tenses(past_participle: str, uses_essere: bool) -> Dict[str, Dict[str, str]]:
    """
    Retourne un dict des temps composés demandés avec leurs formes par personne.
    Noms de temps retournés EXACTEMENT comme dans la table `tenses`.
    """
    aux = get_auxiliary_forms(uses_essere)
    result: Dict[str, Dict[str, str]] = {}

    # Indicativo Passato Prossimo -> aux Indicativo Presente
    result['Indicativo Passato Prossimo'] = build_compound_tense(aux.get('Indicativo Presente'), past_participle, uses_essere)

    # Indicativo Trapassato Prossimo -> aux Indicativo Imperfetto
    result['Indicativo Trapassato Prossimo'] = build_compound_tense(aux.get('Indicativo Imperfetto'), past_participle, uses_essere)

    # Indicativo Trapassato Remoto -> aux Indicativo Passato Remoto
    result['Indicativo Trapassato Remoto'] = build_compound_tense(aux.get('Indicativo Passato Remoto'), past_participle, uses_essere)

    # Indicativo Futuro Anteriore -> aux Indicativo Futuro Semplice
    result['Indicativo Futuro Anteriore'] = build_compound_tense(aux.get('Indicativo Futuro Semplice'), past_participle, uses_essere)

    # Congiuntivo Passato -> aux Congiuntivo Presente
    result['Congiuntivo Passato'] = build_compound_tense(aux.get('Congiuntivo Presente'), past_participle, uses_essere)

    # Congiuntivo Trapassato -> aux Congiuntivo Imperfetto
    result['Congiuntivo Trapassato'] = build_compound_tense(aux.get('Congiuntivo Imperfetto'), past_participle, uses_essere)

    # Condizionale Passato -> aux Condizionale Presente
    result['Condizionale Passato'] = build_compound_tense(aux.get('Condizionale Presente'), past_participle, uses_essere)

    # Infinito Passato -> Infinito + pp (invariable key)
    inf_aux = aux.get('Infinito Presente') or (aux.get('Infinito Presente') if isinstance(aux, dict) else aux)
    result['Infinito Passato'] = {IMPERSONAL_KEY: f"{inf_aux} {past_participle}"}

    # Gerundio Passato -> Gerundio + pp
    ger_aux = aux.get('Gerundio Presente')
    result['Gerundio Passato'] = {IMPERSONAL_KEY: f"{ger_aux} {past_participle}"}

    return result


def expand_mlconjug_simple_tenses(verb_obj) -> Dict[str, Dict[str, str]]:
    """
    Extrait et normalise les temps simples depuis un objet provenant de mlconjug3.
    Retourne : {tense_name: {person: form}}.

    Utilise la table de correspondance TENSE_MAP pour mapper les clés mlconjug3
    vers les noms internes requis.
    """
    TENSE_MAP = {
        ('Indicativo', 'Indicativo Presente'): 'Indicativo Presente',
        ('Indicativo', 'Indicativo Imperfetto'): 'Indicativo Imperfetto',
        ('Indicativo', 'Indicativo Passato Remoto'): 'Indicativo Passato Remoto',
        ('Indicativo', 'Indicativo Futuro Semplice'): 'Indicativo Futuro Semplice',
        ('Congiuntivo', 'Congiuntivo Presente'): 'Congiuntivo Presente',
        ('Congiuntivo', 'Congiuntivo Imperfetto'): 'Congiuntivo Imperfetto',
        ('Condizionale', 'Condizionale Presente'): 'Condizionale Presente',
        ('Imperativo', 'Imperativo Presente'): 'Imperativo Presente',
        ('Infinito', 'Infinito Presente'): 'Infinito Presente',
        ('Participio', 'Participio Presente'): 'Participio Presente',
        ('Participio', 'Participio Passato'): 'Participio Passato',
        ('Gerundio', 'Gerundio Presente'): 'Gerundio Presente'
    }

    out: Dict[str, Dict[str, str]] = {}

    try:
        conjug_info = getattr(verb_obj, 'conjug_info', None) or getattr(verb_obj, 'conjug', None)
        if not conjug_info or not isinstance(conjug_info, dict):
            return out

        # mlconjug3 may structure like conjug_info[Mood][Tense] -> dict of persons
        for ml_mood, ml_block in list(conjug_info.items()):
            if not isinstance(ml_block, dict):
                continue
            for ml_tense_key, forms in list(ml_block.items()):
                key = TENSE_MAP.get((ml_mood, ml_tense_key))
                if not key:
                    continue

                # forms could be dict person->form or string (for impersonal)
                if isinstance(forms, dict):
                    normalized: Dict[str, str] = {}
                    # mlconjug uses keys like 'io','tu','lui/lei' etc. We copy as available.
                    for p in ALL_PERSONS:
                        if p in forms:
                            normalized[p] = forms[p]
                        else:
                            # sometimes only 'lui' present; copy to 'lei' and 'Lei'
                            if p in ('lei', 'Lei') and 'lui' in forms:
                                normalized[p] = forms['lui']
                    # also accept forms with 'lui/lei' single key
                    if not normalized:
                        # try to map any available keys
                        for k, v in forms.items():
                            nk = k
                            if nk == 'lui/lei':
                                normalized['lui'] = v
                                normalized['lei'] = v
                                normalized['Lei'] = v
                            else:
                                normalized[nk] = v

                    # ensure lei and Lei exist
                    if 'lei' not in normalized and 'lui' in normalized:
                        normalized['lei'] = normalized['lui']
                    if 'Lei' not in normalized and 'lui' in normalized:
                        normalized['Lei'] = normalized['lui']

                    out[key] = normalized

                elif isinstance(forms, str):
                    out[key] = {IMPERSONAL_KEY: forms}

    except Exception:
        # Ne pas lever d'exception pour permettre au seed de continuer
        return out

    return out
