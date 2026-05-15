# 🎯 CHANGEMENTS FRONTEND REQUIS

## ❌ CE QU'IL FAUT SUPPRIMER

### 1. Supprimer l'Appel Manuel à `addDeckToUser`

**AVANT (à supprimer) :**
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

## ✅ CE QU'IL FAUT GARDER/VÉRIFIER

### 1. Vérifier que `deck_pk` est TOUJOURS Envoyé

**Code à vérifier :**
```javascript
// ✅ OBLIGATOIRE : deck_pk et card_pk doivent être envoyés
await scoresApi.submitScore({
  deck_pk: deckId,      // ✅ OBLIGATOIRE - Ne doit JAMAIS être null/undefined
  card_pk: cardId,      // ✅ OBLIGATOIRE - Ne doit JAMAIS être null/undefined
  score: 85,
  is_correct: true,
  time_spent: 5,
  quiz_type: "frappe"
});
```

### 2. Vérifier les Types de Données

**Assurez-vous que :**
```javascript
// deck_pk et card_pk doivent être des NOMBRES, pas des strings
const deckId = parseInt(deckIdFromUrl);    // ✅ Convertir en nombre
const cardId = parseInt(card.card_pk);     // ✅ Convertir en nombre

// Validation avant envoi
if (!deckId || !cardId) {
  console.error('deck_pk ou card_pk manquant!');
  return;
}
```

---

## 🔧 MODIFICATIONS DÉTAILLÉES PAR FICHIER

### Fichier 1 : `QuizPage.tsx` (ou équivalent)

**AVANT :**
```typescript
async function startQuiz(deckId: string) {
  try {
    // ❌ SUPPRIMER CETTE PARTIE
    await userDecksApi.addDeckToUser(parseInt(deckId));
    console.log('✅ Deck added to user collection');
  } catch (error) {
    if (error?.response?.status === 400 || error?.response?.status === 409) {
      console.log('ℹ️ Deck already in user collection');
    } else {
      throw error;
    }
  }
  
  // Charger les cartes
  const cards = await cardsApi.getCardsByDeck(parseInt(deckId));
  // ... reste du code
}
```

**APRÈS :**
```typescript
async function startQuiz(deckId: string) {
  // ✅ Plus besoin d'ajouter le deck manuellement
  
  // Charger les cartes directement
  const cards = await cardsApi.getCardsByDeck(parseInt(deckId));
  // ... reste du code
}
```

### Fichier 2 : `ScoresAPI.ts` (ou équivalent)

**Vérifier que le payload est correct :**

```typescript
interface ScoreSubmitData {
  deck_pk: number;      // ✅ OBLIGATOIRE - Type number
  card_pk: number;      // ✅ OBLIGATOIRE - Type number
  score: number;        // ✅ OBLIGATOIRE - 0-100
  is_correct: boolean;  // ✅ OBLIGATOIRE
  time_spent?: number;  // Optionnel - en secondes
  quiz_type?: 'frappe' | 'association' | 'qcm' | 'classique'; // Optionnel
}

async function submitScore(data: ScoreSubmitData) {
  // ✅ Validation avant envoi
  if (!data.deck_pk || !data.card_pk) {
    throw new Error('deck_pk and card_pk are required');
  }
  
  const response = await axios.post('/api/users/scores', {
    deck_pk: data.deck_pk,      // ✅ Toujours envoyer
    card_pk: data.card_pk,      // ✅ Toujours envoyer
    score: data.score,
    is_correct: data.is_correct,
    time_spent: data.time_spent,
    quiz_type: data.quiz_type || 'classique'
  }, {
    headers: {
      'Authorization': `Bearer ${getToken()}`
    }
  });
  
  return response.data;
}
```

### Fichier 3 : `QuizManager.tsx` (ou équivalent)

**AVANT :**
```typescript
async handleSubmitAnswer(userAnswer: string) {
  const card = this.getCurrentCard();
  
  // ❌ PROBLÈME POTENTIEL : deck_pk pourrait être undefined
  await submitScore({
    deck_pk: this.deckId,  // Vérifier que this.deckId existe
    card_pk: card.card_pk,
    score: this.calculateScore(userAnswer),
    is_correct: this.checkAnswer(userAnswer),
    quiz_type: this.quizType
  });
}
```

