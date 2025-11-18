# Documentation de l'Authentification

## Vue d'ensemble

Le système d'authentification supporte deux méthodes :

1. **Authentification Standard** : Email + Mot de passe
2. **Authentification Google OAuth** : Via compte Google

Tous les endpoints sécurisés utilisent des tokens JWT (JSON Web Tokens) pour l'authentification.

---

## Configuration

### Variables d'environnement requises

```bash
# Clé secrète pour signer les tokens JWT
SECRET_KEY=your-secret-key-change-in-production

# Configuration Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Durée de vie des tokens
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
```

### Obtenir les identifiants Google OAuth

1. Aller sur [Google Cloud Console](https://console.cloud.google.com)
2. Créer un nouveau projet
3. Activer l'API Google+ 
4. Créer des identifiants OAuth 2.0 (Type: Application Web)
5. Ajouter les URI autorisés :
   - `http://localhost:8000` (développement)
   - `https://yourdomain.com` (production)
6. Copier le Client ID et Client Secret dans le fichier `.env`

---

## Endpoints d'Authentification

### 1. Enregistrement (Standard)

**POST** `/api/users/register`

Crée un nouvel utilisateur avec email et mot de passe.

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "username",
  "password": "securepassword123",
  "first_name": "John",
  "last_name": "Doe"
}
```

**Response (201):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "user_pk": 1,
    "email": "user@example.com",
    "username": "username",
    "first_name": "John",
    "last_name": "Doe",
    "is_active": true,
    "is_verified": false,
    "total_score": 0,
    "total_cards_learned": 0,
    "total_cards_reviewed": 0,
    "created_at": "2025-01-15T10:30:00",
    "last_login": "2025-01-15T10:30:00"
  }
}
```

---

### 2. Connexion (Standard)

**POST** `/api/users/login`

Authentifie un utilisateur existant.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": { ... }
}
```

**Erreurs possibles:**
- `401 Unauthorized` : Email ou mot de passe invalide
- `403 Forbidden` : Compte utilisateur inactif

---

### 3. Connexion Google

**POST** `/api/users/google-login`

Authentifie ou crée un utilisateur via Google OAuth.

**Request Body:**
```json
{
  "google_id": "123456789",
  "google_email": "user@gmail.com",
  "first_name": "John",
  "last_name": "Doe",
  "google_picture": "https://..."
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": { ... }
}
```

**Note:** Le `google_id` doit être validé côté frontend avant d'être envoyé au backend.

---

### 4. Obtenir la Configuration Google

**GET** `/api/users/oauth/google-config`

Récupère la configuration Google OAuth pour le frontend.

**Response (200):**
```json
{
  "client_id": "your-google-client-id.apps.googleusercontent.com",
  "scope": "profile email",
  "discovery_docs": [...]
}
```

---

### 5. Déconnexion

**POST** `/api/users/logout`

Déconnecte l'utilisateur actuel (supprime le token côté client).

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

## Endpoints Sécurisés (Authentification requise)

Tous les endpoints suivants nécessitent un header `Authorization` :

```
Authorization: Bearer <access_token>
```

### Profil Utilisateur

#### Récupérer le profil actuel
**GET** `/api/users/me`

#### Mettre à jour le profil
**PUT** `/api/users/me`

```json
{
  "first_name": "Jean",
  "last_name": "Martin",
  "bio": "Apprenant d'italien passionné",
  "profile_picture": "https://..."
}
```

#### Récupérer le profil d'un utilisateur
**GET** `/api/users/{user_pk}`

---

### Gestion des Decks

#### Ajouter un deck à la collection
**POST** `/api/users/decks/{deck_pk}`

#### Récupérer tous les decks
**GET** `/api/users/decks`

#### Supprimer un deck de la collection
**DELETE** `/api/users/decks/{deck_pk}`

---

### Scores

#### Enregistrer un score
**POST** `/api/users/scores`

```json
{
  "score": 10,
  "is_correct": true,
  "time_spent": 5,
  "deck_pk": 1,
  "card_pk": 42
}
```

#### Récupérer les scores
**GET** `/api/users/scores?limit=100&offset=0`

#### Récupérer les scores d'un deck
**GET** `/api/users/scores/deck/{deck_pk}`

---

### Enregistrements Audio

#### Créer un enregistrement audio
**POST** `/api/users/audio`

```json
{
  "filename": "recording_001.wav",
  "audio_url": "https://...",
  "duration": 30,
  "quality_score": 85,
  "notes": "Bonne prononciation",
  "card_pk": 42
}
```

#### Récupérer les enregistrements audio
**GET** `/api/users/audio?limit=50&offset=0`

#### Supprimer un enregistrement audio
**DELETE** `/api/users/audio/{audio_pk}`

---

### Statistiques

#### Récupérer les statistiques
**GET** `/api/users/stats`

**Response:**
```json
{
  "total_score": 1250,
  "total_cards_learned": 45,
  "total_cards_reviewed": 320,
  "total_decks": 5,
  "total_audio_records": 23,
  "last_login": "2025-01-15T10:30:00"
}
```

---

## Flux d'Authentification Frontend

### 1. Authentification Standard

```javascript
// Enregistrement
const registerResponse = await fetch('/api/users/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    username: 'username',
    password: 'password123',
    first_name: 'John',
    last_name: 'Doe'
  })
});

