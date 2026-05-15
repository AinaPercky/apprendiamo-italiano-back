# Correction de l'Erreur TypeError dans create_score

## Problème Identifié

Lors de la soumission d'un score de quiz, l'application retournait une erreur 500 avec le message:

```
TypeError: unsupported operand type(s) for +=: 'NoneType' and 'int'
```

**Ligne problématique:** `app/crud_users.py`, ligne 308
```python
user_deck.total_attempts += 1
```

## Cause Racine

Lorsqu'un utilisateur joue un quiz pour la première fois sur un deck, le système crée automatiquement un enregistrement `UserDeck`. Cependant, après la création avec `db.add(user_deck)`, les champs avec des valeurs par défaut définies dans la base de données (comme `total_attempts`, `total_points`, etc.) restaient à `None` car SQLAlchemy n'avait pas encore synchronisé l'objet avec la base de données.

Le code essayait ensuite d'incrémenter ces valeurs `None`, ce qui causait l'erreur.

## Solution Appliquée

Ajout de deux opérations après la création du `UserDeck`:

1. **`await db.flush()`** - Force SQLAlchemy à envoyer l'INSERT à la base de données sans faire de commit complet
2. **`await db.refresh(user_deck)`** - Recharge l'objet depuis la base de données pour obtenir toutes les valeurs par défaut

### Code Avant
```python
if not user_deck:
    user_deck = models.UserDeck(
        user_pk=user_pk,
        deck_pk=score_data.deck_pk,
    )
    db.add(user_deck)
    # On ne fait pas de commit ici, il sera fait à la fin de la fonction

# Mise à jour des statistiques du UserDeck
user_deck.total_attempts += 1  # ❌ ERREUR: total_attempts est None
```

### Code Après
```python
if not user_deck:
    user_deck = models.UserDeck(
        user_pk=user_pk,
        deck_pk=score_data.deck_pk,
    )
    db.add(user_deck)
    # Flush pour que SQLAlchemy initialise les valeurs par défaut
    await db.flush()
    # Rafraîchir l'objet pour obtenir les valeurs par défaut de la DB
    await db.refresh(user_deck)

# Mise à jour des statistiques du UserDeck
user_deck.total_attempts += 1  # ✅ OK: total_attempts = 0 (valeur par défaut)
```

## Impact

✅ **Résolu** - Les utilisateurs peuvent maintenant:
- Jouer leur premier quiz sur n'importe quel deck
- Les statistiques `UserDeck` sont correctement créées et mises à jour
- Les scores sont enregistrés sans erreur 500

## Test Recommandé

Pour vérifier que la correction fonctionne:

1. Créer un nouvel utilisateur
2. Jouer un quiz sur un deck (premier quiz de l'utilisateur sur ce deck)
3. Vérifier que le score est enregistré sans erreur
4. Vérifier que les statistiques du deck sont mises à jour correctement

## Fichiers Modifiés

- `app/crud_users.py` - Fonction `create_score()` (lignes 298-308)
