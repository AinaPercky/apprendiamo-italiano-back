# 🎯 CODE FRONTEND À MODIFIER - Dashboard

**Statut Backend** : ✅ Fonctionne parfaitement  
**Données en base** : ✅ Confirmées (10 tentatives, 1 correcte, 10.0%)  
**Problème** : Frontend n'affiche pas les bonnes données

---

## 📝 Fichiers à Modifier

### 1. Service Dashboard (`src/services/dashboardApi.ts`)

**Créez ou modifiez ce fichier** :

```typescript
import axios from 'axios';

export interface DeckWithStats {
  deck_pk: number;
  name: string;
  description: string;
  total_cards: number;
  user_stats: {
    correct_count: number;
    attempt_count: number;
    success_rate: number;
    last_studied: string | null;
  };
}

export interface GlobalStats {
  total_score: number;
  total_attempts: number;
  average_success_rate: number;
  decks_started: number;
}

export const dashboardApi = {
  /**
   * Récupère tous les decks avec les stats utilisateur
   */
  async getAllDecksWithStats(): Promise<DeckWithStats[]> {
    const { data } = await axios.get('/api/users/decks/all');
    return data;
  },

  /**
   * Calcule les stats globales à partir des decks
   */
  async getGlobalStats(): Promise<GlobalStats> {
    const decks = await this.getAllDecksWithStats();
    
    const totalAttempts = decks.reduce((sum, deck) => 
      sum + (deck.user_stats?.attempt_count ?? 0), 0
    );
    
    const totalCorrect = decks.reduce((sum, deck) => 
      sum + (deck.user_stats?.correct_count ?? 0), 0
    );
    
    const decksStarted = decks.filter(deck => 
      (deck.user_stats?.attempt_count ?? 0) > 0
    ).length;
    
    const averageSuccessRate = totalAttempts > 0
      ? (totalCorrect / totalAttempts) * 100
      : 0;
    
    return {
      total_score: totalCorrect,
      total_attempts: totalAttempts,
      average_success_rate: averageSuccessRate,
      decks_started: decksStarted
    };
  }
};
```

---

### 2. Composant Dashboard (`src/pages/Dashboard.tsx`)

**Modifiez votre composant Dashboard** :

```typescript
import React, { useState, useEffect } from 'react';
import { dashboardApi, GlobalStats, DeckWithStats } from '../services/dashboardApi';

export const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<GlobalStats | null>(null);
  const [decks, setDecks] = useState<DeckWithStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadDashboard();
  }, []);

  const loadDashboard = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // Charger les decks
      const decksData = await dashboardApi.getAllDecksWithStats();
      setDecks(decksData);
      
      // Calculer les stats globales
      const statsData = await dashboardApi.getGlobalStats();
      setStats(statsData);
      
      console.log('📊 Stats chargées:', statsData);
      console.log('📚 Decks chargés:', decksData);
      
    } catch (err: any) {
      console.error('❌ Erreur chargement dashboard:', err);
      setError(err.message || 'Erreur lors du chargement');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="spinner"></div>
        <p>Chargement...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="dashboard-error">
        <p>❌ {error}</p>
        <button onClick={loadDashboard}>Réessayer</button>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h1>Tableau de bord</h1>
        <button onClick={loadDashboard} className="btn-refresh">
          🔄 Rafraîchir
        </button>
      </div>

      {/* Stats Globales */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon">📊</div>
          <div className="stat-content">
            <div className="stat-label">Total scores</div>
            <div className="stat-value">
              {stats?.total_score ?? 0}
            </div>
            <div className="stat-subtitle">Points accumulés</div>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">📈</div>
          <div className="stat-content">
            <div className="stat-label">Score moyen</div>
            <div className="stat-value">
              {stats?.average_success_rate?.toFixed(1) ?? '0.0'}
            </div>
            <div className="stat-subtitle">Par quiz</div>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">🎯</div>
          <div className="stat-content">
            <div className="stat-label">Enregistrements</div>
            <div className="stat-value">0</div>
            <div className="stat-subtitle">Audio</div>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon">📚</div>
          <div className="stat-content">
            <div className="stat-label">Decks</div>
            <div className="stat-value">
              {stats?.decks_started ?? 0}
            </div>
            <div className="stat-subtitle">Collections</div>
          </div>
        </div>
      </div>

      {/* Performance Globale */}
      <div className="performance-section">
        <h2>Performance globale</h2>
        <p className="subtitle">Vue d'ensemble de vos statistiques</p>

        <div className="performance-chart">
          {stats && stats.total_attempts > 0 ? (
            <div className="chart-container">
              <div className="pie-chart">
                <svg viewBox="0 0 200 200" width="200" height="200">
                  <circle
                    cx="100"
                    cy="100"
                    r="80"
                    fill="none"
                    stroke="#e0e0e0"
                    strokeWidth="40"
                  />
                  <circle
                    cx="100"
                    cy="100"
                    r="80"
                    fill="none"
                    stroke="#4caf50"
                    strokeWidth="40"
                    strokeDasharray={`${(stats.average_success_rate / 100) * 502.4} 502.4`}
                    transform="rotate(-90 100 100)"
                  />
                  <text
                    x="100"
                    y="100"
                    textAnchor="middle"
                    dy="0.3em"
                    fontSize="32"
                    fontWeight="bold"
                    fill="#333"
                  >
                    {stats.average_success_rate.toFixed(1)}%
                  </text>
                </svg>
              </div>
              <div className="chart-legend">
                <div className="legend-item">
                  <div className="legend-color" style={{ backgroundColor: '#4caf50' }}></div>
                  <div className="legend-text">
                    <div className="legend-label">Decks: {stats.decks_started}</div>
                  </div>
                </div>
                <div className="legend-item">
                  <div className="legend-color" style={{ backgroundColor: '#2196f3' }}></div>
                  <div className="legend-text">
                    <div className="legend-label">
                      Scores: {stats.total_score}/{stats.total_attempts}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div className="no-data">
              <p>Aucune donnée disponible</p>
              <p className="subtitle">Commencez un quiz pour voir vos statistiques</p>
            </div>
          )}
        </div>
      </div>

      {/* Liste des Decks */}
      <div className="decks-section">
        <h2>Mes Decks</h2>
        <div className="deck-grid">
          {decks.map(deck => {
            const successRate = deck.user_stats?.success_rate ?? 0;
            const attemptCount = deck.user_stats?.attempt_count ?? 0;
            const correctCount = deck.user_stats?.correct_count ?? 0;
            const isStarted = attemptCount > 0;

            return (
              <div key={deck.deck_pk} className={`deck-card ${!isStarted ? 'new' : ''}`}>
                <h3>{deck.name}</h3>
                <p className="deck-description">{deck.description}</p>

                {isStarted ? (
                  <>
                    <div className="deck-progress">
                      <div className="progress-bar">
                        <div 
                          className="progress-fill"
                          style={{ width: `${successRate}%` }}
                        ></div>
                      </div>
                      <div className="progress-text">
                        {successRate.toFixed(1)}% de réussite
                      </div>
                    </div>

                    <div className="deck-stats-mini">
                      <span>{correctCount}/{attemptCount} correctes</span>
                      {deck.user_stats.last_studied && (
                        <span className="last-studied">
                          Dernière révision: {new Date(deck.user_stats.last_studied).toLocaleDateString('fr-FR')}
                        </span>
                      )}
                    </div>
                  </>
                ) : (
                  <div className="deck-new-badge">
                    ✨ À découvrir
                  </div>
                )}

                <button 
                  className="btn-start-quiz"
                  onClick={() => window.location.href = `/deck/${deck.deck_pk}/quiz?type=typing`}
                >
                  {isStarted ? 'Continuer' : 'Commencer'}
                </button>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
```

