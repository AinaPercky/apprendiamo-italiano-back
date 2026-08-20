import json
import re
from pathlib import Path

CORPUS = Path('/home/ubuntu/apprendiamo-italiano-back/data/coniugazione/verbi.json')

PERSONS = ('io', 'tu', 'lui/lei', 'noi', 'voi', 'loro')
PRONOUNS = {'io': 'mi', 'tu': 'ti', 'lui/lei': 'si', 'noi': 'ci', 'voi': 'vi', 'loro': 'si'}
REFLEXIVE_DOUBLE = re.compile(r'(?<!\\w)(mi|ti|si|ci|vi)(\\s+)\\1(?!\\w)', re.IGNORECASE)
REFLEXIVE_FUSED_DOUBLE = re.compile(r'(mi|ti|si|ci|vi)\\1$', re.IGNORECASE)


def marked(form: str) -> str:
    return f'[b]{form}[|b]'


def personal_block(forms: list[str], subjunctive: bool = False) -> str:
    lines = []
    for person, form in zip(PERSONS, forms):
        label = f'che {person}' if subjunctive else person
        lines.append(f'{label} {marked(form)}')
    return '[br]'.join(lines) + '[br]'


def compound_block(auxiliaries: list[str], participle: str, subjunctive: bool = False) -> str:
    lines = []
    for person, auxiliary in zip(PERSONS, auxiliaries):
        label = f'che {person}' if subjunctive else person
        lines.append(f'{label} {auxiliary} {marked(participle)}')
    return '[br]'.join(lines) + '[br]'


def imperative_block(forms: list[str]) -> str:
    return '[br]'.join(marked(form) if form != '-' else '-' for form in forms) + '[br]'


def update_blocks(record: dict, mapping: dict[tuple[str, str], str]) -> int:
    changed = 0
    for block in record.get('coniugazione') or []:
        key = (block.get('modalita_verbale'), block.get('tempo_verbale'))
        if key in mapping and block.get('italiano') != mapping[key]:
            block['italiano'] = mapping[key]
            changed += 1
    return changed


uccidere = {
    ('Indicativo', 'Presente'): personal_block(['uccido', 'uccidi', 'uccide', 'uccidiamo', 'uccidete', 'uccidono']),
    ('Indicativo', 'Passato prossimo'): compound_block(['ho', 'hai', 'ha', 'abbiamo', 'avete', 'hanno'], 'ucciso'),
    ('Indicativo', 'Imperfetto'): personal_block(['uccidevo', 'uccidevi', 'uccideva', 'uccidevamo', 'uccidevate', 'uccidevano']),
    ('Indicativo', 'Trapassato prossimo'): compound_block(['avevo', 'avevi', 'aveva', 'avevamo', 'avevate', 'avevano'], 'ucciso'),
    ('Indicativo', 'Passato remoto'): personal_block(['uccisi', 'uccidesti', 'uccise', 'uccidemmo', 'uccideste', 'uccisero']),
    ('Indicativo', 'Trapassato remoto'): compound_block(['ebbi', 'avesti', 'ebbe', 'avemmo', 'aveste', 'ebbero'], 'ucciso'),
    ('Indicativo', 'Futuro semplice'): personal_block(['ucciderò', 'ucciderai', 'ucciderà', 'uccideremo', 'ucciderete', 'uccideranno']),
    ('Indicativo', 'Futuro anteriore'): compound_block(['avrò', 'avrai', 'avrà', 'avremo', 'avrete', 'avranno'], 'ucciso'),
    ('Condizionale', 'Presente'): personal_block(['ucciderei', 'uccideresti', 'ucciderebbe', 'uccideremmo', 'uccidereste', 'ucciderebbero']),
    ('Condizionale', 'Passato'): compound_block(['avrei', 'avresti', 'avrebbe', 'avremmo', 'avreste', 'avrebbero'], 'ucciso'),
    ('Congiuntivo', 'Presente'): personal_block(['uccida', 'uccida', 'uccida', 'uccidiamo', 'uccidiate', 'uccidano'], subjunctive=True),
    ('Congiuntivo', 'Passato'): compound_block(['abbia', 'abbia', 'abbia', 'abbiamo', 'abbiate', 'abbiano'], 'ucciso', subjunctive=True),
    ('Congiuntivo', 'Imperfetto'): personal_block(['uccidessi', 'uccidessi', 'uccidesse', 'uccidessimo', 'uccideste', 'uccidessero'], subjunctive=True),
    ('Congiuntivo', 'Trapassato'): compound_block(['avessi', 'avessi', 'avesse', 'avessimo', 'aveste', 'avessero'], 'ucciso', subjunctive=True),
    ('Imperativo', 'Presente'): imperative_block(['-', 'uccidi', 'uccida', 'uccidiamo', 'uccidete', 'uccidano']),
    ('Infinito', 'Presente'): marked('uccidere') + '[br]',
    ('Infinito', 'Passato'): 'avere ' + marked('ucciso') + '[br]',
    ('Participio', 'Presente'): marked('uccidente') + '[br]',
    ('Participio', 'Passato'): marked('ucciso') + '[br]',
    ('Gerundio', 'Presente'): marked('uccidendo') + '[br]',
    ('Gerundio', 'Passato'): 'avendo ' + marked('ucciso') + '[br]',
}

