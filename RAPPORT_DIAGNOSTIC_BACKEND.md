# Rapport de Diagnostic Backend : Problème de Sauvegarde des Scores

## 🔍 Analyse du Code Backend

Après examen approfondi du fichier `app/crud_users.py` et de la fonction `create_score`, nous avons constaté que :

1.  **Gestion des Transactions** : La création du score (`UserScore`) et la mise à jour des statistiques (`UserDeck`, `Card`, `User`) sont effectuées au sein de la même session de base de données. Le `db.commit()` est appelé une seule fois à la fin.
2.  **Mécanisme de Mise à Jour** :
    *   La mise à jour de `UserDeck` (statistiques du deck) est effectuée par le **code applicatif** (Python), et non par un Trigger SQL.
    *   Cette mise à jour est conditionnée par la présence de la carte (`if card:`) et du deck (`if score_data.deck_pk:`).
3.  **Intégrité des Données** :
    *   Si le `card_pk` envoyé n'existe pas en base, le code ignore la mise à jour des statistiques Anki et du Deck, mais tente quand même de créer le `UserScore`. Cependant, cela devrait provoquer une erreur de contrainte de clé étrangère (Foreign Key Error) lors du commit, sauf si la base de données est mal configurée.

## 🧪 Tentative de Reproduction

Nous avons créé un script de reproduction (`reproduce_issue.py`) simulant exactement le scénario décrit :
1.  Création d'un nouvel utilisateur.
2.  Soumission d'un score pour une carte du Deck 40 (sans ajout explicite du deck au préalable).
3.  Vérification de la persistance.

**Résultat** : ❌ **Impossible de reproduire le bug localement.**
Le score est bien enregistré, et les statistiques du deck sont mises à jour correctement (points, tentatives, etc.).

## 🛠 Actions Correctives et Améliorations Apportées

Pour faciliter le diagnostic sur votre environnement (où le bug se produit), nous avons modifié `app/crud_users.py` pour ajouter :

1.  **Logs Détaillés** :
    *   Trace de l'entrée dans la fonction avec les IDs reçus.
    *   Confirmation si la carte est trouvée ou non.
    *   Confirmation si le `UserDeck` est trouvé, créé ou mis à jour.
    *   Confirmation du succès du `commit`.
2.  **Gestion d'Erreurs Robuste** :
    *   Ajout d'un bloc `try-except` global.
    *   En cas d'erreur, un `db.rollback()` est explicitement appelé pour nettoyer la session.
    *   L'erreur exacte est loggée avant d'être renvoyée.

## 📋 Instructions pour l'Équipe Frontend / Test

Puisque le code semble correct logiquement mais échoue dans votre environnement, merci de suivre ces étapes avec la nouvelle version déployée :

1.  **Relancer le Test** qui pose problème.
2.  **Consulter les Logs du Serveur Backend**. Recherchez les lignes suivantes :
    *   `INFO:app.crud_users:create_score called for user X, deck Y, card Z`
    *   `INFO:app.crud_users:Card Z found...` ou `WARNING:app.crud_users:Card Z not found!`
    *   `INFO:app.crud_users:Transaction committed successfully.`
    *   `ERROR:app.crud_users:Error in create_score: ...`

### Pistes Probables à Vérifier :
1.  **ID de Carte Incorrect** : Si les logs affichent `Card ... not found`, cela signifie que le `card_pk` envoyé par le front ne correspond à aucune carte en base. Le score ne sera pas sauvegardé correctement (ou échouera silencieusement si les FK sont désactivées).
2.  **Incohérence Deck/Carte** : Vérifiez que le `deck_pk` envoyé correspond bien au deck auquel appartient la carte.
3.  **Erreur Silencieuse** : Si vous voyez `Error in create_score`, le message d'erreur nous donnera la cause exacte (ex: violation de contrainte unique, problème de type, etc.).

Le backend est maintenant instrumenté pour vous dire exactement pourquoi il refuse de sauvegarder les données.

---

## 💻 Guide d'Implémentation Frontend (Protocole de Test)

