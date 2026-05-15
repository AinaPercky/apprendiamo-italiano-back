# 🎨 Guide Complet d'Implémentation Frontend

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Changement API Requis](#changement-api-requis)
3. [Implémentation React](#implémentation-react)
4. [Implémentation Vue.js](#implémentation-vuejs)
5. [Implémentation Vanilla JavaScript](#implémentation-vanilla-javascript)
6. [Gestion des États](#gestion-des-états)
7. [Tests Frontend](#tests-frontend)
8. [Dépannage](#dépannage)

---

## 🎯 Vue d'ensemble

### Problème Actuel
- **Ancien endpoint** : `GET /api/users/decks`
  - Retourne uniquement les decks commencés
  - Nouveau utilisateur → liste vide `[]`

### Solution
- **Nouveau endpoint** : `GET /api/users/decks/all`
  - Retourne **tous** les decks du système
  - Nouveau utilisateur → tous les decks à **0%**
  - Utilisateur actif → stats personnalisées

---

## 🔄 Changement API Requis

### Ancien Code (à remplacer)
```typescript
// ❌ N'affiche que les decks commencés
const response = await fetch('http://localhost:8000/api/users/decks', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

### Nouveau Code (recommandé)
```typescript
// ✅ Affiche TOUS les decks avec stats personnalisées
const response = await fetch('http://localhost:8000/api/users/decks/all', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
});
```

---

## ⚛️ Implémentation React

### 1. Types TypeScript

```typescript
// types/deck.ts

export interface Deck {
  deck_pk: number;
  name: string;
  id_json: string;
  total_correct: number;
  total_attempts: number;
}

export interface UserDeck {
  user_deck_pk: number;
  user_pk: number;
  deck_pk: number;
  deck: Deck;
  
  // Stats Anki
  mastered_cards: number;
  learning_cards: number;
  review_cards: number;
  
  // Scoring
  total_points: number;
  total_attempts: number;
  successful_attempts: number;
  
  // Scoring par mode
  points_frappe: number;
  points_association: number;
  points_qcm: number;
  points_classique: number;
  
  // Dates
  added_at: string;
  last_studied: string | null;
  
  // Champs calculés (fournis par le backend)
  success_rate: number;  // Pourcentage de réussite
  progress: number;      // Pourcentage de progression
}
```

### 2. Service API

```typescript
// services/deckService.ts

import { UserDeck } from '../types/deck';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

export class DeckService {
  /**
   * Récupère tous les decks du système avec les stats personnalisées de l'utilisateur
   */
  static async getAllDecksWithUserStats(token: string): Promise<UserDeck[]> {
    try {
      const response = await fetch(`${API_BASE_URL}/api/users/decks/all`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Erreur lors de la récupération des decks:', error);
      throw error;
    }
  }

  /**
   * Récupère uniquement les decks commencés par l'utilisateur
   * (ancien comportement, conservé pour compatibilité)
   */
  static async getUserStartedDecks(token: string): Promise<UserDeck[]> {
    try {
      const response = await fetch(`${API_BASE_URL}/api/users/decks`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('Erreur lors de la récupération des decks commencés:', error);
      throw error;
    }
  }
}
```

### 3. Hook Personnalisé

```typescript
// hooks/useDecks.ts

import { useState, useEffect, useCallback } from 'react';
import { UserDeck } from '../types/deck';
import { DeckService } from '../services/deckService';

interface UseDecksReturn {
  decks: UserDeck[];
  loading: boolean;
  error: string | null;
  refetch: () => Promise<void>;
  decksWithActivity: UserDeck[];
  decksWithoutActivity: UserDeck[];
}

export const useDecks = (token: string | null): UseDecksReturn => {
  const [decks, setDecks] = useState<UserDeck[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDecks = useCallback(async () => {
    if (!token) {
      setError('Token non disponible');
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      // ✅ Utiliser le nouveau endpoint
      const data = await DeckService.getAllDecksWithUserStats(token);
      
      setDecks(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue');
    } finally {
      setLoading(false);
    }
  }, [token]);

  useEffect(() => {
    fetchDecks();
  }, [fetchDecks]);

  // Séparer les decks en deux catégories
  const decksWithActivity = decks.filter(d => d.total_attempts > 0);
  const decksWithoutActivity = decks.filter(d => d.total_attempts === 0);

  return {
    decks,
    loading,
    error,
    refetch: fetchDecks,
    decksWithActivity,
    decksWithoutActivity
  };
};
```

### 4. Composant Page

```typescript
// pages/MyDecksPage.tsx

import React from 'react';
import { useDecks } from '../hooks/useDecks';
import { DeckCard } from '../components/DeckCard';
import { LoadingSpinner } from '../components/LoadingSpinner';
import { ErrorMessage } from '../components/ErrorMessage';
import './MyDecksPage.css';

export const MyDecksPage: React.FC = () => {
  // Récupérer le token depuis votre système d'auth
  const token = localStorage.getItem('access_token');
  
  const { 
    decks, 
    loading, 
    error, 
    refetch,
    decksWithActivity,
    decksWithoutActivity 
  } = useDecks(token);

  if (loading) {
    return <LoadingSpinner message="Chargement des decks..." />;
  }

  if (error) {
    return (
      <ErrorMessage 
        message={error} 
        onRetry={refetch}
      />
    );
  }

  return (
    <div className="my-decks-page">
      {/* En-tête */}
      <header className="page-header">
        <h1>Mes Decks</h1>
        <p className="subtitle">
          {decks.length} deck{decks.length > 1 ? 's' : ''} disponible{decks.length > 1 ? 's' : ''}
        </p>
        <button onClick={refetch} className="btn-refresh">
          🔄 Actualiser
        </button>
      </header>

      {/* Decks avec activité */}
      {decksWithActivity.length > 0 && (
        <section className="decks-section">
          <h2 className="section-title">
            📚 En cours ({decksWithActivity.length})
          </h2>
          <div className="decks-grid">
            {decksWithActivity.map(deck => (
              <DeckCard 
                key={deck.deck_pk} 
                deck={deck}
                isStarted={true}
              />
            ))}
          </div>
        </section>
      )}

      {/* Decks sans activité */}
      {decksWithoutActivity.length > 0 && (
        <section className="decks-section">
          <h2 className="section-title">
            🆕 À découvrir ({decksWithoutActivity.length})
          </h2>
          <div className="decks-grid">
            {decksWithoutActivity.map(deck => (
              <DeckCard 
                key={deck.deck_pk} 
                deck={deck}
                isStarted={false}
              />
            ))}
          </div>
        </section>
      )}

      {/* Message si aucun deck */}
      {decks.length === 0 && (
        <div className="empty-state">
          <p>Aucun deck disponible pour le moment.</p>
        </div>
      )}
    </div>
  );
};
```

### 5. Composant Carte de Deck

```typescript
// components/DeckCard.tsx

import React from 'react';
import { UserDeck } from '../types/deck';
import { useNavigate } from 'react-router-dom';
import './DeckCard.css';

interface DeckCardProps {
  deck: UserDeck;
  isStarted: boolean;
}

export const DeckCard: React.FC<DeckCardProps> = ({ deck, isStarted }) => {
  const navigate = useNavigate();
  
  const totalCards = deck.mastered_cards + deck.learning_cards + deck.review_cards;

  // Déterminer la couleur de la précision
  const getPrecisionColor = (rate: number): string => {
    if (rate === 0) return 'var(--color-gray)';
    if (rate >= 80) return 'var(--color-success)';
    if (rate >= 50) return 'var(--color-warning)';
    return 'var(--color-danger)';
  };

  const handleStartQuiz = () => {
    navigate(`/quiz/${deck.deck_pk}`);
  };

  const handleViewStats = () => {
    navigate(`/deck/${deck.deck_pk}/stats`);
  };

  return (
    <div className={`deck-card ${!isStarted ? 'not-started' : ''}`}>
      {/* Badge "Nouveau" pour les decks non commencés */}
      {!isStarted && <div className="badge-new">Nouveau</div>}

      {/* En-tête */}
      <div className="deck-header">
        <div className="deck-icon">📚</div>
        <h3 className="deck-name">{deck.deck.name}</h3>
      </div>

      {/* Statistiques principales */}
      <div className="deck-stats">
        <div className="stat">
          <span className="stat-label">Cartes</span>
          <span className="stat-value">{totalCards}</span>
        </div>

        <div className="stat">
          <span className="stat-label">Précision</span>
          <span 
            className="stat-value"
            style={{ color: getPrecisionColor(deck.success_rate) }}
          >
            {deck.success_rate.toFixed(1)}%
          </span>
        </div>

        <div className="stat">
          <span className="stat-label">Points</span>
          <span className="stat-value">{deck.total_points}</span>
        </div>
      </div>

      {/* Barre de progression */}
      <div className="progress-bar-container">
        <div 
          className="progress-bar-fill"
          style={{ 
            width: `${deck.success_rate}%`,
            backgroundColor: getPrecisionColor(deck.success_rate)
          }}
        />
      </div>

      {/* Détails des cartes (Anki) */}
      <div className="card-breakdown">
        <div className="card-stat mastered">
          <span className="dot"></span>
          <span>{deck.mastered_cards} maîtrisées</span>
        </div>
        <div className="card-stat learning">
          <span className="dot"></span>
          <span>{deck.learning_cards} en cours</span>
        </div>
        <div className="card-stat review">
          <span className="dot"></span>
          <span>{deck.review_cards} à revoir</span>
        </div>
      </div>

      {/* Actions */}
      <div className="deck-actions">
        <button 
          className="btn-primary"
          onClick={handleStartQuiz}
        >
          {isStarted ? '▶️ Continuer' : '🚀 Commencer'}
        </button>
        
        {isStarted && (
          <button 
            className="btn-secondary"
            onClick={handleViewStats}
          >
            📊 Stats
          </button>
        )}
      </div>
    </div>
  );
};
```

### 6. Styles CSS

```css
/* MyDecksPage.css */

.my-decks-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.page-header {
  margin-bottom: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.page-header h1 {
  font-size: 2rem;
  font-weight: bold;
  color: var(--color-text-primary, #1f2937);
  margin: 0;
}

.subtitle {
  color: var(--color-text-secondary, #6b7280);
  font-size: 1rem;
  margin: 0.5rem 0 0 0;
}

.btn-refresh {
  padding: 0.75rem 1.5rem;
  background: var(--color-primary, #3b82f6);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.2s ease;
}

.btn-refresh:hover {
  background: var(--color-primary-dark, #2563eb);
  transform: translateY(-1px);
}

.decks-section {
  margin-bottom: 3rem;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--color-text-primary, #1f2937);
  margin-bottom: 1.5rem;
}

.decks-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: var(--color-text-secondary, #6b7280);
}

/* DeckCard.css */

.deck-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.deck-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform: translateY(-2px);
}

.deck-card.not-started {
  border: 2px dashed #e5e7eb;
  background: linear-gradient(135deg, #ffffff 0%, #f9fafb 100%);
}

.badge-new {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  box-shadow: 0 2px 4px rgba(59, 130, 246, 0.3);
}

.deck-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.deck-icon {
  font-size: 2rem;
}

.deck-name {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
  flex: 1;
}

.deck-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
  margin-bottom: 1rem;
}

.stat {
  text-align: center;
}

.stat-label {
  display: block;
  font-size: 0.75rem;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 0.25rem;
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: bold;
  color: #1f2937;
}

.progress-bar-container {
  width: 100%;
  height: 8px;
  background: #e5e7eb;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 1rem;
}

.progress-bar-fill {
  height: 100%;
  transition: width 0.5s ease;
  border-radius: 4px;
}

.card-breakdown {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 8px;
}

.card-stat {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #4b5563;
}

.card-stat .dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.card-stat.mastered .dot {
  background: #22c55e;
}

.card-stat.learning .dot {
  background: #f59e0b;
}

.card-stat.review .dot {
  background: #ef4444;
}

.deck-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-primary,
.btn-secondary {
  flex: 1;
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.875rem;
}

.btn-primary {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  color: white;
  box-shadow: 0 2px 4px rgba(59, 130, 246, 0.3);
}

.btn-primary:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(59, 130, 246, 0.4);
}

.btn-secondary {
  background: #f3f4f6;
  color: #4b5563;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

:root {
  --color-primary: #3b82f6;
  --color-primary-dark: #2563eb;
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-danger: #ef4444;
  --color-gray: #9ca3af;
  --color-text-primary: #1f2937;
  --color-text-secondary: #6b7280;
}
```

---

## 🟢 Implémentation Vue.js

### 1. Composable (Vue 3)

```typescript
// composables/useDecks.ts

import { ref, computed } from 'vue';
import type { Ref } from 'vue';
import type { UserDeck } from '@/types/deck';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000';

export function useDecks(token: Ref<string | null>) {
  const decks = ref<UserDeck[]>([]);
  const loading = ref(false);
  const error = ref<string | null>(null);

  const fetchDecks = async () => {
    if (!token.value) {
      error.value = 'Token non disponible';
      return;
    }

    try {
      loading.value = true;
      error.value = null;

      const response = await fetch(`${API_BASE_URL}/api/users/decks/all`, {
        headers: {
          'Authorization': `Bearer ${token.value}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      decks.value = await response.json();
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Erreur inconnue';
    } finally {
      loading.value = false;
    }
  };

  const decksWithActivity = computed(() => 
    decks.value.filter(d => d.total_attempts > 0)
  );

  const decksWithoutActivity = computed(() => 
    decks.value.filter(d => d.total_attempts === 0)
  );

  return {
    decks,
    loading,
    error,
    fetchDecks,
    decksWithActivity,
    decksWithoutActivity
  };
}
```

### 2. Composant Vue

```vue
<!-- pages/MyDecksPage.vue -->

<template>
  <div class="my-decks-page">
    <!-- En-tête -->
    <header class="page-header">
      <div>
        <h1>Mes Decks</h1>
        <p class="subtitle">
          {{ decks.length }} deck{{ decks.length > 1 ? 's' : '' }} disponible{{ decks.length > 1 ? 's' : '' }}
        </p>
      </div>
      <button @click="fetchDecks" class="btn-refresh">
        🔄 Actualiser
      </button>
    </header>

    <!-- Chargement -->
    <div v-if="loading" class="loading">
      <LoadingSpinner message="Chargement des decks..." />
    </div>

    <!-- Erreur -->
    <div v-else-if="error" class="error">
      <ErrorMessage :message="error" @retry="fetchDecks" />
    </div>

    <!-- Contenu -->
    <div v-else>
      <!-- Decks avec activité -->
      <section v-if="decksWithActivity.length > 0" class="decks-section">
        <h2 class="section-title">
          📚 En cours ({{ decksWithActivity.length }})
        </h2>
        <div class="decks-grid">
          <DeckCard
            v-for="deck in decksWithActivity"
            :key="deck.deck_pk"
            :deck="deck"
            :is-started="true"
          />
        </div>
      </section>

      <!-- Decks sans activité -->
      <section v-if="decksWithoutActivity.length > 0" class="decks-section">
        <h2 class="section-title">
          🆕 À découvrir ({{ decksWithoutActivity.length }})
        </h2>
        <div class="decks-grid">
          <DeckCard
            v-for="deck in decksWithoutActivity"
            :key="deck.deck_pk"
            :deck="deck"
            :is-started="false"
          />
        </div>
      </section>

      <!-- État vide -->
      <div v-if="decks.length === 0" class="empty-state">
        <p>Aucun deck disponible pour le moment.</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, computed } from 'vue';
import { useAuthStore } from '@/stores/auth';
import { useDecks } from '@/composables/useDecks';
import DeckCard from '@/components/DeckCard.vue';
import LoadingSpinner from '@/components/LoadingSpinner.vue';
import ErrorMessage from '@/components/ErrorMessage.vue';

const authStore = useAuthStore();
const token = computed(() => authStore.token);

const {
  decks,
  loading,
  error,
  fetchDecks,
  decksWithActivity,
  decksWithoutActivity
} = useDecks(token);

onMounted(() => {
  fetchDecks();
});
</script>

<style scoped>
/* Même CSS que React */
</style>
```

---

## 📝 Implémentation Vanilla JavaScript

```javascript
// decks.js

class DeckManager {
  constructor(apiBaseUrl = 'http://localhost:8000') {
    this.apiBaseUrl = apiBaseUrl;
    this.decks = [];
  }

  /**
   * Récupère tous les decks avec stats personnalisées
   */
  async fetchAllDecks(token) {
    try {
      const response = await fetch(`${this.apiBaseUrl}/api/users/decks/all`, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      this.decks = await response.json();
      return this.decks;
    } catch (error) {
      console.error('Erreur:', error);
      throw error;
    }
  }

  /**
   * Affiche les decks dans le DOM
   */
  renderDecks(containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;

    // Séparer les decks
    const withActivity = this.decks.filter(d => d.total_attempts > 0);
    const withoutActivity = this.decks.filter(d => d.total_attempts === 0);

    let html = '';

    // Decks avec activité
    if (withActivity.length > 0) {
      html += `
        <section class="decks-section">
          <h2>📚 En cours (${withActivity.length})</h2>
          <div class="decks-grid">
            ${withActivity.map(deck => this.createDeckCard(deck, true)).join('')}
          </div>
        </section>
      `;
    }

    // Decks sans activité
    if (withoutActivity.length > 0) {
      html += `
        <section class="decks-section">
          <h2>🆕 À découvrir (${withoutActivity.length})</h2>
          <div class="decks-grid">
            ${withoutActivity.map(deck => this.createDeckCard(deck, false)).join('')}
          </div>
        </section>
      `;
    }

    container.innerHTML = html;
  }

  /**
   * Crée le HTML d'une carte de deck
   */
  createDeckCard(deck, isStarted) {
    const totalCards = deck.mastered_cards + deck.learning_cards + deck.review_cards;
    const precisionColor = this.getPrecisionColor(deck.success_rate);

    return `
      <div class="deck-card ${!isStarted ? 'not-started' : ''}">
        ${!isStarted ? '<div class="badge-new">Nouveau</div>' : ''}
        
        <div class="deck-header">
          <div class="deck-icon">📚</div>
          <h3 class="deck-name">${deck.deck.name}</h3>
        </div>

        <div class="deck-stats">
          <div class="stat">
            <span class="stat-label">Cartes</span>
            <span class="stat-value">${totalCards}</span>
          </div>
          <div class="stat">
            <span class="stat-label">Précision</span>
            <span class="stat-value" style="color: ${precisionColor}">
              ${deck.success_rate.toFixed(1)}%
            </span>
          </div>
          <div class="stat">
            <span class="stat-label">Points</span>
            <span class="stat-value">${deck.total_points}</span>
          </div>
        </div>

        <div class="progress-bar-container">
          <div class="progress-bar-fill" style="width: ${deck.success_rate}%; background-color: ${precisionColor}"></div>
        </div>

        <div class="card-breakdown">
          <div class="card-stat mastered">
            <span class="dot"></span>
            <span>${deck.mastered_cards} maîtrisées</span>
          </div>
          <div class="card-stat learning">
            <span class="dot"></span>
            <span>${deck.learning_cards} en cours</span>
          </div>
          <div class="card-stat review">
            <span class="dot"></span>
            <span>${deck.review_cards} à revoir</span>
          </div>
        </div>

        <div class="deck-actions">
          <button class="btn-primary" onclick="startQuiz(${deck.deck_pk})">
            ${isStarted ? '▶️ Continuer' : '🚀 Commencer'}
          </button>
          ${isStarted ? `
            <button class="btn-secondary" onclick="viewStats(${deck.deck_pk})">
              📊 Stats
            </button>
          ` : ''}
        </div>
      </div>
    `;
  }

  getPrecisionColor(rate) {
    if (rate === 0) return '#9ca3af';
    if (rate >= 80) return '#22c55e';
    if (rate >= 50) return '#f59e0b';
    return '#ef4444';
  }
}

// Utilisation
const deckManager = new DeckManager();
const token = localStorage.getItem('access_token');

deckManager.fetchAllDecks(token)
  .then(() => {
    deckManager.renderDecks('decks-container');
  })
  .catch(error => {
    console.error('Erreur:', error);
  });
```

---

## 🧪 Tests Frontend

### Test avec Jest et React Testing Library

```typescript
// __tests__/MyDecksPage.test.tsx

import { render, screen, waitFor } from '@testing-library/react';
import { MyDecksPage } from '../pages/MyDecksPage';
import { DeckService } from '../services/deckService';

// Mock du service
jest.mock('../services/deckService');

describe('MyDecksPage', () => {
  const mockDecks = [
    {
      deck_pk: 1,
      deck: { name: 'Test Deck 1' },
      total_attempts: 10,
      success_rate: 75.0,
      total_points: 850,
      mastered_cards: 5,
      learning_cards: 3,
      review_cards: 2
    },
    {
      deck_pk: 2,
      deck: { name: 'Test Deck 2' },
      total_attempts: 0,
      success_rate: 0.0,
      total_points: 0,
      mastered_cards: 0,
      learning_cards: 0,
      review_cards: 0
    }
  ];

  beforeEach(() => {
    localStorage.setItem('access_token', 'fake-token');
    (DeckService.getAllDecksWithUserStats as jest.Mock).mockResolvedValue(mockDecks);
  });

  it('affiche tous les decks', async () => {
    render(<MyDecksPage />);

    await waitFor(() => {
      expect(screen.getByText('Test Deck 1')).toBeInTheDocument();
      expect(screen.getByText('Test Deck 2')).toBeInTheDocument();
    });
  });

  it('affiche 0% pour les decks non commencés', async () => {
    render(<MyDecksPage />);

    await waitFor(() => {
      const deck2 = screen.getByText('Test Deck 2').closest('.deck-card');
      expect(deck2).toHaveTextContent('0.0%');
    });
  });

  it('affiche le badge "Nouveau" pour les decks non commencés', async () => {
    render(<MyDecksPage />);

    await waitFor(() => {
      const badges = screen.getAllByText('Nouveau');
      expect(badges.length).toBeGreaterThan(0);
    });
  });
});
```

---

## 🔧 Dépannage

### Problème 1 : Les decks ne s'affichent pas

**Vérifications :**
1. Ouvrir DevTools (F12) → Network
2. Chercher la requête `GET /api/users/decks/all`
3. Vérifier le status code (devrait être 200)
4. Vérifier la réponse JSON

**Solution :**
```javascript
// Ajouter des logs pour déboguer
console.log('Token:', token);
console.log('Réponse API:', await response.json());
```

### Problème 2 : Erreur CORS

**Symptôme :** `Access to fetch has been blocked by CORS policy`

**Solution backend :** Vérifier que le backend autorise votre domaine frontend

### Problème 3 : Tous les decks sont à 0% même après quiz

**Vérification :**
1. Vérifier que le quiz soumet bien les scores
2. Vérifier que `deck_pk` est envoyé avec chaque score
3. Rafraîchir les decks après le quiz

**Solution :**
```typescript
// Après avoir terminé un quiz
await submitAllScores();
await refetchDecks(); // ← Important !
```

---

## ✅ Checklist d'Implémentation

- [ ] Modifier l'URL de l'API : `/api/users/decks` → `/api/users/decks/all`
- [ ] Mettre à jour les types TypeScript
- [ ] Tester avec un nouveau compte (tous les decks à 0%)
- [ ] Tester avec un compte actif (précisions personnalisées)
- [ ] Vérifier l'affichage du badge "Nouveau"
- [ ] Tester le rafraîchissement après un quiz
- [ ] Vérifier la performance (45 decks)
- [ ] Tester sur mobile/tablette

---

**Document créé le :** 30 novembre 2025  
**Version :** 1.0.0  
**Pour :** Équipe Frontend
