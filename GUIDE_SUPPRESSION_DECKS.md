# 🔧 SOLUTION COMPLÈTE: Suppression de decks + Rafraîchissement Frontend

## 📋 Problèmes identifiés

1. **Frontend ne se rafraîchit pas** : Après suppression, le deck reste affiché
2. **Confusion sur la suppression** : Le deck "Verdure" reste dans la table `decks` après suppression
3. **Besoin de deux types de suppression** :
   - Retirer un deck système de "Mes decks" (supprimer `UserDeck`)
   - Supprimer complètement un deck créé par l'utilisateur (supprimer `Deck`)

## ✅ Solution Backend

### Étape 1 : Ajouter l'endpoint DELETE /api/decks/{deck_pk}

**Fichier** : `app/api/endpoints_cards.py`

Ajouter après l'endpoint `read_deck` (ligne 28) :

```python
@router.delete("/decks/{deck_pk}")
async def delete_deck(deck_pk: int, db: AsyncSession = Depends(get_db)):
    """
    Supprime complètement un deck du système.
    
    ⚠️ ATTENTION : Cette opération est irréversible et supprime :
    - Le deck
    - Toutes ses cartes
    - Toutes les associations utilisateur-deck
    - Tous les scores liés
    
    Utilisez DELETE /api/users/decks/{deck_pk} pour retirer un deck de votre collection sans le supprimer.
    """
    from .. import crud_decks
    
    deleted = await crud_decks.delete_deck(db, deck_pk)
    if not deleted:
        raise HTTPException(status_code=404, detail="Deck not found")
    return {"message": "Deck deleted permanently"}
```

### Étape 2 : Le fichier crud_decks.py existe déjà

✅ Le fichier `app/crud_decks.py` a déjà été créé avec la fonction `delete_deck`.

## ✅ Solution Frontend

### Problème : Le frontend ne se rafraîchit pas

Le frontend doit **recharger la liste des decks** après une suppression réussie.

### Fichiers à modifier

#### 1. `Flashcards.tsx` - Fonction `handleRemoveDeck`

**Ligne ~90** : Ajouter un rechargement après suppression

```typescript
const handleRemoveDeck = async (deckPk: number) => {
  try {
    // Supprimer le deck (retire de la collection utilisateur)
    await removeDeckFromUser(deckPk);
    
    // ✅ AJOUTER : Recharger la liste des decks
    await loadDecks();
    
    // Message de succès
    alert('Deck supprimé de votre collection');
  } catch (error) {
    console.error('Erreur lors de la suppression du deck:', error);
    alert('Erreur lors de la suppression du deck');
  }
};
```

#### 2. `userDecksApi.ts` - Ajouter fonction pour supprimer définitivement

**Ajouter une nouvelle fonction** :

```typescript
/**
 * Supprime complètement un deck du système (définitif)
 * À utiliser UNIQUEMENT pour les decks créés par l'utilisateur
 */
export const deleteDeckPermanently = async (deckPk: number): Promise<void> => {
  const token = localStorage.getItem('token');
  
  const response = await axios.delete(
    `${API_BASE_URL}/api/decks/${deckPk}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    }
  );
  
  return response.data;
};
```

#### 3. `DeckCard.tsx` - Gérer les deux types de suppression

**Modifier la fonction `handleRemove`** (ligne ~50) :

```typescript
const handleRemove = async () => {
  if (!window.confirm('Voulez-vous vraiment supprimer ce deck ?')) {
    return;
  }
  
  try {
    // Déterminer le type de suppression
    const isUserDeck = deck.user_deck_pk > 0; // Si > 0, c'est un deck avec activité
    const isSystemDeck = deck.deck.id_json?.startsWith('sys_'); // Deck système
    
    if (isSystemDeck || !isUserDeck) {
      // Deck système ou jamais commencé : retirer de la collection
      await removeDeckFromUser(deck.deck_pk);
      alert('Deck retiré de votre collection');
    } else {
      // Deck créé par l'utilisateur : supprimer définitivement
      if (window.confirm('Ce deck sera supprimé définitivement. Continuer ?')) {
        await deleteDeckPermanently(deck.deck_pk);
        alert('Deck supprimé définitivement');
      }
    }
    
    // Recharger la liste
    onRemove(deck.deck_pk);
    
  } catch (error) {
    console.error('Erreur lors de la suppression:', error);
    alert('Erreur lors de la suppression');
  }
};
```

## 📊 Tableau récapitulatif

| Type de deck | Action utilisateur | Endpoint utilisé | Résultat |
|--------------|-------------------|------------------|----------|
| Deck système (ex: "Verbes") | Clic sur "Supprimer" | `DELETE /api/users/decks/{deck_pk}` | Retiré de "Mes decks", reste dans le système |
| Deck jamais commencé | Clic sur "Supprimer" | `DELETE /api/users/decks/{deck_pk}` | Aucun effet en base (pas de UserDeck), disparaît de l'affichage |
| Deck créé par l'utilisateur | Clic sur "Supprimer" + Confirmation | `DELETE /api/decks/{deck_pk}` | Supprimé définitivement du système |

## 🧪 Tests

### Test 1 : Supprimer un deck système

1. Se connecter
2. Aller sur "Mes Decks"
3. Cliquer sur "Supprimer" pour un deck système
4. ✅ Le deck disparaît de l'interface
5. ✅ Le deck reste dans la table `decks`
6. ✅ L'entrée `user_decks` est supprimée (si elle existait)

### Test 2 : Supprimer un deck créé par l'utilisateur

1. Créer un nouveau deck "Test"
2. Cliquer sur "Supprimer"
3. Confirmer la suppression définitive
4. ✅ Le deck disparaît de l'interface
5. ✅ Le deck est supprimé de la table `decks`
6. ✅ Toutes les cartes sont supprimées

## 🔄 Ordre d'implémentation

1. ✅ **Backend** : Fichier `crud_decks.py` créé
2. **Backend** : Ajouter l'endpoint dans `endpoints_cards.py`
3. **Frontend** : Ajouter `deleteDeckPermanently` dans `userDecksApi.ts`
4. **Frontend** : Modifier `handleRemoveDeck` dans `Flashcards.tsx`
5. **Frontend** : Modifier `handleRemove` dans `DeckCard.tsx`
6. **Test** : Vérifier les deux scénarios

## ⚠️ Points d'attention

1. **Permissions** : Pour l'instant, n'importe qui peut supprimer n'importe quel deck. Il faudra ajouter une vérification du créateur plus tard.
2. **CASCADE** : Les foreign keys avec `ondelete="CASCADE"` suppriment automatiquement les données liées.
3. **Confirmation** : Toujours demander confirmation avant une suppression définitive.
4. **Rafraîchissement** : Appeler `loadDecks()` après chaque suppression pour mettre à jour l'interface.

## 📝 Prochaines améliorations

1. Ajouter un champ `creator_user_pk` au modèle `Deck`
2. Vérifier que seul le créateur peut supprimer un deck
3. Ajouter un système de "corbeille" pour restaurer les decks supprimés
4. Afficher une icône différente pour les decks créés par l'utilisateur
