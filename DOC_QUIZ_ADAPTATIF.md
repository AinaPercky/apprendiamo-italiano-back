# 📚 Documentation - Système de Quiz Adaptatif Intelligent

## Vue d'ensemble

Le système de quiz adaptatif permet aux utilisateurs de réviser leurs flashcards de manière intelligente et progressive. Il implémente un algorithme sophistiqué qui :

1. **Évite les répétitions** jusqu'à ce que toutes les cartes du deck aient été vues
2. **Priorise les cartes difficiles** dans les cycles suivants
3. **S'adapte aux performances** de chaque utilisateur
4. **Offre un contrôle total** sur le nombre de cartes à réviser

---

## 🎯 Fonctionnalités principales

### 1. Interface de configuration du quiz

L'utilisateur peut :
- Choisir le nombre de cartes à réviser (de 1 à la totalité du deck)
- Voir le nombre total de cartes disponibles dans le deck
- Obtenir un feedback sur le cycle en cours et les cartes restantes

### 2. Algorithme de sélection intelligente

#### **Premier cycle (couverture totale)**
- Les cartes sont sélectionnées **aléatoirement**
- Pas de répétition : les cartes déjà vues sont exclues
- Continue jusqu'à ce que toutes les cartes aient été vues au moins une fois

#### **Cycles suivants (révision ciblée)**
- Les cartes sont sélectionnées avec **pondération basée sur les performances**
- Les cartes difficiles (beaucoup d'erreurs) ont plus de chances d'apparaître
- Les cartes bien maîtrisées apparaissent moins souvent

### 3. Système de scoring

Chaque carte a un `priority_score` calculé selon la formule :

```
priority_score = (incorrect_count × 2) - correct_count
```

**Exemples :**
- Carte jamais révisée : score = 0
- 3 erreurs, 1 bonne réponse : score = (3 × 2) - 1 = 5 (haute priorité)
- 5 bonnes réponses, 1 erreur : score = (1 × 2) - 5 = -3 (basse priorité)

**Poids de sélection :**
```
poids = 1 + max(priority_score, 0)
```

---

## 📡 API Endpoints

### **POST /api/quiz/start**
Démarre un nouveau quiz avec sélection intelligente des cartes.

**Request Body :**
```json
{
  "deck_pk": 1,
  "card_count": 10,
  "quiz_type": "classique"
}
```

**Response :**
```json
{
  "session_pk": 42,
  "deck_pk": 1,
  "cycle_number": 1,
  "total_cards_in_deck": 50,
  "requested_card_count": 10,
  "selected_cards": [
    {
      "card_pk": 5,
      "front": "Ciao",
      "back": "Salut",
      ...
    }
  ],
  "message": "Cycle 1: 10 cartes sélectionnées aléatoirement. 40 cartes restantes."
}
```

**Messages possibles :**
- `"Cycle 1: 10 cartes sélectionnées aléatoirement. 40 cartes restantes."`
- `"Cycle 2: 10 cartes sélectionnées avec priorisation intelligente (cartes difficiles favorisées)."`

---

### **POST /api/quiz/answer**
Enregistre une réponse et met à jour les performances.

**Query Parameters :**
- `card_pk` (int) : ID de la carte
- `deck_pk` (int) : ID du deck
- `is_correct` (bool) : True si réponse correcte

**Response :**
```json
{
  "performance_pk": 123,
  "card_pk": 5,
  "correct_count": 3,
  "incorrect_count": 1,
  "total_attempts": 4,
  "priority_score": -1.0,
  "last_reviewed_at": "2025-12-04T11:45:00"
}
```

---

### **POST /api/quiz/complete/{session_pk}**
Finalise une session de quiz.

**Query Parameters :**
- `correct_count` (int) : Nombre de réponses correctes
- `total_questions` (int) : Nombre total de questions

**Response :**
```json
{
  "session_pk": 42,
  "deck_pk": 1,
  "card_count": 10,
  "quiz_type": "classique",
  "cycle_number": 1,
  "correct_count": 7,
  "total_questions": 10,
  "started_at": "2025-12-04T11:30:00",
  "completed_at": "2025-12-04T11:45:00"
}
```

---

### **GET /api/quiz/sessions**
Récupère l'historique des sessions.

**Query Parameters :**
- `deck_pk` (int, optionnel) : Filtrer par deck
- `limit` (int, default=50) : Nombre de sessions à retourner

**Response :**
```json
[
  {
    "session_pk": 42,
    "deck_pk": 1,
    "card_count": 10,
    "quiz_type": "classique",
    "cycle_number": 1,
    "correct_count": 7,
    "total_questions": 10,
    "started_at": "2025-12-04T11:30:00",
    "completed_at": "2025-12-04T11:45:00"
  }
]
```

---

### **GET /api/quiz/performances/{deck_pk}**
Récupère les performances de toutes les cartes d'un deck.

**Response :**
```json
[
  {
    "performance_pk": 123,
    "card_pk": 5,
    "correct_count": 8,
    "incorrect_count": 2,
    "total_attempts": 10,
    "priority_score": -4.0,
    "last_reviewed_at": "2025-12-04T11:45:00"
  }
]
```

---

## 🗄️ Modèles de données

### **CardPerformance**
Stocke les statistiques de performance pour chaque carte par utilisateur.

| Champ | Type | Description |
|-------|------|-------------|
| `performance_pk` | Integer | Clé primaire |
| `user_pk` | Integer | Référence utilisateur |
| `card_pk` | Integer | Référence carte |
| `deck_pk` | Integer | Référence deck |
| `correct_count` | Integer | Nombre de réponses correctes |
| `incorrect_count` | Integer | Nombre d'erreurs |
| `total_attempts` | Integer | Total de tentatives |
| `priority_score` | Float | Score de priorisation |
| `last_reviewed_at` | DateTime | Dernière révision |

### **QuizSession**
Historique des sessions de quiz.

| Champ | Type | Description |
|-------|------|-------------|
| `session_pk` | Integer | Clé primaire |
| `user_pk` | Integer | Référence utilisateur |
| `deck_pk` | Integer | Référence deck |
| `card_count` | Integer | Nombre de cartes dans le quiz |
| `quiz_type` | String | Type de quiz |
| `cycle_number` | Integer | Numéro du cycle |
| `used_card_pks` | Text (JSON) | IDs des cartes utilisées |
| `correct_count` | Integer | Réponses correctes |
| `total_questions` | Integer | Total de questions |
| `started_at` | DateTime | Début de session |
| `completed_at` | DateTime | Fin de session |

---

## 🔄 Flux de travail typique

### **1. Démarrage du quiz**
```python
# Frontend
response = await fetch('/api/quiz/start', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        deck_pk: 1,
        card_count: 10,
        quiz_type: 'classique'
    })
})

const quizData = await response.json()
// quizData.selected_cards contient les cartes à afficher
// quizData.message indique le contexte (cycle, cartes restantes)
```

### **2. Pour chaque question**
```python
# Après que l'utilisateur répond
await fetch(`/api/quiz/answer?card_pk=${cardPk}&deck_pk=${deckPk}&is_correct=${isCorrect}`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` }
})
```

### **3. Fin du quiz**
```python
await fetch(`/api/quiz/complete/${sessionPk}?correct_count=${correct}&total_questions=${total}`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` }
})
```

---

## 🧪 Exemple de scénario

### **Scénario : Deck de 50 cartes**

**Quiz 1 (Cycle 1):**
- Utilisateur demande 10 cartes
- 10 cartes aléatoires sélectionnées
- Message : "Cycle 1: 10 cartes sélectionnées aléatoirement. 40 cartes restantes."

**Quiz 2 (Cycle 1 continue):**
- Utilisateur demande 15 cartes
- 15 cartes parmi les 40 restantes
- Message : "Cycle 1: 15 cartes sélectionnées aléatoirement. 25 cartes restantes."

**Quiz 3 (Fin du Cycle 1):**
- Utilisateur demande 30 cartes
- Seulement 25 disponibles (les 25 restantes)
- Message : "Cycle 1: 25 cartes sélectionnées. 0 cartes restantes avant fin du cycle."

**Quiz 4 (Début Cycle 2):**
- Utilisateur demande 10 cartes
- Cycle réinitialisé, sélection pondérée basée sur performances
- Les cartes avec beaucoup d'erreurs ont plus de chances d'apparaître
- Message : "Cycle 2: 10 cartes sélectionnées avec priorisation intelligente (cartes difficiles favorisées)."

---

## 📊 Avantages de cette approche

✅ **Couverture complète** : Toutes les cartes sont vues avant répétition
✅ **Apprentissage ciblé** : Focus automatique sur les cartes difficiles
✅ **Flexibilité** : L'utilisateur choisit combien de cartes réviser
✅ **Évolution** : L'algorithme s'adapte aux progrès de l'utilisateur
✅ **Transparence** : Messages clairs sur le cycle et les cartes restantes

---

## 🚀 Installation et Migration

### **1. Appliquer la migration**
```bash
cd d:\dev\apprendiamo-italiano-backend
alembic upgrade head
```

### **2. Redémarrer le serveur**
Le serveur redémarrera automatiquement si uvicorn est en mode `--reload`.

### **3. Tester les endpoints**
```bash
# Tester la documentation interactive
# Ouvrir: http://localhost:8000/docs
# Les nouveaux endpoints seront dans la section "quiz"
```

---

## 🎨 Suggestions d'interface frontend

### **Page de configuration du quiz**
```
┌─────────────────────────────────────────┐
│  📚 Quiz - Deck: Vocabulaire Italien    │
├─────────────────────────────────────────┤
│                                         │
│  Total de cartes: 50                    │
│  Cartes restantes (Cycle 1): 30         │
│                                         │
│  Combien de cartes?                     │
│  [========|==========] 15               │
│  (slider de 1 à 30)                     │
│                                         │
│  Type de quiz:                          │
│  ○ Classique  ● Frappe                  │
│  ○ QCM        ○ Association             │
│                                         │
│  [  Commencer le Quiz  ]                │
│                                         │
└─────────────────────────────────────────┘
```

### **Pendant le quiz**
Après chaque réponse, appeler `/api/quiz/answer` en arrière-plan.

### **Fin du quiz**
```
┌─────────────────────────────────────────┐
│  ✨ Quiz Terminé !                      │
├─────────────────────────────────────────┤
│                                         │
│  Score: 12/15 (80%)                     │
│                                         │
│  📊 Progression:                        │
│  Cycle 1 : 20/50 cartes vues            │
│                                         │
│  💡 3 cartes nécessitent plus           │
│     de pratique !                       │
│                                         │
│  [  Nouveau Quiz  ]  [  Accueil  ]      │
│                                         │
└─────────────────────────────────────────┘
```

---

## 📝 Notes importantes

1. **Authentification requise** : Tous les endpoints nécessitent un token JWT valide
2. **Isolation utilisateur** : Chaque utilisateur a ses propres performances et sessions
3. **Pas de conflit** : Les quiz simultanés sur différents decks sont supportés
4. **Performance** : L'algorithme est optimisé pour les decks jusqu'à 1000 cartes

---

## 🐛 Debugging

### **Voir le cycle actuel d'un utilisateur**
```python
GET /api/quiz/sessions?deck_pk=1&limit=10
# Regarder le cycle_number de la dernière session
```

### **Voir les cartes prioritaires**
```python
GET /api/quiz/performances/1
# Trier par priority_score DESC pour voir les cartes difficiles
```

---

Créé le 2025-12-04 | Backend Apprendiamo Italiano
