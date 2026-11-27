# P0-06 — Isolation des activités et progressions

## Décision d'architecture

- Neon reste la base centrale des contenus pédagogiques et des activités du Studio.
- Les activités et progressions de PerckyLingua, du jeu de l'oie et des autres clients restent dans leurs bases respectives.
- Les applications clientes consomment le contenu pédagogique central en lecture seule ; elles ne doivent pas enregistrer leurs propres résultats dans les tables d'activité du Studio.
- Aucun champ `client_app_code` n'est ajouté aux tables d'activité de Neon : la séparation retenue est une séparation de bases, et non un simple étiquetage de lignes.
- `X-Client-App` reste un identifiant public et ne constitue pas une authentification serveur-à-serveur.

## Correction incluse

Les champs Anki `easiness`, `interval`, `consecutive_correct`, `next_review` et `box` étaient enregistrés sur `cards`, alors que les réponses appartiennent à un utilisateur. Les opérations de quiz modifiaient donc un état partagé entre apprenants.

P0-06 déplace cet état dans `card_performance`, qui possède déjà `user_pk`, `card_pk` et `deck_pk`. Une contrainte unique `(user_pk, card_pk)` garantit un seul état Anki par utilisateur et carte.

Les opérations de quiz et de score mettent à jour cet état individuel. La sélection adaptative et les statistiques de maîtrise lisent désormais les colonnes individuelles.

Les anciennes colonnes Anki de `cards` sont conservées pour compatibilité avec les anciens contrats et outils Studio, mais le flux de quiz ne doit plus les modifier ni les utiliser pour la progression d'un apprenant.

## Limite de sécurité applicative à traiter

Cette PR corrige l'état Anki partagé et fixe la frontière de stockage visée, mais elle ne met pas encore en place une authentification applicative forte pour les routes d'activité existantes.

Aujourd'hui, ces routes reposent sur le JWT utilisateur. `X-Client-App` est optionnel et public ; il ne prouve pas l'identité d'un serveur ou d'une application. Il ne faut donc pas le considérer comme une barrière empêchant à lui seul une autre application d'appeler les routes d'activité du Studio.

Règle opérationnelle jusqu'au chantier complémentaire : seul le Studio doit appeler les routes d'activité de ce backend ; les autres applications doivent écrire dans leurs propres bases via leurs propres backends. Avant d'autoriser des clients externes à appeler les routes d'activité centrales, il faudra ajouter une authentification applicative vérifiable côté serveur (par exemple un BFF ou des jetons à audience/app scope), puis couvrir cette règle par des tests d'accès inter-applications.

## Migration

Révision Alembic : `p006_user_card_progress`

Dépendance : `add_client_applications_registry` (migration P0-05).

La migration :
1. vérifie qu'il n'existe pas de doublon `(user_pk, card_pk)` ;
2. ajoute les cinq colonnes individuelles à `card_performance` ;
3. ajoute la contrainte unique.

Elle ne supprime aucune colonne, ne supprime aucune ligne et ne modifie aucune donnée dans Neon lors de la création du PR. Les valeurs Anki individuelles existantes sont initialisées avec des valeurs neutres : facilité 2.5, intervalle 0, répétitions consécutives 0, boîte 0 et prochaine révision à l'heure de migration.

Il est impossible de reconstituer exactement les anciennes valeurs individuelles à partir de `cards`, car elles étaient globales et écrasées par les réponses successives de différents utilisateurs. Elles ne sont donc pas copiées arbitrairement.

## Compatibilité et limites

- Les identifiants de cartes, decks, utilisateurs, sessions et performances restent inchangés.
- Les compteurs de réponses existants (`correct_count`, `incorrect_count`, `total_attempts`) sont conservés.
- Les statistiques de maîtrise historiques dans `user_decks` ne sont pas réécrites par cette migration.
- Les comptes restent inchangés.
- Aucune activité n'est déplacée entre Neon et la base PerckyLingua.
- La migration P0-05 doit être appliquée avant P0-06 ; elle n'est pas exécutée par ce PR.

## Retour arrière

Le downgrade supprime la contrainte et les cinq colonnes ajoutées. Toute progression Anki individuelle enregistrée après l'application de la migration serait perdue lors d'un downgrade. Avant tout retour arrière en production, sauvegarder la base et exporter les colonnes individuelles. Les anciennes colonnes globales de `cards` ne permettent pas de restaurer fidèlement ces données.

## Contrôles

Le workflow de sécurité exécute `test_p0_06_user_progress.py` en plus des tests P0-01 à P0-05.
