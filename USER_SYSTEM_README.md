# Système de Gestion des Utilisateurs - Documentation

## Résumé des modifications

Ce document décrit les nouvelles fonctionnalités ajoutées au backend Apprendiamo Italiano pour la gestion complète des utilisateurs, l'authentification sécurisée et la gestion des données utilisateur.

---

## Nouvelles Tables de Base de Données

### 1. **users** - Table principale des utilisateurs

Stocke les informations de base et les statistiques des utilisateurs.

| Colonne | Type | Description |
|---------|------|-------------|
| user_pk | Integer (PK) | Identifiant unique |
| email | String (Unique) | Email de l'utilisateur |
| username | String (Unique) | Nom d'utilisateur unique |
| hashed_password | String | Mot de passe haché (nullable pour Google) |
| google_id | String (Unique) | ID Google (nullable) |
| google_email | String | Email Google (nullable) |
| google_picture | String | URL de la photo Google (nullable) |
| first_name | String | Prénom |
| last_name | String | Nom de famille |
| profile_picture | String | URL de la photo de profil |
| bio | Text | Biographie/Description |
| is_active | Boolean | Statut du compte |
| is_verified | Boolean | Vérification email |
| verification_token | String | Token de vérification |
| total_score | Integer | Score total accumulé |
| total_cards_learned | Integer | Nombre de cartes apprises |
| total_cards_reviewed | Integer | Nombre de cartes révisées |
| created_at | DateTime | Date de création |
| updated_at | DateTime | Date de dernière mise à jour |
| last_login | DateTime | Dernière connexion |

### 2. **user_decks** - Association utilisateurs-decks

Gère la relation entre les utilisateurs et les decks de flashcards.

| Colonne | Type | Description |
|---------|------|-------------|
| user_deck_pk | Integer (PK) | Identifiant unique |
| user_pk | Integer (FK) | Référence à l'utilisateur |
| deck_pk | Integer (FK) | Référence au deck |
| correct_count | Integer | Nombre de réponses correctes |
| attempt_count | Integer | Nombre de tentatives |
| cards_mastered | Integer | Nombre de cartes maîtrisées |
| added_at | DateTime | Date d'ajout du deck |
| last_studied | DateTime | Dernière étude |

### 3. **user_scores** - Historique des scores

Enregistre tous les scores et performances des utilisateurs.

| Colonne | Type | Description |
|---------|------|-------------|
| score_pk | Integer (PK) | Identifiant unique |
| user_pk | Integer (FK) | Référence à l'utilisateur |
| deck_pk | Integer (FK) | Référence au deck (nullable) |
| card_pk | Integer (FK) | Référence à la carte (nullable) |
| score | Integer | Points obtenus |
| is_correct | Boolean | Réponse correcte ? |
| time_spent | Integer | Temps passé (secondes) |
| created_at | DateTime | Timestamp |

### 4. **user_audio** - Enregistrements audio utilisateur

Gère les enregistrements audio des utilisateurs.

| Colonne | Type | Description |
|---------|------|-------------|
| audio_pk | Integer (PK) | Identifiant unique |
| user_pk | Integer (FK) | Référence à l'utilisateur |
| card_pk | Integer (FK) | Référence à la carte (nullable) |
| filename | String | Nom du fichier |
| audio_url | String | URL d'accès au fichier |
| duration | Integer | Durée (secondes) |
| quality_score | Integer | Score de qualité (0-100) |
| notes | Text | Notes utilisateur |
| created_at | DateTime | Timestamp |

---

## Nouveaux Fichiers Créés

### 1. **app/security.py**
Gestion complète de la sécurité :
- Hachage des mots de passe avec bcrypt
- Création et vérification des tokens JWT
- Dépendances d'authentification FastAPI

### 2. **app/crud_users.py**
Opérations CRUD pour les utilisateurs :
- Création et gestion des utilisateurs
- Authentification standard et Google OAuth
- Gestion des scores, audio et decks utilisateur
- Statistiques utilisateur

### 3. **app/google_oauth.py**
Gestion de Google OAuth 2.0 :
- Vérification des tokens Google
- Extraction des informations utilisateur
- Configuration pour le frontend

### 4. **app/api/endpoints_users.py**
Endpoints API pour :
- Enregistrement et connexion
- Gestion du profil
- Gestion des decks
- Enregistrement des scores
- Gestion des enregistrements audio
- Statistiques utilisateur

### 5. **AUTHENTICATION.md**
Documentation complète de l'authentification avec exemples de code

### 6. **.env.example**
Fichier de configuration d'exemple

---

## Dépendances Ajoutées

```
passlib[bcrypt]              # Hachage des mots de passe
python-jose[cryptography]    # Gestion des tokens JWT
email-validator              # Validation des emails
google-auth                  # Authentification Google
google-auth-oauthlib         # OAuth Google
google-auth-httplib2         # HTTP pour Google Auth
```

---

## Endpoints API

### Authentification
- `POST /api/users/register` - Enregistrement
- `POST /api/users/login` - Connexion standard
- `POST /api/users/google-login` - Connexion Google
- `POST /api/users/logout` - Déconnexion

### Profil
- `GET /api/users/me` - Profil actuel
- `PUT /api/users/me` - Mise à jour du profil
- `GET /api/users/{user_pk}` - Profil public

