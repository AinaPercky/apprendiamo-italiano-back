"""Classification stable des verbes italiens utilisée par le frontend.

Les catégories correspondent aux options visibles dans le quiz du frontend. Un
verbe peut être classé dans une seule catégorie pour conserver un contrat simple
avec le sélecteur actuel; les formes réfléchies héritent automatiquement de la
catégorie de leur infinitif non réfléchi lorsque celui-ci est connu.
"""

from __future__ import annotations

from collections import OrderedDict

CATEGORY_ORDER = (
    "Auxiliaires",
    "Mouvement",
    "Communication",
    "Vie quotidienne",
    "Modaux",
    "Actions",
)

GRAMMAR_CATEGORY_ORDER = (
    "Verbes en -are (réguliers)",
    "Verbes en -ire (réguliers)",
    "Verbes en -ere (réguliers)",
    "Verbes irréguliers",
    "Verbes réfléchis",
)

# Verbes dont le radical, l’auxiliaire ou les formes principales ne suivent pas
# le modèle régulier de leur terminaison. Les réflexifs héritent de cette liste.
IRREGULAR_VERBS = frozenset(
    {
        # Union des bases historiques et de la liste image.
        "accendere",
        "accorgere",
        "aggiungere",
        "ammettere",
        "andare",
        "apparire",
        "appendere",
        "apprendere",
        "aprire",
        "assistere",
        "assolvere",
        "assumere",
        "attendere",
        "avere",
        "bere",
        "cadere",
        "chiedere",
        "chiudere",
        "cogliere",
        "comprendere",
        "concedere",
        "concludere",
        "condurre",
        "confondere",
        "conoscere",
        "convincere",
        "coprire",
        "correggere",
        "correre",
        "costringere",
        "crescere",
        "cuocere",
        "dare",
        "decidere",
        "dedurre",
        "deludere",
        "descrivere",
        "difendere",
        "diffondere",
        "dipendere",
        "dire",
        "dirigere",
        "discutere",
        "distendere",
        "distinguere",
        "distruggere",
        "dividere",
        "dovere",
        "eleggere",
        "emergere",
        "erigere",
        "escludere",
        "esigere",
        "esistere",
        "espellere",
        "esplodere",
        "esprimere",
        "essere",
        "estendere",
        "estinguere",
        "fare",
        "fingere",
        "fondere",
        "friggere",
        "fungere",
        "giungere",
        "godere",
        "illudere",
        "immergere",
        "imprimere",
        "incidere",
        "indurre",
        "influenzare",
        "infrangere",
        "insistere",
        "intendere",
        "interrompere",
        "introdurre",
        "invadere",
        "iscrivere",
        "leggere",
        "mordere",
        "morire",
        "muovere",
        "nascere",
        "nascondere",
        "nuocere",
        "occorrere",
        "offendere",
        "offrire",
        "pentire",
        "perdere",
        "permettere",
        "persuadere",
        "piacere",
        "piangere",
        "porre",
        "potere",
        "prendere",
        "pretendere",
        "produrre",
        "promettere",
        "proteggere",
        "pungere",
        "raccogliere",
        "radere",
        "raggiungere",
        "redigere",
        "reggere",
        "rendere",
        "resistere",
        "respingere",
        "ridere",
        "ridurre",
        "riflettere",
        "rimanere",
        "risolvere",
        "rispondere",
        "rivolgere",
        "rompere",
        "salire",
        "sapere",
        "scalfire",
        "scegliere",
        "scendere",
        "scommettere",
        "sconfiggere",
        "scoprire",
        "scorgere",
        "scrivere",
        "scuotere",
        "sedere",
        "sentire",
        "smettere",
        "soffrire",
        "sorgere",
        "sorprendere",
        "sorridere",
        "sospendere",
        "spegnere",
        "spendere",
        "spingere",
        "stare",
        "stendere",
        "stringere",
        "succedere",
        "svolgere",
        "tendere",
        "tenere",
        "tingere",
        "togliere",
        "tradurre",
        "trarre",
        "trascorrere",
        "uccidere",
        "udire",
        "ungere",
        "uscire",
        "valere",
        "vedere",
        "venire",
        "vincere",
        "vivere",
        "volere",
        "volgere",
    }
)

