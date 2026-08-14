# ⚡ QUICK START - Corrections du Système d'Images

## 🎯 En 5 Minutes

### 1️⃣ Valider que ça fonctionne

```bash
cd d:\dev\apprendiamo-italiano-backend
python test_image_handling.py
```

**Résultat attendu:** ✅ TOUS LES TESTS SONT PASSÉS!

### 2️⃣ Tester le scraping d'images

```python
from app.core.image_scraper import fetch_icon_url, clear_image_cache

clear_image_cache()
url = fetch_icon_url("apple")
print(f"URL trouvée: {url}")
```

### 3️⃣ Tester la conversion Base64

```python
from app.crud_cards import url_to_base64

url = "https://example.com/image.png"
data_uri = url_to_base64(url)
print(f"Converti: {len(data_uri)/1024:.1f} KB")
```

### 4️⃣ Tester via API

```bash
curl -X POST http://localhost:8000/api/cards/batch_import \
  -H "Content-Type: application/json" \
  -d '[{"front":"Test","back":"Test","translation_en":"Test","deck_pk":1,"created_at":"2024-01-01T00:00:00","next_review":"2024-01-02T00:00:00","image":null}]'
```

**Réponse attendue:**

```json
{
  "created": 1,
  "updated": 0,
  "errors": 0,
  "images_found": 1,
  "images_failed": 0
}
```

---

## 🔍 Les 4 Cas d'Usage Principaux

### Cas 1: Créer une carte SANS image

```python
card_data = {
    "front": "Pomme",
    "back": "Mela",
    "translation_en": "Apple",
    "deck_pk": 1,
    "created_at": "2024-01-01T00:00:00",
    "next_review": "2024-01-02T00:00:00",
    "image": None  # ← Image sera cherchée automatiquement!
}

# Réponse:
# {
#   "images_found": 1,
#   "created": 1
# }
```

### Cas 2: Créer une carte AVEC image URL

```python
card_data = {
    "front": "Pomme",
    "back": "Mela",
    "translation_en": "Apple",
    "deck_pk": 1,
    "created_at": "2024-01-01T00:00:00",
    "next_review": "2024-01-02T00:00:00",
    "image": "https://example.com/apple.png"  # ← Sera convertie en Base64
}

# Réponse:
# {
#   "created": 1
# }
```

### Cas 3: Batch import (10+ cartes)

```python
cards = [
    {...card1...},
    {...card2...},
    {...card3...},
]

# POST /api/cards/batch_import

# Réponse:
# {
#   "created": 3,
#   "updated": 0,
#   "errors": 0,
#   "images_found": 2,
#   "images_failed": 1,
#   "errors_details": []
# }
```

### Cas 4: Mettre à jour une carte

```python
# Si la carte existe (par 'back'), elle sera mise à jour
card_data = {
    "front": "Pomme (Updated)",  # ← Changé
    "back": "Mela",              # ← Même (pour trouver la carte)
    "translation_en": "Apple",
    "deck_pk": 1,
    "created_at": "...",
    "next_review": "...",
    "image": None  # ← Image sera cherchée si vide
}

# Réponse:
# {
#   "updated": 1,
#   "images_found": 1
# }
```

---

## 📊 Voir les Détails des Erreurs

**Cas: Quelques cartes en erreur**

```json
{
  "created": 8,
  "updated": 2,
  "errors": 2,
  "errors_details": ["Dictionnaire: Image trop grande (6MB)", "Cheval: Erreur réseau (timeout)"],
  "images_found": 7,
  "images_failed": 3
}
```

**Action:** Vérifier la liste `errors_details` pour savoir quelles cartes échouent et pourquoi.

---

## 🔧 Configuration (Optionnel)

**Pour les images lentes (réseau lent):**

```python
# Dans app/crud_cards.py, augmenter les timeouts

MAX_IMAGE_SIZE_MB = 5           # Augmenter si besoin
TIMEOUT_IMAGE_DOWNLOAD = 30     # Augmenter pour réseau lent
```

**Pour les images compactes (économie de stockage):**

```python
MAX_IMAGE_SIZE_MB = 2           # Plus restrictif
MAX_BASE64_SIZE_MB = 1          # Compact
```

---

