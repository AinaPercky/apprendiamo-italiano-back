# 📘 Guide API Frontend - Apprendiamo Italiano

> Guide complet pour l'intégration frontend avec le backend Apprendiamo Italiano
> Dernière mise à jour : 23 novembre 2025

---

## 🌐 Configuration de Base

### URL de Base
```javascript
const API_BASE_URL = "http://localhost:8000";
```

### Headers d'Authentification
Tous les endpoints protégés nécessitent un token Bearer :
```javascript
const headers = {
  "Content-Type": "application/json",
  "Authorization": `Bearer ${accessToken}`
};
```

---

## 🔐 Authentification

### 1. Inscription (Register)

**Endpoint :** `POST /api/users/register`

**Body :**
```json
{
  "email": "user@example.com",
  "full_name": "Jean Dupont",
  "password": "SecurePassword123!"
}
```

**Exemple JavaScript :**
```javascript
async function register(email, fullName, password) {
  try {
    const response = await fetch(`${API_BASE_URL}/api/users/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email,
        full_name: fullName,
        password
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Registration failed');
    }

    const data = await response.json();
    // Sauvegarder le token
    localStorage.setItem('access_token', data.access_token);
    return data;
  } catch (error) {
    console.error('Registration error:', error);
    throw error;
  }
}
```

**Réponse (201) :**
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "user": {
    "user_pk": 1,
    "email": "user@example.com",
    "full_name": "Jean Dupont",
    "is_active": true,
    "is_verified": false,
    "total_score": 0,
    "total_cards_learned": 0,
    "total_cards_reviewed": 0,
    "profile_picture": null,
    "bio": null,
    "created_at": "2025-11-23T10:00:00",
    "last_login": "2025-11-23T10:00:00"
  }
}
```

---

### 2. Connexion (Login)

**Endpoint :** `POST /api/users/login`

