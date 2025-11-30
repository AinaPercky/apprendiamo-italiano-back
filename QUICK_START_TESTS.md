# Guide Rapide - Tests Automatiques

## 🚀 Démarrage Rapide

### Option 1: Script Automatique (Recommandé)
```powershell
.\run_tests.ps1
```
Ce script va:
- Vérifier si le serveur est en cours d'exécution
- Démarrer le serveur si nécessaire
- Lancer tous les tests
- Arrêter le serveur à la fin

### Option 2: Manuel

**Étape 1**: Démarrer le serveur
```bash
uvicorn app.main:app --reload
```

**Étape 2**: Dans un autre terminal, lancer les tests
```bash
python test_comprehensive_api.py
```

## 📊 Résultats

Les tests génèrent automatiquement:
- `test_report_YYYYMMDD_HHMMSS.txt` - Rapport complet
- `bugs_found_YYYYMMDD_HHMMSS.txt` - Liste des bugs (si trouvés)

## 🔧 Correction des Bugs

Si des bugs sont identifiés:
```bash
python fix_bugs.py
```

## 📝 Sections Testées

1. ✅ **Authentification**
   - Création d'utilisateur
   - Connexion

2. ✅ **Gestion des Decks**
   - Création
   - Récupération
   - Détails

3. ✅ **Gestion des Cartes**
   - Création multiple
   - Récupération
   - Filtrage par deck
   - Mise à jour

4. ✅ **Decks Utilisateur**
   - Ajout à la bibliothèque
   - Récupération

5. ✅ **Quiz et Scores**
   - Quiz Frappe
   - Quiz Association
   - Quiz QCM
   - Quiz Classique
   - Réponse incorrecte

6. ✅ **Vérifications**
   - Algorithme Anki
   - Statistiques deck utilisateur

7. ✅ **Nettoyage**
   - Suppression des données de test

## 🎯 Taux de Réussite Attendu

**100%** si tout fonctionne correctement

## ⚠️ Problèmes Courants

### Le serveur ne démarre pas
```bash
# Vérifier les dépendances
pip install -r requirements.txt

# Vérifier la base de données
# Assurez-vous que PostgreSQL est en cours d'exécution
```

### Tests échouent
1. Vérifier que le serveur est accessible sur http://localhost:8000
2. Consulter les logs du serveur
3. Exécuter `python fix_bugs.py`
4. Relancer les tests

### Erreur de base de données
```bash
# Appliquer les migrations
alembic upgrade head

# Ou utiliser le script de correction
python fix_bugs.py
```

## 📞 Pour Plus d'Informations

Consultez `TESTING_README.md` pour la documentation complète.
