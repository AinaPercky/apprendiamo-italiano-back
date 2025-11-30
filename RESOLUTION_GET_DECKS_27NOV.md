# 🔧 Résolution Erreur GET /api/users/decks - 27 Nov 2025

## ✅ Problème Résolu

### Erreur Backend
**Erreur:** `MissingGreenlet: greenlet_spawn has not been called`  
**Endpoint:** `GET /api/users/decks`  
**Statut HTTP:** 500 Internal Server Error

### Symptômes Frontend
```
Access to XMLHttpRequest at 'http://localhost:8000/api/users/decks' 
from origin 'http://localhost:8081' has been blocked by CORS policy
```

**Note:** L'erreur CORS est une **conséquence** de l'erreur backend 500, pas la cause.

---

## 🔍 Cause Racine

### Problème SQLAlchemy Async
La fonction `update_user_deck_anki_stats()` faisait un **`commit()`** à chaque appel. 

Quand elle était appelée dans une boucle depuis `get_user_decks()`:
```python
for user_deck in user_decks:
    await update_user_deck_anki_stats(db, user_deck)  # ❌ Commit ici
```

**Séquence du problème:**
1. Premier appel: `commit()` → l'objet `user_deck` est "expiré" (detached)
2. Deuxième itération: accès à `user_deck.deck_pk`
3. SQLAlchemy tente de recharger l'objet depuis la DB
4. **ERREUR**: Contexte async incompatible → `MissingGreenlet`

---

## ✅ Solution Appliquée

### Modification de `update_user_deck_anki_stats`
**Fichier:** `app/crud_users.py` (lignes 488-530)

**Changement:**
- ✅ Ajout d'un paramètre `commit_changes: bool = False`
- ✅ Le `commit()` n'est fait que si `commit_changes=True`
- ✅ Par défaut, pas de commit (évite les problèmes dans les boucles)

```python
async def update_user_deck_anki_stats(
    db: AsyncSession,
    user_deck: models.UserDeck,
    commit_changes: bool = False  # ✅ Nouveau paramètre
) -> models.UserDeck:
    """Met à jour les compteurs de cartes maîtrisées/en cours/à revoir."""
    
    # ... logique de calcul ...
    
    db.add(user_deck)
    
    # ✅ Commit conditionnel
    if commit_changes:
        await db.commit()
        await db.refresh(user_deck)
    
    return user_deck
```

### Impact sur les Appels

#### 1. `get_user_decks()` - Lecture seule
```python
for user_deck in user_decks:
    await update_user_deck_anki_stats(db, user_deck)  # commit_changes=False (défaut)
# ✅ Pas de commit dans la boucle → Pas d'erreur MissingGreenlet
```

#### 2. `create_score()` - Écriture
```python
await update_user_deck_anki_stats(db, user_deck)  # commit_changes=False
# ... autres modifications ...
await db.commit()  # ✅ Commit global à la fin de la fonction
```

---

## 🧪 Résultat du Test

**Test:** `test_get_decks.py`

```
✅ Récupération réussie!
   Nombre de decks: 3

📦 Deck PK: 16
   Nom: Pesci
   Total Points: 100
   Total Attempts: 8
   Mastered: 1, Learning: 7, Review: 0

📦 Deck PK: 10
   Nom: Quattro stagioni
   Total Points: 200
   Total Attempts: 4
   Mastered: 2, Learning: 2, Review: 0

📦 Deck PK: 9
   Nom: Dodici mesi
   Total Points: 85
   Total Attempts: 1
   Mastered: 1, Learning: 0, Review: 11
```

---

## 🚀 Prochaines Étapes

### 1. Le Serveur Devrait Redémarrer Automatiquement
Le mode `--reload` d'uvicorn devrait avoir détecté les changements.

### 2. Tester depuis le Frontend
Accédez au **Dashboard** depuis votre application frontend. Les données devraient maintenant se charger correctement sans erreur CORS.

### 3. Si Problème Persiste
Redémarrez manuellement le serveur:
```bash
# CTRL+C pour arrêter
uvicorn app.main:app --reload
```

---

## 📝 Résumé des Corrections

| Fichier | Fonction | Changement | Raison |
|---------|----------|------------|--------|
| `crud_users.py` | `update_user_deck_anki_stats` | Ajout param `commit_changes` | Éviter commit dans boucles |
| `crud_users.py` | `update_user_deck_anki_stats` | Commit conditionnel | Contrôle fin des transactions |

---

## 🎯 État Final

| Aspect | État | Détails |
|--------|------|---------|
| **Erreur MissingGreenlet** | ✅ Corrigée | Pas de commit dans les boucles |
| **GET /api/users/decks** | ✅ Fonctionnel | Test validé avec 3 decks |
| **Erreur CORS** | ✅ Résolue | Conséquence du 500 corrigé |
| **Dashboard Frontend** | ⏳ À tester | Devrait fonctionner maintenant |

**L'erreur provient du backend (problème SQLAlchemy async), pas du frontend.**
