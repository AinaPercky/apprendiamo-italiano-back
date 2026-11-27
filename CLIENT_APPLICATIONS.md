# Registre des applications clientes

Le registre permet au backend d'identifier explicitement les applications qui consomment l'API centrale.

## Principes de sécurité

- `X-Client-App` contient un code public et stable, jamais une clé secrète.
- L'identifiant ne prouve pas l'authenticité du client et ne confère aucun droit.
- Les permissions restent celles de l'utilisateur authentifié et des règles de ressource/abonnement.
- Une application web enregistrée doit présenter une origine autorisée.
- L'absence de `X-Client-App` reste acceptée pendant la transition afin de préserver les anciens frontends.
- Une application mobile ou un serveur ne doit pas embarquer de secret serveur. Les futurs échanges serveur-à-serveur nécessiteront un mécanisme dédié et des credentials conservés côté serveur.

## Administration

Toutes les routes sont réservées aux administrateurs :

- `GET /api/admin/client-applications` : lister les applications.
- `POST /api/admin/client-applications` : enregistrer une application.
- `PATCH /api/admin/client-applications/{code}` : désactiver/réactiver ou modifier les origines.

Exemple d'enregistrement :

```json
{
  "code": "perckyl-ingua",
  "name": "PerckyLingua",
  "client_type": "public_web",
  "description": "Application cliente de quiz et progression",
  "allowed_origins": ["https://perckyl-ingua.example"]
}
```

Les origines sont des origines complètes sans chemin. Les applications web doivent utiliser HTTPS en production.

## Utilisation côté client

Une application enregistrée peut envoyer `X-Client-App: perckyl-ingua` avec ses requêtes authentifiées. Le backend vérifie l'existence, l'activation et, pour les clients web, l'origine. Les anciennes applications peuvent continuer à ne pas envoyer cet en-tête.

## Limites de cette première étape

Ce registre n'implémente pas encore OAuth 2.0 client credentials, les scopes applicatifs, ni l'isolation des activités par application. Il prépare une identité applicative vérifiable au niveau de la configuration sans transformer un identifiant public en secret. Ces mécanismes seront définis séparément avant d'accorder des droits serveur-à-serveur.
