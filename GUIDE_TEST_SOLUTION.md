# 🚀 Guide de Test - Solution Précision Personnalisée

## ⚠️ Prérequis

Le serveur backend doit être **démarré** avant de tester la solution.

---

## 📝 Étape 1 : Démarrer le Serveur Backend

### Option A : Avec uvicorn (recommandé)

```bash
cd d:\dev\apprendiamo-italiano-backend
uvicorn app.main:app --reload
```

### Option B : Avec Python

```bash
cd d:\dev\apprendiamo-italiano-backend
python -m uvicorn app.main:app --reload
```

**Vérifier que le serveur démarre correctement :**
- Vous devriez voir : `Uvicorn running on http://127.0.0.1:8000`
- Pas d'erreurs au démarrage

---

## 📝 Étape 2 : Tester le Nouvel Endpoint

### Test Automatique (Recommandé)

Dans un **nouveau terminal** (laisser le serveur tourner) :

```bash
cd d:\dev\apprendiamo-italiano-backend
python test_all_decks_endpoint.py
```

**Résultat attendu :**
```
✅ TEST RÉUSSI!
   - Tous les decks du système sont affichés
   - Toutes les statistiques sont à 0% pour le nouveau utilisateur
   - Le nouvel endpoint fonctionne correctement
```

### Test Manuel avec curl

```bash
# 1. Créer un compte
curl -X POST http://127.0.0.1:8000/api/users/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"full_name\":\"Test User\",\"password\":\"Test123!\"}"

# 2. Copier le token de la réponse

# 3. Tester le nouvel endpoint
curl -X GET http://127.0.0.1:8000/api/users/decks/all \
  -H "Authorization: Bearer <VOTRE_TOKEN>"
```

**Vérifier dans la réponse :**
- ✅ Tous les decks du système sont présents
- ✅ `success_rate: 0.0` pour tous les decks
- ✅ `total_attempts: 0` pour tous les decks

---

## 📝 Étape 3 : Intégration Frontend

### Modifier le Code Frontend

**Fichier à modifier :** Le composant qui affiche "Mes Decks" ou "Mes Flashcards"

**Ancien code :**
```typescript
const response = await fetch('/api/users/decks', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

**Nouveau code :**
```typescript
const response = await fetch('/api/users/decks/all', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

### Vérifier l'Affichage

1. **Créer un nouveau compte utilisateur** dans le frontend
2. **Accéder à "Mes Decks"**
3. **Vérifier que :**
   - ✅ Tous les decks du système s'affichent
   - ✅ Tous les pourcentages sont à **0%**
   - ✅ Tous les compteurs sont à **0**

4. **Faire un quiz** sur un deck
5. **Retourner à "Mes Decks"**
6. **Vérifier que :**
   - ✅ Le deck testé affiche maintenant un pourcentage > 0%
   - ✅ Les autres decks restent à 0%

---

## 🐛 Dépannage

### Erreur : "Connection refused"

**Problème :** Le serveur backend n'est pas démarré

**Solution :**
```bash
cd d:\dev\apprendiamo-italiano-backend
uvicorn app.main:app --reload
```

### Erreur : "404 Not Found"

**Problème :** L'endpoint n'existe pas

**Vérifier :**
1. Le serveur a bien redémarré après les modifications
2. L'URL est correcte : `/api/users/decks/all`

### Les stats ne sont pas à 0%

**Problème :** Le compte utilisateur a déjà fait des quiz

**Solution :**
1. Créer un **nouveau compte** utilisateur
2. Tester avec ce nouveau compte

### Erreur 401 Unauthorized

**Problème :** Token invalide ou expiré

**Solution :**
1. Se reconnecter pour obtenir un nouveau token
2. Vérifier que le header Authorization est correct

---

## 📊 Comparaison des Endpoints

### `/api/users/decks` (Ancien)
- Retourne **uniquement** les decks commencés
- Pour un nouveau utilisateur : **liste vide** `[]`
- Utile pour : "Mes Decks en Cours"

### `/api/users/decks/all` (Nouveau)
- Retourne **tous les decks du système**
- Pour un nouveau utilisateur : **tous à 0%**
- Utile pour : "Tous les Decks Disponibles"

---

## ✅ Checklist Finale

### Backend
- [ ] Serveur démarré sans erreur
- [ ] Test automatique réussi
- [ ] Endpoint `/api/users/decks/all` accessible

### Frontend
- [ ] Code modifié pour utiliser `/api/users/decks/all`
- [ ] Test avec nouveau compte : tous les decks à 0%
- [ ] Test après quiz : pourcentage mis à jour

---

## 📞 Si Problème Persiste

1. **Vérifier les logs du serveur** pour les erreurs
2. **Consulter** `SOLUTION_DECKS_PRECISION_PERSONNALISEE.md`
3. **Tester** avec le script `test_all_decks_endpoint.py`
4. **Vérifier** dans DevTools Network la réponse de l'API

---

**Créé le :** 29 novembre 2025  
**Version :** 1.0.0
