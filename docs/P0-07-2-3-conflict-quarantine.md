# P0-07.2.3 — Détection et quarantaine des conflits

## Règle de cohérence
Aucune base n'est prioritaire. Quand Neon et Supabase possèdent encore des événements non appliqués pour la même table et la même clé primaire, les deux événements sont considérés comme concurrents.

## Détection
Avant tout rejeu d'un événement :
- recherche dans l'outbox cible des événements de l'autre source pour la même table et le même `pk_json` ;
- les états `pending` et `processing` sont considérés comme concurrents ;
- un événement déjà placé en quarantaine pour conflit reste un signal de conflit en cas de reprise après commit partiel.

Cette détection s'appuie sur le fonctionnement actuel du backend : il choisit Neon lorsqu'il est disponible et bascule sur Supabase uniquement lorsque Neon est indisponible. Les écritures de bascule restent donc en attente sur Supabase jusqu'à la reprise de Neon.

## Quarantaine
- Aucun des deux événements n'est appliqué à l'autre base.
- Les deux lignes d'outbox passent à `quarantined`.
- Les leases sont libérés.
- `last_error` ne contient qu'une raison générique, sans payload.
- Un identifiant de conflit UUIDv5 déterministe référence les deux événements.
- Un registre `sync_conflicts` est écrit dans les deux bases. Les payloads restent dans les outboxes originales, sans duplication.
- La clé déterministe rend les reprises idempotentes si un commit sur une base réussit et que l'autre doit être repris.

## Sécurité
`sync_conflicts` est une table interne avec RLS activé. Les rôles publics `PUBLIC`, `anon` et `authenticated` n'ont aucun accès. Les payloads ne sont pas recopiés dans le registre et ne sont jamais journalisés.

## Limites connues
- La détection cible les événements concurrents simultanément en attente/traitement, ce qui correspond au mécanisme de bascule Neon/Supabase actuel.
- Les modifications effectuées directement par un opérateur SQL ou par un client qui contourne le backend/outbox ne sont pas détectables par ce mécanisme.
- La résolution manuelle des conflits et l'interface d'administration sont hors périmètre.
- Le worker durable hors cycle de vie serverless reste P0-07.3.

## Migration
La migration additive `p007_sync_conflicts` crée le registre protégé. Aucun contenu pédagogique ou événement existant n'est supprimé.

## Retour arrière
1. Suspendre les workers et les écritures dual-write.
2. Exporter les conflits ouverts et les événements en quarantaine.
3. Revenir au code précédent.
4. Supprimer `sync_conflicts` seulement après vérification de l'export.
