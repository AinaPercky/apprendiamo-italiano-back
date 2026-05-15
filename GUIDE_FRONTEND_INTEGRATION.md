# 🎯 Guide Frontend : Intégration Quiz Après Correction

## ✅ Problème Résolu

Le bug où les scores n'étaient pas enregistrés dans `user_decks` a été **corrigé côté backend**.

**Changement principal :** `user_deck` est maintenant créé **automatiquement** lors du premier score.

---

## 🔄 Flux Simplifié (Nouveau)

```
1. Utilisateur clique sur "Commencer le Quiz"
   ↓
2. Frontend : GET /cards/?deck_pk={deck_id}
   (Charge les cartes du deck)
   ↓
3. Utilisateur répond aux cartes
   ↓
4. Frontend : POST /api/users/scores (pour chaque réponse)
   {
     "deck_pk": 40,      ✅ OBLIGATOIRE
     "card_pk": 972,     ✅ OBLIGATOIRE
     "score": 85,
     "is_correct": true,
     "time_spent": 5,
     "quiz_type": "frappe"
   }
   ↓
5. Backend : Crée automatiquement user_deck si nécessaire
   ↓
6. Frontend : GET /api/users/decks
   (Récupère les stats pour le dashboard)
   ↓
7. Dashboard affiche les vraies stats ✅
```

---

## 🚫 Ce Qu'il NE FAUT PLUS Faire

### ❌ SUPPRIMER CET APPEL

```javascript
// ❌ NE PLUS FAIRE ÇA
try {
  await userDecksApi.addDeckToUser(parseInt(deckId));
  console.log('✅ Deck added to user collection');
} catch (error) {
  if (error?.response?.status === 400 || error?.response?.status === 409) {
    console.log('ℹ️ Deck already in user collection');
  }
}
```

**Raison :** Le backend crée maintenant `user_deck` automatiquement lors du premier score.

---

## ✅ Code Frontend Recommandé

### 1. Charger les Cartes du Deck

```javascript
/**
 * Charge les cartes d'un deck
 * @param {number} deckId - ID du deck
 * @returns {Promise<Array>} Liste des cartes
 */
async function loadDeckCards(deckId) {
  try {
    const response = await fetch(
      `${API_BASE_URL}/cards/?deck_pk=${deckId}`,
      {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
          // Pas d'authentification nécessaire pour les cartes
        }
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to load cards: ${response.status}`);
    }

    const cards = await response.json();
    return cards;
  } catch (error) {
    console.error('Error loading cards:', error);
    throw error;
  }
}
```

### 2. Soumettre un Score

```javascript
/**
 * Soumet le score d'une carte
 * @param {Object} scoreData - Données du score
 * @returns {Promise<Object>} Réponse du serveur
 */