---

### 3. Rafraîchir Après un Quiz

**Dans votre composant Quiz**, après la fin du quiz :

```typescript
const handleQuizComplete = async (sessionId: number, correct: number, total: number) => {
  try {
    // 1. Finaliser le quiz
    await quizApi.completeQuiz(sessionId, correct, total);
    
    // 2. ⭐ IMPORTANT : Rafraîchir le dashboard
    // Option A : Redirection simple
    window.location.href = '/dashboard';
    
    // Option B : Navigation React Router
    // navigate('/dashboard');
    // window.location.reload();
    
  } catch (error) {
    console.error('Erreur finalisation quiz:', error);
  }
};
```

---

## 🧪 Test

### 1. Vérifier dans la Console du Navigateur

Après avoir modifié le code, ouvrez la console (F12) et rechargez le dashboard.

Vous devriez voir :
```javascript
📊 Stats chargées: {
  total_score: 1,
  total_attempts: 10,
  average_success_rate: 10.0,
  decks_started: 1
}

📚 Decks chargés: [
  {
    deck_pk: 8,
    name: "Verbi riflessivi",
    user_stats: {
      correct_count: 1,
      attempt_count: 10,
      success_rate: 10.0,
      last_studied: "2025-12-05T16:11:06"
    }
  }
]
```

### 2. Vérifier l'Affichage

Le dashboard devrait maintenant afficher :
- ✅ Total scores: **1**
- ✅ Score moyen: **10.0**
- ✅ Decks: **1**
- ✅ Verbi riflessivi: **10.0%** (1/10)

---

## 🔍 Debugging

Si ça ne fonctionne toujours pas :

### 1. Vérifier l'Endpoint

Ouvrez l'onglet Network (F12) et vérifiez que `/api/users/decks/all` est appelé.

### 2. Vérifier la Réponse

La réponse devrait être :
```json
[
  {
    "deck_pk": 8,
    "name": "Verbi riflessivi",
    "user_stats": {
      "correct_count": 1,
      "attempt_count": 10,
      "success_rate": 10.0,
      "last_studied": "2025-12-05T16:11:06.648545"
    }
  }
]
```

### 3. Vérifier les Logs

Ajoutez des console.log pour débugger :
```typescript
console.log('📊 Stats:', stats);
console.log('📚 Decks:', decks);
console.log('✅ Total score:', stats?.total_score);
console.log('✅ Average:', stats?.average_success_rate);
```

---

## ✅ Checklist

- [ ] Fichier `dashboardApi.ts` créé/modifié
- [ ] Composant `Dashboard.tsx` modifié
- [ ] Rafraîchissement après quiz ajouté
- [ ] Dashboard rechargé dans le navigateur
- [ ] Console vérifiée (pas d'erreur)
- [ ] Network tab vérifié (endpoint appelé)
- [ ] Affichage vérifié (scores corrects)

---

## 🎯 Résultat Attendu

Après modification, le dashboard devrait afficher :

```
Dashboard:
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│ Total scores    │ Score moyen     │ Enregistrements │ Decks           │
│ 1               │ 10.0            │ 0               │ 1               │
│ Points accumulés│ Par quiz        │ Audio           │ Collections     │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘

Mes Decks:
┌─────────────────────────────────────────────────────────────────────┐
│ Verbi riflessivi                                                    │
│ ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 10.0%  │
│ 1/10 correctes                                                      │
│ Dernière révision: 05/12/2025                                       │
│ [Continuer]                                                         │
└─────────────────────────────────────────────────────────────────────┘
```

---

**Créé le** : 5 décembre 2025  
**Statut** : ✅ Backend OK - Code frontend fourni  
**Action** : Copier-coller le code ci-dessus
