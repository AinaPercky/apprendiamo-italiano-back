# 🔴 PROBLÈME CRITIQUE - UserDeck Pas Mis à Jour

**Diagnostic** : Vous avez terminé un quiz (40 cartes du deck Verbi riflessivi) mais le UserDeck affiche :
- ❌ Tentatives: 0
- ❌ Correctes: 0
- ❌ Last Studied: None

**Cause** : Le quiz ne met PAS à jour le UserDeck après `completeQuiz()`.

---

## 🎯 Solution : Corriger le Backend

### Vérifier l'Endpoint `completeQuiz`

Ouvrez `app/api/endpoints_quiz.py` et vérifiez la fonction `complete_quiz` :

```python
@router.post("/complete/{session_pk}")
async def complete_quiz(
    session_pk: int,
    correct_count: int = Query(...),
    total_questions: int = Query(...),
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Finalise une session de quiz"""
    
    # 1. Finaliser la session
    session = await crud_quiz.complete_quiz_session(
        db,
        session_pk,
        correct_count,
        total_questions
    )
    
    # 2. ⭐ IMPORTANT : Mettre à jour le UserDeck
    user_deck = await crud_quiz.get_or_create_user_deck(
        db,
        current_user.user_pk,
        session.deck_pk
    )
    
    # Mettre à jour les compteurs
    user_deck.attempt_count += total_questions
    user_deck.correct_count += correct_count
    user_deck.last_studied = datetime.utcnow()
    
    await db.commit()
    await db.refresh(user_deck)
    
    # Calculer le success_rate
    success_rate = (correct_count / total_questions * 100) if total_questions > 0 else 0
    
    return {
        "session_pk": session.session_pk,
        "correct_count": correct_count,
        "total_questions": total_questions,
        "success_rate": success_rate,
        "completed_at": session.completed_at
    }
```

---

## 🔧 Correction Complète

### 1. Vérifier `crud_quiz.py`

Ouvrez `app/crud_quiz.py` et ajoutez cette fonction si elle n'existe pas :

```python
async def get_or_create_user_deck(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int
) -> models.UserDeck:
    """Récupère ou crée un UserDeck"""
    stmt = select(models.UserDeck).where(
        models.UserDeck.user_pk == user_pk,
        models.UserDeck.deck_pk == deck_pk
    )
    result = await db.execute(stmt)
    user_deck = result.scalar_one_or_none()
    
    if not user_deck:
        user_deck = models.UserDeck(
            user_pk=user_pk,
            deck_pk=deck_pk,
            correct_count=0,
            attempt_count=0,
            cards_mastered=0
        )
        db.add(user_deck)
        await db.commit()
        await db.refresh(user_deck)
    
    return user_deck
```

### 2. Modifier `complete_quiz_session`

Dans `app/crud_quiz.py`, modifiez la fonction `complete_quiz_session` :

```python
async def complete_quiz_session(
    db: AsyncSession,
    session_pk: int,
    correct_count: int,
    total_questions: int
) -> models.QuizSession:
    """Finalise une session de quiz ET met à jour UserDeck"""
    
    # Récupérer la session
    stmt = select(models.QuizSession).where(
        models.QuizSession.session_pk == session_pk
    )
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    
    if not session:
        raise ValueError(f"Session {session_pk} not found")
    
    # Mettre à jour la session
    session.correct_count = correct_count
    session.total_questions = total_questions
    session.completed_at = datetime.utcnow()
    
    # ⭐ IMPORTANT : Mettre à jour le UserDeck
    user_deck = await get_or_create_user_deck(
        db,
        session.user_pk,
        session.deck_pk
    )
    
    user_deck.attempt_count += total_questions
    user_deck.correct_count += correct_count
    user_deck.last_studied = datetime.utcnow()
    
    await db.commit()
    await db.refresh(session)
    await db.refresh(user_deck)
    
    return session
```

---

## 🧪 Test de Vérification

### 1. Redémarrer le Backend

```bash
# Le backend devrait se recharger automatiquement avec uvicorn --reload
# Sinon, redémarrez manuellement
```

### 2. Faire un Quiz de Test

```bash
# Utiliser le test marathon
python test_quiz_marathon_enhanced.py
```

### 3. Vérifier le UserDeck

```bash
python check_user_dashboard.py
```

