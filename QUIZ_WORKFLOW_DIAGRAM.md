# 🎯 Système de Quiz Adaptatif - Diagramme de Flux

## 🔄 Workflow Complet

```
┌─────────────────────────────────────────────────────────────────────┐
│                    UTILISATEUR DÉMARRE UN QUIZ                      │
│                                                                     │
│  POST /api/quiz/start                                              │
│  Body: { deck_pk: 1, card_count: 10, quiz_type: "classique" }     │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           ▼
         ┌─────────────────────────────────────┐
         │   Vérifier le cycle actuel         │
         │   (get_current_cycle_info)         │
         └────────┬───────────────┬────────────┘
                  │               │
         Cycle 1  │               │  Cycle 2+
                  │               │
     ┌────────────▼───────┐   ┌──▼────────────────────┐
     │ SÉLECTION ALÉATOIRE│   │ SÉLECTION PONDÉRÉE    │
     │                    │   │                       │
     │ 1. Charger toutes  │   │ 1. Charger toutes     │
     │    les cartes      │   │    les cartes         │
     │                    │   │                       │
     │ 2. Exclure cartes  │   │ 2. Récupérer les      │
     │    déjà vues       │   │    performances       │
     │                    │   │                       │
     │ 3. random.sample() │   │ 3. Calculer poids:    │
     │    (N cartes)      │   │    w = 1 + max(s, 0)  │
     │                    │   │                       │
     │ Message:           │   │ 4. random.choices()   │
     │ "X cartes          │   │    avec poids         │
     │  sélectionnées     │   │                       │
     │  aléatoirement.    │   │ Message:              │
     │  Y restantes."     │   │ "X cartes avec        │
     │                    │   │  priorisation         │
     │                    │   │  intelligente."       │
     └────────┬───────────┘   └──┬────────────────────┘
              │                  │
              └──────────┬───────┘
                         │
                         ▼
         ┌───────────────────────────────────┐
         │  Créer QuizSession                │
         │  - Stocker used_card_pks (JSON)   │
         │  - Enregistrer cycle_number       │
         └───────────────┬───────────────────┘
                         │
                         ▼
         ┌───────────────────────────────────┐
         │  Retourner les cartes             │
         │  sélectionnées au frontend        │
         └───────────────┬───────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────────────────┐
│                    UTILISATEUR RÉPOND AUX QUESTIONS                │
│                                                                    │
│  Pour chaque carte:                                                │
│  POST /api/quiz/answer?card_pk=X&deck_pk=Y&is_correct=true        │
└──────────────────────────┬─────────────────────────────────────────┘
                           │
                           ▼
         ┌─────────────────────────────────────┐
         │  get_or_create_card_performance     │
         └────────┬────────────────────────────┘
                  │
                  ▼
         ┌────────────────────────────────────────┐
         │  Mettre à jour les compteurs:          │
         │  - total_attempts += 1                 │
         │  - correct_count ou incorrect_count    │
         │                                        │
         │  Recalculer priority_score:            │
         │  score = (incorrect × 2) - correct     │
         │                                        │
         │  Mettre à jour last_reviewed_at        │
         └────────┬───────────────────────────────┘
                  │
                  ▼
         ┌────────────────────────────────────────┐
         │  Retourner la performance mise à jour  │
         └────────────────────────────────────────┘
                  │
                  │ (répéter pour chaque carte)
                  │
                  ▼
┌────────────────────────────────────────────────────────────────────┐
│                        FIN DU QUIZ                                 │
│                                                                    │
│  POST /api/quiz/complete/{session_pk}                             │
│  Params: correct_count=7, total_questions=10                      │
└──────────────────────────┬─────────────────────────────────────────┘
                           │
                           ▼
         ┌─────────────────────────────────────┐
         │  Mettre à jour QuizSession:         │
         │  - correct_count = 7                │
         │  - total_questions = 10             │
         │  - completed_at = NOW()             │
         └─────────────────────────────────────┘
                           │
                           ▼
                   ┌───────────────┐
                   │   TERMINÉ ✅   │
                   └───────────────┘
```

---

## 🔄 Gestion des Cycles

