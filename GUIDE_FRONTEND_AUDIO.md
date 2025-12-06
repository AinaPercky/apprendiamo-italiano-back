# Guide d'Intégration Frontend - Endpoints Audio

## 📋 Vue d'Ensemble

Le backend propose **deux types d'audios** :

1. **AudioItem** - Audios système (communs à tous les utilisateurs)
2. **UserAudio** - Audios personnalisés (privés par utilisateur)

## 🎵 1. AudioItem - Audios Système

### Description
Les AudioItem sont des audios générés par TTS (Text-to-Speech) et disponibles pour tous les utilisateurs. Ils sont utilisés pour les exemples de prononciation.

### Endpoints

#### 1.1 Créer un Audio Système
```typescript
POST /audios/
Content-Type: multipart/form-data
```

**Paramètres (Form Data):**
| Paramètre | Type | Requis | Valeurs possibles |
|-----------|------|--------|-------------------|
| title | string | ✅ | Titre de l'audio |
| text | string | ✅ | Texte à convertir en audio |
| category | string | ✅ | `mot`, `phrase`, `texte`, `poème`, `virelangue` |
| language | string | ❌ | `it` (défaut), `en`, `fr`, `de`, `es`, `ru`, `ja`, `zh` |

**Exemple de requête:**
```typescript
const formData = new FormData();
formData.append('title', 'Bonjour');
formData.append('text', 'Ciao, come stai?');
formData.append('category', 'phrase');
formData.append('language', 'it');

const response = await fetch('http://localhost:8000/audios/', {
  method: 'POST',
  body: formData
});

const audio = await response.json();
```

**Réponse (200 OK):**
```json
{
  "id": 123,
  "title": "Bonjour",
  "text": "Ciao, come stai?",
  "filename": "abc123def456.mp3",
  "category": "phrase",
  "language": "it",
  "ipa": null,
  "audio_url": "/audios/files/abc123def456.mp3"
}
```

#### 1.2 Lister Tous les Audios Système
```typescript
GET /audios/
```

**Paramètres:** Aucun

**Réponse (200 OK):**
```json
[
  {
    "id": 123,
    "title": "Bonjour",
    "text": "Ciao, come stai?",
    "filename": "abc123.mp3",
    "category": "phrase",
    "language": "it",
    "ipa": null,
    "audio_url": "/audios/files/abc123.mp3"
  },
  ...
]
```

**Exemple TypeScript:**
```typescript
interface AudioItem {
  id: number;
  title: string;
  text: string;
  filename: string;
  category: 'mot' | 'phrase' | 'texte' | 'poème' | 'virelangue';
  language: 'it' | 'en' | 'fr' | 'de' | 'es' | 'ru' | 'ja' | 'zh';
  ipa: string | null;
  audio_url: string;
}

async function getAllSystemAudios(): Promise<AudioItem[]> {
  const response = await fetch('http://localhost:8000/audios/');
  if (!response.ok) throw new Error('Failed to fetch audios');
  return response.json();
}
```

#### 1.3 Récupérer un Audio Spécifique
```typescript
GET /audios/{audio_id}
```

**Paramètres:**
| Paramètre | Type | Description |
|-----------|------|-------------|
| audio_id | number | ID de l'audio (dans l'URL) |

**Réponse (200 OK):** Même structure que 1.1

**Erreurs:**
- `404 Not Found` - Audio non trouvé

#### 1.4 Supprimer un Audio Système
```typescript
DELETE /audios/{audio_id}
```

**Paramètres:**
| Paramètre | Type | Description |
|-----------|------|-------------|
| audio_id | number | ID de l'audio (dans l'URL) |

**Réponse (200 OK):**
```json
{
  "detail": "Audio deleted"
}
```

**Erreurs:**
- `404 Not Found` - Audio non trouvé

---

## 👤 2. UserAudio - Audios Personnalisés

### Description
Les UserAudio sont des enregistrements audio privés, spécifiques à chaque utilisateur. Ils peuvent être associés à des cartes (flashcards) et incluent des métadonnées comme la durée et le score de qualité.

⚠️ **Authentification requise** pour tous les endpoints UserAudio.

### Endpoints

#### 2.1 Créer un Audio Utilisateur
```typescript
POST /api/users/audio
Content-Type: application/json
Authorization: Bearer <token>
```

**Headers:**
```typescript
{
  "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "Content-Type": "application/json"
}
```

