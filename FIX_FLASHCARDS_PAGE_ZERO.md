# 🔧 Correction Page Flashcards - Affichage 0.0%

**Problème** : La page Flashcards affiche toujours 0.0% de précision même après avoir terminé un quiz.

**Données en base** : ✅ Confirmées (10 tentatives, 1 correcte, 10.0% pour Verbi riflessivi)

---

## 🎯 Problème Identifié

La page Flashcards ne se met pas à jour après un quiz. Elle affiche :
- ❌ Verbi riflessivi: 0.0% (devrait être 10.0%)
- ❌ 0 maîtrisées (devrait être 1/10)
- ❌ 40 à revoir (devrait être 9)

---

## ✅ Solution : Utiliser `/api/users/decks/all`

### 1. Service API pour Flashcards

Créez ou modifiez `src/services/deckApi.ts` :

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

export const deckApi = {
  /**
   * Récupère tous les decks avec les stats utilisateur
   */
  async getAllDecksWithStats(): Promise<DeckWithStats[]> {
    const { data } = await axios.get('/api/users/decks/all');
    return data;
  },

  /**
   * Récupère un deck spécifique avec ses stats
   */
  async getDeckWithStats(deckId: number): Promise<DeckWithStats> {
    const decks = await this.getAllDecksWithStats();
    const deck = decks.find(d => d.deck_pk === deckId);
    
    if (!deck) {
      throw new Error(`Deck ${deckId} not found`);
    }
    
    return deck;
  }
};
```

---

### 2. Composant Flashcards

Modifiez `src/pages/Flashcards.tsx` :

```typescript
import React, { useState, useEffect } from 'react';
import { deckApi, DeckWithStats } from '../services/deckApi';

