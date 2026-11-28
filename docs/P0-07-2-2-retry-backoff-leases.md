# P0-07.2.2 — Reprise, leases et backoff

## Contrat
- Les événements passent par les états `pending`, `processing`, `applied` ou `quarantined`.
- Un worker réserve un lot dans une transaction avec `FOR UPDATE SKIP LOCKED`, puis marque chaque événement `processing` avec un lease (`locked_at`, `locked_by`).
- Un worker concurrent ne peut pas réserver les mêmes lignes pendant la transaction de réservation.
- Un lease expiré est remis à `pending` afin de récupérer les événements abandonnés après crash.
- Un événement en échec incrémente `attempts`, stocke uniquement la classe de l'exception, libère le lease et reçoit une nouvelle échéance `available_at`.
- Le délai suit un backoff exponentiel avec jitter et plafond.
- Après `SYNC_MAX_ATTEMPTS` tentatives, l'événement passe en quarantaine. Il n'est pas supprimé.

## Paramètres
- `SYNC_EVENT_LEASE_SECONDS` : 120 s par défaut (minimum 30 s).
- `SYNC_BATCH_SIZE` : 100 événements (plafond 500).
- `SYNC_MAX_ATTEMPTS` : 10 tentatives.
- Backoff : base 5 s, double à chaque échec, plafond 1 h, jitter ±20 %.

## Migration
`p007_sync_outbox_retry` ajoute `available_at`, `locked_at`, `locked_by` et un index de réservation. Les événements existants reçoivent une échéance égale à leur `created_at`; aucun événement ni payload n'est supprimé.

## Sécurité et exploitation
Les payloads ne sont jamais inclus dans les logs. Le rôle d'exploitation doit pouvoir consulter et traiter les événements en quarantaine via un canal interne, jamais via une route publique.

## Limites
- La quarantaine est une décision après un nombre borné de tentatives ; l'interface de résolution manuelle est hors scope.
- Les conflits métier entre deux sources ne sont pas arbitrés ici et seront traités dans P0-07.2.3.
- Le worker hors serverless reste P0-07.3.

## Retour arrière
1. Suspendre les workers et les écritures dual-write.
2. Exporter/traiter les événements `pending`, `processing` et `quarantined`.
3. Revenir au code précédent.
4. Supprimer les colonnes de lease uniquement après vérification qu'aucun worker ne les lit.
