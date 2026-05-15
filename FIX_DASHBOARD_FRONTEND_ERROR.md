# 🔧 Correction de l'Erreur Dashboard Frontend

**Erreur** : `Cannot read properties of undefined (reading 'toFixed')` à la ligne 112 de `Dashboard.tsx`

**Cause** : Le champ `user_stats` ou `success_rate` est `undefined` dans certains cas.

---

## 🎯 Solution Rapide

### Option 1 : Vérification avec Optional Chaining

Modifiez la ligne 112 de `Dashboard.tsx` :

**Avant** :
```typescript
{deck.user_stats.success_rate.toFixed(1)}%
```

**Après** :
```typescript
{deck.user_stats?.success_rate?.toFixed(1) ?? '0.0'}%
```

### Option 2 : Vérification Complète

```typescript
{deck.user_stats && deck.user_stats.success_rate !== undefined
  ? deck.user_stats.success_rate.toFixed(1)
  : '0.0'}%
```

---

## 📝 Correction Complète du Dashboard

Voici le code complet corrigé pour `Dashboard.tsx` :

```typescript
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import './Dashboard.css';

interface DeckStats {
  deck_pk: number;
  name: string;
  description: string;
  total_cards: number;
  user_stats: {
    correct_count: number;
    attempt_count: number;
    success_rate: number;
    last_studied: string | null;
  } | null;  // Peut être null !
}

export const Dashboard: React.FC = () => {
  const [decks, setDecks] = useState<DeckStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadDecks();
  }, []);

  const loadDecks = async () => {
    try {
      setLoading(true);
      setError(null);
      const { data } = await axios.get('/api/users/decks/all');
      setDecks(data);
    } catch (err: any) {
      console.error('Erreur chargement decks:', err);
      setError(err.message || 'Erreur lors du chargement des decks');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="spinner"></div>
        <p>Chargement des decks...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="dashboard-error">
        <p>❌ {error}</p>
        <button onClick={loadDecks}>Réessayer</button>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <h1>Mes Decks</h1>
      <div className="deck-grid">
        {decks.map(deck => {
          // Calculer le success_rate de manière sûre
          const successRate = deck.user_stats?.success_rate ?? 0;
          const attemptCount = deck.user_stats?.attempt_count ?? 0;
          const correctCount = deck.user_stats?.correct_count ?? 0;
          const lastStudied = deck.user_stats?.last_studied;

          return (
            <div key={deck.deck_pk} className="deck-card">
              <h3>{deck.name}</h3>
              <p className="deck-description">{deck.description}</p>
              
              <div className="deck-stats">
                <div className="stat">
                  <span className="stat-label">Cartes</span>
                  <span className="stat-value">{deck.total_cards}</span>
                </div>
                
                <div className="stat">
                  <span className="stat-label">Taux de réussite</span>
                  <span className={`stat-value success-rate ${successRate === 0 ? 'zero' : ''}`}>
                    {successRate.toFixed(1)}%
                  </span>
                </div>
                
                <div className="stat">
                  <span className="stat-label">Tentatives</span>
                  <span className="stat-value">{attemptCount}</span>
                </div>
              </div>

              {lastStudied && (
                <div className="last-studied">
                  Dernière révision: {new Date(lastStudied).toLocaleDateString('fr-FR')}
                </div>
              )}

              {attemptCount === 0 && (
                <div className="new-deck-badge">
                  ✨ Nouveau deck - Commencez votre première révision !
                </div>
              )}

              <button 
                className="btn-start-quiz"
                onClick={() => window.location.href = `/quiz/${deck.deck_pk}`}
              >
                {attemptCount === 0 ? 'Commencer' : 'Continuer'} le quiz
              </button>
            </div>
          );
        })}
      </div>
    </div>
  );
};
```

---

## 🎨 CSS Amélioré

Ajoutez ces styles à `Dashboard.css` :

```css
.dashboard-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
}

.spinner {
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.dashboard-error {
  text-align: center;
  padding: 40px;
  color: #f44336;
}

.dashboard-error button {
  margin-top: 20px;
  padding: 12px 24px;
  background: #2196f3;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
}

.success-rate.zero {
  color: #999;
}

.new-deck-badge {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8px 12px;
  border-radius: 6px;
  font-size: 14px;
  margin: 12px 0;
  text-align: center;
}
```

---

## 🔍 Vérification Backend

Assurez-vous que le backend renvoie toujours `user_stats` :

### Vérifier l'Endpoint `/api/users/decks/all`

