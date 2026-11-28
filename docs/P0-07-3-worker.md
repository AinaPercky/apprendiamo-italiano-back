# P0-07.3 — Réplication planifiée, supervision et reprise

## Architecture

- Le backend FastAPI reste hébergé sur Vercel.
- `POST /internal/sync/reconcile` déclenche un seul cycle `reconcile_once()`.
- Chaque cycle traite au maximum `SYNC_BATCH_SIZE` événements par direction (défaut 100, plafond 500).
- La réservation existante utilise les leases et `FOR UPDATE SKIP LOCKED`. Les reçus idempotents et la quarantaine des conflits restent les mécanismes de sécurité de la réplication.
- GitHub Actions déclenche le cycle toutes les cinq minutes. Le workflow est également exécutable manuellement.

Le worker périodique du lifespan FastAPI est conservé pendant la transition. Il ne constitue pas une garantie de traitement continu sur une plateforme serverless ; le scheduler externe est le mécanisme planifié attendu une fois configuré et validé.

## Configuration du secret

### Vercel — environnement Production du backend

Définir `SYNC_CRON_SECRET` dans l'environnement Production du projet backend. Générer une valeur aléatoire forte d'au moins 32 octets d'entropie. Ne jamais la placer dans le code, un fichier versionné ou un log.

### GitHub — secret du dépôt

Dans les paramètres du dépôt → **Secrets and variables** → **Actions**, créer un seul **repository secret** :

- `SYNC_CRON_SECRET` : exactement la même valeur que celle configurée dans Vercel.

Aucune variable GitHub n'est nécessaire : l'URL de production est l'alias stable `https://apprendiamo-italiano-backend.vercel.app/internal/sync/reconcile`, défini dans `.github/workflows/sync-replication-scheduler.yml`.

Ne pas lancer le workflow avant que le secret soit configuré des deux côtés. Le backend refuse les appels si le secret est absent ou incorrect.

## Contrôles de fonctionnement

1. Lancer manuellement le workflow depuis Actions après configuration.
2. Vérifier que le job termine en succès et que l'endpoint retourne `status=completed`.
3. Vérifier `/health/db` : `neon=up`, `supabase=up`, `dual_write=true`.
4. Observer `pending_events.neon` et `pending_events.supabase` sur plusieurs cycles. Ces compteurs sont plafonnés à 1 000 éléments par base dans le health endpoint existant ; ils ne constituent pas un total exact au-delà de ce plafond.
5. Observer l'historique Actions pour contrôler la régularité des déclenchements. Le planificateur GitHub est best-effort : un déclenchement peut être retardé.
6. Pour une validation fonctionnelle, utiliser les tests PostgreSQL indépendants existants dans `tests/test_sync_replication_integration.py`. Ne pas utiliser de données pédagogiques de production comme données de test.

## Diagnostic rapide

| Signal | Interprétation / action |
| --- | --- |
| HTTP 401 | Secret absent de l'en-tête ou différent entre GitHub et Vercel ; comparer la configuration sans afficher la valeur |
| HTTP 503 avant le cycle | Une base n'est pas disponible ; contrôler `/health/db` et les connexions |
| HTTP 503 après le cycle | La santé des bases s'est dégradée pendant le cycle ; vérifier la disponibilité avant de relancer |
| Job GitHub en échec | Examiner le code HTTP et le journal du job ; ne jamais activer le mode shell debug avec des secrets |
| Compteurs pending qui stagnent | Contrôler l'historique Actions, les statuts `pending/processing/quarantined`, les leases et les erreurs de classe dans `sync_outbox` |
| Événements quarantined | Ne pas les supprimer ni les rejouer en masse ; inspecter le conflit et préserver les deux versions avant résolution |

## Retour arrière

- Désactiver le workflow `Scheduled Neon Supabase replication` dans GitHub Actions.
- L'endpoint interne peut rester déployé mais ne sera plus appelé par le scheduler.
- Ne supprimer aucun événement, reçu, conflit ou ligne métier.
- Ne pas modifier les leases ou remettre les événements en `pending` sans diagnostic.
- Le worker du lifespan n'est pas supprimé dans cette étape ; aucun basculement destructif n'est requis.

## Périmètre et limites

- Aucune migration SQL n'est requise par cette étape.
- Aucune modification des données Neon ou Supabase.
- La création de cette documentation et des tests n'effectue aucun appel à l'endpoint de production.
- GitHub Actions schedule n'est pas un SLA temps réel. Le quota d'exécution dépend de la visibilité et des paramètres du dépôt.