```
DECK DE 15 CARTES - EXEMPLE DE PROGRESSION
═══════════════════════════════════════════

┌─────────── CYCLE 1 ───────────┐
│                               │
│  Quiz 1: 5 cartes             │  ← Sélection aléatoire
│  [1, 3, 7, 9, 12]             │  → 10 cartes restantes
│                               │
│  Quiz 2: 7 cartes             │  ← Sélection aléatoire
│  [2, 4, 5, 8, 10, 13, 14]     │  → 3 cartes restantes
│                               │
│  Quiz 3: 3 cartes             │  ← Sélection aléatoire
│  [6, 11, 15]                  │  → 0 cartes restantes
│                               │
└───────────────────────────────┘
            │
            │ Toutes les cartes vues!
            │ Réinitialisation automatique
            ▼
┌─────────── CYCLE 2 ───────────┐
│                               │
│  Performances enregistrées:   │
│  - Cartes 7, 9: très difficiles (score: 6.0)
│  - Cartes 1, 3: difficiles (score: 3.0)
│  - Cartes 2, 4, etc: faciles (score: -2.0)
│                               │
│  Quiz 4: 5 cartes             │  ← Sélection PONDÉRÉE
│  Probabilité:                 │
│  - Cartes 7, 9: 70% chacune   │  (hauts scores)
│  - Cartes 1, 3: 40% chacune   │  (scores moyens)
│  - Autres: 10% chacune        │  (scores bas)
│                               │
│  Résultat possible:           │
│  [7, 9, 1, 7, 3]              │  ← Carte 7 apparaît 2x!
│                               │     (très haute priorité)
│                               │
└───────────────────────────────┘
```

---

## 📊 Calcul du Priority Score

```
FORMULE
═══════
priority_score = (incorrect_count × 2) - correct_count


EXEMPLES
════════

Carte jamais révisée:
  correct: 0, incorrect: 0
  → score = (0 × 2) - 0 = 0
  → poids = 1 + max(0, 0) = 1
  ✓ Priorité normale


Carte très facile (10 bonnes, 1 erreur):
  correct: 10, incorrect: 1
  → score = (1 × 2) - 10 = -8
  → poids = 1 + max(-8, 0) = 1
  ✓ Priorité minimale (pas besoin de révision)


Carte moyenne (5 bonnes, 3 erreurs):
  correct: 5, incorrect: 3
  → score = (3 × 2) - 5 = 1
  → poids = 1 + max(1, 0) = 2
  ✓ Priorité légèrement élevée


Carte difficile (2 bonnes, 5 erreurs):
  correct: 2, incorrect: 5
  → score = (5 × 2) - 2 = 8
  → poids = 1 + max(8, 0) = 9
  ✓ Priorité très élevée (révision fréquente)


Carte très difficile (1 bonne, 10 erreurs):
  correct: 1, incorrect: 10
  → score = (10 × 2) - 1 = 19
  → poids = 1 + max(19, 0) = 20
  ✓✓✓ PRIORITÉ MAXIMALE (apparaîtra très souvent)
```

---

## 🎯 Sélection Pondérée (Cycle 2+)

```python
# Pseudo-code de l'algorithme de sélection

cards = get_all_cards(deck_pk)
performances = get_performances(user_pk, deck_pk)

weights = []
for card in cards:
    perf = performances.get(card.card_pk)
    
    if perf:
        # Carte déjà révisée
        score = perf.priority_score
        weight = 1.0 + max(score, 0)
    else:
        # Carte jamais vue
        weight = 1.0
    
    weights.append(weight)

# Sélection pondérée
selected = random.choices(
    cards,
    weights=weights,
    k=card_count
)
```

**Exemple avec 5 cartes:**

| Carte ID | Score | Poids | Probabilité |
|----------|-------|-------|-------------|
| 1 | -3.0 | 1.0 | 8% |
| 2 | 0.0 | 1.0 | 8% |
| 3 | 2.0 | 3.0 | 25% |
| 4 | 5.0 | 6.0 | 50% |
| 5 | -1.0 | 1.0 | 8% |

**Total des poids:** 12.0

Carte 4 (difficile) a **50% de chances** d'être sélectionnée!  
Carte 1 (facile) a seulement **8% de chances**.

---

## 📈 Évolution de l'apprentissage

