# P0-07.2.1 — Rejeu idempotent de l'outbox

## Objectif
Garantir qu'un événement métier ne soit appliqué qu'une seule fois sur la base cible, même si la transaction cible est validée mais que l'accusé de réception de la base source est perdu.

## Mécanisme
- Chaque événement possède un `event_id` unique.
- La base cible enregistre cet identifiant dans `sync_event_receipts`.
- L'insertion du reçu et l'écriture métier sont exécutées dans la même transaction cible.
- La clé primaire de `sync_event_receipts` sérialise les livraisons concurrentes du même événement.
- Si un reçu existe déjà, le rejeu devient un no-op.
- Les opérations upsert utilisent `INSERT ... ON CONFLICT DO UPDATE` au lieu du couple UPDATE puis INSERT, ce qui évite la course à l'insertion concurrente.
- Les événements dont la clé primaire du payload ne correspond pas à `pk_json` sont refusés.

## Migration
La migration `p007_sync_event_receipts` ajoute uniquement une table interne sans modifier les lignes métier existantes. Elle doit être appliquée sur Neon et Supabase avant le déploiement du code qui l'utilise.

## Transaction et reprise
Le reçu est atomique avec la mutation métier sur la base cible. L'accusé de réception source reste dans une transaction distincte. En cas d'échec de cet accusé, la prochaine livraison retrouve le reçu et ne réapplique pas la mutation.

## Limites
- Cette étape ne résout pas encore les conflits entre deux modifications métier concurrentes provenant de bases différentes.
- La réservation concurrente, les leases, le backoff et la quarantaine seront ajoutés en P0-07.2.2.
- Le worker serverless durable reste P0-07.3.
- Aucun payload ni secret ne doit être ajouté aux logs.

## Retour arrière
1. Arrêter le worker et suspendre les écritures dual-write.
2. Vérifier que les événements pending/processing sont drainés ou sauvegardés.
3. Revenir au code précédent.
4. Supprimer `sync_event_receipts` uniquement après avoir confirmé qu'aucune version applicative ne l'utilise.
