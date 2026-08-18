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
)

# Verbes dont le radical, l’auxiliaire ou les formes principales ne suivent pas
# le modèle régulier de leur terminaison. Les réflexifs héritent de cette liste.
IRREGULAR_VERBS = frozenset(
    {
        "andare", "avere", "bere", "dare", "dire", "dovere", "essere", "fare",
        "morire", "porre", "potere", "rimanere", "salire", "sapere", "scegliere",
        "pentire", "accorgere", "offrire", "aprire", "coprire", "soffrire",
        "sedere", "stare", "tenere", "trarre", "uscire", "venire", "volere",
        "vedere", "vivere", "condurre", "produrre", "tradurre", "ridurre",
        "cogliere", "togliere", "raccogliere", "piacere", "nascere", "conoscere",
        "crescere", "scendere", "spegnere", "muovere", "nuocere", "valere",
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
                    "scendere", "restare", "rientrare", "trasferire", "viaggiare",
                }
            ),
        ),
        (
            "Communication",
            frozenset(
                {
                    "dire", "parlare", "chiamare", "rispondere", "domandare", "chiedere",
                    "comunicare", "raccontare", "spiegare", "ascoltare", "leggere",
                    "scrivere", "discutere", "contattare", "conversare", "annunciare",
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
                    "fermare", "truccare", "sistemare", "laureare",
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
                    "accorgere", "iscrivere", "divertire", "sentire", "sedere", "ricordare",
                    "arrabbiare", "vergognare", "occupare", "preoccupare",
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
    """Classify an infinitive by regular ending or known irregular behavior."""
    base = base_infinitive(infinitive)
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