soccombere = {
    ('Indicativo', 'Presente'): personal_block(['soccombo', 'soccombi', 'soccombe', 'soccombiamo', 'soccombete', 'soccombono']),
    ('Indicativo', 'Imperfetto'): personal_block(['soccombevo', 'soccombevi', 'soccombeva', 'soccombevamo', 'soccombevate', 'soccombevano']),
    ('Indicativo', 'Passato remoto'): personal_block(['soccombei/soccombetti', 'soccombesti', 'soccombette', 'soccombemmo', 'soccombeste', 'soccombettero']),
    ('Indicativo', 'Futuro semplice'): personal_block(['soccomberò', 'soccomberai', 'soccomberà', 'soccomberemo', 'soccomberete', 'soccomberanno']),
    ('Condizionale', 'Presente'): personal_block(['soccomberei', 'soccomberesti', 'soccomberebbe', 'soccomberemmo', 'soccombereste', 'soccomberebbero']),
    ('Congiuntivo', 'Presente'): personal_block(['soccomba', 'soccomba', 'soccomba', 'soccombiamo', 'soccombiate', 'soccombano'], subjunctive=True),
    ('Congiuntivo', 'Imperfetto'): personal_block(['soccombessi', 'soccombessi', 'soccombesse', 'soccombessimo', 'soccombeste', 'soccombessero'], subjunctive=True),
    ('Imperativo', 'Presente'): imperative_block(['-', 'soccombi', 'soccomba', 'soccombiamo', 'soccombete', 'soccombano']),
}

with CORPUS.open(encoding='utf-8') as handle:
    records = json.load(handle)

changed_blocks = 0
prefixed_translations = 0
normalized_reflexive_texts = 0
for record in records:
    verb = (record.get('verbi') or '').strip()
    if verb == 'uccidere':
        changed_blocks += update_blocks(record, uccidere)
    elif verb == 'soccombere':
        changed_blocks += update_blocks(record, soccombere)

    translation = (record.get('translation_en') or '').strip()
    if translation and not translation.casefold().startswith('to '):
        record['translation_en'] = f'to {translation}'
        prefixed_translations += 1

    if verb.casefold().endswith('si'):
        for block in record.get('coniugazione') or []:
            italian = str(block.get('italiano') or '')
            normalized = REFLEXIVE_DOUBLE.sub(r'\1', italian)
            normalized = REFLEXIVE_FUSED_DOUBLE.sub(r'\1', normalized)
            if normalized != italian:
                block['italiano'] = normalized
                normalized_reflexive_texts += 1

with CORPUS.open('w', encoding='utf-8') as handle:
    json.dump(records, handle, ensure_ascii=False, indent=2)
    handle.write('\n')

print(json.dumps({
    'changed_conjugation_blocks': changed_blocks,
    'prefixed_english_translations': prefixed_translations,
    'normalized_reflexive_blocks': normalized_reflexive_texts,
}, ensure_ascii=False, indent=2))
