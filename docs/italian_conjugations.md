# Module autonome de conjugaison italienne

Le module `italian-conjugations` stocke et sert les conjugaisons directement depuis Neon. Une fois le corpus importé, l’application ne sollicite **ni Gemini ni une API de conjugaison externe**.

## Corpus et attribution

Le corpus versionné dans `data/coniugazione/verbi.json` provient du dépôt [leandrobhbr/coniugazione](https://github.com/leandrobhbr/coniugazione), sous licence [MIT](https://github.com/leandrobhbr/coniugazione/blob/master/LICENSE). Le fichier de licence source est conservé sous `data/coniugazione/LICENSE.MIT`.

Le corpus contient 523 infinitifs distincts, 10 752 blocs de conjugaison source et les modes `Indicativo`, `Congiuntivo`, `Condizionale`, `Imperativo`, `Infinito`, `Participio` et `Gerundio`. Les entrées sans mode ou sans forme italienne sont ignorées au cours de l’import ; les doublons sont fusionnés par infinitif, mode et temps.

## Modèle de données

| Table | Rôle |
|---|---|
| `italian_verbs` | Un infinitif normalisé, avec son attribution de source. |
| `italian_conjugations` | Un bloc par combinaison **verbe + mode + temps**. |
| `italian_conjugation_forms` | Les formes individuelles, indexées pour la recherche. |

Les tables sont indépendantes des flashcards afin de pouvoir servir les exercices de conjugaison, le dictionnaire et les écrans de révision sans dupliquer les données.

## Endpoints de lecture

| Méthode | Route | Usage |
|---|---|---|
| `GET` | `/italian-conjugations/metadata` | Modes et temps disponibles pour les filtres. |
| `GET` | `/italian-conjugations/verbs` | Liste paginée, recherche par infinitif, filtres `mood` et `tense`. |
| `GET` | `/italian-conjugations/verbs/{infinitive}` | Tous les modes, temps et personnes d’un verbe. |
| `GET` | `/italian-conjugations/search?query=...` | Recherche par forme conjuguée ou infinitif. |

## Endpoints d’administration

Les opérations d’écriture nécessitent un jeton utilisateur actif, comme les autres opérations authentifiées du backend.

| Méthode | Route | Usage |
|---|---|---|
| `POST` | `/italian-conjugations/verbs` | Ajout manuel d’un verbe et de ses blocs. |
| `PUT` | `/italian-conjugations/verbs/{infinitive}` | Mise à jour d’un infinitif et remplacement facultatif de ses blocs. |
| `DELETE` | `/italian-conjugations/verbs/{infinitive}` | Suppression d’un verbe et de ses formes. |
| `POST` | `/italian-conjugations/admin/import` | Réimport idempotent du corpus local versionné. |

## Import local

Après application de la migration Alembic, l’import peut être lancé une fois par l’endpoint d’administration ou par le script :

```bash
DATABASE_URL=... python scripts/import_italian_conjugations.py
```

L’import est idempotent : il met à jour les verbes et blocs présents dans le corpus, puis remplace leurs formes importées sans appeler de service extérieur.
