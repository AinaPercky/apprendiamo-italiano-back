/**
 * API Client pour les Endpoints Audio
 * Backend: Apprendiamo Italiano
 * Version: 1.0.0
 * Date: 2025-12-01
 */

// ============================================================================
// TYPES ET INTERFACES
// ============================================================================

/**
 * Audio système (commun à tous les utilisateurs)
 */
export interface AudioItem {
    id: number;
    title: string;
    text: string;
    filename: string;
    category: 'mot' | 'phrase' | 'texte' | 'poème' | 'virelangue';
    language: 'it' | 'en' | 'fr' | 'de' | 'es' | 'ru' | 'ja' | 'zh';
    ipa: string | null;
    audio_url: string;
}

/**
 * Données pour créer un audio système
 */
export interface AudioItemCreate {
    title: string;
    text: string;
    category: 'mot' | 'phrase' | 'texte' | 'poème' | 'virelangue';
    language?: 'it' | 'en' | 'fr' | 'de' | 'es' | 'ru' | 'ja' | 'zh';
}

/**
 * Audio utilisateur (privé)
 */
export interface UserAudio {
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

/**
 * Données pour créer un audio utilisateur
 */
export interface UserAudioCreate {
    filename: string;
    audio_url: string;
    duration?: number;
    quality_score?: number;
    notes?: string;
    card_pk?: number;
}

/**
 * Configuration de l'API
 */
export interface AudioApiConfig {
    baseUrl: string;
    getAuthToken: () => string | null;
}

// ============================================================================
// CLASSE API CLIENT
// ============================================================================

export class AudioApiClient {
    private baseUrl: string;
    private getAuthToken: () => string | null;

    constructor(config: AudioApiConfig) {
        this.baseUrl = config.baseUrl;
        this.getAuthToken = config.getAuthToken;
    }

    /**
     * Gère les erreurs HTTP
     */
    private async handleResponse<T>(response: Response): Promise<T> {
        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));

            switch (response.status) {
                case 401:
                    throw new Error('Non authentifié. Veuillez vous reconnecter.');
                case 403:
                    throw new Error('Accès non autorisé.');
                case 404:
                    throw new Error('Ressource non trouvée.');
                case 500:
                    throw new Error('Erreur serveur. Veuillez réessayer plus tard.');
                default:
                    throw new Error(errorData.detail || `Erreur ${response.status}`);
            }
        }

        return response.json();
    }

    /**
     * Obtient les headers avec authentification si disponible
     */
    private getHeaders(includeAuth: boolean = false): HeadersInit {
        const headers: HeadersInit = {
            'Content-Type': 'application/json',
        };

        if (includeAuth) {
            const token = this.getAuthToken();
            if (token) {
                headers['Authorization'] = `Bearer ${token}`;
            }
        }

        return headers;
    }

    // ==========================================================================
    // AUDIO SYSTÈME (AUDIOITEM)
    // ==========================================================================

    /**
     * Crée un audio système via TTS
     */
    async createSystemAudio(data: AudioItemCreate): Promise<AudioItem> {
        const formData = new FormData();
        formData.append('title', data.title);
        formData.append('text', data.text);
        formData.append('category', data.category);
        if (data.language) {
            formData.append('language', data.language);
        }

        const response = await fetch(`${this.baseUrl}/audios/`, {
            method: 'POST',
            body: formData,
        });

        return this.handleResponse<AudioItem>(response);
    }

    /**
     * Récupère tous les audios système
     */
    async getAllSystemAudios(): Promise<AudioItem[]> {
        const response = await fetch(`${this.baseUrl}/audios/`);
        return this.handleResponse<AudioItem[]>(response);
    }

    /**
     * Récupère un audio système par ID
     */
    async getSystemAudio(audioId: number): Promise<AudioItem> {
        const response = await fetch(`${this.baseUrl}/audios/${audioId}`);
        return this.handleResponse<AudioItem>(response);
    }

    /**
     * Supprime un audio système
     */
    async deleteSystemAudio(audioId: number): Promise<void> {
        const response = await fetch(`${this.baseUrl}/audios/${audioId}`, {
            method: 'DELETE',
        });

        await this.handleResponse<{ detail: string }>(response);
    }

    // ==========================================================================
    // AUDIO UTILISATEUR (USERAUDIO)
    // ==========================================================================

    /**
     * Crée un audio utilisateur
     * Nécessite une authentification
     */
    async createUserAudio(data: UserAudioCreate): Promise<UserAudio> {
        const response = await fetch(`${this.baseUrl}/api/users/audio`, {
            method: 'POST',
            headers: this.getHeaders(true),
            body: JSON.stringify(data),
        });

        return this.handleResponse<UserAudio>(response);
    }

    /**
     * Récupère tous les audios de l'utilisateur connecté
     * Nécessite une authentification
     */
    async getUserAudios(
        limit: number = 50,
        offset: number = 0
    ): Promise<UserAudio[]> {
        const url = `${this.baseUrl}/api/users/audio?limit=${limit}&offset=${offset}`;

        const response = await fetch(url, {
            headers: this.getHeaders(true),
        });

        return this.handleResponse<UserAudio[]>(response);
    }

    /**
     * Récupère les audios de l'utilisateur pour une carte spécifique
     * Nécessite une authentification
     */
    async getUserAudiosForCard(cardPk: number): Promise<UserAudio[]> {
        const allAudios = await this.getUserAudios(100, 0);
        return allAudios.filter(audio => audio.card_pk === cardPk);
    }

    /**
     * Supprime un audio utilisateur
     * Nécessite une authentification
     */
    async deleteUserAudio(audioPk: number): Promise<void> {
        const response = await fetch(
            `${this.baseUrl}/api/users/audio/${audioPk}`,
            {
                method: 'DELETE',
                headers: this.getHeaders(true),
            }
        );

        await this.handleResponse<{ message: string }>(response);
    }
}