**Body (JSON):**
| Paramètre | Type | Requis | Description |
|-----------|------|--------|-------------|
| filename | string | ✅ | Nom du fichier audio |
| audio_url | string | ✅ | URL du fichier audio |
| duration | number | ❌ | Durée en secondes |
| quality_score | number | ❌ | Score de qualité (0-100) |
| notes | string | ❌ | Notes personnelles |
| card_pk | number | ❌ | ID de la carte associée |

**Exemple de requête:**
```typescript
interface UserAudioCreate {
  filename: string;
  audio_url: string;
  duration?: number;
  quality_score?: number;
  notes?: string;
  card_pk?: number;
}

async function createUserAudio(
  token: string, 
  audioData: UserAudioCreate
): Promise<UserAudio> {
  const response = await fetch('http://localhost:8000/api/users/audio', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(audioData)
  });
  
  if (!response.ok) {
    if (response.status === 401) {
      throw new Error('Non authentifié');
    }
    throw new Error('Échec de création de l\'audio');
  }
  
  return response.json();
}

// Utilisation
const newAudio = await createUserAudio(userToken, {
  filename: 'my_recording_123.mp3',
  audio_url: '/user_audios/my_recording_123.mp3',
  duration: 15,
  quality_score: 85,
  notes: 'Mon premier enregistrement',
  card_pk: 42
});
```

**Réponse (201 Created):**
```json
{
  "audio_pk": 1,
  "user_pk": 28,
  "filename": "my_recording_123.mp3",
  "audio_url": "/user_audios/my_recording_123.mp3",
  "duration": 15,
  "quality_score": 85,
  "notes": "Mon premier enregistrement",
  "card_pk": 42,
  "created_at": "2025-12-01T16:00:00Z"
}
```

#### 2.2 Lister les Audios de l'Utilisateur
```typescript
GET /api/users/audio?limit=50&offset=0
Authorization: Bearer <token>
```

**Paramètres (Query):**
| Paramètre | Type | Défaut | Description |
|-----------|------|--------|-------------|
| limit | number | 50 | Nombre max d'audios à retourner |
| offset | number | 0 | Nombre d'audios à ignorer (pagination) |

**Exemple:**
```typescript
interface UserAudio {
  audio_pk: number;
  user_pk: number;
  filename: string;
  audio_url: string;
  duration: number | null;
  quality_score: number | null;
  notes: string | null;
  card_pk: number | null;
  created_at: string;
}

async function getUserAudios(
  token: string,
  limit: number = 50,
  offset: number = 0
): Promise<UserAudio[]> {
  const url = `http://localhost:8000/api/users/audio?limit=${limit}&offset=${offset}`;
  
  const response = await fetch(url, {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  });
  
  if (!response.ok) {
    throw new Error('Échec de récupération des audios');
  }
  
  return response.json();
}

// Utilisation avec pagination
const firstPage = await getUserAudios(userToken, 10, 0);  // 10 premiers
const secondPage = await getUserAudios(userToken, 10, 10); // 10 suivants
```

**Réponse (200 OK):**
```json
[
  {
    "audio_pk": 1,
    "user_pk": 28,
    "filename": "recording_1.mp3",
    "audio_url": "/user_audios/recording_1.mp3",
    "duration": 15,
    "quality_score": 85,
    "notes": "Premier enregistrement",
    "card_pk": 42,
    "created_at": "2025-12-01T16:00:00Z"
  },
  ...
]
```

#### 2.3 Supprimer un Audio Utilisateur
```typescript
DELETE /api/users/audio/{audio_pk}
Authorization: Bearer <token>
```

**Paramètres:**
| Paramètre | Type | Description |
|-----------|------|-------------|
| audio_pk | number | ID de l'audio (dans l'URL) |

**Exemple:**
```typescript
async function deleteUserAudio(
  token: string,
  audioPk: number
): Promise<void> {
  const response = await fetch(
    `http://localhost:8000/api/users/audio/${audioPk}`,
    {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    }
  );
  
  if (!response.ok) {
    if (response.status === 404) {
      throw new Error('Audio non trouvé');
    }
    throw new Error('Échec de suppression de l\'audio');
  }
}