**APRÈS :**
```typescript
async handleSubmitAnswer(userAnswer: string) {
  const card = this.getCurrentCard();
  
  // ✅ Validation explicite
  if (!this.deckId) {
    throw new Error('deckId is not set');
  }
  
  if (!card?.card_pk) {
    throw new Error('card_pk is not available');
  }
  
  await submitScore({
    deck_pk: parseInt(this.deckId),  // ✅ S'assurer que c'est un nombre
    card_pk: parseInt(card.card_pk), // ✅ S'assurer que c'est un nombre
    score: this.calculateScore(userAnswer),
    is_correct: this.checkAnswer(userAnswer),
    time_spent: this.getTimeSpent(),
    quiz_type: this.quizType
  });
}
```

---

## 🐛 ERREURS COURANTES À ÉVITER

### Erreur 1 : deck_pk est undefined

```javascript
// ❌ MAUVAIS
const deckId = useParams().id;  // Peut être undefined
await submitScore({ deck_pk: deckId, ... });

// ✅ BON
const deckId = useParams().id;
if (!deckId) {
  throw new Error('Deck ID is required');
}
await submitScore({ deck_pk: parseInt(deckId), ... });
```

### Erreur 2 : deck_pk est une string au lieu d'un number

```javascript
// ❌ MAUVAIS
await submitScore({ 
  deck_pk: "40",  // String au lieu de number
  ...
});

// ✅ BON
await submitScore({ 
  deck_pk: 40,    // Number
  ...
});
```

### Erreur 3 : Oublier de convertir les IDs

```javascript
// ❌ MAUVAIS
const deckId = route.params.deckId;  // "40" (string)
await submitScore({ deck_pk: deckId, ... });

// ✅ BON
const deckId = parseInt(route.params.deckId);  // 40 (number)
await submitScore({ deck_pk: deckId, ... });
```

---

## 📝 CHECKLIST DE VÉRIFICATION

### Avant de Déployer

- [ ] ✅ Supprimer tous les appels à `POST /api/users/decks/{id}` avant le quiz
- [ ] ✅ Vérifier que `deck_pk` est toujours envoyé dans `submitScore()`
- [ ] ✅ Vérifier que `card_pk` est toujours envoyé dans `submitScore()`
- [ ] ✅ Vérifier que `deck_pk` et `card_pk` sont des **nombres**, pas des strings
- [ ] ✅ Ajouter une validation pour s'assurer que les IDs ne sont pas null/undefined
- [ ] ✅ Vider le cache du navigateur après les modifications
- [ ] ✅ Tester avec un nouveau compte
- [ ] ✅ Vérifier que le dashboard affiche les stats après un quiz

### Tests à Faire

1. **Test 1 : Nouveau compte**
   - Créer un nouveau compte
   - Faire un quiz complet
   - Vérifier que le dashboard affiche les stats

2. **Test 2 : Console du navigateur**
   - Ouvrir F12 → Console
   - Faire un quiz
   - Vérifier qu'il n'y a pas d'erreurs
   - Vérifier dans Network que le payload contient `deck_pk` et `card_pk`

3. **Test 3 : Plusieurs quiz**
   - Faire un premier quiz
   - Vérifier les stats
   - Faire un deuxième quiz sur le même deck
   - Vérifier que les stats sont mises à jour (incrémentées)

---

## 🔍 DEBUGGING FRONTEND

### Ajouter des Logs Temporaires

```typescript
async function submitScore(data: ScoreSubmitData) {
  // 🔍 LOG POUR DEBUGGING
  console.log('📤 Submitting score:', {
    deck_pk: data.deck_pk,
    card_pk: data.card_pk,
    deck_pk_type: typeof data.deck_pk,
    card_pk_type: typeof data.card_pk
  });
  
  // Vérifier les types
  if (typeof data.deck_pk !== 'number') {
    console.error('❌ deck_pk should be a number, got:', typeof data.deck_pk);
  }
  
  if (typeof data.card_pk !== 'number') {
    console.error('❌ card_pk should be a number, got:', typeof data.card_pk);
  }
  
  const response = await axios.post('/api/users/scores', data, {
    headers: { 'Authorization': `Bearer ${getToken()}` }
  });
  
  // 🔍 LOG DE LA RÉPONSE
  console.log('📥 Score response:', response.data);
  
  // Vérifier que deck_pk n'est pas NULL dans la réponse
  if (response.data.deck_pk === null) {
    console.error('❌ BUG: deck_pk is NULL in response!');
  }
  
  return response.data;
}
```