CATEGORY_VERBS: OrderedDict[str, frozenset[str]] = OrderedDict(
    (
        (
            "Auxiliaires",
            frozenset({"essere", "avere"}),
        ),
        (
            "Mouvement",
            frozenset(
                {
                    "andare", "venire", "partire", "arrivare", "tornare", "escire",
                    "entrare", "muovere", "correre", "camminare", "fuggire", "salire",
                    "scendere", "restare", "rientrare", "trasferire", "viaggiare", "allontanare",
                }
            ),
        ),
        (
            "Communication",
            frozenset(
                {
                    "dire", "parlare", "chiamare", "rispondere", "domandare", "chiedere",
                    "comunicare", "raccontare", "spiegare", "ascoltare", "leggere",
                    "scrivere", "discutere", "contattare", "conversare", "annunciare", "esprimere",
                    "presentare",
                }
            ),
        ),
        (
            "Vie quotidienne",
            frozenset(
                {
                    "mangiare", "bere", "dormire", "lavorare", "studiare", "abitare",
                    "vivere", "alzare", "lavare", "vestire", "svegliare", "addormentare", "cucinare",
                    "cenare", "comprare", "preparare", "sposare", "incontrare", "rilassare",
                    "fermare", "truccare", "sistemare", "laureare", "abituare", "annoiare",
                    "coricare", "pettinare", "riposare",
                }
            ),
        ),
        (
            "Modaux",
            frozenset({"potere", "dovere", "volere", "sapere"}),
        ),
        (
            "Actions",
            frozenset(
                {
                    "fare", "dare", "prendere", "mettere", "vedere", "guardare", "aprire",
                    "chiudere", "giocare", "cantare", "ballare", "amare", "capire", "finire",
                    "iniziare", "decidere", "aiutare", "usare", "tenere", "portare", "trovare",
                    "perdere", "vincere", "cambiare", "tagliare", "offrire", "servire",
                    "lamentare", "sbrigare", "comportare", "fidare", "innamorare", "pentire",
                    "accorgere", "addire", "iscrivere", "divertire", "sentire", "sedere", "ricordare",
                    "arrabbiare", "vergognare", "occupare", "preoccupare", "aspettare", "battere",
                    "bruciare", "nascondere", "rendere", "rompere", "sbagliare", "sorprendere",
                }
            ),
        ),
    )
)

_BASE_TO_CATEGORY = {
    verb: category
    for category, verbs in CATEGORY_VERBS.items()
    for verb in verbs
}


def base_infinitive(infinitive: str) -> str:
    normalized = infinitive.strip().casefold()
    # Corpus reflexive infinitives end in -rsi: alzarsi -> alzare,
    # pentirsi -> pentire, accorgersi -> accorgere.
    if normalized.endswith("rsi"):
        return f"{normalized[:-3]}re"
    return normalized


def category_for_infinitive(infinitive: str) -> str | None:
    """Return the thematic frontend category for an infinitive, if classified."""
    normalized = infinitive.strip().casefold()
    direct = _BASE_TO_CATEGORY.get(normalized)
    if direct:
        return direct
    return _BASE_TO_CATEGORY.get(base_infinitive(normalized))


def grammar_category_for_infinitive(infinitive: str) -> str:
    """Classify an infinitive, keeping reflexive verbs in their own category."""
    normalized = infinitive.strip().casefold()
    if normalized.endswith("si"):
        return "Verbes réfléchis"
    base = base_infinitive(normalized)
    if base in IRREGULAR_VERBS:
        return "Verbes irréguliers"
    if base.endswith("are"):
        return "Verbes en -are (réguliers)"
    if base.endswith("ire"):
        return "Verbes en -ire (réguliers)"
    if base.endswith("ere"):
        return "Verbes en -ere (réguliers)"
    return "Verbes irréguliers"


def categories_for_infinitives(infinitives: list[str]) -> dict[str, str | None]:
    return {infinitive: category_for_infinitive(infinitive) for infinitive in infinitives}
