# Documentation des Endpoints API - Apprendiamo Italiano

## 🔐 Authentification

Tous les endpoints protégés nécessitent un token Bearer dans le header:

```
Authorization: Bearer <access_token>
```

Variable d'environnement: (Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned) ; (& d:\dev\apprendiamo-italiano-backend\.venv\Scripts\Activate.ps1)

uvicorn app.main:app --reload

---

## 👤 Endpoints Utilisateur

### POST /api/users/register

Créer un nouveau compte utilisateur

**Body**:

```json
{
  "email": "user@example.com",
  "full_name": "John Doe",
  "password": "SecurePassword123!"
}
```

**Response** (201):

```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "user": {
    "user_pk": 1,
    "email": "user@example.com",
    "full_name": "John Doe",
    "is_active": true,
    "is_verified": false,
    "total_score": 0,
    "total_cards_learned": 0,
    "total_cards_reviewed": 0,
    "created_at": "2025-11-21T10:00:00"
  }
}
```

---

### POST /api/users/login

Se connecter avec email et mot de passe

**Body**:

```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response** (200):

```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "user": { ... }
}
```

---

### POST /api/users/google-login

Connexion/Inscription via Google OAuth

**Body**:

```json
{
  "google_id": "1234567890",
  "google_email": "user@gmail.com",
  "first_name": "John",
  "last_name": "Doe",
  "google_picture": "https://..."
}
```

**Response** (200):

```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "user": { ... }
}
```

---

### GET /api/users/me

Récupérer les informations de l'utilisateur connecté

**Headers**: `Authorization: Bearer <token>`

**Response** (200):

```json
{
  "user_pk": 1,
  "email": "user@example.com",
  "full_name": "John Doe",
  "google_id": null,
  "google_picture": null,
  "is_active": true,
  "is_verified": false,
  "total_score": 150,
  "total_cards_learned": 25,
  "total_cards_reviewed": 50,
  "profile_picture": null,
  "bio": null,
  "created_at": "2025-11-21T10:00:00",
  "updated_at": "2025-11-21T11:00:00",
  "last_login": "2025-11-21T11:00:00"
}
```

---

### PUT /api/users/me

Mettre à jour le profil de l'utilisateur

**Headers**: `Authorization: Bearer <token>`

**Body**:

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "bio": "Apprenant passionné d'italien",
  "profile_picture": "https://..."
}
```

**Response** (200):

```json
{
  "user_pk": 1,
  "email": "user@example.com",
  "full_name": "John Doe",
  ...
}
```

---

### GET /api/users/stats

Récupérer les statistiques globales de l'utilisateur

**Headers**: `Authorization: Bearer <token>`

**Response** (200):

```json
{
  "total_score": 1250,
  "total_cards_learned": 150,
  "total_cards_reviewed": 300,
  "total_decks": 5,
  "total_audio_records": 20,
  "last_login": "2025-11-21T11:00:00"
}
```

---

## 📚 Endpoints Decks

### POST /decks/

Créer un nouveau deck

**Body**:

```json
{
  "name": "Vocabulaire de base",
  "id_json": "vocab_base_001"
}
```

**Response** (200):

```json
{
  "deck_pk": 1,
  "id_json": "vocab_base_001",
  "name": "Vocabulaire de base",
  "total_correct": 0,
  "total_attempts": 0,
  "cards": []
}
```

---

### GET /decks/

Récupérer la liste des decks

**Query Parameters**:

- `skip` (int, default=0): Nombre d'éléments à sauter
- `limit` (int, default=10): Nombre maximum d'éléments
- `search` (string, optional): Recherche par nom

**Response** (200):

```json
[
  {
    "deck_pk": 1,
    "id_json": "vocab_base_001",
    "name": "Vocabulaire de base",
    "total_correct": 50,
    "total_attempts": 100,
    "cards": [...]
  }
]
```

---

### GET /decks/{deck_pk}

Récupérer les détails d'un deck

**Response** (200):

```json
{
  "deck_pk": 1,
  "id_json": "vocab_base_001",
  "name": "Vocabulaire de base",
  "total_correct": 50,
  "total_attempts": 100,
  "cards": [
    {
      "card_pk": 1,
      "front": "Ciao",
      "back": "Bonjour",
      "pronunciation": "tchao",
      "tags": ["salutations"],
      "easiness": 2.5,
      "interval": 0,
      "consecutive_correct": 0,
      ...
    }
  ]
}
```

---

## 🃏 Endpoints Cartes

### POST /cards/

Créer une nouvelle carte

**Body**:

```json
{
  "deck_pk": 1,
  "front": "Ciao",
  "back": "Bonjour",
  "pronunciation": "tchao",
  "image": null,
  "tags": ["salutations", "basique"],
  "id_json": "card_001",
  "created_at": "2025-11-21T10:00:00",
  "next_review": "2025-11-21T10:00:00"
}
```

**Response** (200):

```json
{
  "card_pk": 1,
  "id_json": "card_001",
  "deck_pk": 1,
  "front": "Ciao",
  "back": "Bonjour",
  "pronunciation": "tchao",
  "image": null,
  "tags": ["salutations", "basique"],
  "box": 0,
  "easiness": 2.5,
  "interval": 0,
  "consecutive_correct": 0,
  "created_at": "2025-11-21T10:00:00",
  "next_review": "2025-11-21T10:00:00"
}
```

---

### GET /cards/

Récupérer la liste des cartes

**Query Parameters**:

