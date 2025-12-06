# Guide Intégration Frontend : Labels des Cartes & Mises à Jour

Ce document détaille comment intégrer la nouvelle logique de labels dynamiques ("En cours", "Maîtrisée", "Non maîtrisée") et comment assurer que votre interface est toujours à jour après un quiz.

## 1. Nouvelle Logique des Status (Labels)

Le backend calcule désormais automatiquement le statut de chaque carte selon vos règles strictes. Vous n'avez plus besoin de faire de calculs complexes côté front.

| Label (API) | Condition Backend | Signification Utilisateur |
| :--- | :--- | :--- |
| **"En cours"** | `total_attempts == 0` | Carte jamais jouée. |
| **"Maîtrisée"** | `consecutive_correct > 0` | La **dernière** réponse était correcte. |
| **"Non maîtrisée"** | `attempts > 0` ET `error` | La **dernière** réponse était fausse. |

---

## 2. Mise à Jour des Types (TypeScript)

Mettez à jour votre interface `Card` ou `CardPerformance` pour inclure le champ `label` qui est maintenant renvoyé par l'API.

```typescript
// src/types.ts ou src/features/flashcards/types.ts

export interface CardPerformance {
  performance_pk: number;
  card_pk: number;
  // ... autres champs
  label: "En cours" | "Maîtrisée" | "Non maîtrisée"; // <-- NOUVEAU
}

export interface Card {
  card_pk: number;
  front: string;
  back: string;
  // ...
  status?: string; // Sera rempli avec le label de l'API
}
```

---

## 3. Récupération des Labels (Hook `useCards`)

L'objectif est de récupérer les cartes ET leurs performances (labels) en même temps.

**Fichier : `src/features/flashcards/hooks/useCards.ts`**

```typescript
import { useState, useCallback } from 'react';
// import services...

export const useCards = (deckId: number | null) => {
  const [cards, setCards] = useState<Card[]>([]);
  // ... autres states

  const loadCards = useCallback(async () => {
    if (!deckId) return;
    setLoading(true);
    try {
      // 1. Lancer les deux requêtes en parallèle pour la rapidité
      const [cardsData, performancesData] = await Promise.all([
        deckApi.getCards(deckId),           // GET /api/decks/{id}/cards
        quizApi.getPerformances(deckId)     // GET /api/quiz/performances/{id}
      ]);

      // 2. Fusionner les données
      const mergedCards = cardsData.map((card: Card) => {
        // Trouver la perf associée
        const perf = performancesData.find((p: any) => p.card_pk === card.card_pk);
        
        return {
          ...card,
          // UTILISER LE LABEL DU BACKEND DIRECTEMENT
          status: perf?.label || "En cours",
          
          // Optionnel : garder d'autres stats si besoin
          box: perf?.consecutive_correct || 0 
        };
      });

      setCards(mergedCards);
    } catch (err) {
      setError("Erreur lors du chargement des cartes");
    } finally {
      setLoading(false);
    }
  }, [deckId]);

  return { cards, loadCards, loading, error };
};
```

---

## 4. Affichage des Badges (Code Couleur)

Dans votre composant de liste de cartes (ex: `CardListView.tsx`), utilisez le status pour déterminer la couleur.

```tsx
const getStatusBadge = (status: string) => {
  switch (status) {
    case 'Maîtrisée':
      return (
        <span className="px-2 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-800 border border-green-200">
          Maîtrisée
        </span>
      );
    case 'Non maîtrisée':
      return (
        <span className="px-2 py-1 rounded-full text-xs font-semibold bg-red-100 text-red-800 border border-red-200">
          Non maîtrisée
        </span>
      );
    case 'En cours':
    default:
      return (
        <span className="px-2 py-1 rounded-full text-xs font-semibold bg-orange-100 text-orange-800 border border-orange-200">
          En cours
        </span>
      );
  }
};

// Utilisation dans le JSX :
// {getStatusBadge(card.status)}
```

---

## 5. Workflow de Mise à Jour (Après un Quiz)

C'est l'étape critique. Une fois le quiz terminé, les données locales (scores, status) sont obsolètes. Voici comment garantir qu'elles soient rafraîchies.

### Scénario : L'utilisateur termine un Quiz

Dans votre composant `Quiz` ou `Flashcards`, vous avez probablement une fonction `handleQuizComplete`.

```tsx
// src/pages/Flashcards.tsx (ou équivalent)

const handleQuizEnd = async () => {
  // 1. Fermer la modale de quiz
  setShowQuiz(false);

  // 2. Rafraîchir les CARTES (pour mettre à jour les labels Maîtrisée/Non maîtrisée)
  // Si vous utilisez le hook useCards, appelez sa méthode de rechargement
  if (selectedDeck) {
    await loadCards(); 
  }

  // 3. Rafraîchir les DECKS (pour mettre à jour le score global et la progression)
  // Si vous avez un hook useDecks ou une fonction getUserDecks
  await fetchUserDecks(); 
};
```

### Pourquoi recharger ?
C'est la méthode la plus fiable (`Single Source of Truth`). Le backend vient de recalculer tous les scores et statuts Anki complexes. En rechargeant :
1.  Vous obtenez les nouveaux labels ("Non maîtrisée" si erreur).
2.  Vous obtenez le nouveau score global du deck.
3.  Vous obtenez les nouveaux pourcentages de progression.

### Résumé des appels API
Quand l'écran s'affiche après un quiz, 2 appels doivent partir :
1.  `GET /api/quiz/performances/{deckId}` (via `loadCards`) -> Met à jour les **Badges**.
2.  `GET /api/users/decks` (ou `/api/users/decks/all`) -> Met à jour les **Scores globaux**.

---

## Point de Vérification
Si après un quiz, les cartes ne changent pas de couleur :
1.  Vérifiez que `loadCards` est bien appelé dans le callback `onComplete` du quiz.
2.  Vérifiez dans l'onglet Network (F12) que `performances/{id}` renvoie bien le nouveau `label`.
