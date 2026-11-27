# Registre des applications clientes

Le registre permet au backend d'identifier explicitement les applications qui consomment l'API centrale.

## Principes de sécurité

- `X-Client-App` contient un code public et stable, jamais une clé secrète.
- L'identifiant ne prouve pas l'authenticité du client et ne confère aucun droit. Il sert uniquement à identifier le client déclaré et à contrôler son origine.
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

## Identité applicative du Studio

Le Studio utilise désormais un flux Authorization Code avec PKCE S256 :
- URI de callback exacte enregistrée dans `allowed_redirect_uris` ;
- codes aléatoires à usage unique, expirant après 90 secondes, dont seul le hash est stocké ;
- jetons d'accès signés avec `aud=studio`, `client_app=studio` et `token_use=app_access` ;
- les routes de quiz, de progression et les opérations réservées au Studio exigent ce jeton applicatif lorsque `REQUIRE_STUDIO_APP_TOKEN=true`. Ce drapeau est désactivé par défaut pour permettre le déploiement coordonné sans interruption.

Le flux PKCE ne vaut que pour le client web Studio enregistré. Il ne fournit pas encore de mécanisme d'authentification serveur-à-serveur ni d'identité native mobile. Les autres applications ne doivent pas réutiliser l'identité Studio : chacune devra avoir son propre flux et ses propres règles de stockage d'activités.
