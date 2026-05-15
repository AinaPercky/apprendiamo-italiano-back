# Tests Automatiques - Apprendiamo Italiano API

Ce document explique comment utiliser le système de tests automatiques complet pour l'API Apprendiamo Italiano.

## 📋 Fichiers de Test

### 1. `test_comprehensive_api.py`
Test automatique complet de tous les endpoints avec focus sur:
- Authentification (création d'utilisateur, login)
- Gestion des decks
- Gestion des cartes (flashcards)
- Association decks-utilisateur
- Quiz et scores (frappe, association, QCM, classique)
- Vérification de l'algorithme Anki
- Vérification des statistiques

### 2. `fix_bugs.py`
Script de correction automatique des bugs identifiés:
- Ajout de la colonne `quiz_type` si manquante
- Vérification des relations UserDeck
- Correction des valeurs Anki invalides
- Recalcul des statistiques utilisateur
- Recalcul des statistiques UserDeck

## 🚀 Prérequis

1. **Installer les dépendances**:
```bash
pip install httpx pytest pytest-asyncio python-dotenv
```

2. **Démarrer le serveur**:
```bash
uvicorn app.main:app --reload
```

Le serveur doit être accessible sur `http://localhost:8000`

## 🧪 Exécution des Tests

### Test Complet de l'API

```bash
python test_comprehensive_api.py
```

Ce script va:
1. ✅ Créer un utilisateur de test
2. ✅ Tester la connexion
3. ✅ Créer un deck
4. ✅ Créer plusieurs cartes
5. ✅ Ajouter le deck à l'utilisateur
6. ✅ Exécuter différents types de quiz
7. ✅ Vérifier l'algorithme Anki
8. ✅ Vérifier les statistiques
9. ✅ Nettoyer les données de test

### Résultats

Le script génère automatiquement:
- **Rapport détaillé** dans `test_report_YYYYMMDD_HHMMSS.txt`
- **Liste des bugs** dans `bugs_found_YYYYMMDD_HHMMSS.txt` (si bugs trouvés)

Exemple de sortie:
```
================================================================================
                    RAPPORT DE TESTS AUTOMATIQUES
================================================================================
Date: 2025-11-21 11:45:30
Durée totale: 15.34s

RÉSUMÉ:
--------
Total de tests: 18
✅ Réussis: 16
❌ Échoués: 2
⚠️ Avertissements: 0
⏭️ Ignorés: 0

Taux de réussite: 88.9%
```

## 🔧 Correction des Bugs

### Correction Automatique

```bash
python fix_bugs.py
```

Ce script va:
1. Vérifier et ajouter la colonne `quiz_type` si nécessaire
2. Nettoyer les relations UserDeck orphelines
3. Corriger les valeurs Anki invalides
4. Recalculer toutes les statistiques utilisateur
5. Recalculer toutes les statistiques UserDeck

### Migration Alembic

Si vous préférez utiliser Alembic pour la migration:

```bash
# Appliquer la migration
alembic upgrade head

# Ou si vous avez besoin de revenir en arrière
alembic downgrade -1
```

## 📊 Types de Quiz Testés

Le système teste 4 types de quiz:

1. **Frappe** (`frappe`): Quiz de frappe/typing
2. **Association** (`association`): Quiz d'association de mots
3. **QCM** (`qcm`): Quiz à choix multiples
4. **Classique** (`classique`): Quiz classique recto-verso

Chaque type de quiz:
- Enregistre un score (0-100)
- Met à jour les statistiques utilisateur
- Déclenche l'algorithme Anki
- Met à jour les statistiques du deck

## 🐛 Bugs Connus et Corrections

### Bug #1: Colonne quiz_type manquante
**Symptôme**: Erreur lors de la création d'un score
**Correction**: Exécuter `fix_bugs.py` ou la migration Alembic

### Bug #2: Endpoint de login manquant
**Symptôme**: Erreur 404 sur `/api/users/login`
**Correction**: ✅ Corrigé dans `app/api/endpoints_users.py`

### Bug #3: Statistiques incohérentes
**Symptôme**: Les totaux ne correspondent pas aux scores enregistrés
**Correction**: Exécuter `fix_bugs.py` pour recalculer

## 📝 Structure des Endpoints Testés

### Authentification
- `POST /api/users/register` - Créer un utilisateur
- `POST /api/users/login` - Se connecter
- `POST /api/users/google-login` - Connexion Google
- `GET /api/users/me` - Profil utilisateur
- `PUT /api/users/me` - Mettre à jour le profil

### Decks
- `POST /decks/` - Créer un deck
- `GET /decks/` - Liste des decks
- `GET /decks/{deck_pk}` - Détails d'un deck

### Cartes
- `POST /cards/` - Créer une carte
- `GET /cards/` - Liste des cartes
- `GET /cards/{card_pk}` - Détails d'une carte
- `PUT /cards/{card_pk}` - Mettre à jour une carte
- `DELETE /cards/{card_pk}` - Supprimer une carte

### Decks Utilisateur
- `GET /api/users/decks` - Decks de l'utilisateur
- `POST /api/users/decks/{deck_pk}` - Ajouter un deck
- `DELETE /api/users/decks/{deck_pk}` - Retirer un deck

### Scores
- `POST /api/users/scores` - Enregistrer un score
- `GET /api/users/stats` - Statistiques globales

## 🎯 Algorithme Anki

L'algorithme Anki est automatiquement déclenché lors de l'enregistrement d'un score. Il met à jour:

- `easiness`: Facteur de facilité (1.3 - 5.0)
- `interval`: Intervalle de révision (en jours)
- `consecutive_correct`: Nombre de réponses correctes consécutives
- `next_review`: Date de la prochaine révision
- `box`: Boîte Leitner (0-10)

### Grades Anki
- **0 (Again)**: Réponse incorrecte (score < 50)
- **1 (Hard)**: Difficile (score 50-74)
- **2 (Good)**: Bon (score 75-89)
- **3 (Easy)**: Facile (score 90-100)

## 📈 Statistiques Suivies

### Utilisateur Global
- `total_score`: Score total accumulé
- `total_cards_learned`: Nombre de cartes apprises
- `total_cards_reviewed`: Nombre de révisions

### Par Deck (UserDeck)
- `total_points`: Points totaux sur ce deck
- `total_attempts`: Nombre total de tentatives
- `successful_attempts`: Nombre de réponses correctes
- `points_frappe`: Points en mode frappe
- `points_association`: Points en mode association
- `points_qcm`: Points en mode QCM
- `points_classique`: Points en mode classique
- `mastered_cards`: Cartes maîtrisées (interval >= 21 jours)
- `learning_cards`: Cartes en apprentissage (consecutive_correct < 2)
- `review_cards`: Cartes en révision

## 🔍 Debugging

Pour activer les logs détaillés:

```python
# Dans test_comprehensive_api.py
import logging
logging.basicConfig(level=logging.DEBUG)
```

Pour tester un endpoint spécifique:

```python
async with APITester() as tester:
    await tester.run_test("Mon test", tester.test_create_deck)
```

## 📞 Support

En cas de problème:
1. Vérifier que le serveur est démarré
2. Vérifier la base de données
3. Consulter les logs du serveur
4. Exécuter `fix_bugs.py`
5. Consulter le rapport de tests généré

## 🎉 Résultat Attendu

Si tout fonctionne correctement, vous devriez voir:

```
✨ Aucun bug identifié!
Taux de réussite: 100.0%
```

Bonne chance avec vos tests! 🚀
