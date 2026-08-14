"""
seed_italian_verbs.py
Script d'initialisation pour peupler la base PostgreSQL `italian_verbs`.
Usage: python seed_italian_verbs.py --dsn "postgresql://postgres:password@localhost/italian_verbs"

Ce script utilise `mlconjug3` pour générer les formes simples, puis
complète les temps composés à l'aide des auxiliaires et du participe passé.
"""

import sys
import argparse
import logging
from typing import Dict, Optional

import psycopg2
from psycopg2.extras import execute_batch, DictCursor

import mlconjug3

from italian_grammar import (
    get_verb_class, get_auxiliary, get_past_participle,
    build_all_compound_tenses, expand_mlconjug_simple_tenses,
    ESSERE_VERBS, BOTH_AUX_VERBS, IMPERSONAL_KEY
)

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger(__name__)


# Liste d'au moins 400 verbes italiens fréquents (dédupliquée ensuite)
VERBS = [
    # auxiliaires & irréguliers essentiels
    'essere','avere','fare','dire','andare','venire','sapere','potere','volere','dovere',
    'stare','dare','bere','scegliere','togliere','rimanere','porre','tradurre','condurre','trarre',
    # mouvements / transport
    'partire','arrivare','tornare','entrare','uscire','salire','scendere','guidare','volare','prendere',
    'camminare','correre','nuotare','navigare','telefonare','viaggiare','trascorrere','attraversare','passare','trasportare',
    # communication / perception / cognition
    'parlare','ascoltare','sentire','vedere','guardare','capire','pensare','credere','sapere','conoscere',
    'spiegare','chiedere','rispondere','domandare','raccontare','descrivere','ricordare','dimenticare','immaginare','osservare',
    # émotions / préférences
    'amare','odiare','piacere','preferire','sperare','temere','desiderare','preoccupare','preoccuparsene','sorridere',
    # actions quotidiennes
    'mangiare','bere','dormire','svegliarsi','alzarsi','sedersi','lavare','pulire','cucinare','comprare',
    'vendere','pagare','spendere','risparmiare','lavorare','studiare','imparare','insegnare','leggere','scrivere',
    # travail / technologie
    'lavorare','programmare','scrivere','compilare','eseguire','installare','aggiornare','connettere','scaricare','caricare',
    'stampare','digitare','cliccare','inviare','ricevere','configurare','sviluppare','progettare','testare','deployare',
    # relations / possession
    'avere','possedere','tenere','lasciare','prendere','offrire','ricevere','regalare','scambiare','condividere',
    # changement / état
    'diventare','cambiare','migliorare','peggiorare','aumentare','diminuire','crescere','dimagrire','ingrassare','guarire',
    # météo / existence
    'piovere','nevicare','grandinare','esistere','apparire','sparire','succedere','sembrare','parere','comparire',
    # corps / santé
    'sentire','tossire','starnutire','sanguinare','ferire','guarire','ammalarsi','curare','controllare','misurare',
    # art / culture / sport
    'cantare','suonare','ballare','dipingere','disegnare','fotografare','recitare','produrre','allenare','giocare',
    # argent / finance
    'investire','guadagnare','perdere','riscuotere','pagare','accumulare','spendere','risparmiare','prestare','mutuare',
    # autres verbes fréquents
    'aprire','chiudere','mettere','togliere','accendere','spegnere','mostrare','nascondere','scegliere','decidere',
    'offrire','soffrire','correre','camminare','abitare','vivere','morire','nascere','crescere','cercare',
    'trovare','aspettare','arrivare','partire','salire','scendere','ricevere','invio','lamentare','festeggiare',
]