// ============================================================================
// INSTANCE SINGLETON (OPTIONNEL)
// ============================================================================

let audioApiInstance: AudioApiClient | null = null;

/**
 * Initialise l'API client audio
 */
export function initAudioApi(config: AudioApiConfig): AudioApiClient {
    audioApiInstance = new AudioApiClient(config);
    return audioApiInstance;
}

/**
 * Obtient l'instance de l'API client audio
 */
export function getAudioApi(): AudioApiClient {
    if (!audioApiInstance) {
        throw new Error(
            'AudioApiClient non initialisé. Appelez initAudioApi() d\'abord.'
        );
    }
    return audioApiInstance;
}

// ============================================================================
// EXEMPLE D'UTILISATION
// ============================================================================

/*

// 1. Initialiser l'API au démarrage de l'application
import { initAudioApi } from './audioApi';

const audioApi = initAudioApi({
  baseUrl: 'http://localhost:8000',
  getAuthToken: () => localStorage.getItem('auth_token')
});

// 2. Utiliser l'API dans vos composants

// Créer un audio système
const systemAudio = await audioApi.createSystemAudio({
  title: 'Bonjour',
  text: 'Ciao, come stai?',
  category: 'phrase',
  language: 'it'
});

// Lister tous les audios système
const allSystemAudios = await audioApi.getAllSystemAudios();

// Créer un audio utilisateur
const userAudio = await audioApi.createUserAudio({
  filename: 'my_recording.mp3',
  audio_url: '/user_audios/my_recording.mp3',
  duration: 15,
  quality_score: 85,
  notes: 'Mon premier enregistrement',
  card_pk: 42
});

// Lister les audios de l'utilisateur
const myAudios = await audioApi.getUserAudios(10, 0);

// Récupérer les audios pour une carte spécifique
const cardAudios = await audioApi.getUserAudiosForCard(42);

// Supprimer un audio utilisateur
await audioApi.deleteUserAudio(123);

// 3. Gestion d'erreurs

try {
  const audio = await audioApi.createUserAudio({
    filename: 'test.mp3',
    audio_url: '/test.mp3'
  });
  console.log('Audio créé:', audio);
} catch (error) {
  console.error('Erreur:', error.message);
  // Afficher un message à l'utilisateur
}

*/

// ============================================================================
// HOOKS REACT (OPTIONNEL)
// ============================================================================

/*

import { useState, useEffect } from 'react';
import { getAudioApi, UserAudio } from './audioApi';

// Hook pour récupérer les audios utilisateur
export function useUserAudios() {
  const [audios, setAudios] = useState<UserAudio[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadAudios = async () => {
    setLoading(true);
    setError(null);

    try {
      const audioApi = getAudioApi();
      const data = await audioApi.getUserAudios();
      setAudios(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const deleteAudio = async (audioPk: number) => {
    try {
      const audioApi = getAudioApi();
      await audioApi.deleteUserAudio(audioPk);
      await loadAudios(); // Recharger la liste
    } catch (err) {
      setError(err.message);
    }
  };

  useEffect(() => {
    loadAudios();
  }, []);

  return {
    audios,
    loading,
    error,
    reload: loadAudios,
    deleteAudio
  };
}

// Utilisation dans un composant
function MyAudiosComponent() {
  const { audios, loading, error, deleteAudio } = useUserAudios();

  if (loading) return <div>Chargement...</div>;
  if (error) return <div>Erreur: {error}</div>;

  return (
    <div>
      <h2>Mes Audios ({audios.length})</h2>
      {audios.map(audio => (
        <div key={audio.audio_pk}>
          <p>{audio.filename}</p>
          <audio controls src={audio.audio_url} />
          <button onClick={() => deleteAudio(audio.audio_pk)}>
            Supprimer
          </button>
        </div>
      ))}
    </div>
  );
}

*/

export default AudioApiClient;
