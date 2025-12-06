# ⚡ Quick Start - Quiz Flexible (5 Minutes)

**Version** : 2.0  
**Statut** : ✅ Production Ready

---

## 🎯 En 5 Minutes Chrono

### 1️⃣ Copier le Service API (1 min)

Créez `src/services/quizApi.ts` :

```typescript
import axios from 'axios';

const API = '/api/quiz';

export const quizApi = {
  startQuiz: (deckPk: number, cardCount: number) =>
    axios.post(`${API}/start`, {
      deck_pk: deckPk,
      card_count: cardCount,
      quiz_type: 'classique'
    }).then(res => res.data),

  recordAnswer: (cardPk: number, deckPk: number, isCorrect: boolean) =>
    axios.post(`${API}/answer`, null, {
      params: { card_pk: cardPk, deck_pk: deckPk, is_correct: isCorrect }
    }).then(res => res.data),

  completeQuiz: (sessionPk: number, correct: number, total: number) =>
    axios.post(`${API}/complete/${sessionPk}`, null, {
      params: { correct_count: correct, total_questions: total }
    }).then(res => res.data)
};
```

### 2️⃣ Créer le Composant Quiz (2 min)

```typescript
import { useState } from 'react';
import { quizApi } from './services/quizApi';

export const Quiz = ({ deckId }: { deckId: number }) => {
  const [quiz, setQuiz] = useState<any>(null);
  const [index, setIndex] = useState(0);
  const [score, setScore] = useState(0);
  const [show, setShow] = useState(false);

  const start = async () => {
    const data = await quizApi.startQuiz(deckId, 20);
    setQuiz(data);
    setIndex(0);
    setScore(0);
  };

  const answer = async (correct: boolean) => {
    await quizApi.recordAnswer(
      quiz.selected_cards[index].card_pk,
      deckId,
      correct
    );
    
    if (correct) setScore(score + 1);
    
    if (index === quiz.selected_cards.length - 1) {
      await quizApi.completeQuiz(
        quiz.session_pk,
        score + (correct ? 1 : 0),
        quiz.selected_cards.length
      );
      alert(`Terminé! ${score}/${quiz.selected_cards.length}`);
      setQuiz(null);
    } else {
      setIndex(index + 1);
      setShow(false);
    }
  };

  if (!quiz) return <button onClick={start}>Démarrer</button>;

  const card = quiz.selected_cards[index];

  return (
    <div>
      <p>Carte {index + 1}/{quiz.selected_cards.length} - Score: {score}</p>
      <h2>{card.front}</h2>
      {show && <p>{card.back}</p>}
      {!show ? (
        <button onClick={() => setShow(true)}>Voir réponse</button>
      ) : (
        <>
          <button onClick={() => answer(false)}>❌</button>
          <button onClick={() => answer(true)}>✅</button>
        </>
      )}
    </div>
  );
};
```

### 3️⃣ Ajouter les Styles (1 min)

```css
/* Copiez dans votre CSS */
div {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  text-align: center;
}

h2 {
  font-size: 32px;
  margin: 40px 0;
}

button {
  padding: 12px 24px;
  margin: 10px;
  font-size: 16px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  background: #2196f3;
  color: white;
}

button:hover {
  background: #1976d2;
}
```

### 4️⃣ Utiliser (30 sec)

```typescript
// Dans votre App
import { Quiz } from './Quiz';

function App() {
  return <Quiz deckId={10} />;
}
```

### 5️⃣ Tester (30 sec)

```bash
npm start
```

**C'est tout !** Vous avez un quiz fonctionnel. 🎉

---

## 📊 Dashboard en Bonus (2 min)

```typescript
import { useEffect, useState } from 'react';
import axios from 'axios';

export const Dashboard = () => {
  const [decks, setDecks] = useState([]);

  useEffect(() => {
    axios.get('/api/users/decks/all').then(res => setDecks(res.data));
  }, []);

  return (
    <div>
      {decks.map((deck: any) => (
        <div key={deck.deck_pk}>
          <h3>{deck.name}</h3>
          <p>Réussite: {deck.user_stats.success_rate.toFixed(1)}%</p>
          <p>Tentatives: {deck.user_stats.attempt_count}</p>
        </div>
      ))}
    </div>
  );
};
```

---

## 🎨 Styles Améliorés (Optionnel)

```css
.quiz-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.quiz-card {
  background: white;
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
  min-height: 300px;
}

.quiz-card h2 {
  font-size: 32px;
  color: #333;
}

.quiz-buttons {
  display: flex;
  gap: 20px;
  justify-content: center;
  margin-top: 30px;
}

.btn-correct {
  background: #4caf50;
  color: white;
  padding: 16px 32px;
  border: none;
  border-radius: 12px;
  font-size: 18px;
  cursor: pointer;
}

.btn-incorrect {
  background: #f44336;
  color: white;
  padding: 16px 32px;
  border: none;
  border-radius: 12px;
  font-size: 18px;
  cursor: pointer;
}

.btn-correct:hover {
  background: #45a049;
  transform: translateY(-2px);
}

.btn-incorrect:hover {
  background: #da190b;
  transform: translateY(-2px);
}
```

---

## 🔥 Fonctionnalités Clés

### Messages Système
Le backend renvoie des messages descriptifs :

```typescript
// Exemple de message
quiz.message
// "Cycle 1: 20 cartes sélectionnées aléatoirement. 80 cartes restantes."
```

Affichez-le à l'utilisateur :

```typescript
{quiz.message && <div className="message">{quiz.message}</div>}
```

### Cycle Actuel
Affichez le cycle en cours :

```typescript
<div className="cycle-badge">
  Cycle {quiz.cycle_number}
</div>
```

### Nombre de Cartes Flexible
Laissez l'utilisateur choisir :

```typescript
const [count, setCount] = useState(20);

<input 
  type="number" 
  min="1" 
  max="100"
  value={count}
  onChange={e => setCount(Number(e.target.value))}
/>
<button onClick={() => start(count)}>Démarrer</button>
```

---

## ⚠️ Gestion des Erreurs

```typescript
const start = async () => {
  try {
    const data = await quizApi.startQuiz(deckId, cardCount);
    setQuiz(data);
  } catch (error) {
    alert('Erreur: ' + error.message);
  }
};
```

---

## 🎯 Endpoints Essentiels

| Endpoint | Méthode | Usage |
|----------|---------|-------|
| `/api/quiz/start` | POST | Démarrer |
| `/api/quiz/answer` | POST | Répondre |
| `/api/quiz/complete/{id}` | POST | Finaliser |
| `/api/users/decks/all` | GET | Dashboard |

---

## 📚 Documentation Complète

Pour plus de détails :
- **Guide complet** : `GUIDE_INTEGRATION_QUIZ_FLEXIBLE.md`
- **Exemples avancés** : Hook personnalisé, composants complets
- **Tests** : 60+ scénarios validés

---

## ✅ Checklist

- [ ] Service API créé
- [ ] Composant Quiz créé
- [ ] Styles CSS ajoutés
- [ ] Test effectué
- [ ] Dashboard intégré (optionnel)

---

## 🚀 Prêt !

Votre quiz est fonctionnel. Pour aller plus loin :

1. Ajoutez des animations
2. Personnalisez les styles
3. Ajoutez le dashboard
4. Implémentez d'autres types de quiz

**Bon développement !** 🎉

---

**Version** : 2.0  
**Temps d'intégration** : 5 minutes  
**Statut** : ✅ Production Ready