export const Flashcards: React.FC = () => {
  const [decks, setDecks] = useState<DeckWithStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadDecks();
  }, []);

  const loadDecks = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const data = await deckApi.getAllDecksWithStats();
      setDecks(data);
      
      console.log('📚 Decks chargés:', data);
      
    } catch (err: any) {
      console.error('❌ Erreur chargement decks:', err);
      setError(err.message || 'Erreur lors du chargement');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="loading">Chargement...</div>;
  }

  if (error) {
    return (
      <div className="error">
        <p>❌ {error}</p>
        <button onClick={loadDecks}>Réessayer</button>
      </div>
    );
  }

  // Séparer les decks en deux catégories
  const startedDecks = decks.filter(deck => 
    (deck.user_stats?.attempt_count ?? 0) > 0
  );
  
  const newDecks = decks.filter(deck => 
    (deck.user_stats?.attempt_count ?? 0) === 0
  );

  return (
    <div className="flashcards-page">
      <h1>Flashcards</h1>
      
      <button onClick={loadDecks} className="btn-refresh">
        🔄 Rafraîchir
      </button>

      {/* Decks Commencés */}
      {startedDecks.length > 0 && (
        <section className="decks-section">
          <h2>Mes Decks ({startedDecks.length})</h2>
          <div className="deck-grid">
            {startedDecks.map(deck => (
              <DeckCard key={deck.deck_pk} deck={deck} />
            ))}
          </div>
        </section>
      )}

      {/* Decks À Découvrir */}
      {newDecks.length > 0 && (
        <section className="decks-section">
          <h2>À découvrir ({newDecks.length})</h2>
          <div className="deck-grid">
            {newDecks.map(deck => (
              <DeckCard key={deck.deck_pk} deck={deck} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
};

// Composant pour une carte de deck
const DeckCard: React.FC<{ deck: DeckWithStats }> = ({ deck }) => {
  const successRate = deck.user_stats?.success_rate ?? 0;
  const attemptCount = deck.user_stats?.attempt_count ?? 0;
  const correctCount = deck.user_stats?.correct_count ?? 0;
  const isStarted = attemptCount > 0;

  // Calculer les statistiques
  const masteredCount = correctCount; // Cartes maîtrisées
  const inProgressCount = 0; // À implémenter selon votre logique
  const toReviewCount = deck.total_cards - masteredCount; // Cartes à revoir

  return (
    <div className={`deck-card ${!isStarted ? 'new' : ''}`}>
      <div className="deck-icon">📚</div>
      
      <h3>{deck.name}</h3>
      <p className="deck-total">{deck.total_cards} cartes</p>

      {/* Statistiques */}
      <div className="deck-stats">
        <div className="stat-row">
          <span className="stat-label">CARTES</span>
          <span className="stat-value">{deck.total_cards}</span>
        </div>
        
        <div className="stat-row">
          <span className="stat-label">PRÉCISION</span>
          <span className="stat-value">
            {successRate.toFixed(1)}%
          </span>
        </div>
        
        <div className="stat-row">
          <span className="stat-label">POINTS</span>
          <span className="stat-value">{correctCount}</span>
        </div>
      </div>

      {/* Détails */}
      {isStarted ? (
        <div className="deck-details">
          <div className="detail-item">
            <span className="dot green"></span>
            <span>{masteredCount} maîtrisées</span>
          </div>
          <div className="detail-item">
            <span className="dot orange"></span>
            <span>{inProgressCount} en cours</span>
          </div>
          <div className="detail-item">
            <span className="dot red"></span>
            <span>{toReviewCount} à revoir</span>
          </div>
        </div>
      ) : (
        <div className="deck-new-badge">
          ✨ Nouveau deck
        </div>
      )}

      {/* Boutons */}
      <div className="deck-actions">
        <button 
          className="btn-primary"
          onClick={() => window.location.href = `/deck/${deck.deck_pk}/quiz?type=typing`}
        >
          {isStarted ? 'Continuer' : 'Commencer'}
        </button>
        
        <button className="btn-secondary">Stats</button>
        <button className="btn-secondary">Gérer</button>
        <button className="btn-danger">Supprimer</button>
      </div>
    </div>
  );
};
```

---

### 3. Rafraîchir Après un Quiz

**IMPORTANT** : Après avoir terminé un quiz, vous devez rafraîchir la page Flashcards.

Dans votre composant Quiz :

```typescript
const handleQuizComplete = async (sessionId: number, correct: number, total: number) => {
  try {
    // 1. Finaliser le quiz
    await quizApi.completeQuiz(sessionId, correct, total);
    
    // 2. ⭐ Rediriger vers Flashcards
    window.location.href = '/flashcards';
    
  } catch (error) {
    console.error('Erreur finalisation quiz:', error);
  }
};
```

---

## 🎨 CSS pour les Cartes de Deck

```css
/* Flashcards.css */
.flashcards-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.btn-refresh {
  margin-bottom: 20px;
  padding: 10px 20px;
  background: #2196f3;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

.decks-section {
  margin-bottom: 40px;
}

.deck-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.deck-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  transition: transform 0.2s;
}

.deck-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.deck-card.new {
  border: 2px dashed #ccc;
}

.deck-icon {
  font-size: 32px;
  margin-bottom: 10px;
}

.deck-stats {
  margin: 20px 0;
  padding: 15px;
  background: #f5f5f5;
  border-radius: 8px;
}

.stat-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
}

.stat-row:last-child {
  margin-bottom: 0;
}

.stat-label {
  font-size: 12px;
  color: #666;
  font-weight: 600;
}

.stat-value {
  font-size: 16px;
  font-weight: 700;
  color: #333;
}

.deck-details {
  margin: 15px 0;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.dot.green {
  background: #4caf50;
}

.dot.orange {
  background: #ff9800;
}

.dot.red {
  background: #f44336;
}

.deck-new-badge {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 12px;
  border-radius: 8px;
  text-align: center;
  margin: 15px 0;
}

.deck-actions {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-top: 15px;
}

.btn-primary {
  grid-column: 1 / -1;
  padding: 12px;
  background: #4caf50;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
}

.btn-primary:hover {
  background: #45a049;
}

.btn-secondary {
  padding: 8px;
  background: #e0e0e0;
  color: #333;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
}

.btn-secondary:hover {
  background: #d0d0d0;
}

.btn-danger {
  grid-column: 1 / -1;
  padding: 8px;
  background: #f44336;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  cursor: pointer;
}

.btn-danger:hover {
  background: #da190b;
}
```

---

## 🧪 Test

### 1. Vérifier dans la Console

Après avoir modifié le code, rechargez la page Flashcards et ouvrez la console (F12).

Vous devriez voir :
```javascript
📚 Decks chargés: [
  {
    deck_pk: 8,
    name: "Verbi riflessivi",
    total_cards: 40,
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

La page Flashcards devrait maintenant afficher :
- ✅ Verbi riflessivi: **10.0%** (au lieu de 0.0%)
- ✅ Points: **1** (au lieu de 0)
- ✅ 1 maîtrisées (au lieu de 0)
- ✅ 39 à revoir (au lieu de 40)

---

## 🔍 Debugging

Si ça ne fonctionne toujours pas :

### 1. Vérifier l'Endpoint

Ouvrez l'onglet Network (F12) et vérifiez que `/api/users/decks/all` est appelé.

### 2. Vérifier la Réponse

La réponse devrait contenir `user_stats` avec `success_rate: 10.0`.

### 3. Ajouter des Logs

```typescript
console.log('📚 Deck:', deck);
console.log('✅ Success Rate:', deck.user_stats?.success_rate);
console.log('✅ Correct Count:', deck.user_stats?.correct_count);
console.log('✅ Attempt Count:', deck.user_stats?.attempt_count);
```

---

## ✅ Checklist

- [ ] Service `deckApi.ts` créé/modifié
- [ ] Composant `Flashcards.tsx` modifié
- [ ] CSS ajouté
- [ ] Page rechargée
- [ ] Console vérifiée (pas d'erreur)
- [ ] Network tab vérifié (endpoint appelé)
- [ ] Affichage vérifié (10.0% au lieu de 0.0%)

---

## 🎯 Résultat Attendu

Après modification, la page Flashcards devrait afficher :

```
Mes Decks (1)
┌─────────────────────────────────────────────────────────────┐
│ 📚 Verbi riflessivi                                         │
│ 40 cartes                                                   │
│                                                             │
│ CARTES      40                                              │
│ PRÉCISION   10.0%  ← Devrait afficher 10.0% au lieu de 0.0%│
│ POINTS      1      ← Devrait afficher 1 au lieu de 0       │
│                                                             │
│ • 1 maîtrisées                                              │
│ • 0 en cours                                                │
│ • 39 à revoir                                               │
│                                                             │
│ [Continuer]  [Stats]                                        │
│ [Gérer]      [Supprimer]                                    │
└─────────────────────────────────────────────────────────────┘
```

---

**Créé le** : 5 décembre 2025  
**Statut** : ✅ Code fourni  
**Action** : Modifier le composant Flashcards