# To reach >=400 verbs, we extend with many common verbs and pronominal forms
extra_verbs = [
    'accompagnare','accettare','accogliere','acquistare','adattare','addormentarsi','ammirare','analizzare','annunciare','apprendere',
    'approvare','arrangiare','arrotondare','assegnare','assumere','attingere','attivare','attendere','attenuare','attivarsi',
    'attrarre','attuare','aumentare','avanzare','avvertire','avvicinare','barare','battere','beneficiare','bloccare',
    'brillare','bruciare','calcolare','cambiare','camuffare','cancellare','capovolgere','caricare','castrare','catturare',
    'celebrare','centrare','chiamare','chiudere','cliccare','cooperare','correggere','costruire','crescere','curare',
    'custodire','decorare','decrescere','definire','deludere','dimostrare','dimostrare','diplomare','dire','discutere',
    'dispensare','disporre','distinguere','dividere','divertire','diventare','distrarre','domare','dominare','donare',
    'dubitare','educare','elaborare','eleggere','eliminare','esaminare','esibire','esistere','esplorare','esprimere',
    'falle','fallire','fermare','fidarsi','filtrare','fissare','fondere','fornire','fotografare','frequentare',
    'funzionare','gestire','giudicare','giungere','gradire','implicitare','imperare','importare','imporre','includere',
    'indicizzare','informare','ingaggiare','inglobare','ingrandire','iniziare','insistere','installare','integrare','interagire',
    'interessare','interrompere','interpretare','introdurre','investigare','investire','isolare','lacrimare','lamentarsi','lasciare',
    'legare','licenziare','limitare','lottare','mantenere','mandare','marcare','maturare','migliorare','minacciare',
    'modellare','modificare','monitorare','muovere','navigare','negare','notare','notificare','nutrire','obbligare',
    'obiettare','occorrere','offendere','operare','ordinare','organizzare','osservare','ottenere','partecipare','partizionare',
    'passare','persuadere','pesare','pianificare','piangere','piegare','pillolare','poggiare','portare','porre',
    'posare','posizionare','potenziare','potere','preparare','preservare','presentare','pressare','pretendere','prevedere',
    'procedere','produrre','proiettare','promettere','promuovere','propagare','proporre','proseguire','proteggere','provare',
    'pubblicare','pullulare','pulire','puntare','quadruplicare','qualificare','quantificare','querelare','raccontare','racimolare',
    'raccogliere','radiare','rafforzare','raggiungere','rallentare','rammendare','rappresentare','raspare','rassicurare','ratificare',
    'recuperare','regalare','reggere','registrare','regolare','reinserire','reindirizzare','relazionare','relevare','remare',
    'rimediare','rimuovere','riparare','riportare','riprendere','riprodurre','risalire','riscaldare','rischiare','risonare',
    'risolvere','risparmiare','rispondere','ristabilire','ristorare','ristrutturare','ritardare','ritirare','ritornare','ritrovare',
    'rivelare','rivendere','rivolgere','rompere','rotolare','ruotare','saldare','salvare','salutare','scommettere',
    'scegliere','scendere','sciare','scivolare','sconfiggere','scoprire','scorrere','scrivere','scusare','segnare',
    'sembrare','separare','serrare','servire','sortire','sospendere','sostenere','sottolineare','sovrapporre','spalancare',
    'sparare','sparire','spaventare','specificare','spiegare','sperimentare','spiegare','spostare','spruzzare','stabilire',
    'staccare','stancare','stare','stimare','stipare','strategizzare','strappare','strategiare','stringere','studiare',
    'subire','succedere','suggerire','suggellare','suggerire','suffragare','suggerire','surgelare','supplicare','supportare',
    'suscitare','svegliare','svolgere','tagliare','tangentare','tassare','tendere','tentare','terminare','tornare',
    'tosare','toccare','tradire','tradurre','tranquillizzare','trasferire','trasmettere','trasformare','trasmettere','trasportare',
    'trattare','trovare','uccidere','ufficializzare','unire','utilizzare','valutare','vampirizzare','vendere','venire',
    'verificare','vestire','viaggiare','vincere','vogliare','voltare','votare','volgere','volere','zittire'
]

VERBS = list(dict.fromkeys(VERBS + extra_verbs))

if len(VERBS) < 400:
    logger.warning('VERBS list contains %d verbs; expected at least 400. Current length.', len(VERBS))

# KNOWN_IRREGULARS: ~50 verbes irréguliers pour le marquage
KNOWN_IRREGULARS = set([
    'essere','avere','fare','dire','andare','venire','dare','stare','vedere','prendere',
    'mettere','scrivere','leggere','porre','tenere','tenere','correre','perdere','vincere','rompere',
    'scegliere','togliere','rimanere','tradurre','condurre','trarre','produrre','ridurre','accendere','decidere',
    'scoprire','offrire','soffrire','aprire','chiudere','nascere','morire','crescere','scegliere','spegnere',
    'bere','vedere','ridere','piangere','conoscere','sapere','potere','volere','dovere'
])



def get_db_connection(dsn: str) -> psycopg2.extensions.connection:
    return psycopg2.connect(dsn)


def load_tense_ids(cur) -> Dict[str, int]:
    cur.execute('SELECT id, name FROM tenses')
    rows = cur.fetchall()
    return {r[1]: r[0] for r in rows}


