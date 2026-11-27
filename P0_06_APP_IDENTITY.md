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
Les routes de quiz et les routes d'activité utilisateur du Studio exigent désormais ce JWT applicatif. Les routes générales de profil restent compatibles avec les anciens jetons pendant la transition. Les permissions de gestion et les opérations réservées aux professeurs/administrateurs exigent aussi un jeton Studio.

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
- Les jetons génériques existants peuvent toujours consulter les routes de profil, mais ne peuvent plus enregistrer ou lire les activités réservées au Studio.

## Déploiement
Ne pas appliquer la migration avant que la PR backend et la PR Studio soient intégrées et que les callbacks/origines de production aient été confirmés. Prévoir un backup Neon. Aucun changement Neon/Supabase ni déploiement n'est réalisé par cette PR.
