# 🎯 Quiz Adaptatif - Guide de Démarrage Rapide

## 🚀 Démarrage en 3 étapes

### 1️⃣ Appliquer la migration
```bash
python apply_quiz_migration.py
```

**Vous devriez voir:**
```
✅ Table 'card_performance' créée avec succès
✅ Table 'quiz_sessions' créée avec succès
📊 Système de quiz adaptatif prêt à l'emploi!
```

### 2️⃣ Le serveur est déjà lancé ! ✅
```bash
# Le serveur uvicorn tourne déjà en mode --reload
# Les nouveaux endpoints sont automatiquement disponibles
```

### 3️⃣ Tester les endpoints
Ouvrir dans votre navigateur : **http://localhost:8000/docs**

Chercher la section **"quiz"** - vous verrez 5 nouveaux endpoints ! 🎉

---

## 📡 Endpoints disponibles

| Endpoint | Description |
|----------|-------------|
| `POST /api/quiz/start` | Démarrer un quiz intelligent |
| `POST /api/quiz/answer` | Enregistrer une réponse |
| `POST /api/quiz/complete/{session_pk}` | Finaliser une session |
| `GET /api/quiz/sessions` | Historique des quiz |
| `GET /api/quiz/performances/{deck_pk}` | Stats par carte |

---

## 🧪 Tester rapidement

```bash
# Lancer le script de test complet
python test_quiz_adaptive.py
```

**Résultat attendu:** Tous les tests passent ✅

---

## 🎨 Exemple d'utilisation Frontend

```typescript
// 1. Commencer un quiz de 10 cartes
const quiz = await fetch('/api/quiz/start', {
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
}).then(r => r.json());

// quiz.selected_cards contient les cartes à afficher
// quiz.message explique le contexte (ex: "Cycle 1: 10 cartes sélectionnées...")

// 2. Pour chaque réponse
await fetch(`/api/quiz/answer?card_pk=${cardId}&deck_pk=1&is_correct=true`, {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` }
});

// 3. À la fin
await fetch(`/api/quiz/complete/${quiz.session_pk}?correct_count=7&total_questions=10`, {
  method: 'POST',
  headers: { 'Authorization': `Bearer ${token}` }
});
```

---

## 🧠 Comment ça marche ?

### **Cycle 1 : Couverture totale**
- Les cartes sont sélectionnées **aléatoirement**
- Pas de répétition jusqu'à ce que toutes les cartes soient vues
- Message : *"Cycle 1: X cartes sélectionnées aléatoirement. Y cartes restantes."*

### **Cycles suivants : Priorisation intelligente**
- Les cartes difficiles (beaucoup d'erreurs) apparaissent **plus souvent**
- Les cartes bien maîtrisées apparaissent **moins souvent**
- Formule : `priority_score = (erreurs × 2) - bonnes_réponses`
- Message : *"Cycle 2: X cartes sélectionnées avec priorisation intelligente."*

---

## 📚 Documentation complète

- **`DOC_QUIZ_ADAPTATIF.md`** : Documentation API détaillée
- **`IMPLEMENTATION_SUMMARY.md`** : Résumé de l'implémentation
- **`test_quiz_adaptive.py`** : Exemples de code

---

## ✅ Checklist

- [x] Migration appliquée (`python apply_quiz_migration.py`)
- [x] Serveur redémarré (automatique avec `--reload`)
- [x] Tests réussis (`python test_quiz_adaptive.py`)
- [ ] Frontend intégré (à faire)
- [ ] Interface utilisateur créée (à faire)

---

## 🎉 C'est prêt !

Le système de quiz adaptatif est **opérationnel**. Vous pouvez maintenant :

1. **Tester les endpoints** dans Swagger UI
2. **Intégrer l'API** dans votre frontend
3. **Créer une interface** pour choisir le nombre de cartes

**Bon développement ! 🚀**
