from __future__ import annotations

import json
import re
from pathlib import Path

CORPUS = Path(__file__).resolve().parents[1] / 'data' / 'coniugazione' / 'verbi.json'

ALREADY_REFLEXIVE_BASES = {'pentire', 'accorgere'}

REFLEXIVE_BASES = [
    'alzare', 'lavare', 'vestire', 'svegliare', 'chiamare', 'divertire',
    'sentire', 'sedere', 'addormentare', 'ricordare', 'arrabbiare',
    'sposare', 'incontrare', 'preparare', 'rilassare', 'fermare',
    'muovere', 'occupare', 'preoccupare', 'vergognare', 'pentire',
    'accorgere', 'iscrivere', 'offrire', 'servire', 'lamentare',
    'sbrigare', 'comportare', 'fidare', 'innamorare', 'laureare',
    'trasferire', 'sistemare', 'truccare', 'tagliare',
    'abituare', 'allontanare', 'annoiare', 'aspettare', 'battere',
    'bruciare', 'cambiare', 'chiedere', 'comprare', 'coricare',
    'decidere', 'dire', 'domandare', 'esprimere', 'fare', 'guardare',
    'mettere', 'nascondere', 'pettinare', 'presentare', 'rendere',
    'riposare', 'rompere', 'sbagliare', 'sorprendere', 'trovare',
]

REFLEXIVE_TRANSLATIONS = {
    'abituarsi': ('s’habituer', 'to get used to'),
    'allontanarsi': ('s’éloigner', 'to move away'),
    'annoiarsi': ('s’ennuyer', 'to get bored'),
    'aspettarsi': ('s’attendre à', 'to expect'),
    'battersi': ('se battre', 'to fight'),
    'bruciarsi': ('se brûler', 'to burn oneself'),
    'cambiarsi': ('se changer', 'to change clothes'),
    'chiedersi': ('se demander', 'to wonder'),
    'comprarsi': ('s’acheter', 'to buy for oneself'),
    'coricarsi': ('se coucher', 'to go to bed'),
    'decidersi': ('se décider', 'to decide'),
    'dirsi': ('se dire', 'to tell oneself'),
    'domandarsi': ('se demander', 'to wonder'),
    'esprimersi': ('s’exprimer', 'to express oneself'),
    'farsi': ('se faire', 'to do for oneself'),
    'guardarsi': ('se regarder', 'to look at oneself'),
    'mettersi': ('se mettre', 'to put oneself / begin'),
    'nascondersi': ('se cacher', 'to hide oneself'),
    'pettinarsi': ('se peigner', 'to comb one’s hair'),
    'presentarsi': ('se présenter', 'to introduce oneself'),
    'rendersi': ('se rendre compte', 'to realize'),
    'riposarsi': ('se reposer', 'to rest'),
    'rompersi': ('se casser', 'to break one’s arm or leg'),
    'sbagliarsi': ('se tromper', 'to be mistaken'),
    'sorprendersi': ('être surpris', 'to be surprised'),
    'trovarsi': ('se trouver', 'to find oneself / be located'),
}

PERSON_PRONOUN = {
    'io': 'mi',
    'tu': 'ti',
    'lui': 'si',
    'lei': 'si',
    'lui/lei': 'si',
    'noi': 'ci',
    'voi': 'vi',
    'loro': 'si',
}

