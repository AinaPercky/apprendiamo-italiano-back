# 🚀 Guide de Migration Frontend - Étape par Étape

## 📋 Vue d'Ensemble

Ce guide vous accompagne dans la migration de votre code frontend pour utiliser le nouvel endpoint qui affiche **tous les decks du système** avec des **statistiques personnalisées**.

---

## ⏱️ Temps Estimé

- **Migration simple :** 5-10 minutes
- **Migration avec tests :** 30 minutes
- **Migration complète avec refactoring :** 1-2 heures

---

## 🎯 Objectif

### Avant la Migration
```
Nouveau Utilisateur
    ↓
GET /api/users/decks
    ↓
Réponse: []  (liste vide)
    ↓
Interface vide ❌
```

### Après la Migration
```
Nouveau Utilisateur
    ↓
GET /api/users/decks/all
    ↓
Réponse: [45 decks tous à 0%]
    ↓
Interface complète ✅
```

---

## 📝 Étape 1 : Localiser le Code à Modifier

### 1.1 Trouver l'Appel API

Cherchez dans votre code :

```bash
# Dans votre projet frontend
grep -r "/api/users/decks" src/
# ou
grep -r "users/decks" src/
```

**Fichiers typiques à vérifier :**
- `src/services/deckService.ts`
- `src/api/decks.ts`
- `src/hooks/useDecks.ts`
- `src/composables/useDecks.ts`
- `src/pages/MyDecksPage.tsx`

### 1.2 Identifier le Pattern

Vous cherchez un code qui ressemble à :

```typescript
// Pattern 1 : Fetch direct
fetch('/api/users/decks', ...)

// Pattern 2 : Axios
axios.get('/api/users/decks')

// Pattern 3 : Variable
const endpoint = '/api/users/decks'
```

---

## 🔧 Étape 2 : Effectuer la Migration

### Option A : Migration Simple (Recommandée)