Pour garantir que le frontend communique correctement avec le backend, voici le protocole exact à suivre pour le scénario de test, avec les spécifications techniques des endpoints.

### Étape 1 : Authentification (Login)
Avant toute action, assurez-vous d'avoir un token JWT valide.

*   **Endpoint** : `POST /api/users/login`
*   **Content-Type** : `application/json`
*   **Payload** :
    ```json
    {
      "email": "votre_email@example.com",
      "password": "votre_mot_de_passe"
    }
    ```
*   **Réponse Attendue (200 OK)** :
    ```json
    {
      "access_token": "eyJhbGciOiJIUzI1...",
      "token_type": "bearer",
      "user": { ... }
    }
    ```
*   **Action Frontend** : Stocker `access_token` et l'ajouter dans le header `Authorization: Bearer <token>` pour toutes les requêtes suivantes.

### Étape 2 : Récupération des Cartes (Optionnel mais recommandé)
Pour être sûr d'envoyer des IDs valides, récupérez d'abord les cartes du deck.

*   **Endpoint** : `GET /cards/?deck_pk=40` (exemple pour le deck 40)
*   **Header** : `Authorization: Bearer <token>`
*   **Réponse Attendue (200 OK)** : Liste d'objets `Card`.
*   **Action Frontend** : Utiliser le `card_pk` réel retourné par cette route pour la soumission des scores. **Ne pas utiliser d'IDs codés en dur.**

### Étape 3 : Soumission du Score (Action Critique)
C'est ici que le problème est suspecté. Assurez-vous que le payload respecte **strictement** ce format.

*   **Endpoint** : `POST /api/users/scores`
*   **Header** : `Authorization: Bearer <token>`
*   **Content-Type** : `application/json`
*   **Payload (Exemple Complet)** :
    ```json
    {
      "deck_pk": 40,
      "card_pk": 974,
      "score": 100,
      "is_correct": true,
      "time_spent": 5,
      "quiz_type": "frappe"
    }
    ```
    *   **Détails des champs** :
        *   `deck_pk` (Integer, Requis) : L'ID du deck en cours.
        *   `card_pk` (Integer, Requis) : L'ID **réel** de la carte en base de données.
        *   `score` (Integer, Requis) : Valeur entre 0 et 100.
        *   `is_correct` (Boolean, Requis) : `true` ou `false`.
        *   `time_spent` (Integer, Optionnel) : Temps en secondes.
        *   `quiz_type` (String, Requis) : Valeurs acceptées : `"frappe"`, `"association"`, `"qcm"`, `"classique"`.

*   **Réponse Attendue (201 Created)** :
    ```json
    {
      "score_pk": 123,
      "user_pk": 45,
      "deck_pk": 40,
      "card_pk": 974,
      "score": 100,
      "quiz_type": "frappe",
      "created_at": "2025-11-24T..."
    }
    ```

### Étape 4 : Vérification des Statistiques (Dashboard)
Pour vérifier que les données sont bien persistées et agrégées.

*   **Endpoint** : `GET /api/users/decks`
*   **Header** : `Authorization: Bearer <token>`
*   **Réponse Attendue (200 OK)** : Liste des decks de l'utilisateur.
*   **Vérification** :
    *   Trouver l'objet correspondant au `deck_pk` 40.
    *   Vérifier que `total_points` a augmenté.
    *   Vérifier que `total_attempts` a augmenté.
    *   Vérifier que `points_frappe` (si quiz_type="frappe") a augmenté.

### Résumé des Points de Vigilance Frontend
1.  **IDs Dynamiques** : Assurez-vous que `card_pk` provient bien de l'API (`GET /cards`) et n'est pas une valeur mockée ou obsolète.
2.  **Types de Données** : `score` et `deck_pk` doivent être des entiers (pas de chaînes de caractères "100").
3.  **Enum Quiz Type** : La valeur de `quiz_type` est sensible à la casse ("frappe" est valide, "Frappe" peut être rejeté ou mal traité).
