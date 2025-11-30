# Guide de Diagnostic Frontend - Affichage du Success Rate

## Problème
Le backend envoie maintenant le champ `success_rate`, mais il ne s'affiche pas dans le frontend.

---

## Étape 1: Vérifier que le Backend Envoie les Données

### Exécutez le script de diagnostic:
```bash
python diagnose_success_rate.py
```

Entrez vos identifiants (julien@gmail.com) et vérifiez que la réponse contient bien `success_rate`.

**Résultat attendu:**
```json
{
  "user_deck_pk": 113,
  "success_rate": 66.67,  ← Doit être présent
  "progress": 0.0
}
```

---

## Étape 2: Vérifier le Code Frontend

### A. Vérifier l'Interface TypeScript

Cherchez le fichier qui définit l'interface `UserDeck` (probablement dans `types/` ou `api/`):

```typescript
// ❌ AVANT (manquant)
interface UserDeck {
  user_deck_pk: number;
  total_attempts: number;
  successful_attempts: number;
  // success_rate manquant!
}

// ✅ APRÈS (correct)
interface UserDeck {
  user_deck_pk: number;
  total_attempts: number;
  successful_attempts: number;
  success_rate: number;  // ← Ajouter cette ligne
  progress: number;      // ← Ajouter cette ligne aussi
}
```

### B. Vérifier le Composant qui Affiche le Deck

Cherchez le composant qui affiche "0%" (probablement `Dashboard.tsx` ou `DeckCard.tsx`):

```typescript
// ❌ MAUVAIS - Calcul manuel incorrect
<div>{deck.successful_attempts / deck.total_attempts * 100}%</div>

// ✅ BON - Utiliser success_rate du backend
<div>{deck.success_rate}%</div>
```

### C. Vérifier l'Appel API

Cherchez où vous appelez `GET /api/users/decks`:

```typescript
// Exemple avec fetch
const response = await fetch('/api/users/decks', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});
const decks = await response.json();

// Vérifier dans la console
console.log('Decks reçus:', decks);
console.log('Success rate du premier deck:', decks[0]?.success_rate);
```

---

## Étape 3: Vider le Cache du Navigateur

Le frontend peut avoir mis en cache l'ancienne réponse API.

### Chrome/Edge:
1. Ouvrez les DevTools (F12)
2. Clic droit sur le bouton Actualiser
3. Sélectionnez **"Vider le cache et actualiser de manière forcée"**

Ou utilisez: `Ctrl + Shift + R`

---

## Étape 4: Vérifier dans la Console du Navigateur

1. Ouvrez les DevTools (F12)
2. Allez dans l'onglet **Network**
3. Actualisez la page
4. Cherchez la requête `GET /api/users/decks`
5. Cliquez dessus et regardez la **Response**

**Vérifiez que la réponse contient:**
```json
{
  "success_rate": 66.67,
  "progress": 0.0
}
```

---

## Étape 5: Fichiers Frontend à Vérifier

Voici les fichiers que vous devrez probablement modifier:

### 1. **Interface TypeScript** (types.ts ou api/types.ts)
```typescript
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
  
  // Points par type
  points_frappe: number;
  points_association: number;
  points_qcm: number;
  points_classique: number;
  
  // Dates
  added_at: string;
  last_studied: string | null;
  
  // ✅ AJOUTER CES DEUX LIGNES
  success_rate: number;
  progress: number;
}
```

### 2. **Composant d'Affichage** (Dashboard.tsx ou DeckCard.tsx)
```typescript
// Cherchez où vous affichez "0%"
// Remplacez par:

{deck.success_rate !== undefined ? (
  <span>{deck.success_rate.toFixed(2)}%</span>
) : (
  <span>0%</span>
)}
```

### 3. **Appel API** (userDecksApi.ts ou similar)
```typescript
export const getUserDecks = async (token: string): Promise<UserDeck[]> => {
  const response = await fetch(`${API_BASE_URL}/api/users/decks`, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  });
  
  if (!response.ok) {
    throw new Error('Failed to fetch user decks');
  }
  
  const decks = await response.json();
  
  // ✅ AJOUTER CE LOG POUR DÉBUGGER
  console.log('Decks reçus du backend:', decks);
  
  return decks;
};
```

---

## Étape 6: Test Rapide avec cURL

Pour vérifier rapidement que le backend envoie bien les données:

```bash
# Remplacez YOUR_TOKEN par votre token JWT
curl -H "Authorization: Bearer YOUR_TOKEN" http://127.0.0.1:8000/api/users/decks
```

---

## Checklist de Diagnostic

- [ ] Backend envoie `success_rate` (vérifier avec `diagnose_success_rate.py`)
- [ ] Interface TypeScript `UserDeck` contient `success_rate: number`
- [ ] Composant utilise `deck.success_rate` au lieu de calculer manuellement
- [ ] Cache du navigateur vidé (Ctrl+Shift+R)
- [ ] Réponse API vérifiée dans Network tab des DevTools
- [ ] Console du navigateur ne montre pas d'erreurs TypeScript

---

## Si le Problème Persiste

Envoyez-moi:
1. Le code du composant qui affiche "0%"
2. Le code de l'interface TypeScript `UserDeck`
3. Une capture d'écran de la réponse dans l'onglet Network des DevTools

---

**Note:** Le backend est maintenant correct et envoie bien `success_rate`. Le problème vient très probablement du frontend qui:
1. N'a pas l'interface TypeScript à jour
2. Calcule manuellement au lieu d'utiliser `success_rate`
3. A mis en cache l'ancienne réponse