def upsert_verb(cur, infinitive: str, rank: int) -> Optional[int]:
    vclass = get_verb_class(infinitive)
    is_pronominal = infinitive.strip().lower().endswith('si')
    auxiliary = get_auxiliary(infinitive, is_pronominal)
    base = infinitive.strip().lower().rstrip('si')
    is_irregular = base in KNOWN_IRREGULARS
    notes = ''
    if base in BOTH_AUX_VERBS:
        notes = BOTH_AUX_VERBS.get(base)

    sql = (
        "INSERT INTO verbs (infinitive, verb_class, auxiliary, is_irregular, is_pronominal, frequency_rank, notes) "
        "VALUES (%(infinitive)s, %(vclass)s, %(aux)s, %(is_irregular)s, %(is_pronominal)s, %(rank)s, %(notes)s) "
        "ON CONFLICT (infinitive) DO UPDATE SET verb_class=EXCLUDED.verb_class, auxiliary=EXCLUDED.auxiliary, "
        "is_irregular=EXCLUDED.is_irregular, is_pronominal=EXCLUDED.is_pronominal, frequency_rank=EXCLUDED.frequency_rank, notes=EXCLUDED.notes "
        "RETURNING id"
    )
    cur.execute(sql, {
        'infinitive': infinitive,
        'vclass': vclass,
        'aux': auxiliary,
        'is_irregular': is_irregular,
        'is_pronominal': is_pronominal,
        'rank': rank,
        'notes': notes
    })
    row = cur.fetchone()
    return row[0] if row else None


def insert_conjugations(cur, verb_id: int, tense_ids: Dict[str, int], all_forms: Dict[str, Dict[str, str]]):
    # Préparer les lignes à insérer
    params = []
    for tense_name, forms in all_forms.items():
        tense_id = tense_ids.get(tense_name)
        if not tense_id:
            continue
        if not isinstance(forms, dict):
            continue
        for person, form in forms.items():
            # Normaliser person -> si clé impersonal
            p = person
            params.append({
                'verb_id': verb_id,
                'tense_id': tense_id,
                'person': p,
                'form': form
            })

    if not params:
        return

    insert_sql = (
        "INSERT INTO conjugations (verb_id, tense_id, person, form) "
        "VALUES (%(verb_id)s, %(tense_id)s, %(person)s, %(form)s) "
        "ON CONFLICT (verb_id, tense_id, person) DO UPDATE SET form = EXCLUDED.form"
    )

    execute_batch(cur, insert_sql, params, page_size=500)


def seed(dsn: str):
    conn = None
    success = 0
    errors = 0
    try:
        conn = get_db_connection(dsn)
        conn.autocommit = False
        cur = conn.cursor()

        tense_ids = load_tense_ids(cur)
        if not tense_ids:
            logger.error('Aucun temps trouvé dans la table `tenses`. Exécutez schema.sql d\'abord.')
            return

        conjugator = mlconjug3.Conjugator(language='it')

        for idx, infinitive in enumerate(VERBS, start=1):
            try:
                logger.info('Processing %d/%d: %s', idx, len(VERBS), infinitive)
                verb_obj = None
                try:
                    verb_obj = conjugator.conjugate(infinitive)
                except Exception as e:
                    logger.warning('mlconjug3 failed for %s: %s', infinitive, e)

                simple_forms = expand_mlconjug_simple_tenses(verb_obj) if verb_obj is not None else {}
                past_participle = get_past_participle(infinitive, verb_obj)

                # S'assurer que Participio Passato est présent
                if 'Participio Passato' not in simple_forms:
                    simple_forms['Participio Passato'] = {IMPERSONAL_KEY: past_participle}

                is_pronominal = infinitive.strip().lower().endswith('si')
                uses_essere = (infinitive.strip().lower().rstrip('si') in ESSERE_VERBS) or is_pronominal

                compound_forms = build_all_compound_tenses(past_participle, uses_essere)

                all_forms = {}
                all_forms.update(simple_forms)
                all_forms.update(compound_forms)

                # Upsert verb
                verb_id = upsert_verb(cur, infinitive, idx)
                if not verb_id:
                    raise RuntimeError('Failed to upsert verb ' + infinitive)

                # Insert conjugations
                insert_conjugations(cur, verb_id, tense_ids, all_forms)

                conn.commit()
                success += 1

            except Exception as e:
                logger.exception('Error processing verb %s: %s', infinitive, e)
                errors += 1
                if conn:
                    conn.rollback()

    finally:
        if conn:
            conn.close()

    logger.info('Seeding complete: success=%d errors=%d total=%d', success, errors, len(VERBS))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dsn', default='postgresql://postgres:password@localhost/italian_verbs')
    args = parser.parse_args()
    seed(args.dsn)