async function submitScore(scoreData) {
  const token = localStorage.getItem('access_token');
  
  if (!token) {
    throw new Error('User not authenticated');
  }

  // 🚨 VALIDATION IMPORTANTE
  if (!scoreData.deck_pk || !scoreData.card_pk) {
    throw new Error('deck_pk and card_pk are required');
  }

  try {
    const response = await fetch(`${API_BASE_URL}/api/users/scores`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify({
        deck_pk: scoreData.deck_pk,      // ✅ OBLIGATOIRE
        card_pk: scoreData.card_pk,      // ✅ OBLIGATOIRE
        score: scoreData.score,           // ✅ OBLIGATOIRE (0-100)
        is_correct: scoreData.is_correct, // ✅ OBLIGATOIRE
        time_spent: scoreData.time_spent, // Optionnel (en secondes)
        quiz_type: scoreData.quiz_type    // Optionnel (défaut: "classique")
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Failed to submit score');
    }

    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Error submitting score:', error);
    throw error;
  }
}
```

### 3. Récupérer les Stats du Dashboard

```javascript
/**
 * Récupère les statistiques de tous les decks de l'utilisateur
 * @returns {Promise<Array>} Liste des decks avec stats
 */
async function getUserDecksStats() {
  const token = localStorage.getItem('access_token');
  
  if (!token) {
    throw new Error('User not authenticated');
  }

  try {
    const response = await fetch(`${API_BASE_URL}/api/users/decks`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!response.ok) {
      throw new Error('Failed to fetch user decks');
    }

    const decks = await response.json();
    return decks;
  } catch (error) {
    console.error('Error fetching user decks:', error);
    throw error;
  }
}
```

---

## 🎮 Exemple Complet : Gestionnaire de Quiz

```javascript
class QuizManager {
  constructor(deckId, quizType = 'frappe') {
    this.deckId = deckId;
    this.quizType = quizType;
    this.cards = [];
    this.currentIndex = 0;
    this.startTime = null;
  }

  /**
   * Initialise le quiz
   */
  async initialize() {
    try {
      // Charger les cartes
      this.cards = await loadDeckCards(this.deckId);
      console.log(`✅ Loaded ${this.cards.length} cards`);
      
      // Mélanger les cartes (optionnel)
      this.shuffleCards();
      
      // Démarrer le chrono pour la première carte
      this.startTime = Date.now();
      
      return true;
    } catch (error) {
      console.error('Failed to initialize quiz:', error);
      return false;
    }
  }

  /**
   * Obtient la carte actuelle
   */
  getCurrentCard() {
    if (this.currentIndex < this.cards.length) {
      return this.cards[this.currentIndex];
    }
    return null;
  }

  /**
   * Soumet la réponse de l'utilisateur
   */
  async submitAnswer(userAnswer) {
    const card = this.getCurrentCard();
    if (!card) return null;

    // Calculer le temps passé
    const timeSpent = Math.floor((Date.now() - this.startTime) / 1000);
    
    // Vérifier si la réponse est correcte
    const correctAnswer = card.back.toLowerCase().trim();
    const userAnswerNormalized = userAnswer.toLowerCase().trim();
    const isCorrect = userAnswerNormalized === correctAnswer;
    
    // Calculer le score (0-100)
    let score = 0;
    if (isCorrect) {
      score = 100;
    } else {
      // Score partiel basé sur la similarité
      const similarity = this.calculateSimilarity(
        userAnswerNormalized,
        correctAnswer
      );
      score = Math.floor(similarity * 100);
    }

    try {
      // 🚨 IMPORTANT : Toujours inclure deck_pk et card_pk
      const result = await submitScore({
        deck_pk: this.deckId,      // ✅ OBLIGATOIRE
        card_pk: card.card_pk,     // ✅ OBLIGATOIRE
        score: score,              // ✅ OBLIGATOIRE
        is_correct: isCorrect,     // ✅ OBLIGATOIRE
        time_spent: timeSpent,     // Optionnel
        quiz_type: this.quizType   // Optionnel
      });

      console.log('✅ Score submitted:', result);
      return { success: true, score, isCorrect, result };
    } catch (error) {
      console.error('❌ Failed to submit score:', error);
      return { success: false, error };
    }
  }

  /**
   * Passe à la carte suivante
   */
  nextCard() {
    this.currentIndex++;
    if (this.currentIndex < this.cards.length) {
      this.startTime = Date.now();
      return this.getCurrentCard();
    }
    return null;
  }

  /**
   * Vérifie si le quiz est terminé
   */
  isFinished() {
    return this.currentIndex >= this.cards.length;
  }

  /**
   * Récupère les stats finales
   */
  async getFinalStats() {
    try {
      const allDecks = await getUserDecksStats();
      const currentDeck = allDecks.find(d => d.deck_pk === this.deckId);
      return currentDeck || null;
    } catch (error) {
      console.error('Failed to get final stats:', error);
      return null;
    }
  }

  // Utilitaires
  shuffleCards() {
    for (let i = this.cards.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [this.cards[i], this.cards[j]] = [this.cards[j], this.cards[i]];
    }
  }

  calculateSimilarity(str1, str2) {
    // Levenshtein distance
    const len1 = str1.length;
    const len2 = str2.length;
    const matrix = [];

    for (let i = 0; i <= len1; i++) {
      matrix[i] = [i];
    }
    for (let j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (let i = 1; i <= len1; i++) {
      for (let j = 1; j <= len2; j++) {
        const cost = str1[i - 1] === str2[j - 1] ? 0 : 1;
        matrix[i][j] = Math.min(
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        );
      }
    }

    const distance = matrix[len1][len2];
    const maxLen = Math.max(len1, len2);
    return maxLen === 0 ? 1 : 1 - distance / maxLen;
  }
}
```

---

## 🎯 Utilisation dans un Composant React

```jsx
import { useState, useEffect } from 'react';

function QuizComponent({ deckId }) {
  const [quiz, setQuiz] = useState(null);
  const [currentCard, setCurrentCard] = useState(null);
  const [userAnswer, setUserAnswer] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isFinished, setIsFinished] = useState(false);
  const [finalStats, setFinalStats] = useState(null);

  // Initialiser le quiz au montage
  useEffect(() => {
    async function initQuiz() {
      const quizManager = new QuizManager(deckId, 'frappe');
      const success = await quizManager.initialize();
      
      if (success) {
        setQuiz(quizManager);
        setCurrentCard(quizManager.getCurrentCard());
      }
    }
    
    initQuiz();
  }, [deckId]);

  // Soumettre la réponse
  const handleSubmit = async (e) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      // Soumettre la réponse
      const result = await quiz.submitAnswer(userAnswer);
      
      if (result.success) {
        console.log(`Score: ${result.score}/100, Correct: ${result.isCorrect}`);
        
        // Passer à la carte suivante
        const nextCard = quiz.nextCard();
        
        if (nextCard) {
          setCurrentCard(nextCard);
          setUserAnswer('');
        } else {
          // Quiz terminé
          setIsFinished(true);
          const stats = await quiz.getFinalStats();
          setFinalStats(stats);
        }
      }
    } catch (error) {
      console.error('Error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isFinished) {
    return (
      <div className="quiz-finished">
        <h2>Quiz Terminé !</h2>
        {finalStats && (
          <div className="stats">
            <p>Points totaux: {finalStats.total_points}</p>
            <p>Tentatives: {finalStats.total_attempts}</p>
            <p>Réussites: {finalStats.successful_attempts}</p>
            <p>Taux de réussite: {
              (finalStats.successful_attempts / finalStats.total_attempts * 100).toFixed(1)
            }%</p>
          </div>
        )}
      </div>
    );
  }

  if (!currentCard) {
    return <div>Chargement...</div>;
  }

  return (
    <div className="quiz-container">
      <h2>Carte {quiz.currentIndex + 1}/{quiz.cards.length}</h2>
      <div className="card-front">{currentCard.front}</div>
      
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={userAnswer}
          onChange={(e) => setUserAnswer(e.target.value)}
          placeholder="Votre réponse..."
          disabled={isLoading}
          autoFocus
        />
        <button type="submit" disabled={isLoading || !userAnswer}>
          {isLoading ? 'Envoi...' : 'Valider'}
        </button>
      </form>
    </div>
  );
}

export default QuizComponent;
```

---

## 📊 Affichage du Dashboard

```jsx
import { useState, useEffect } from 'react';

function DashboardComponent() {
  const [decks, setDecks] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function loadStats() {
      try {
        const userDecks = await getUserDecksStats();
        setDecks(userDecks);
      } catch (error) {
        console.error('Failed to load stats:', error);
      } finally {
        setIsLoading(false);
      }
    }
    
    loadStats();
  }, []);

  if (isLoading) {
    return <div>Chargement des statistiques...</div>;
  }

  if (decks.length === 0) {
    return (
      <div className="empty-state">
        <p>Aucun deck joué pour le moment.</p>
        <p>Commencez un quiz pour voir vos statistiques !</p>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <h1>Mes Statistiques</h1>
      
      {decks.map(deck => (
        <div key={deck.deck_pk} className="deck-stats">
          <h2>{deck.deck.name}</h2>
          
          <div className="stats-grid">
            <div className="stat">
              <span className="label">Points totaux</span>
              <span className="value">{deck.total_points}</span>
            </div>
            
            <div className="stat">
              <span className="label">Tentatives</span>
              <span className="value">{deck.total_attempts}</span>
            </div>
            
            <div className="stat">
              <span className="label">Taux de réussite</span>
              <span className="value">
                {(deck.successful_attempts / deck.total_attempts * 100).toFixed(1)}%
              </span>
            </div>
            
            <div className="stat">
              <span className="label">Cartes maîtrisées</span>
              <span className="value">{deck.mastered_cards}</span>
            </div>
          </div>
          
          <div className="quiz-types">
            <h3>Points par type de quiz</h3>
            <ul>
              <li>Frappe: {deck.points_frappe}</li>
              <li>Association: {deck.points_association}</li>
              <li>QCM: {deck.points_qcm}</li>
              <li>Classique: {deck.points_classique}</li>
            </ul>
          </div>
          
          <div className="last-studied">
            Dernière étude: {new Date(deck.last_studied).toLocaleString()}
          </div>
        </div>
      ))}
    </div>
  );
}

export default DashboardComponent;
```

---

## ✅ Checklist d'Intégration

### Modifications à Faire

- [ ] Supprimer l'appel `POST /api/users/decks/{id}` avant le quiz
- [ ] Vérifier que `deck_pk` est toujours envoyé dans `submitScore()`
- [ ] Vérifier que `card_pk` est toujours envoyé dans `submitScore()`
- [ ] Tester le flux complet : quiz → dashboard
- [ ] Valider que les stats s'affichent correctement

### Tests à Effectuer

- [ ] Créer un nouveau compte
- [ ] Faire un quiz complet
- [ ] Vérifier que le dashboard affiche les stats
- [ ] Faire un deuxième quiz sur le même deck
- [ ] Vérifier que les stats sont mises à jour
- [ ] Se déconnecter et se reconnecter
- [ ] Vérifier que les stats persistent

---

## 🐛 Debugging

### Si les Stats ne S'affichent Pas

1. **Vérifier la console du navigateur**
   ```javascript
   // Ajouter des logs
   console.log('Submitting score:', scoreData);
   console.log('Response:', result);
   ```

2. **Vérifier la réponse de l'API**
   ```javascript
   const result = await submitScore(scoreData);
   console.log('deck_pk in response:', result.deck_pk);
   // Doit être un nombre, pas null
   ```

3. **Vérifier les stats**
   ```javascript
   const decks = await getUserDecksStats();
   console.log('User decks:', decks);
   // Doit contenir au moins un deck après le quiz
   ```

### Erreurs Courantes

| Erreur | Cause | Solution |
|--------|-------|----------|
| `deck_pk is required` | `deck_pk` manquant dans le payload | Ajouter `deck_pk` dans `submitScore()` |
| `card_pk is required` | `card_pk` manquant dans le payload | Ajouter `card_pk` dans `submitScore()` |
| `401 Unauthorized` | Token manquant ou expiré | Vérifier `localStorage.getItem('access_token')` |
| Dashboard vide | Backend pas redémarré | Redémarrer le serveur backend |

---

## 📞 Support

Pour toute question ou problème :

1. Consulter `SOLUTION_COMPLETE_SCORES.md`
2. Consulter `FRONTEND_API_GUIDE.md`
3. Vérifier les logs du backend
4. Tester l'API avec curl ou Postman

---

**Document créé le :** 25 novembre 2025  
**Version :** 1.0.0  
**Status :** ✅ Prêt pour l'Intégration