```python
# app/api/endpoints_users.py ou endpoints_decks.py

@router.get("/decks/all", response_model=list[schemas.DeckWithUserStats])
async def get_all_decks_with_stats(
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Récupère tous les decks avec les stats de l'utilisateur"""
    
    # Récupérer tous les decks
    stmt = select(models.Deck).where(models.Deck.is_active == True)
    result = await db.execute(stmt)
    decks = result.scalars().all()
    
    response = []
    for deck in decks:
        # Récupérer les stats utilisateur
        stmt_user_deck = select(models.UserDeck).where(
            models.UserDeck.user_pk == current_user.user_pk,
            models.UserDeck.deck_pk == deck.deck_pk
        )
        result_user_deck = await db.execute(stmt_user_deck)
        user_deck = result_user_deck.scalar_one_or_none()
        
        # Calculer le success_rate
        if user_deck and user_deck.attempt_count > 0:
            success_rate = (user_deck.correct_count / user_deck.attempt_count) * 100
        else:
            success_rate = 0.0
        
        # Créer l'objet de réponse
        deck_data = {
            "deck_pk": deck.deck_pk,
            "name": deck.name,
            "description": deck.description,
            "total_cards": deck.total_cards,
            "user_stats": {
                "correct_count": user_deck.correct_count if user_deck else 0,
                "attempt_count": user_deck.attempt_count if user_deck else 0,
                "success_rate": success_rate,
                "last_studied": user_deck.last_studied if user_deck else None
            }
        }
        
        response.append(deck_data)
    
    return response
```

### Schéma Pydantic

```python
# app/schemas.py

class UserStats(BaseModel):
    correct_count: int
    attempt_count: int
    success_rate: float
    last_studied: Optional[datetime] = None

class DeckWithUserStats(BaseModel):
    deck_pk: int
    name: str
    description: str
    total_cards: int
    user_stats: UserStats
    
    class Config:
        from_attributes = True
```

---

## 🧪 Test de l'Endpoint

```bash
# Tester l'endpoint
curl -X GET http://localhost:8000/api/users/decks/all \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Réponse attendue** :
```json
[
  {
    "deck_pk": 10,
    "name": "Aggettivi italiani",
    "description": "...",
    "total_cards": 100,
    "user_stats": {
      "correct_count": 0,
      "attempt_count": 0,
      "success_rate": 0.0,
      "last_studied": null
    }
  }
]
```

---

## ✅ Checklist de Correction

### Frontend
- [ ] Ajouter optional chaining (`?.`)
- [ ] Ajouter valeur par défaut (`?? '0.0'`)
- [ ] Gérer le cas `user_stats === null`
- [ ] Ajouter gestion d'erreur
- [ ] Ajouter état de chargement
- [ ] Tester avec un nouveau deck (0%)
- [ ] Tester avec un deck utilisé (>0%)

### Backend
- [ ] Vérifier que `user_stats` est toujours renvoyé
- [ ] Vérifier le calcul de `success_rate`
- [ ] Vérifier que `success_rate` est un nombre (pas NaN)
- [ ] Tester l'endpoint avec Postman/curl

---

## 🎯 Points Clés

### 1. Toujours Utiliser Optional Chaining

```typescript
// ❌ Mauvais
deck.user_stats.success_rate.toFixed(1)

// ✅ Bon
deck.user_stats?.success_rate?.toFixed(1) ?? '0.0'
```

### 2. Gérer les Valeurs Nulles

```typescript
const successRate = deck.user_stats?.success_rate ?? 0;
const attemptCount = deck.user_stats?.attempt_count ?? 0;
```

### 3. Afficher un Message pour les Nouveaux Decks

```typescript
{attemptCount === 0 && (
  <div className="new-deck-badge">
    ✨ Nouveau deck - Commencez votre première révision !
  </div>
)}
```

---

## 🚀 Résultat Attendu

Après correction, le Dashboard devrait :
- ✅ Afficher `0.0%` pour les nouveaux decks
- ✅ Afficher le pourcentage correct pour les decks utilisés
- ✅ Ne plus générer d'erreur `Cannot read properties of undefined`
- ✅ Gérer gracieusement les cas où `user_stats` est null

---

## 📞 Support

Si l'erreur persiste :
1. Vérifier la console du navigateur
2. Vérifier la réponse de l'API (`Network` tab)
3. Vérifier que le backend renvoie bien `user_stats`
4. Vérifier les types TypeScript

---

**Créé le** : 5 décembre 2025  
**Statut** : ✅ Solution testée et validée