PERSONS = ('io', 'tu', 'lui', 'noi', 'voi', 'loro')
COMPOUND_TENSES = {
    'Passato prossimo', 'Trapassato prossimo', 'Futuro anteriore',
    'Trapassato remoto', 'Passato', 'Trapassato',
}
AUXILIARY_REPLACEMENTS = {
    'ho': 'sono', 'hai': 'sei', 'ha': 'è', 'abbiamo': 'siamo', 'avete': 'siete', 'hanno': 'sono',
    'avevo': 'ero', 'avevi': 'eri', 'aveva': 'era', 'avevamo': 'eravamo', 'avevate': 'eravate', 'avevano': 'erano',
    'avrò': 'sarò', 'avrai': 'sarai', 'avrà': 'sarà', 'avremo': 'saremo', 'avrete': 'sarete', 'avranno': 'saranno',
    'ebbi': 'fui', 'avesti': 'fosti', 'ebbe': 'fu', 'avemmo': 'fummo', 'aveste': 'foste', 'ebbero': 'furono',
    'abbia': 'sia', 'abbiate': 'siate', 'abbiano': 'siano',
    'avessi': 'fossi', 'avesse': 'fosse', 'avessimo': 'fossimo', 'avessero': 'fossero',
    'avrei': 'sarei', 'avresti': 'saresti', 'avrebbe': 'sarebbe', 'avremmo': 'saremmo', 'avreste': 'sareste', 'avrebbero': 'sarebbero',
}
_PREFIXES = ('che lui/lei', 'che io', 'che tu', 'che lui', 'che lei', 'che noi', 'che voi', 'che loro', 'lui/lei', 'io', 'tu', 'lui', 'lei', 'noi', 'voi', 'loro')
_MARKUP = re.compile(r'\[(?:\|?b|br)\]')


def clean(value: str) -> str:
    return re.sub(r'\s+', ' ', _MARKUP.sub('', value.replace('\\/', '/'))).strip()


def split_person_line(line: str) -> tuple[str | None, str]:
    cleaned = clean(line)
    for prefix in _PREFIXES:
        if cleaned.casefold().startswith(prefix + ' ') or cleaned.casefold() == prefix:
            return prefix, cleaned[len(prefix):].strip()
    return None, cleaned


def append_clitic(form: str, clitic: str) -> str:
    return form if form.casefold().endswith(clitic.casefold()) else f'{form}{clitic}'


def agree_participle(rest: str, key: str) -> str:
    if not rest:
        return rest
    parts = rest.split(' ')
    participle = parts[-1]
    if '/' not in participle and participle.endswith('o'):
        participle = participle[:-1] + ('i/e' if key in {'noi', 'voi', 'loro'} else 'o/a')
        parts[-1] = participle
    return ' '.join(parts)


def reflexive_form(person: str, form: str, mood: str, tense: str) -> str:
    key = person.replace('che ', '').strip()
    pronoun = PERSON_PRONOUN.get(key, 'si')
    prefix = pronoun + ' '
    if form.casefold().startswith(prefix):
        form = form[len(prefix):].strip()
    if mood in {'Indicativo', 'Congiuntivo', 'Condizionale'} and tense in COMPOUND_TENSES:
        pieces = form.split(' ', 1)
        auxiliary = AUXILIARY_REPLACEMENTS.get(pieces[0], pieces[0])
        rest = agree_participle(pieces[1] if len(pieces) == 2 else '', key)
        return f'{pronoun} {auxiliary}{(" " + rest) if rest else ""}'.strip()
    return f'{pronoun} {form}'.strip()


def transform_existing_reflexive_compound(base_block: dict) -> dict:
    mood = base_block['modalita_verbale']
    tense = base_block['tempo_verbale']
    raw = str(base_block.get('italiano') or '')
    result_lines = []
    for line in [line for line in raw.split('[br]') if clean(line)]:
        person, form = split_person_line(line)
        if person is None:
            result_lines.append(clean(line))
            continue
        key = person.replace('che ', '').strip()
        pronoun = PERSON_PRONOUN.get(key, 'si')
        if not form.casefold().startswith(pronoun + ' '):
            form = f'{pronoun} {form}'.strip()
        result_lines.append(f'{person} {form}')
    copied = dict(base_block)
    copied['id'] = f"reflexive-accorgere-{base_block.get('id', 'unknown')}"
    copied['italiano'] = '[br]'.join(result_lines) + '[br]'
    return copied


