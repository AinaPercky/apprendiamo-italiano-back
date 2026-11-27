# Documentation de l'Authentification

## Vue d'ensemble

Le système d'authentification supporte deux méthodes :

1. **Authentification Standard** : Email + Mot de passe
2. **Authentification Google OAuth** : Via compte Google

Tous les endpoints sécurisés utilisent des tokens JWT (JSON Web Tokens) pour l'authentification.

## Configuration

### Variables d'environnement requises

\`\`\`bash
SECRET_KEY=your-long-random-secret
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
\`\`\`

SECRET_KEY est obligatoire : le backend refuse de démarrer si la variable est absente ou vide. Utilisez une valeur aléatoire longue, stockée uniquement dans l'environnement du serveur ou dans .env.local. Ne la commitez jamais.

**Important pour une mise à jour sans déconnexion massive :** les nouveaux access tokens portent le claim type=access. Les access tokens historiques sans claim type restent acceptés pendant leur durée de vie résiduelle. Les refresh tokens portant type=refresh sont refusés sur les endpoints protégés. Ne faites pas tourner SECRET_KEY pendant ce déploiement : cette clé signe également les liens QR publics.

## Endpoints d'authentification

- POST /api/users/register : création de compte et émission d'un access token.
- POST /api/users/login : connexion email/mot de passe.
- POST /api/users/google-login : connexion Google (le contrat de vérification Google sera traité dans la PR P0-02).
- POST /api/users/logout : déconnexion côté client, par suppression du token.

Les access tokens ont une durée de vie de 30 minutes. Les refresh tokens sont prévus pour une durée de 7 jours, mais cette PR ne crée pas de route de renouvellement.

## Utilisation

Les endpoints protégés attendent :

\`\`\`http
Authorization: Bearer <access_token>
\`\`\`

Les erreurs de token invalide, expiré ou de type non autorisé retournent HTTP 401.