**Avant :**
```typescript
const response = await fetch('/api/users/decks', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

**Après :**
```typescript
const response = await fetch('/api/users/decks/all', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

**Changement :** Ajouter `/all` à la fin de l'URL

### Option B : Migration avec Paramètre (Flexible)

```typescript
// Créer une fonction avec option
async function getDecks(token: string, showAll: boolean = true) {
  const endpoint = showAll 
    ? '/api/users/decks/all'   // Tous les decks
    : '/api/users/decks';      // Seulement commencés
  
  const response = await fetch(endpoint, {
    headers: { 'Authorization': `Bearer ${token}` }
  });
  
  return response.json();
}

// Utilisation
const allDecks = await getDecks(token, true);      // Tous
const startedDecks = await getDecks(token, false); // Commencés
```

### Option C : Migration avec Deux Endpoints (Avancé)

```typescript
// services/deckService.ts

export class DeckService {
  // Nouveau : Tous les decks avec stats personnalisées
  static async getAllDecks(token: string) {
    return this.fetchDecks('/api/users/decks/all', token);
  }
  
  // Ancien : Seulement les decks commencés
  static async getStartedDecks(token: string) {
    return this.fetchDecks('/api/users/decks', token);
  }
  
  private static async fetchDecks(endpoint: string, token: string) {
    const response = await fetch(endpoint, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    return response.json();
  }
}

// Utilisation
const allDecks = await DeckService.getAllDecks(token);
const startedDecks = await DeckService.getStartedDecks(token);
```

---

## 🧪 Étape 3 : Tester la Migration

### 3.1 Test Manuel - Nouveau Utilisateur

1. **Créer un nouveau compte**
   ```
   Email: test@example.com
   Mot de passe: Test123!
   ```

2. **Aller sur "Mes Decks"**

3. **Vérifier :**
   - ✅ Tous les decks du système s'affichent
   - ✅ Tous les pourcentages sont à **0%**
   - ✅ Tous les compteurs sont à **0**

### 3.2 Test Manuel - Utilisateur Actif

1. **Faire un quiz** sur un deck

2. **Retourner sur "Mes Decks"**

3. **Vérifier :**
   - ✅ Le deck testé affiche un pourcentage > 0%
   - ✅ Les autres decks restent à 0%
   - ✅ Le nombre total de decks n'a pas changé

### 3.3 Test Automatisé

```typescript
// __tests__/deckService.test.ts

import { DeckService } from '../services/deckService';

describe('DeckService', () => {
  it('récupère tous les decks du système', async () => {
    const token = 'fake-token';
    const decks = await DeckService.getAllDecks(token);
    
    // Vérifier qu'on a bien des decks
    expect(decks.length).toBeGreaterThan(0);
    
    // Vérifier la structure
    expect(decks[0]).toHaveProperty('deck_pk');
    expect(decks[0]).toHaveProperty('success_rate');
    expect(decks[0]).toHaveProperty('total_attempts');
  });
  
  it('affiche 0% pour un nouveau utilisateur', async () => {
    // Créer un nouveau compte de test
    const newUserToken = await createTestUser();
    const decks = await DeckService.getAllDecks(newUserToken);
    
    // Tous les decks doivent être à 0%
    decks.forEach(deck => {
      expect(deck.success_rate).toBe(0.0);
      expect(deck.total_attempts).toBe(0);
    });
  });
});
```

---

## 🎨 Étape 4 : Améliorer l'Interface (Optionnel)

### 4.1 Ajouter un Badge "Nouveau"

```typescript
{decks.map(deck => (
  <div key={deck.deck_pk} className="deck-card">
    {/* Badge pour les decks non commencés */}
    {deck.total_attempts === 0 && (
      <span className="badge-new">Nouveau</span>
    )}
    
    <h3>{deck.deck.name}</h3>
    <p>Précision: {deck.success_rate}%</p>
  </div>
))}
```

### 4.2 Séparer les Decks

```typescript
const MyDecksPage = () => {
  const { decks } = useDecks();
  
  // Séparer en deux catégories
  const inProgress = decks.filter(d => d.total_attempts > 0);
  const toDiscover = decks.filter(d => d.total_attempts === 0);
  
  return (
    <div>
      {/* Section : En cours */}
      {inProgress.length > 0 && (
        <section>
          <h2>📚 En cours ({inProgress.length})</h2>
          <DeckGrid decks={inProgress} />
        </section>
      )}
      
      {/* Section : À découvrir */}
      {toDiscover.length > 0 && (
        <section>
          <h2>🆕 À découvrir ({toDiscover.length})</h2>
          <DeckGrid decks={toDiscover} />
        </section>
      )}
    </div>
  );
};
```

### 4.3 Ajouter des Couleurs

```typescript
const getPrecisionColor = (rate: number): string => {
  if (rate === 0) return '#9ca3af';      // Gris
  if (rate >= 80) return '#22c55e';      // Vert
  if (rate >= 50) return '#f59e0b';      // Orange
  return '#ef4444';                       // Rouge
};

// Utilisation
<span style={{ color: getPrecisionColor(deck.success_rate) }}>
  {deck.success_rate.toFixed(1)}%
</span>
```

---

## 🔍 Étape 5 : Vérification DevTools

### 5.1 Ouvrir DevTools

1. Appuyer sur **F12**
2. Aller dans l'onglet **Network**
3. Cocher **Disable cache**

### 5.2 Vérifier la Requête

1. Recharger la page
2. Chercher la requête `decks/all`
3. Cliquer dessus

**Vérifier :**
- **Status :** 200 OK ✅
- **Request URL :** `.../api/users/decks/all` ✅
- **Request Headers :** `Authorization: Bearer ...` ✅

### 5.3 Vérifier la Réponse

Cliquer sur l'onglet **Response**

**Pour un nouveau utilisateur :**
```json
[
  {
    "deck_pk": 1,
    "deck": { "name": "Dodici mesi" },
    "total_attempts": 0,        ← Devrait être 0
    "success_rate": 0.0,        ← Devrait être 0.0
    "total_points": 0           ← Devrait être 0
  },
  // ... autres decks tous à 0
]
```

**Pour un utilisateur actif :**
```json
[
  {
    "deck_pk": 1,
    "deck": { "name": "Pesci" },
    "total_attempts": 8,        ← Nombre de tentatives
    "success_rate": 75.0,       ← Précision personnalisée
    "total_points": 850         ← Points gagnés
  },
  {
    "deck_pk": 2,
    "deck": { "name": "Frutti" },
    "total_attempts": 0,        ← Pas encore fait
    "success_rate": 0.0,        ← 0%
    "total_points": 0
  }
]
```

---

## 🐛 Dépannage

### Problème 1 : Erreur 404 Not Found

**Cause :** L'endpoint n'existe pas

**Solution :**
1. Vérifier que le backend est à jour
2. Vérifier que le serveur est redémarré
3. Vérifier l'URL : doit être `/api/users/decks/all`

### Problème 2 : Erreur 401 Unauthorized

**Cause :** Token invalide ou manquant

**Solution :**
```typescript
// Vérifier le token
const token = localStorage.getItem('access_token');
console.log('Token:', token);

// Vérifier qu'il est envoyé
console.log('Headers:', {
  'Authorization': `Bearer ${token}`
});
```

### Problème 3 : Tous les decks sont à 0% même après quiz

**Cause :** Les decks ne sont pas rafraîchis après le quiz

**Solution :**
```typescript
// Après avoir terminé un quiz
await submitAllScores();

// Rafraîchir les decks
await refetchDecks();  // ← Important !
```

### Problème 4 : Certains decks manquent

**Cause :** Filtrage côté frontend

**Solution :**
```typescript
// Vérifier qu'il n'y a pas de filtre
const decks = await getAllDecks();  // Tous les decks

// Pas de filtre comme :
// const decks = allDecks.filter(d => d.total_attempts > 0);  ← À éviter
```

---

## 📊 Checklist de Migration

### Avant de Commencer
- [ ] Lire la documentation
- [ ] Comprendre le changement
- [ ] Identifier les fichiers à modifier

### Pendant la Migration
- [ ] Modifier l'URL de l'API
- [ ] Vérifier les types TypeScript
- [ ] Tester en local

### Après la Migration
- [ ] Test avec nouveau compte (tous à 0%)
- [ ] Test avec compte actif (précisions personnalisées)
- [ ] Vérifier dans DevTools
- [ ] Tests automatisés (si applicable)
- [ ] Déployer en production

---

## 📚 Ressources

### Documentation
- **Guide détaillé :** `GUIDE_IMPLEMENTATION_FRONTEND_DETAILLE.md`
- **Guide visuel :** `GUIDE_FRONTEND_VISUEL_SIMPLIFIE.md`
- **Exemple complet :** `EXEMPLE_COMPOSANT_FRONTEND_COMPLET.tsx`

### Backend
- **Documentation API :** `SOLUTION_DECKS_PRECISION_PERSONNALISEE.md`
- **Test backend :** `test_alpha_beta_users.py`

---

## 🎉 Félicitations !

Si vous avez suivi toutes les étapes, votre application devrait maintenant :

✅ Afficher **tous les decks** du système  
✅ Montrer **0%** pour les nouveaux utilisateurs  
✅ Afficher les **précisions personnalisées** pour les utilisateurs actifs  
✅ Offrir une **meilleure expérience utilisateur**

---

**Document créé le :** 30 novembre 2025  
**Version :** 1.0.0  
**Auteur :** Équipe Backend