## 🐛 Debugging (Si ça ne fonctionne pas)

### Issue: Pas d'images trouvées

```python
# 1. Vérifier les logs
import logging
logging.basicConfig(level=logging.DEBUG)

# 2. Tester directement
from app.core.image_scraper import fetch_icon_url
url = fetch_icon_url("apple")
print(url)  # Devrait print une URL ou None
```

### Issue: Images cassées ou mal converties

```python
# 1. Vérifier la taille
from app.crud_cards import url_to_base64
result = url_to_base64("https://example.com/image.png")
print(len(result) / 1024 / 1024, "MB")  # Voir la taille

# 2. Si > 2MB, augmenter MAX_BASE64_SIZE_MB
```

### Issue: Erreurs de commit

```python
# Vérifier la base de données
from sqlalchemy import select
from app import models

stmt = select(models.Card).where(models.Card.back == "Mela")
result = await db.execute(stmt)
card = result.scalars().first()
print(card)  # Vérifier que la carte existe
```

---

## ✅ Checklist Rapide

- [ ] Tests passent: `python test_image_handling.py`
- [ ] Au moins une carte scrapée avec succès
- [ ] Au moins une image convertie en Base64
- [ ] `errors_details` vide ou compréhensible
- [ ] Logs structurés visibles en DEBUG

---

## 📚 Documentation Complète

Pour plus de détails, voir:

- `GUIDE_DEBUG_IMAGES.md` - Guide complet de debugging
- `RESUME_CORRECTIONS_IMAGES.md` - Résumé des changements
- `RAPPORT_CORRECTIONS_IMAGES.md` - Rapport détaillé
- `CHANGELOG_IMAGES_V2.md` - Changelog technique

---

## 🎓 Vidéo/Exemple (Text-based)

### Scénario: Importer 3 cartes (2 avec images, 1 sans)

**Requête:**

```python
POST /api/cards/batch_import

[
  {
    "front": "Pomme", "back": "Mela", "translation_en": "Apple",
    "deck_pk": 1, "created_at": "2024-01-01T00:00:00",
    "next_review": "2024-01-02T00:00:00",
    "image": null  # ← Sera cherchée
  },
  {
    "front": "Orange", "back": "Arancia", "translation_en": "Orange",
    "deck_pk": 1, "created_at": "2024-01-01T00:00:00",
    "next_review": "2024-01-02T00:00:00",
    "image": "https://example.com/orange.png"  # ← Convertie
  },
  {
    "front": "Banane", "back": "Banana", "translation_en": "Banana",
    "deck_pk": 1, "created_at": "2024-01-01T00:00:00",
    "next_review": "2024-01-02T00:00:00",
    "image": null  # ← Sera cherchée
  }
]
```

**Logs:**

```
INFO     🔄 Début batch: 3 cartes
DEBUG    [1/3] 🖼️ Auto-recherche image pour 'apple'
INFO        ✅ Image trouvée: https://...
DEBUG       Conversion image URL → Base64
INFO     ✓ Nouvelle carte créée: mela (id=1)

DEBUG    [2/3]
INFO     ✓ Nouvelle carte créée: arancia (id=2)

DEBUG    [3/3] 🖼️ Auto-recherche image pour 'banana'
INFO        ✅ Image trouvée: https://...
DEBUG       Conversion image URL → Base64
INFO     ✓ Nouvelle carte créée: banana (id=3)

INFO     ✅ Batch completed: 3 créées, 0 mises à jour, 0 erreurs
INFO     📊 Images: 2 trouvées, 0 échouées
```

**Réponse:**

```json
{
  "created": 3,
  "updated": 0,
  "errors": 0,
  "errors_details": [],
  "images_found": 2,
  "images_failed": 0
}
```

---

## 💡 Pro Tips

1. **Cache peut grandir** - Appeler `clear_image_cache()` dans les tests
2. **Requêtes identiques** - Le cache réutilise automatiquement
3. **Images manquantes** - Regarder `images_failed` pour diagnostiquer
4. **Logging détaillé** - Activer `logging.DEBUG` pour plus de détail
5. **Batch import** - Beaucoup plus rapide que POST unique

---

**Prêt? 🚀 Commencez par:** `python test_image_handling.py`
