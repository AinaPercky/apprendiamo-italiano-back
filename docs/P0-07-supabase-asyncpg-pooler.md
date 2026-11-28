# Diagnostic P0-07 — Connexion Supabase / asyncpg

## Symptôme observé
Le contrôle `/health/db` a alterné entre `supabase=up` et `supabase=down` sur la même version de production. Les logs PostgreSQL Supabase contenaient les erreurs :
- `prepared statement "__asyncpg_stmt_…" already exists`
- `prepared statement "__asyncpg_stmt_…" does not exist`

Le fichier `.env.production.example` confirme que le miroir Supabase est prévu via le pooler partagé Supavisor en mode transaction (port 6543). Le backend utilise SQLAlchemy 2.0 + asyncpg.

## Cause technique
Le mode transaction réaffecte une connexion serveur après chaque transaction. L'état de session et les prepared statements nommés ne sont donc pas garantis entre deux transactions. Le cache asyncpg/SQLAlchemy combiné au pooler peut produire des collisions ou des prepared statements absents. Un simple `SELECT 1` peut réussir alors qu'une opération applicative ultérieure échoue.

Références :
- Supabase — transaction mode : prepared statements désactivés ; asyncpg `statement_cache_size=0`.
- Supabase — SQLAlchemy en environnement serverless : `NullPool`.
- SQLAlchemy — cache asyncpg configurable par `prepared_statement_cache_size`.

## Correction proposée
Détecter le pooler Supabase transaction uniquement lorsque l'hôte se termine par `.pooler.supabase.com` et que le port est 6543, puis :
- désactiver le cache asyncpg (`statement_cache_size=0`) ;
- désactiver le cache prepared statement du dialecte SQLAlchemy (`prepared_statement_cache_size=0`) ;
- utiliser `NullPool` pour ne pas conserver de connexions locales réutilisables entre invocations serverless.

Les connexions Neon ne sont pas modifiées. Aucun secret ni aucune valeur d'environnement n'est changé.

## Validation après déploiement
- Vérifier plusieurs appels santé successifs.
- Exécuter des lectures et écritures isolées via le chemin applicatif dual-write.
- Confirmer l'absence de nouvelles erreurs prepared statement dans les logs Supabase.
- Effectuer un test de réplication contrôlé dans les deux sens et nettoyer les seules lignes techniques créées.
- Ne commencer P0-07.2.3 qu'après ces validations.

## Retour arrière
Réversion du commit applicatif et redéploiement de la version précédente. Aucun changement de schéma ni de donnée n'est requis par ce correctif.