### Vérifier dans le Network Tab

1. Ouvrir F12 → Network
2. Faire un quiz
3. Chercher la requête `POST /api/users/scores`
4. Cliquer dessus → Payload
5. Vérifier que le JSON contient :
   ```json
   {
     "deck_pk": 40,
     "card_pk": 908,
     "score": 85,
     "is_correct": true,
     "time_spent": 5,
     "quiz_type": "frappe"
   }
   ```

---

## 📦 EXEMPLE COMPLET : Composant Quiz React

```typescript
import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { cardsApi, scoresApi } from './api';

interface Card {
  card_pk: number;
  front: string;
  back: string;
}

export function QuizPage() {
  const { deckId } = useParams<{ deckId: string }>();
  const [cards, setCards] = useState<Card[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [userAnswer, setUserAnswer] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // Charger les cartes au montage
  useEffect(() => {
    async function loadCards() {
      if (!deckId) {
        console.error('Deck ID is required');
        return;
      }

      try {
        // ✅ Plus besoin d'ajouter le deck manuellement
        // ❌ await userDecksApi.addDeckToUser(parseInt(deckId));
        
        // Charger directement les cartes
        const fetchedCards = await cardsApi.getCardsByDeck(parseInt(deckId));
        setCards(fetchedCards);
      } catch (error) {
        console.error('Failed to load cards:', error);
      }
    }

    loadCards();
  }, [deckId]);

  // Soumettre la réponse
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!deckId) {
      console.error('Deck ID is missing');
      return;
    }

    const currentCard = cards[currentIndex];
    if (!currentCard) {
      console.error('Current card is missing');
      return;
    }

    setIsLoading(true);

    try {
      const isCorrect = userAnswer.toLowerCase().trim() === 
                       currentCard.back.toLowerCase().trim();
      const score = isCorrect ? 100 : 0;

      // ✅ Envoyer le score avec deck_pk et card_pk
      await scoresApi.submitScore({
        deck_pk: parseInt(deckId),        // ✅ OBLIGATOIRE
        card_pk: currentCard.card_pk,     // ✅ OBLIGATOIRE
        score: score,
        is_correct: isCorrect,
        time_spent: 5,
        quiz_type: 'frappe'
      });

      // Passer à la carte suivante
      if (currentIndex < cards.length - 1) {
        setCurrentIndex(currentIndex + 1);
        setUserAnswer('');
      } else {
        // Quiz terminé, rediriger vers le dashboard
        window.location.href = '/dashboard';
      }
    } catch (error) {
      console.error('Failed to submit score:', error);
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
          autoFocus
        />
        <button type="submit" disabled={isLoading || !userAnswer}>
          {isLoading ? 'Envoi...' : 'Valider'}
        </button>
      </form>
    </div>
  );
}
```

---

## 🎯 RÉSUMÉ DES CHANGEMENTS

### À SUPPRIMER ❌

```javascript
// ❌ SUPPRIMER COMPLÈTEMENT
await userDecksApi.addDeckToUser(parseInt(deckId));
```

### À GARDER ✅

```javascript
// ✅ GARDER ET VÉRIFIER
await scoresApi.submitScore({
  deck_pk: parseInt(deckId),    // ✅ Toujours un nombre
  card_pk: card.card_pk,        // ✅ Toujours un nombre
  score: 85,
  is_correct: true,
  time_spent: 5,
  quiz_type: "frappe"
});
```

### À AJOUTER ✅

```javascript
// ✅ AJOUTER DES VALIDATIONS
if (!deckId || !card?.card_pk) {
  throw new Error('Missing required IDs');
}

// ✅ AJOUTER DES LOGS (temporaires)
console.log('Submitting score:', { deck_pk: deckId, card_pk: card.card_pk });
```

---

## 📞 Support

Si après ces modifications ça ne fonctionne toujours pas :

1. Vérifiez la console du navigateur (F12)
2. Vérifiez l'onglet Network pour voir le payload envoyé
3. Partagez-moi :
   - Le code de votre fonction `submitScore`
   - Le payload exact envoyé (visible dans Network)
   - Les erreurs éventuelles dans la console

---

**Temps estimé pour les modifications :** 10-15 minutes  
**Complexité :** Faible (principalement supprimer du code)  
**Impact :** Critique (nécessaire pour que les stats fonctionnent)