**Résultat attendu** :
```
✅ Utilisateur trouvé: jean

📈 Statistiques Globales:
   • Total tentatives: 127
   • Total correctes: 93
   • Success rate global: 73.2%
   • Decks commencés: 1

🎯 Verbi riflessivi (ID: 8)
   • Tentatives: 127
   • Correctes: 93
   • Success Rate: 73.2%
   • Dernière révision: 2025-12-05 15:22:28
```

---

## 🔍 Alternative : Vérifier le Code Actuel

Si vous n'êtes pas sûr de ce qui est implémenté, cherchons :

```bash
# Chercher la fonction complete_quiz
grep -n "def complete_quiz" app/api/endpoints_quiz.py

# Chercher user_deck dans complete_quiz
grep -A 20 "def complete_quiz" app/api/endpoints_quiz.py | grep user_deck
```

Si `user_deck` n'apparaît PAS, c'est le problème !

---

## 📝 Code Complet à Ajouter

### Dans `app/api/endpoints_quiz.py`

Remplacez la fonction `complete_quiz` par :

```python
from datetime import datetime
from app import crud_quiz

@router.post("/complete/{session_pk}")
async def complete_quiz(
    session_pk: int,
    correct_count: int = Query(...),
    total_questions: int = Query(...),
    current_user = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_db)
):
    """Finalise une session de quiz et met à jour le dashboard"""
    
    # Finaliser la session (cela met déjà à jour UserDeck si la fonction est corrigée)
    session = await crud_quiz.complete_quiz_session(
        db,
        session_pk,
        correct_count,
        total_questions
    )
    
    # Calculer le success_rate
    success_rate = (correct_count / total_questions * 100) if total_questions > 0 else 0
    
    return {
        "session_pk": session.session_pk,
        "correct_count": correct_count,
        "total_questions": total_questions,
        "success_rate": success_rate,
        "completed_at": session.completed_at
    }
```

### Dans `app/crud_quiz.py`

Ajoutez ou modifiez :

```python
from datetime import datetime

async def get_or_create_user_deck(
    db: AsyncSession,
    user_pk: int,
    deck_pk: int
) -> models.UserDeck:
    """Récupère ou crée un UserDeck"""
    stmt = select(models.UserDeck).where(
        models.UserDeck.user_pk == user_pk,
        models.UserDeck.deck_pk == deck_pk
    )
    result = await db.execute(stmt)
    user_deck = result.scalar_one_or_none()
    
    if not user_deck:
        user_deck = models.UserDeck(
            user_pk=user_pk,
            deck_pk=deck_pk,
            correct_count=0,
            attempt_count=0,
            cards_mastered=0
        )
        db.add(user_deck)
        await db.commit()
        await db.refresh(user_deck)
    
    return user_deck


async def complete_quiz_session(
    db: AsyncSession,
    session_pk: int,
    correct_count: int,
    total_questions: int
) -> models.QuizSession:
    """Finalise une session de quiz ET met à jour UserDeck"""
    
    # Récupérer la session
    stmt = select(models.QuizSession).where(
        models.QuizSession.session_pk == session_pk
    )
    result = await db.execute(stmt)
    session = result.scalar_one_or_none()
    
    if not session:
        raise ValueError(f"Session {session_pk} not found")
    
    # Mettre à jour la session
    session.correct_count = correct_count
    session.total_questions = total_questions
    session.completed_at = datetime.utcnow()
    
    # ⭐ METTRE À JOUR LE USERDECK
    user_deck = await get_or_create_user_deck(
        db,
        session.user_pk,
        session.deck_pk
    )
    
    user_deck.attempt_count += total_questions
    user_deck.correct_count += correct_count
    user_deck.last_studied = datetime.utcnow()
    
    await db.commit()
    await db.refresh(session)
    await db.refresh(user_deck)
    
    return session
```

---

## ✅ Checklist

- [ ] Fonction `get_or_create_user_deck` existe dans `crud_quiz.py`
- [ ] Fonction `complete_quiz_session` met à jour UserDeck
- [ ] Backend redémarré
- [ ] Test exécuté
- [ ] `check_user_dashboard.py` montre des tentatives > 0
- [ ] Dashboard frontend affiche les bons scores

---

## 🚀 Action Immédiate

1. **Vérifier le code actuel** :
```bash
grep -A 30 "def complete_quiz_session" app/crud_quiz.py
```

2. **Si UserDeck n'est pas mis à jour, appliquer la correction ci-dessus**

3. **Tester** :
```bash
python test_quiz_marathon_enhanced.py
python check_user_dashboard.py
```

---

**Créé le** : 5 décembre 2025  
**Priorité** : 🔴 CRITIQUE  
**Statut** : Solution fournie
