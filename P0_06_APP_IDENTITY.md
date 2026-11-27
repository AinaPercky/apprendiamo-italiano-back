# P0-06 — Identité applicative du Studio (PKCE)

## Flux
1. L'authentification existante (mot de passe ou Google) produit un jeton utilisateur transitoire.
2. Le Studio crée un vérificateur PKCE aléatoire, son challenge S256 et un state aléatoire conservé en sessionStorage.
3. Le navigateur soumet un formulaire POST vers `/api/oauth/authorize`. Le jeton transitoire est placé dans le corps du formulaire, jamais dans l'URL.
4. Le backend valide le jeton, l'origine réelle du navigateur, le client actif et l'URI de callback exacte enregistrée.
5. Le backend persiste uniquement le SHA-256 du code, lié à l'utilisateur, au client, à l'URI et au challenge PKCE. Le code expire après 90 secondes et ne peut être consommé qu'une fois.
6. Le backend redirige le navigateur vers le callback exact du Studio avec `code` et `state`.
7. Le callback compare le state, puis échange le code et le vérificateur sur `/api/oauth/token`.
8. Le JWT délivré contient `aud=studio`, `client_app=studio` et `token_use=app_access`.

## Protection des routes
Lorsque `REQUIRE_STUDIO_APP_TOKEN=true`, les routes de quiz, les routes d'activité utilisateur et les opérations réservées aux professeurs/administrateurs exigent ce JWT applicatif. Tant que le drapeau est absent ou vaut `false`, les anciens jetons restent temporairement acceptés sur ces routes afin de permettre un déploiement sans interruption.

## Registre et migration
La migration `p006_app_identity_oauth` :
- ajoute `allowed_redirect_uris` au registre des applications ;
- crée `oauth_authorization_codes` avec stockage du hash, expiration et consommation ;
- enregistre le Studio avec les origines et callbacks de production et de développement vérifiés.

Cette migration dépend de `p006_user_card_progress`, lui-même dépendant de `add_client_applications_registry`. Elle n'est pas exécutée par cette PR.

## Limites et sécurité
- Le client ID et `X-Client-App` ne sont pas des secrets.
- L'origine navigateur et CORS protègent le parcours SPA contre les requêtes inter-sites, mais ne constituent pas une authentification serveur-à-serveur.
- Les applications mobiles et serveurs nécessiteront des profils d'identité adaptés ; aucune identité ne leur est accordée par ce flux.
- Les URL Vercel Preview non listées ne sont pas autorisées. Utiliser le domaine de production stable ou ajouter explicitement un callback validé via le registre.
- Après activation de `REQUIRE_STUDIO_APP_TOKEN=true`, les jetons génériques existants peuvent toujours consulter les routes de profil et les lectures de contenu non personnalisé, mais ne peuvent plus enregistrer ou lire les activités réservées au Studio.

## Déploiement progressif sans interruption
1. Fusionner les PR backend et Studio après revue.
2. Sauvegarder Neon puis appliquer les migrations dans l'ordre : `add_client_applications_registry`, `p006_user_card_progress`, `p006_app_identity_oauth`.
3. Déployer le backend avec `REQUIRE_STUDIO_APP_TOKEN=false` (ou absent) : les nouveaux endpoints OAuth sont disponibles et les anciens jetons restent temporairement acceptés.
4. Déployer le Studio PKCE et vérifier les connexions email, Google, les anciens jetons, les quiz et les progressions.
5. Activer `REQUIRE_STUDIO_APP_TOKEN=true` dans l'environnement backend puis redéployer. À partir de là, les routes d'activité refusent les jetons génériques.

Ne pas activer l'étape 5 avant validation du Studio en production. Prévoir un backup Neon et une procédure de retour arrière. Aucun changement Neon/Supabase, variable d'environnement ni déploiement n'est réalisé par cette PR.