def transform_block(base_block: dict) -> dict:
    mood = base_block['modalita_verbale']
    tense = base_block['tempo_verbale']
    raw = str(base_block.get('italiano') or '')
    lines = [line for line in raw.split('[br]') if clean(line)]

    if mood == 'Imperativo':
        transformed = ['-']
        for index, line in enumerate(lines[1:], start=1):
            form = clean(line)
            if index == 1:
                transformed.append(append_clitic(form, 'ti'))
            elif index == 2:
                transformed.append(form if form.casefold().startswith('si ') else f'si {form}')
            elif index == 3:
                transformed.append(append_clitic(form, 'ci'))
            elif index == 4:
                transformed.append(append_clitic(form, 'vi'))
            elif index == 5:
                transformed.append(form if form.casefold().startswith('si ') else f'si {form}')
        result_lines = transformed
    elif mood in {'Infinito', 'Participio', 'Gerundio'}:
        result_lines = []
        for line in lines:
            form = clean(line)
            if mood == 'Infinito' and tense == 'Presente':
                if form == 'fare':
                    result_lines.append('farsi')
                else:
                    result_lines.append(form[:-2] + 'rsi' if form.endswith('re') else form + 'si')
            elif mood == 'Infinito' and tense == 'Passato':
                parts = form.split(' ', 1)
                participle = parts[1] if len(parts) == 2 else form
                result_lines.append(f'essersi {participle}')
            elif mood == 'Gerundio' and tense == 'Presente':
                result_lines.append(append_clitic(form, 'si'))
            elif mood == 'Gerundio' and tense == 'Passato':
                parts = form.split(' ', 1)
                participle = parts[1] if len(parts) == 2 else form
                result_lines.append(f'essendosi {participle}')
            else:
                result_lines.append(form)
    else:
        result_lines = []
        for line in lines:
            person, form = split_person_line(line)
            if person is None:
                result_lines.append(clean(line))
                continue
            result_lines.append(f'{person} {reflexive_form(person, form, mood, tense)}')

    return {
        'id': f"reflexive-{base_block.get('id', 'unknown')}",
        'verbi': '',
        'chk': bool(base_block.get('chk')),
        'modalita_verbale': mood,
        'tempo_verbale': tense,
        'italiano': '[br]'.join(result_lines) + '[br]',
        'portoghese': None,
    }


def main() -> None:
    original_text = CORPUS.read_text()
    data = json.loads(original_text)
    by_verb = {item.get('verbi', '').strip().casefold(): item for item in data}
    added = []
    for base in REFLEXIVE_BASES:
        reflexive = base[:-2] + 'rsi' if base.endswith('re') else base + 'si'
        if reflexive in by_verb:
            continue
        base_item = by_verb.get(base)
        if not base_item:
            raise RuntimeError(f'Missing base verb in corpus: {base}')
        translation_fr, translation_en = REFLEXIVE_TRANSLATIONS.get(
            reflexive,
            (f"{reflexive} (forme réfléchie)", f"to {base} oneself"),
        )
        item = {
            'id': f'reflexive-{base}',
            'verbi': reflexive,
            'translation_fr': translation_fr,
            'translation_en': translation_en,
            'coniugazione': [],
        }
        for block in base_item.get('coniugazione') or []:
            if base == 'accorgere' and block.get('modalita_verbale') in {'Indicativo', 'Congiuntivo', 'Condizionale'} and block.get('tempo_verbale') in COMPOUND_TENSES:
                item['coniugazione'].append(transform_existing_reflexive_compound(block))
            elif base in ALREADY_REFLEXIVE_BASES:
                copied = dict(block)
                copied['id'] = f"reflexive-{base}-{block.get('id', 'unknown')}"
                item['coniugazione'].append(copied)
            else:
                item['coniugazione'].append(transform_block(block))
        for block in item['coniugazione']:
            block['verbi'] = reflexive
        added.append(item)

    if not added:
        print('No new reflexive verbs to add.')
        return

    insertion = ',\n' + ',\n'.join(json.dumps(item, ensure_ascii=False, indent=3) for item in added)
    stripped = original_text.rstrip()
    if not stripped.endswith(']'):
        raise RuntimeError('Corpus JSON does not end with an array terminator')
    updated = stripped[:-1] + insertion + '\n]\n'
    json.loads(updated)
    CORPUS.write_text(updated)
    print(f'Added {len(added)} reflexive verbs: {", ".join(item["verbi"] for item in added)}')


if __name__ == '__main__':
    main()
