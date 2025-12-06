# 🗑️ Documentation API : Suppression de Deck

## 🎯 Vue d'Ensemble

Cette documentation détaille l'utilisation de l'endpoint API permettant de **supprimer définitivement un deck** et toutes ses données associées.

---

## 🔌 Endpoint

```http
DELETE /decks/{deck_pk}
```

- **Méthode** : `DELETE`
- **URL** : `/decks/{deck_pk}`
- **Authentification** : Requise (Bearer Token) - *Note: Actuellement ouvert, sécurisation recommandée*

---

## 📝 Description

Cet endpoint permet de supprimer un deck spécifique de la base de données. 

⚠️ **ATTENTION : Cette action est irréversible.**

La suppression est effectuée en **CASCADE**, ce qui signifie que toutes les données liées à ce deck sont également supprimées automatiquement :
- 🃏 Toutes les **cartes** (Flashcards) contenues dans ce deck.
- 👤 Toutes les associations **utilisateurs-decks** (`user_decks`).
- 📊 Tous les **scores** (`user_scores`) liés à ce deck.
- 🎙️ Tous les enregistrements **audio** (`user_audio`) liés aux cartes de ce deck.

---

## 📥 Paramètres

| Paramètre | Type | Emplacement | Description | Requis |
|-----------|------|-------------|-------------|--------|
| `deck_pk` | `int` | Path | L'identifiant unique (Primary Key) du deck à supprimer. | ✅ Oui |

---

## 📤 Réponses

### ✅ Succès (200 OK)

Le deck a été supprimé avec succès.

```json
{
  "detail": "Deck deleted"
}
```

### ❌ Erreur (404 Not Found)

Le deck spécifié n'existe pas.

```json
{
  "detail": "Deck not found"
}
```

### ❌ Erreur (422 Validation Error)

L'identifiant fourni n'est pas un entier valide.

```json
{
  "detail": [
    {
      "loc": ["path", "deck_pk"],
      "msg": "value is not a valid integer",
      "type": "type_error.integer"
    }
  ]
}
```

---

## 💻 Exemples d'Utilisation

### JavaScript (Fetch API)

```javascript
const deleteDeck = async (deckId) => {
  try {
    const response = await fetch(`http://localhost:8000/decks/${deckId}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Bearer ${token}` // Si authentification active
      }
    });

    if (response.ok) {
      console.log('✅ Deck supprimé avec succès');
    } else if (response.status === 404) {
      console.error('❌ Deck introuvable');
    } else {
      console.error('❌ Erreur lors de la suppression');
    }
  } catch (error) {
    console.error('❌ Erreur réseau:', error);
  }
};
```

### Python (Requests)

```python
import requests

def delete_deck(deck_id, token):
    url = f"http://localhost:8000/decks/{deck_id}"
    headers = {"Authorization": f"Bearer {token}"}
    
    response = requests.delete(url, headers=headers)
    
    if response.status_code == 200:
        print("✅ Deck supprimé")
    elif response.status_code == 404:
        print("❌ Deck introuvable")
    else:
        print(f"❌ Erreur: {response.status_code}")
```

### cURL

```bash
curl -X DELETE "http://localhost:8000/decks/123" \
     -H "Authorization: Bearer VOTRE_TOKEN"
```

---

## 🛡️ Sécurité et Permissions

Actuellement, l'endpoint vérifie l'existence du deck mais ne restreint pas la suppression au créateur du deck (car le concept de "créateur" est en cours d'implémentation).

**Recommandation future :**
- Restreindre la suppression aux administrateurs OU au créateur du deck.
- Vérifier les permissions avant d'exécuter `crud_decks.delete_deck`.

---

## 🔄 Flux de Données (Backend)

1. **Réception** : La requête arrive sur `app/api/endpoints_cards.py`.
2. **Traitement** : La fonction `delete_deck` appelle `crud_decks.delete_deck(db, deck_pk)`.
3. **Base de Données** :
   - SQLAlchemy exécute une requête `SELECT` pour vérifier l'existence.
   - Si trouvé, `DELETE` est exécuté.
   - La base de données (PostgreSQL) gère la suppression en cascade via les contraintes `ON DELETE CASCADE`.
4. **Réponse** : Retourne un message de succès ou une erreur 404.
