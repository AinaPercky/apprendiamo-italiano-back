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


def category_for_infinitive(infinitive: str) -> str | None:
    """Return the frontend category for an infinitive, if classified."""
    normalized = infinitive.strip().casefold()
    direct = _BASE_TO_CATEGORY.get(normalized)
    if direct:
        return direct

    # Corpus reflexive infinitives end in -rsi (alzarsi, pentirsi, accorgersi).
    if normalized.endswith("rsi"):
        base = f"{normalized[:-3]}re"
        return _BASE_TO_CATEGORY.get(base)
    return None


def categories_for_infinitives(infinitives: list[str]) -> dict[str, str | None]:
    return {infinitive: category_for_infinitive(infinitive) for infinitive in infinitives}