```
EXEMPLE SUR 6 QUIZ
══════════════════

Quiz 1 (Cycle 1):       [Cartes: 1,2,3,4,5]
  ↓ Résultats:          ✓✗✗✓✓
  ↓ Scores:             -1, 1, 1, -1, -1


Quiz 2 (Cycle 1):       [Cartes: 6,7,8,9,10]
  ↓ Résultats:          ✓✓✓✗✗
  ↓ Scores:             -1, -1, -1, 1, 1


Quiz 3 (Cycle 1):       [Cartes: 11,12,13,14,15]
  ↓ Résultats:          ✓✓✓✓✓
  ↓ Scores:             -1, -1, -1, -1, -1
  
  → FIN DU CYCLE 1 (toutes les cartes vues)


Quiz 4 (Cycle 2):       [Cartes: 2,3,9,10,4]  ← Cartes difficiles favorisées!
  ↓ Résultats:          ✓✓✓✗✓
  ↓ Nouveaux scores:    -1, -1, -1, 3, -1
  
  → Carte 10 toujours difficile, les autres maîtrisées


Quiz 5 (Cycle 2):       [Cartes: 10,1,5,12,10]  ← Carte 10 apparaît 2x!
  ↓ Résultats:          ✓✓✓✓✓
  ↓ Nouveaux scores:    -3, -3, -3, -3, -1
  
  → Carte 10 enfin maîtrisée!


Quiz 6 (Cycle 2):       [Cartes: 7,14,2,11,8]  ← Sélection équilibrée
  ↓ Résultats:          ✓✓✓✓✓
  
  → Toutes les cartes bien maîtrisées ✅
```

---

## 🎨 Exemple d'Interface Utilisateur

```
┌──────────────────────────────────────────────────┐
│  📚 Vocabulaire Italien - Quiz Adaptatif        │
├──────────────────────────────────────────────────┤
│                                                  │
│  Total de cartes dans ce deck: 50               │
│                                                  │
│  ┌────────────────────────────────────┐          │
│  │  Vous êtes au Cycle 2              │          │
│  │  30 cartes déjà vues               │          │
│  │                                    │          │
│  │  💡 Les cartes difficiles seront  │          │
│  │     priorisées automatiquement!   │          │
│  └────────────────────────────────────┘          │
│                                                  │
│  Combien de cartes voulez-vous réviser?         │
│                                                  │
│  ┌────────────────────────────────┐              │
│  │  [========|==============] 15  │              │
│  └────────────────────────────────┘              │
│       1 ←                     → 50               │
│                                                  │
│  Type de quiz:                                   │
│  ○ Classique  ● Frappe  ○ QCM  ○ Association    │
│                                                  │
│  [      Commencer le Quiz      ]                │
│                                                  │
└──────────────────────────────────────────────────┘


PENDANT LE QUIZ
═══════════════

┌──────────────────────────────────────────────────┐
│  Question 3/15                    Cycle 2        │
├──────────────────────────────────────────────────┤
│                                                  │
│  🏠                                              │
│                                                  │
│  Casa                                            │
│                                                  │
│  ┌────────────────────────┐                      │
│  │  Votre réponse:       │                      │
│  │  _________________    │                      │
│  └────────────────────────┘                      │
│                                                  │
│  [  Valider  ]          [  Passer  ]            │
│                                                  │
│  💡 Cette carte a été difficile pour vous       │
│     lors du dernier quiz                        │
│                                                  │
└──────────────────────────────────────────────────┘


FIN DU QUIZ
═══════════

┌──────────────────────────────────────────────────┐
│  ✨ Quiz Terminé !                               │
├──────────────────────────────────────────────────┤
│                                                  │
│  📊 Résultat: 12/15 (80%)                       │
│                                                  │
│  ┌────────────────────────────────┐              │
│  │  Progression du Cycle 2        │              │
│  │  [████████████░░░░] 45/50      │              │
│  │                                │              │
│  │  5 cartes restantes à voir!   │              │
│  └────────────────────────────────┘              │
│                                                  │
│  💡 Cartes nécessitant plus de pratique:        │
│     • Casa (3 erreurs)                          │
│     • Libro (2 erreurs)                         │
│                                                  │
│  Ces cartes apparaîtront plus souvent lors      │
│  des prochains quiz!                            │
│                                                  │
│  [  Nouveau Quiz  ]    [  Accueil  ]            │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

**Créé le 2025-12-04** | Système de Quiz Adaptatif Intelligent