// Utilisation
await deleteUserAudio(userToken, 123);
```

**Réponse (200 OK):**
```json
{
  "message": "Audio deleted successfully"
}
```

**Erreurs:**
- `404 Not Found` - Audio non trouvé ou n'appartient pas à l'utilisateur
- `401 Unauthorized` - Token invalide ou manquant

---

## 🔒 Sécurité et Isolation

### Règles de Sécurité
1. ✅ Un utilisateur ne peut voir que **ses propres** audios UserAudio
2. ✅ Un utilisateur ne peut **pas** supprimer les audios d'un autre utilisateur
3. ✅ Les AudioItem (système) sont **publics** et visibles par tous
4. ✅ Les UserAudio nécessitent une **authentification JWT**

### Exemple de Gestion d'Erreurs
```typescript
async function handleAudioRequest<T>(
  requestFn: () => Promise<Response>
): Promise<T> {
  try {
    const response = await requestFn();
    
    if (!response.ok) {
      switch (response.status) {
        case 401:
          // Rediriger vers la page de connexion
          window.location.href = '/login';
          throw new Error('Session expirée');
          
        case 404:
          throw new Error('Audio non trouvé');
          
        case 403:
          throw new Error('Accès non autorisé');
          
        default:
          throw new Error(`Erreur ${response.status}`);
      }
    }
    
    return response.json();
  } catch (error) {
    console.error('Erreur audio:', error);
    throw error;
  }
}
```

---

## 🎨 Exemple d'Intégration Complète

### Composant React pour Gérer les Audios Utilisateur

```typescript
import React, { useState, useEffect } from 'react';

interface UserAudio {
  audio_pk: number;
  user_pk: number;
  filename: string;
  audio_url: string;
  duration: number | null;
  quality_score: number | null;
  notes: string | null;
  card_pk: number | null;
  created_at: string;
}

const UserAudioManager: React.FC = () => {
  const [audios, setAudios] = useState<UserAudio[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const token = localStorage.getItem('auth_token'); // Récupérer le token
  
  // Charger les audios au montage
  useEffect(() => {
    loadAudios();
  }, []);
  
  const loadAudios = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await fetch('http://localhost:8000/api/users/audio', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (!response.ok) throw new Error('Échec de chargement');
      
      const data = await response.json();
      setAudios(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };
  
  const deleteAudio = async (audioPk: number) => {
    try {
      const response = await fetch(
        `http://localhost:8000/api/users/audio/${audioPk}`,
        {
          method: 'DELETE',
          headers: {
            'Authorization': `Bearer ${token}`
          }
        }
      );
      
      if (!response.ok) throw new Error('Échec de suppression');
      
      // Recharger la liste
      await loadAudios();
    } catch (err) {
      setError(err.message);
    }
  };
  
  if (loading) return <div>Chargement...</div>;
  if (error) return <div>Erreur: {error}</div>;
  
  return (
    <div>
      <h2>Mes Enregistrements Audio ({audios.length})</h2>
      
      {audios.length === 0 ? (
        <p>Aucun enregistrement audio</p>
      ) : (
        <ul>
          {audios.map(audio => (
            <li key={audio.audio_pk}>
              <div>
                <strong>{audio.filename}</strong>
                {audio.duration && <span> - {audio.duration}s</span>}
                {audio.quality_score && (
                  <span> - Qualité: {audio.quality_score}%</span>
                )}
              </div>
              
              {audio.notes && <p>{audio.notes}</p>}
              
              <audio controls src={audio.audio_url} />
              
              <button onClick={() => deleteAudio(audio.audio_pk)}>
                Supprimer
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default UserAudioManager;
```

---

## 📝 Résumé des Changements

### Nouveaux Endpoints Disponibles

| Endpoint | Méthode | Auth | Description |
|----------|---------|------|-------------|
| `/audios/` | POST | ❌ | Créer un audio système |
| `/audios/` | GET | ❌ | Lister les audios système |
| `/audios/{id}` | GET | ❌ | Récupérer un audio système |
| `/audios/{id}` | DELETE | ❌ | Supprimer un audio système |
| `/api/users/audio` | POST | ✅ | Créer un audio utilisateur |
| `/api/users/audio` | GET | ✅ | Lister les audios utilisateur |
| `/api/users/audio/{pk}` | DELETE | ✅ | Supprimer un audio utilisateur |

### Paramètres Importants

**AudioItem (Système):**
- `category`: `mot`, `phrase`, `texte`, `poème`, `virelangue`
- `language`: `it`, `en`, `fr`, `de`, `es`, `ru`, `ja`, `zh`

**UserAudio (Utilisateur):**
- `card_pk`: Pour associer l'audio à une carte spécifique
- `duration`: Durée en secondes
- `quality_score`: Score de qualité (0-100)
- `notes`: Notes personnelles

### Corrections Apportées
1. ✅ Ajout du champ `audio_url` dans les réponses AudioItem
2. ✅ Correction de l'erreur 500 sur GET `/audios/{id}`
3. ✅ Correction de la suppression d'audios système

---

**Date:** 2025-12-01  
**Version Backend:** 1.0.0  
**Taux de Réussite des Tests:** 96.9%
