# 🔍 DIAGNOSTIC - Dashboard Affiche 0 Partout

**Problème Observé** :
```json
{
    "decksCount": 4,
    "stats": {
        "total_score": 0,           // ❌ Devrait être > 0
        "total_cards_learned": 0,   // ❌ Devrait être > 0
        "total_cards_reviewed": 32, // ✅ Correct
        "total_decks": 4,           // ✅ Correct
        "total_audio_records": 0,
        "last_login": "2025-12-05T15:34:12.157833"
    }
}
```

**Capture d'écran** : Tous les decks affichent "0.0%" et "0 cartes maîtrisées"

---

## 🎯 Problème Identifié

Le frontend appelle un endpoint qui calcule mal les scores. Il y a **2 endpoints différents** :

1. **Ancien endpoint** (celui que vous utilisez) : Renvoie `total_score`, `total_cards_learned`
2. **Nouvel endpoint** (pour le quiz) : `/api/users/decks/all` avec `success_rate`

---

## ✅ Solution : Utiliser le Bon Endpoint

### Option 1 : Utiliser `/api/users/decks/all` (RECOMMANDÉ)

Cet endpoint renvoie les vraies statistiques du système de quiz.

**Modifier le frontend** :

```typescript
// ❌ ANCIEN (ne fonctionne pas)
const { data } = await axios.get('/api/users/stats');  // ou autre endpoint

// ✅ NOUVEAU (fonctionne)
const { data } = await axios.get('/api/users/decks/all');
```

**Réponse attendue** :
```json
[
  {
    "deck_pk": 8,
    "name": "Verbi riflessivi",
    "description": "...",
    "total_cards": 40,
    "user_stats": {
      "correct_count": 30,
      "attempt_count": 40,
      "success_rate": 75.0,
      "last_studied": "2025-12-05T15:22:28"
    }
  }
]
```

---

### Option 2 : Corriger l'Endpoint Actuel

Si vous voulez garder l'endpoint actuel, il faut le corriger pour qu'il utilise les données du quiz.

**Trouver l'endpoint** :

```bash
# Chercher dans le code backend
grep -r "total_score" app/
grep -r "decksCount" app/
```

**Puis le modifier pour utiliser UserDeck** :

```python
# app/api/endpoints_users.py (ou similaire)

@router.get("/stats")
async def get_user_stats(
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    # Récupérer tous les UserDecks
    stmt = select(models.UserDeck).where(
        models.UserDeck.user_pk == current_user.user_pk
    )
    result = await db.execute(stmt)
    user_decks = result.scalars().all()
    
    # Calculer les stats
    total_attempts = sum(ud.attempt_count for ud in user_decks)
    total_correct = sum(ud.correct_count for ud in user_decks)
    
    # Compter les decks
    stmt_decks = select(func.count(models.Deck.deck_pk)).where(
        models.Deck.is_active == True
    )
    result_decks = await db.execute(stmt_decks)
    total_decks = result_decks.scalar()
    
    return {
        "decksCount": total_decks,
        "stats": {
            "total_score": total_correct,  # ⭐ Utiliser correct_count
            "total_cards_learned": total_correct,  # ⭐ Utiliser correct_count
            "total_cards_reviewed": total_attempts,  # ⭐ Utiliser attempt_count
            "total_decks": total_decks,
            "total_audio_records": 0,  # À implémenter
            "last_login": current_user.last_login or datetime.utcnow()
        }
    }
```

---

## 🔧 Solution Immédiate (Frontend)

### 1. Modifier le Service Dashboard

Créez ou modifiez `src/services/dashboardApi.ts` :

```typescript
import axios from 'axios';

export const dashboardApi = {
  // Nouvelle méthode utilisant le bon endpoint
  async getStats() {
    // Utiliser l'endpoint du quiz
    const { data: decks } = await axios.get('/api/users/decks/all');
    
    // Calculer les stats à partir des decks
    const totalAttempts = decks.reduce((sum: number, deck: any) => 
      sum + (deck.user_stats?.attempt_count ?? 0), 0
    );
    
    const totalCorrect = decks.reduce((sum: number, deck: any) => 
      sum + (deck.user_stats?.correct_count ?? 0), 0
    );
    
    const averageSuccessRate = totalAttempts > 0
      ? (totalCorrect / totalAttempts) * 100
      : 0;
    
    const decksStarted = decks.filter((deck: any) => 
      (deck.user_stats?.attempt_count ?? 0) > 0
    ).length;
    
    return {
      decksCount: decks.length,
      stats: {
        total_score: totalCorrect,
        total_cards_learned: totalCorrect,
        total_cards_reviewed: totalAttempts,
        total_decks: decks.length,
        average_success_rate: averageSuccessRate,
        decks_started: decksStarted
      },
      decks: decks
    };
  }
};
```

### 2. Modifier le Composant Dashboard

