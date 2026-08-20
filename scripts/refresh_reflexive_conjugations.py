import json
from pathlib import Path

from generate_reflexive_conjugations import (
    ALREADY_REFLEXIVE_BASES,
    COMPOUND_TENSES,
    CORPUS,
    REFLEXIVE_BASES,
    REFLEXIVE_TRANSLATIONS,
    transform_block,
    transform_existing_reflexive_compound,
)


def main() -> None:
    data = json.loads(CORPUS.read_text(encoding='utf-8'))
    by_verb = {item.get('verbi', '').strip().casefold(): item for item in data}
    refreshed = []
    for base in REFLEXIVE_BASES:
        reflexive = base[:-2] + 'rsi' if base.endswith('re') else base + 'si'
        item = by_verb.get(reflexive)
        base_item = by_verb.get(base)
        if item is None or base_item is None:
            continue
        blocks = []
        for block in base_item.get('coniugazione') or []:
            if base == 'accorgere' and block.get('modalita_verbale') in {'Indicativo', 'Congiuntivo', 'Condizionale'} and block.get('tempo_verbale') in COMPOUND_TENSES:
                blocks.append(transform_existing_reflexive_compound(block))
            elif base in ALREADY_REFLEXIVE_BASES:
                copied = dict(block)
                copied['id'] = f'reflexive-{base}-{block.get("id", "unknown")}'
                blocks.append(copied)
            else:
                blocks.append(transform_block(block))
        for block in blocks:
            block['verbi'] = reflexive
        item['coniugazione'] = blocks
        if reflexive in REFLEXIVE_TRANSLATIONS:
            item['translation_fr'], item['translation_en'] = REFLEXIVE_TRANSLATIONS[reflexive]
        refreshed.append(reflexive)

    CORPUS.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Refreshed {len(refreshed)} reflexive verbs: {", ".join(refreshed)}')


if __name__ == '__main__':
    main()