### Decks
- `POST /api/users/decks/{deck_pk}` - Ajouter un deck
- `GET /api/users/decks` - Lister les decks
- `DELETE /api/users/decks/{deck_pk}` - Supprimer un deck

### Scores
- `POST /api/users/scores` - Enregistrer un score
- `GET /api/users/scores` - Lister les scores
- `GET /api/users/scores/deck/{deck_pk}` - Scores d'un deck

### Audio
- `POST /api/users/audio` - Créer un enregistrement
- `GET /api/users/audio` - Lister les enregistrements
- `DELETE /api/users/audio/{audio_pk}` - Supprimer un enregistrement

### Statistiques
- `GET /api/users/stats` - Statistiques complètes
- `GET /api/users/oauth/google-config` - Configuration Google

---

## Installation et Configuration

### 1. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 2. Configurer les variables d'environnement

```bash
cp .env.example .env
# Éditer .env avec vos valeurs
```

### 3. Initialiser la base de données

Les tables sont créées automatiquement au démarrage de l'application.

```bash
python -m uvicorn app.main:app --reload
```

---

## Flux d'Utilisation

### Enregistrement d'un nouvel utilisateur

```
1. Utilisateur remplit le formulaire d'enregistrement
2. Frontend envoie POST /api/users/register
3. Backend crée l'utilisateur et retourne un token JWT
4. Frontend stocke le token et redirige vers le tableau de bord
```

### Connexion utilisateur

```
1. Utilisateur remplit le formulaire de connexion
2. Frontend envoie POST /api/users/login
3. Backend vérifie les identifiants et retourne un token JWT
4. Frontend stocke le token et redirige vers le tableau de bord
```

### Connexion Google

```
1. Utilisateur clique sur "Se connecter avec Google"
2. Frontend obtient le token Google
3. Frontend envoie POST /api/users/google-login
4. Backend crée ou met à jour l'utilisateur et retourne un token JWT
5. Frontend stocke le token et redirige vers le tableau de bord
```

### Accès aux endpoints sécurisés

```
1. Frontend inclut le token dans le header Authorization
2. Backend vérifie le token et identifie l'utilisateur
3. Opération exécutée pour cet utilisateur
4. Réponse retournée
```

---

## Sécurité

### Mesures de sécurité implémentées

1. **Hachage des mots de passe**
   - Utilisation de bcrypt avec salt
   - Impossible de récupérer le mot de passe original

2. **Tokens JWT**
   - Signature cryptographique
   - Expiration automatique (30 minutes par défaut)
   - Validation à chaque requête

3. **Authentification Google**
   - Validation des tokens Google
   - Vérification de l'expiration
   - Création automatique d'utilisateurs vérifiés

4. **Isolation des données**
   - Chaque utilisateur ne peut accéder qu'à ses propres données
   - Les endpoints vérifient la propriété des ressources

5. **CORS configuré**
   - Origines autorisées spécifiées
   - Credentials autorisés

---

## Exemples de Requêtes

### Enregistrement

```bash
curl -X POST http://localhost:8000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "username": "john_doe",
    "password": "SecurePass123!",
    "first_name": "John",
    "last_name": "Doe"
  }'
```

### Connexion

```bash
curl -X POST http://localhost:8000/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'
```

### Récupérer le profil

```bash
curl -X GET http://localhost:8000/api/users/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Enregistrer un score

```bash
curl -X POST http://localhost:8000/api/users/scores \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "score": 10,
    "is_correct": true,
    "time_spent": 5,
    "deck_pk": 1,
    "card_pk": 42
  }'
```

---

## Tests

Pour tester les endpoints, vous pouvez utiliser :

1. **Swagger UI** : http://localhost:8000/docs
2. **ReDoc** : http://localhost:8000/redoc
3. **Postman** : Importer les endpoints
4. **cURL** : Voir les exemples ci-dessus

---

## Troubleshooting

### Erreur: "Email already registered"
- L'email est déjà utilisé
- Utiliser un autre email ou se connecter

### Erreur: "Invalid token"
- Le token a expiré
- Se reconnecter pour obtenir un nouveau token

### Erreur: "User not found"
- L'utilisateur n'existe pas
- Vérifier l'ID utilisateur

### Erreur: "Deck not found in user collection"
- Le deck n'a pas été ajouté à la collection
- Ajouter le deck d'abord avec POST /api/users/decks/{deck_pk}

---

## Prochaines Étapes

### Améliorations futures

1. **Récupération de mot de passe**
   - Endpoint pour demander une réinitialisation
   - Email de confirmation

2. **Vérification email**
   - Envoi d'un email de confirmation
   - Endpoint pour confirmer l'email

3. **Rafraîchissement des tokens**
   - Endpoint pour rafraîchir le token d'accès
   - Gestion des refresh tokens

4. **Suppression de compte**
   - Endpoint pour supprimer le compte
   - Suppression en cascade des données

5. **Rôles et permissions**
   - Système de rôles (admin, modérateur, utilisateur)
   - Permissions granulaires

6. **Audit et logging**
   - Enregistrement des actions utilisateur
   - Logs de sécurité

---

## Support

Pour plus d'informations, consultez :
- `AUTHENTICATION.md` - Documentation détaillée de l'authentification
- `app/api/endpoints_users.py` - Code des endpoints
- `app/security.py` - Implémentation de la sécurité