- `skip` (int, default=0)
- `limit` (int, default=10)
- `deck_pk` (int, optional): Filtrer par deck
- `search` (string, optional): Recherche dans front/back
- `min_box` (int, optional): Boîte minimum
- `due_only` (bool, default=false): Seulement les cartes à réviser

**Response** (200):

```json
[
  {
    "card_pk": 1,
    "front": "Ciao",
    "back": "Bonjour",
    ...
  }
]
```

---

### GET /cards/{card_pk}

Récupérer les détails d'une carte

**Response** (200):

```json
{
  "card_pk": 1,
  "front": "Ciao",
  "back": "Bonjour",
  "pronunciation": "tchao",
  "tags": ["salutations"],
  "easiness": 2.6,
  "interval": 1,
  "consecutive_correct": 1,
  ...
}
```

---

### PUT /cards/{card_pk}

Mettre à jour une carte

**Body**:

```json
{
  "front": "Ciao (Updated)",
  "back": "Bonjour (Mis à jour)",
  "pronunciation": "tchao",
  "tags": ["salutations", "updated"]
}
```

**Response** (200):

```json
{
  "card_pk": 1,
  "front": "Ciao (Updated)",
  ...
}
```

---

### DELETE /cards/{card_pk}

Supprimer une carte

**Response** (200):

```json
{
  "detail": "Card deleted"
}
```

---

## 📖 Endpoints Decks Utilisateur

### GET /api/users/decks

Récupérer tous les decks de l'utilisateur avec statistiques

**Headers**: `Authorization: Bearer <token>`

**Response** (200):

```json
[
  {
    "user_deck_pk": 1,
    "user_pk": 1,
    "deck_pk": 1,
    "deck": {
      "deck_pk": 1,
      "name": "Vocabulaire de base",
      "cards": [...]
    },
    "mastered_cards": 10,
    "learning_cards": 5,
    "review_cards": 15,
    "total_points": 850,
    "total_attempts": 100,
    "successful_attempts": 85,
    "points_frappe": 200,
    "points_association": 250,
    "points_qcm": 200,
    "points_classique": 200,
    "added_at": "2025-11-21T10:00:00",
    "last_studied": "2025-11-21T11:00:00"
  }
]
```

---

### POST /api/users/decks/{deck_pk}

Ajouter un deck à la bibliothèque de l'utilisateur

**Headers**: `Authorization: Bearer <token>`

**Response** (201):

```json
{
  "user_deck_pk": 1,
  "user_pk": 1,
  "deck_pk": 1,
  "deck": {...},
  "mastered_cards": 0,
  "learning_cards": 0,
  "review_cards": 0,
  ...
}
```

---

### DELETE /api/users/decks/{deck_pk}

Retirer un deck de la bibliothèque

**Headers**: `Authorization: Bearer <token>`

**Response** (200):

```json
{
  "detail": "Deck retiré avec succès"
}
```

---

## 🎯 Endpoints Scores

### POST /api/users/scores

Enregistrer un score de quiz (déclenche l'algorithme Anki)

**Headers**: `Authorization: Bearer <token>`

**Body**:

```json
{
  "deck_pk": 1,
  "card_pk": 1,
  "score": 85,
  "is_correct": true,
  "time_spent": 5,
  "quiz_type": "frappe"
}
```

**Response** (201):

```json
{
  "score_pk": 1,
  "user_pk": 1,
  "deck_pk": 1,
  "card_pk": 1,
  "score": 85,
  "is_correct": true,
  "time_spent": 5,
  "quiz_type": "frappe",
  "created_at": "2025-11-21T11:00:00"
}
```

**Effets de bord**:

1. Met à jour les champs Anki de la carte:
   - `easiness`: Ajusté selon la performance
   - `interval`: Calculé pour la prochaine révision
   - `consecutive_correct`: Incrémenté si correct
   - `next_review`: Date de la prochaine révision
   - `box`: Boîte Leitner (0-10)

2. Met à jour les statistiques utilisateur:
   - `total_score`: += score
   - `total_cards_learned`: += 1 si correct
   - `total_cards_reviewed`: += 1

3. Met à jour les statistiques UserDeck:
   - `total_points`: += score
   - `total_attempts`: += 1
   - `successful_attempts`: += 1 si correct
   - `points_<quiz_type>`: += score
   - Recalcule `mastered_cards`, `learning_cards`, `review_cards`

---

## 📊 Algorithme Anki

### Grades

Le score est converti en grade Anki:

- **Grade 0 (Again)**: score < 50 → Réinitialise la progression
- **Grade 1 (Hard)**: 50 ≤ score < 75 → Progression lente
- **Grade 2 (Good)**: 75 ≤ score < 90 → Progression normale
- **Grade 3 (Easy)**: score ≥ 90 → Progression rapide

### Calcul de l'intervalle

- **Première révision**: 1 jour
- **Deuxième révision**: 6 jours
- **Révisions suivantes**: `interval * easiness * multiplier`

### Facteur de facilité (Easiness)

- Valeur initiale: 2.5
- Minimum: 1.3
- Maximum: 5.0
- Ajusté selon la performance

---

## 🔍 Codes d'Erreur

- **200**: Succès
- **201**: Créé avec succès
- **400**: Requête invalide
- **401**: Non authentifié
- **404**: Ressource non trouvée
- **500**: Erreur serveur

---

## 📝 Notes

1. Tous les timestamps sont en UTC
2. Les tokens JWT expirent après 60 minutes
3. Les mots de passe doivent faire au moins 8 caractères
4. Les scores doivent être entre 0 et 100
5. L'algorithme Anki est automatiquement déclenché lors de l'enregistrement d'un score

---

**Version**: 1.0  
**Date**: 2025-11-21