**Body :**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Exemple JavaScript :**
```javascript
async function login(email, password) {
  try {
    const response = await fetch(`${API_BASE_URL}/api/users/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ email, password })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.detail || 'Login failed');
    }

    const data = await response.json();
    localStorage.setItem('access_token', data.access_token);
    return data;
  } catch (error) {
    console.error('Login error:', error);
    throw error;
  }
}
```

**Réponse (200) :**
Même structure que l'inscription.

---

### 3. Déconnexion (Logout)

**Endpoint :** `POST /api/users/logout`

**Headers :** Authentification requise

**Exemple JavaScript :**
```javascript
async function logout() {
  const token = localStorage.getItem('access_token');
  
  try {
    await fetch(`${API_BASE_URL}/api/users/logout`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
  } finally {
    // Supprimer le token localement
    localStorage.removeItem('access_token');
  }
}
```

---

## 🃏 Gestion des Cartes

### 4. Récupérer les Cartes d'un Deck

**Endpoint :** `GET /cards/?deck_pk={deck_id}`

**🚨 IMPORTANT pour le Frontend :**
- Cet endpoint **NE NÉCESSITE PAS** d'authentification
- Les cartes sont publiques
- Utilisez cet endpoint pour charger les cartes avant un quiz

**Exemple JavaScript :**
```javascript
async function fetchDeckCards(deckId) {
  try {
    const response = await fetch(
      `${API_BASE_URL}/cards/?deck_pk=${deckId}`,
      {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to fetch cards: ${response.status}`);
    }

    const cards = await response.json();
    return cards;
  } catch (error) {
    console.error('Error fetching cards:', error);
    throw error;
  }
}
```

**Réponse (200) :**
```json
[
  {
    "card_pk": 972,
    "id_json": "card_972",
    "deck_pk": 40,
    "front": "Barman",
    "back": "Barista",
    "pronunciation": "ba-ris-ta",
    "image": null,
    "tags": ["profession", "travail"],
    "box": 0,
    "easiness": 2.5,
    "interval": 0,
    "consecutive_correct": 0,
    "created_at": "2025-11-23T10:00:00",
    "next_review": "2025-11-23T10:00:00"
  },
  {
    "card_pk": 973,
    "front": "Chauffeur de taxi",
    "back": "Tassista",
    "pronunciation": "tas-sis-ta",
    ...
  }
]
```

---

## 🎯 Gestion des Scores (QUIZ)

### 5. Enregistrer un Score 🚨 CRITIQUE

**Endpoint :** `POST /api/users/scores`

**Headers :** Authentification requise

**🚨 IMPORTANT - Correction du Bug deck_pk NULL :**

Le problème que vous rencontrez vient du fait que le frontend n'envoie pas le `deck_pk` dans le body. Les champs suivants sont **OBLIGATOIRES** :

- ✅ `deck_pk` (int) - **OBLIGATOIRE**
- ✅ `card_pk` (int) - **OBLIGATOIRE**
- ✅ `score` (int, 0-100) - **OBLIGATOIRE**
- ✅ `is_correct` (boolean) - **OBLIGATOIRE**
- ⚠️ `time_spent` (int, en secondes) - Optionnel
- ⚠️ `quiz_type` (string) - Optionnel, par défaut "classique"

**Body Correct :**
```json
{
  "deck_pk": 40,
  "card_pk": 972,
  "score": 85,
  "is_correct": true,
  "time_spent": 5,
  "quiz_type": "frappe"
}
```

**Types de Quiz Valides :**
- `"frappe"` - Quiz de frappe/typing
- `"association"` - Quiz d'association
- `"qcm"` - Quiz à choix multiples
- `"classique"` - Quiz classique recto-verso

**Exemple JavaScript Complet :**
```javascript
/**
 * Soumet un score pour une carte
 * @param {number} deckId - ID du deck (OBLIGATOIRE)
 * @param {number} cardId - ID de la carte (OBLIGATOIRE)
 * @param {number} score - Score entre 0 et 100 (OBLIGATOIRE)
 * @param {boolean} isCorrect - Réponse correcte ou non (OBLIGATOIRE)
 * @param {number} timeSpent - Temps passé en secondes (optionnel)
 * @param {string} quizType - Type de quiz (optionnel, défaut: "classique")
 */
async function submitScore(deckId, cardId, score, isCorrect, timeSpent = null, quizType = "classique") {
  const token = localStorage.getItem('access_token');
  
  if (!token) {
    throw new Error('User not authenticated');
  }

  // 🚨 VALIDATION IMPORTANTE
  if (!deckId || !cardId) {
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
        deck_pk: deckId,      // 🚨 OBLIGATOIRE
        card_pk: cardId,      // 🚨 OBLIGATOIRE
        score: score,         // 🚨 OBLIGATOIRE (0-100)
        is_correct: isCorrect, // 🚨 OBLIGATOIRE
        time_spent: timeSpent, // Optionnel
        quiz_type: quizType   // Optionnel
      })
    });

    if (!response.ok) {
      const error = await response.json();
      console.error('Score submission failed:', error);
      throw new Error(error.detail || 'Failed to submit score');
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error submitting score:', error);
    throw error;
  }
}
```

**Exemple d'utilisation dans un Quiz :**
```javascript
// Exemple avec TypeScript
interface QuizCard {
  card_pk: number;
  front: string;
  back: string;
  // ... autres champs
}

class QuizManager {
  private deckId: number;
  private cards: QuizCard[];
  private currentCardIndex: number = 0;
  private startTime: number;

  constructor(deckId: number) {
    this.deckId = deckId;
  }

  async loadCards() {
    this.cards = await fetchDeckCards(this.deckId);
    console.log(`Loaded ${this.cards.length} cards for deck ${this.deckId}`);
  }

  startCard() {
    this.startTime = Date.now();
  }

  async submitAnswer(userAnswer: string, quizType: string = "frappe") {
    const currentCard = this.cards[this.currentCardIndex];
    const correctAnswer = currentCard.back.toLowerCase().trim();
    const userAnswerNormalized = userAnswer.toLowerCase().trim();
    
    // Calculer si la réponse est correcte
    const isCorrect = userAnswerNormalized === correctAnswer;
    
    // Calculer le score (0-100)
    let score = 0;
    if (isCorrect) {
      score = 100;
    } else {
      // Calculer un score partiel basé sur la similarité
      const similarity = this.calculateSimilarity(userAnswerNormalized, correctAnswer);
      score = Math.floor(similarity * 100);
    }
    
    // Calculer le temps passé
    const timeSpent = Math.floor((Date.now() - this.startTime) / 1000);
    
    // 🚨 SOUMETTRE LE SCORE AVEC deck_pk
    try {
      const result = await submitScore(
        this.deckId,           // deck_pk - OBLIGATOIRE
        currentCard.card_pk,   // card_pk - OBLIGATOIRE
        score,                 // score (0-100)
        isCorrect,             // is_correct
        timeSpent,             // time_spent en secondes
        quizType               // quiz_type
      );
      
      console.log('Score submitted successfully:', result);
      return result;
    } catch (error) {
      console.error('Failed to submit score:', error);
      throw error;
    }
  }

  calculateSimilarity(str1: string, str2: string): number {
    // Implémentation simple de similarité (Levenshtein distance)
    const len1 = str1.length;
    const len2 = str2.length;
    const matrix = Array(len1 + 1).fill(null).map(() => Array(len2 + 1).fill(0));

    for (let i = 0; i <= len1; i++) matrix[i][0] = i;
    for (let j = 0; j <= len2; j++) matrix[0][j] = j;

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

  nextCard() {
    this.currentCardIndex++;
    if (this.currentCardIndex < this.cards.length) {
      this.startCard();
      return this.cards[this.currentCardIndex];
    }
    return null;
  }
}

// Utilisation
async function runQuiz(deckId: number) {
  const quiz = new QuizManager(deckId);
  await quiz.loadCards();
  
  // Commencer le quiz
  quiz.startCard();
  
  // Quand l'utilisateur soumet une réponse
  const userAnswer = "Barista"; // Exemple de réponse utilisateur
  await quiz.submitAnswer(userAnswer, "frappe");
  
  // Passer à la carte suivante
  const nextCard = quiz.nextCard();
  if (nextCard) {
    // Afficher la carte suivante
    console.log('Next card:', nextCard);
  } else {
    console.log('Quiz terminé!');
  }
}
```

**Réponse (201) :**
```json
{
  "score_pk": 1,
  "user_pk": 1,
  "deck_pk": 40,
  "card_pk": 972,
  "score": 85,
  "is_correct": true,
  "time_spent": 5,
  "quiz_type": "frappe",
  "created_at": "2025-11-23T11:00:00"
}
```

**Effets de bord automatiques :**
1. ✅ Mise à jour de la carte (algorithme Anki) :
   - `easiness`, `interval`, `consecutive_correct`, `next_review`, `box`
2. ✅ Mise à jour des stats utilisateur :
   - `total_score`, `total_cards_learned`, `total_cards_reviewed`
3. ✅ Création/Mise à jour du UserDeck :
   - Si le deck n'est pas dans la collection, il est ajouté automatiquement
   - `total_points`, `total_attempts`, `successful_attempts`
   - `points_{quiz_type}` (points_frappe, points_qcm, etc.)
   - `mastered_cards`, `learning_cards`, `review_cards`

---

### 6. Récupérer les Scores d'un Deck

**Endpoint :** `GET /api/users/scores/deck/{deck_pk}`

**Headers :** Authentification requise

**Exemple JavaScript :**
```javascript
async function getDeckScores(deckId) {
  const token = localStorage.getItem('access_token');
  
  try {
    const response = await fetch(
      `${API_BASE_URL}/api/users/scores/deck/${deckId}`,
      {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${token}`
        }
      }
    );

    if (!response.ok) {
      throw new Error('Failed to fetch scores');
    }

    const scores = await response.json();
    return scores;
  } catch (error) {
    console.error('Error fetching deck scores:', error);
    throw error;
  }
}
```

**Réponse (200) :**
```json
[
  {
    "score_pk": 1,
    "user_pk": 1,
    "deck_pk": 40,
    "card_pk": 972,
    "score": 85,
    "is_correct": true,
    "time_spent": 5,
    "quiz_type": "frappe",
    "created_at": "2025-11-23T11:00:00"
  },
  ...
]
```

---

## 📊 Statistiques des Decks

### 7. Récupérer les Decks de l'Utilisateur avec Stats

**Endpoint :** `GET /api/users/decks`

**Headers :** Authentification requise

**🎯 UTILISATION :** Cet endpoint retourne les statistiques complètes de tous les decks de l'utilisateur. Utilisez-le pour afficher les dashboards, les progrès, etc.

**Exemple JavaScript :**
```javascript
async function getUserDecks() {
  const token = localStorage.getItem('access_token');
  
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

**Réponse (200) :**
```json
[
  {
    "user_deck_pk": 1,
    "user_pk": 1,
    "deck_pk": 40,
    "deck": {
      "deck_pk": 40,
      "id_json": "deck_40",
      "name": "Professions",
      "total_correct": 150,
      "total_attempts": 200
    },
    "mastered_cards": 8,
    "learning_cards": 12,
    "review_cards": 5,
    "total_points": 2468,
    "total_attempts": 40,
    "successful_attempts": 26,
    "points_frappe": 613,
    "points_association": 503,
    "points_qcm": 572,
    "points_classique": 780,
    "added_at": "2025-11-23T10:00:00",
    "last_studied": "2025-11-23T15:30:00"
  }
]
```

**Exemple d'utilisation pour un Dashboard :**
```javascript
async function displayDashboard() {
  try {
    const decks = await getUserDecks();
    
    decks.forEach(deck => {
      const successRate = (deck.successful_attempts / deck.total_attempts * 100).toFixed(1);
      const progress = (deck.mastered_cards / (deck.mastered_cards + deck.learning_cards + deck.review_cards) * 100).toFixed(1);
      
      console.log(`
        Deck: ${deck.deck.name}
        📊 Points totaux: ${deck.total_points}
        ✅ Taux de réussite: ${successRate}%
        🎯 Progression: ${progress}%
        ⏰ Dernière étude: ${new Date(deck.last_studied).toLocaleString()}
        
        Répartition par type:
        - Frappe: ${deck.points_frappe} pts
        - Association: ${deck.points_association} pts
        - QCM: ${deck.points_qcm} pts
        - Classique: ${deck.points_classique} pts
      `);
    });
  } catch (error) {
    console.error('Dashboard error:', error);
  }
}
```

---

## 📈 Statistiques Globales

### 8. Statistiques Globales de l'Utilisateur

**Endpoint :** `GET /api/users/stats`

**Headers :** Authentification requise

**Exemple JavaScript :**
```javascript
async function getUserStats() {
  const token = localStorage.getItem('access_token');
  
  try {
    const response = await fetch(`${API_BASE_URL}/api/users/stats`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!response.ok) {
      throw new Error('Failed to fetch user stats');
    }

    const stats = await response.json();
    return stats;
  } catch (error) {
    console.error('Error fetching user stats:', error);
    throw error;
  }
}
```

**Réponse (200) :**
```json
{
  "total_score": 5240,
  "total_cards_learned": 156,
  "total_cards_reviewed": 342,
  "total_decks": 5,
  "total_audio_records": 23,
  "last_login": "2025-11-23T15:30:00"
}
```

---

## 🎨 Exemple Complet : Flow d'un Quiz

```javascript
/**
 * Exemple complet d'un flow de quiz
 */
class CompleteQuizFlow {
  constructor(deckId, quizType = 'frappe') {
    this.deckId = deckId;
    this.quizType = quizType;
    this.cards = [];
    this.currentIndex = 0;
    this.results = [];
  }

  /**
   * Étape 1: Initialiser le quiz
   */
  async initialize() {
    try {
      // Charger les cartes
      this.cards = await fetchDeckCards(this.deckId);
      console.log(`✅ Chargé ${this.cards.length} cartes`);
      
      // Mélanger les cartes (optionnel)
      this.cards = this.shuffleArray(this.cards);
      
      return true;
    } catch (error) {
      console.error('❌ Erreur d\'initialisation:', error);
      return false;
    }
  }

  /**
   * Étape 2: Obtenir la carte actuelle
   */
  getCurrentCard() {
    if (this.currentIndex < this.cards.length) {
      return this.cards[this.currentIndex];
    }
    return null;
  }

  /**
   * Étape 3: Soumettre une réponse
   */
  async submitAnswer(userAnswer, startTime) {
    const card = this.getCurrentCard();
    if (!card) return null;

    const timeSpent = Math.floor((Date.now() - startTime) / 1000);
    const isCorrect = this.checkAnswer(userAnswer, card.back);
    const score = this.calculateScore(userAnswer, card.back);

    try {
      // 🚨 IMPORTANT: Toujours inclure deck_pk
      const result = await submitScore(
        this.deckId,        // deck_pk ✅
        card.card_pk,       // card_pk ✅
        score,              // score (0-100) ✅
        isCorrect,          // is_correct ✅
        timeSpent,          // time_spent
        this.quizType       // quiz_type
      );

      this.results.push({
        card: card,
        userAnswer: userAnswer,
        isCorrect: isCorrect,
        score: score,
        timeSpent: timeSpent,
        apiResponse: result
      });

      return result;
    } catch (error) {
      console.error('❌ Erreur de soumission:', error);
      throw error;
    }
  }

  /**
   * Étape 4: Passer à la carte suivante
   */
  nextCard() {
    this.currentIndex++;
    return this.getCurrentCard();
  }

  /**
   * Étape 5: Obtenir le rapport final
   */
  async getFinalReport() {
    const totalCards = this.results.length;
    const correctAnswers = this.results.filter(r => r.isCorrect).length;
    const totalScore = this.results.reduce((sum, r) => sum + r.score, 0);
    const averageScore = totalScore / totalCards;
    const totalTime = this.results.reduce((sum, r) => sum + r.timeSpent, 0);

    // Récupérer les stats mises à jour du deck
    const deckStats = await getUserDecks();
    const currentDeckStats = deckStats.find(d => d.deck_pk === this.deckId);

    return {
      quiz: {
        type: this.quizType,
        totalCards: totalCards,
        correctAnswers: correctAnswers,
        incorrectAnswers: totalCards - correctAnswers,
        successRate: (correctAnswers / totalCards * 100).toFixed(1),
        totalScore: totalScore,
        averageScore: averageScore.toFixed(1),
        totalTime: totalTime
      },
      deckStats: currentDeckStats,
      details: this.results
    };
  }

  // Utilitaires
  checkAnswer(userAnswer, correctAnswer) {
    return userAnswer.toLowerCase().trim() === correctAnswer.toLowerCase().trim();
  }

  calculateScore(userAnswer, correctAnswer) {
    if (this.checkAnswer(userAnswer, correctAnswer)) {
      return 100;
    }
    // Score partiel basé sur la similarité
    const similarity = this.calculateSimilarity(
      userAnswer.toLowerCase(),
      correctAnswer.toLowerCase()
    );
    return Math.floor(similarity * 100);
  }

  calculateSimilarity(str1, str2) {
    // Simple Levenshtein distance
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

  shuffleArray(array) {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }
}

// ============================================================================
// UTILISATION COMPLÈTE
// ============================================================================

async function runCompleteQuiz() {
  const quiz = new CompleteQuizFlow(40, 'frappe');

  // Étape 1: Initialiser
  const initialized = await quiz.initialize();
  if (!initialized) {
    console.error('Failed to initialize quiz');
    return;
  }

  // Étape 2: Boucle de quiz
  let card = quiz.getCurrentCard();
  while (card) {
    console.log(`\n📝 Carte: ${card.front}`);
    
    // Simuler l'attente de la réponse utilisateur
    const startTime = Date.now();
    
    // ICI: Attendre la réponse de l'utilisateur (dans votre UI)
    const userAnswer = "Barista"; // Exemple
    
    // Soumettre la réponse
    await quiz.submitAnswer(userAnswer, startTime);
    
    // Passer à la suivante
    card = quiz.nextCard();
  }

  // Étape 3: Afficher le rapport final
  const report = await quiz.getFinalReport();
  console.log('\n🎉 QUIZ TERMINÉ!');
  console.log('Rapport:', report);
}
```

---

## ⚠️ Gestion des Erreurs

### Codes de Statut HTTP

| Code | Signification | Action Frontend |
|------|---------------|-----------------|
| 200 | Succès | Continuer |
| 201 | Créé avec succès | Continuer |
| 400 | Requête invalide | Vérifier les données envoyées |
| 401 | Non authentifié | Rediriger vers login |
| 403 | Accès interdit | Vérifier les permissions |
| 404 | Ressource non trouvée | Afficher message d'erreur |
| 500 | Erreur serveur | Réessayer ou contacter support |

### Exemple de Gestion d'Erreurs Globale

```javascript
class APIError extends Error {
  constructor(status, message, details) {
    super(message);
    this.status = status;
    this.details = details;
  }
}

async function apiRequest(url, options = {}) {
  try {
    const response = await fetch(url, options);
    
    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      throw new APIError(
        response.status,
        error.detail || `HTTP Error ${response.status}`,
        error
      );
    }
    
    return await response.json();
  } catch (error) {
    if (error instanceof APIError) {
      // Gérer les erreurs API spécifiques
      if (error.status === 401) {
        // Token expiré ou invalide
        localStorage.removeItem('access_token');
        window.location.href = '/login';
      }
      throw error;
    }
    
    // Erreurs réseau ou autres
    throw new Error(`Network error: ${error.message}`);
  }
}
```

---

## 🔍 Debugging

### Vérifier si deck_pk est bien envoyé

```javascript
// Dans la console du navigateur
async function testScoreSubmission() {
  const payload = {
    deck_pk: 40,
    card_pk: 972,
    score: 85,
    is_correct: true,
    time_spent: 5,
    quiz_type: "frappe"
  };

  console.log('📤 Payload envoyé:', payload);

  const token = localStorage.getItem('access_token');
  
  const response = await fetch('http://localhost:8000/api/users/scores', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify(payload)
  });

  console.log('📥 Status:', response.status);
  const data = await response.json();
  console.log('📥 Réponse:', data);
  
  // ✅ Vérifier que deck_pk n'est pas NULL
  if (data.deck_pk === null) {
    console.error('🚨 BUG: deck_pk est NULL dans la réponse!');
  } else {
    console.log('✅ deck_pk correctement enregistré:', data.deck_pk);
  }
}

testScoreSubmission();
```

---

## 📋 Checklist d'Intégration Frontend

### Avant de Commencer
- [ ] Backend démarré sur `http://localhost:8000`
- [ ] Token JWT configuré dans localStorage
- [ ] Headers d'authentification configurés

### Pour le Quiz
- [ ] Récupération des cartes avec `GET /cards/?deck_pk={id}`
- [ ] Sauvegarde du `deck_pk` dans l'état du quiz
- [ ] Soumission des scores avec `deck_pk` et `card_pk` obligatoires
- [ ] Gestion du temps en secondes
- [ ] Type de quiz correctement spécifié

### Après le Quiz
- [ ] Récupération des stats avec `GET /api/users/decks`
- [ ] Affichage du rapport final
- [ ] Mise à jour du dashboard

---

## 🎯 Exemple React/TypeScript (Bonus)

```typescript
import { useState, useEffect } from 'react';

interface Card {
  card_pk: number;
  front: string;
  back: string;
  // ... autres champs
}

interface QuizProps {
  deckId: number;
  quizType: 'frappe' | 'association' | 'qcm' | 'classique';
}

export function Quiz({ deckId, quizType }: QuizProps) {
  const [cards, setCards] = useState<Card[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [userAnswer, setUserAnswer] = useState('');
  const [startTime, setStartTime] = useState<number>(Date.now());
  const [isLoading, setIsLoading] = useState(false);

  // Charger les cartes au montage
  useEffect(() => {
    async function loadCards() {
      try {
        const fetchedCards = await fetchDeckCards(deckId);
        setCards(fetchedCards);
        setStartTime(Date.now());
      } catch (error) {
        console.error('Failed to load cards:', error);
      }
    }
    loadCards();
  }, [deckId]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      const card = cards[currentIndex];
      const timeSpent = Math.floor((Date.now() - startTime) / 1000);
      const isCorrect = userAnswer.toLowerCase().trim() === card.back.toLowerCase().trim();
      const score = isCorrect ? 100 : 0;

      // 🚨 IMPORTANT: deck_pk dans la soumission
      await submitScore(
        deckId,           // deck_pk ✅
        card.card_pk,     // card_pk ✅
        score,
        isCorrect,
        timeSpent,
        quizType
      );

      // Passer à la carte suivante
      if (currentIndex < cards.length - 1) {
        setCurrentIndex(currentIndex + 1);
        setUserAnswer('');
        setStartTime(Date.now());
      } else {
        // Quiz terminé
        alert('Quiz terminé!');
      }
    } catch (error) {
      console.error('Failed to submit answer:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (cards.length === 0) {
    return <div>Chargement...</div>;
  }

  const currentCard = cards[currentIndex];

  return (
    <div className="quiz-container">
      <h2>Carte {currentIndex + 1}/{cards.length}</h2>
      <div className="card-front">{currentCard.front}</div>
      
      <form onSubmit={handleSubmit}>
        <input
          type="text"
          value={userAnswer}
          onChange={(e) => setUserAnswer(e.target.value)}
          placeholder="Votre réponse..."
          disabled={isLoading}
        />
        <button type="submit" disabled={isLoading}>
          {isLoading ? 'Envoi...' : 'Valider'}
        </button>
      </form>
    </div>
  );
}
```

---

## 📞 Support

Pour toute question ou problème d'intégration, vérifier :
1. Les logs du backend (`uvicorn`)
2. La console du navigateur (Network tab)
3. Le payload envoyé dans les requêtes
4. Que `deck_pk` et `card_pk` sont bien présents et non `null`

---

**Document créé le :** 23 novembre 2025  
**Version :** 2.0.0  
**Status :** 🟢 Production Ready