const { access_token, user } = await registerResponse.json();
localStorage.setItem('access_token', access_token);

// Connexion
const loginResponse = await fetch('/api/users/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'password123'
  })
});

const { access_token, user } = await loginResponse.json();
localStorage.setItem('access_token', access_token);
```

### 2. Authentification Google

```javascript
// Obtenir la configuration Google
const configResponse = await fetch('/api/users/oauth/google-config');
const googleConfig = await configResponse.json();

// Initialiser Google Sign-In (côté frontend)
google.accounts.id.initialize({
  client_id: googleConfig.client_id,
  callback: handleCredentialResponse
});

// Callback après authentification Google
async function handleCredentialResponse(response) {
  const googleToken = response.credential;
  
  // Envoyer le token au backend
  const authResponse = await fetch('/api/users/google-login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      google_id: decodedToken.sub,
      google_email: decodedToken.email,
      first_name: decodedToken.given_name,
      last_name: decodedToken.family_name,
      google_picture: decodedToken.picture
    })
  });
  
  const { access_token, user } = await authResponse.json();
  localStorage.setItem('access_token', access_token);
}
```

### 3. Utiliser le Token pour les Requêtes Sécurisées

```javascript
// Récupérer le profil actuel
const profileResponse = await fetch('/api/users/me', {
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('access_token')}`
  }
});

const userProfile = await profileResponse.json();
```

---

## Gestion des Erreurs

### Codes d'erreur courants

| Code | Message | Cause |
|------|---------|-------|
| 400 | Email already registered | L'email est déjà utilisé |
| 400 | Username already taken | Le nom d'utilisateur est déjà utilisé |
| 401 | Invalid email or password | Email ou mot de passe incorrect |
| 401 | Invalid token | Token JWT expiré ou invalide |
| 403 | User account is inactive | Le compte utilisateur est désactivé |
| 404 | User not found | L'utilisateur n'existe pas |
| 404 | Deck not found in user collection | Le deck n'est pas dans la collection |

---

## Sécurité

### Bonnes pratiques

1. **Stockage du Token**
   - Stocker le token dans `localStorage` ou `sessionStorage` (pas dans les cookies)
   - Ne jamais exposer le token dans les logs

2. **Transmission du Token**
   - Toujours utiliser HTTPS en production
   - Envoyer le token dans le header `Authorization: Bearer <token>`

3. **Gestion des Mots de Passe**
   - Les mots de passe sont hachés avec bcrypt
   - Minimum 8 caractères recommandé
   - Utiliser une combinaison de majuscules, minuscules, chiffres et caractères spéciaux

4. **Expiration des Tokens**
   - Les tokens d'accès expirent après 30 minutes par défaut
   - Implémenter un mécanisme de rafraîchissement des tokens si nécessaire

5. **CORS**
   - Les origines autorisées doivent être strictement définies
   - Ne pas utiliser `*` en production

---

## Troubleshooting

### Le token est expiré
- Réponse: `401 Unauthorized - Invalid token`
- Solution: Reconnecter l'utilisateur

### Email ou mot de passe incorrect
- Réponse: `401 Unauthorized - Invalid email or password`
- Solution: Vérifier les identifiants ou utiliser "Mot de passe oublié"

### Compte inactif
- Réponse: `403 Forbidden - User account is inactive`
- Solution: Contacter l'administrateur pour réactiver le compte

### Google OAuth ne fonctionne pas
- Vérifier que le `GOOGLE_CLIENT_ID` est correct
- Vérifier que l'URI est autorisé dans Google Cloud Console
- Vérifier que le token Google n'a pas expiré