```typescript
import { useState, useEffect } from 'react';
import { dashboardApi } from '../services/dashboardApi';

export const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [decks, setDecks] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboard();
  }, []);

  const loadDashboard = async () => {
    try {
      setLoading(true);
      const data = await dashboardApi.getStats();
      setStats(data.stats);
      setDecks(data.decks);
    } catch (error) {
      console.error('Erreur:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div>Chargement...</div>;

  return (
    <div className="dashboard">
      {/* Total Scores */}
      <div className="stat-card">
        <div className="stat-label">Total scores</div>
        <div className="stat-value">{stats?.total_score ?? 0}</div>
        <div className="stat-subtitle">Points accumulés</div>
      </div>

      {/* Score Moyen */}
      <div className="stat-card">
        <div className="stat-label">Score moyen</div>
        <div className="stat-value">
          {stats?.average_success_rate?.toFixed(1) ?? '0.0'}
        </div>
        <div className="stat-subtitle">Par quiz</div>
      </div>

      {/* Decks */}
      <div className="stat-card">
        <div className="stat-label">Decks</div>
        <div className="stat-value">{stats?.decks_started ?? 0}</div>
        <div className="stat-subtitle">Collections</div>
      </div>

      {/* Liste des decks */}
      <div className="decks-list">
        {decks.map(deck => (
          <div key={deck.deck_pk} className="deck-item">
            <h3>{deck.name}</h3>
            <div className="deck-stats">
              <span>
                {deck.user_stats?.success_rate?.toFixed(1) ?? '0.0'}%
              </span>
              <span>
                {deck.user_stats?.correct_count ?? 0}/
                {deck.user_stats?.attempt_count ?? 0}
              </span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
```

---

## 🧪 Test de Vérification

### 1. Tester l'Endpoint `/api/users/decks/all`

```bash
curl -X GET http://localhost:8000/api/users/decks/all \
  -H "Authorization: Bearer YOUR_TOKEN" | jq
```

**Résultat attendu** :
```json
[
  {
    "deck_pk": 8,
    "name": "Verbi riflessivi",
    "user_stats": {
      "correct_count": 30,    // ⭐ Devrait être > 0
      "attempt_count": 40,    // ⭐ Devrait être > 0
      "success_rate": 75.0,   // ⭐ Devrait être > 0
      "last_studied": "2025-12-05T15:22:28"
    }
  }
]
```

### 2. Vérifier dans la Base de Données

```python
# Script de vérification
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select
from app.database import DATABASE_URL
from app.models import UserDeck, User

async def check_user_decks():
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession)
    
    async with async_session() as db:
        # Trouver l'utilisateur
        stmt = select(User).where(User.email == "jean@gmail.com")
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        
        if not user:
            print("❌ Utilisateur non trouvé")
            return
        
        print(f"✅ Utilisateur: {user.username} (ID: {user.user_pk})")
        
        # Récupérer les UserDecks
        stmt = select(UserDeck).where(UserDeck.user_pk == user.user_pk)
        result = await db.execute(stmt)
        user_decks = result.scalars().all()
        
        print(f"\n📊 UserDecks trouvés: {len(user_decks)}")
        
        for ud in user_decks:
            success_rate = (ud.correct_count / ud.attempt_count * 100) if ud.attempt_count > 0 else 0
            print(f"\nDeck {ud.deck_pk}:")
            print(f"  - Tentatives: {ud.attempt_count}")
            print(f"  - Correctes: {ud.correct_count}")
            print(f"  - Success Rate: {success_rate:.1f}%")
            print(f"  - Last Studied: {ud.last_studied}")
    
    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(check_user_decks())
```

Sauvegardez ce script dans `check_user_dashboard.py` et exécutez :

```bash
python check_user_dashboard.py
```

---

## 🎯 Résultat Attendu

Après correction, le dashboard devrait afficher :
- ✅ "Total scores: 30" (ou votre nombre de réponses correctes)
- ✅ "Score moyen: 75.0" (ou votre pourcentage)
- ✅ "Decks: 1" (ou le nombre de decks commencés)
- ✅ Chaque deck avec son vrai pourcentage

---

## 📝 Checklist

### Backend
- [ ] Endpoint `/api/users/decks/all` existe et fonctionne
- [ ] Renvoie `user_stats` avec `success_rate`
- [ ] Les données UserDeck sont correctes en base
- [ ] Testé avec curl/Postman

### Frontend
- [ ] Utilise `/api/users/decks/all` au lieu de l'ancien endpoint
- [ ] Calcule les stats globales à partir des decks
- [ ] Affiche les bonnes valeurs
- [ ] Pas d'erreur dans la console

---

## 🚀 Action Immédiate

**1. Créez le script de vérification** :

Copiez le code Python ci-dessus dans `check_user_dashboard.py`

**2. Exécutez-le** :

```bash
python check_user_dashboard.py
```

**3. Vérifiez les résultats** :
- Si `attempt_count` et `correct_count` sont > 0 → Le backend fonctionne
- Si = 0 → Le quiz ne met pas à jour UserDeck

**4. Modifiez le frontend** :

Utilisez le code fourni dans "Solution Immédiate (Frontend)"

---

**Créé le** : 5 décembre 2025  
**Statut** : ✅ Diagnostic complet
