# 🔍 GUIDE DE DÉBUGAGE - Système de Recherche et Téléchargement d'Images

## 📋 Vue d'ensemble

Ce document explique comment debugger la recherche automatique et le téléchargement d'images pour les cards.

### Architecture

```
Frontend (POST /cards/batch_import)
    ↓
API Endpoint (endpoints_cards.py)
    ↓
crud_cards.batch_upsert_cards()
    ├─→ Pour chaque carte:
    │   ├─→ Vérifier si existe
    │   ├─→ Si no image: fetch_icon_url() [DuckDuckGo/Google]
    │   ├─→ Si URL: url_to_base64() [Conversion Base64]
    │   └─→ Créer/Update + M2M
    └─→ db.commit()
```

---

## 🐛 Problèmes Courants et Solutions

### Problème 1: Les images ne sont pas trouvées

**Symptôme:** `❌ No icon found` dans les logs

**Causes possibles:**

1. **DuckDuckGo rate-limitée** → Vérifier que le service est accessible
2. **Google scraper échoue** → Le parsing HTML peut être fragile
3. **Requête trop générique** → Ex: "le", "un", "de"
4. **Réseau bloqué** → Vérifier firewall/proxy

**Solutions:**

```python
# 1. Vérifier les logs détaillés
import logging
logging.basicConfig(level=logging.DEBUG)

# 2. Tester directement
from app.core.image_scraper import fetch_icon_url, clear_image_cache
clear_image_cache()
url = fetch_icon_url("apple")
print(url)  # Devrait print une URL ou None

# 3. Augmenter les timeouts si réseau lent
# Dans image_scraper.py, modifier TIMEOUT values

# 4. Améliorer la requête de recherche
# Ajouter des termes spécifiques: "apple icon png"
```

---

### Problème 2: Images mal converties en Base64

**Symptôme:** `Base64 trop grand` ou images cassées

**Causes possibles:**

1. **Image trop grande** → Dépasse MAX_IMAGE_SIZE_MB
2. **Content-Type invalide** → Non-image téléchargé
3. **Erreur réseau** → Téléchargement incomplet
4. **Timeout insuffisant** → 15s peut être trop court

**Solutions:**

```python
# 1. Vérifier les logs
# Dans crud_cards.py, line 58:
logger.info(f"✓ Image convertie en Base64: {len(base64_string)} caractères ({base64_size_mb:.2f}MB)")

# 2. Augmenter les limites si nécessaire (dans crud_cards.py)
MAX_IMAGE_SIZE_MB = 10  # Augmenter si besoin
MAX_BASE64_SIZE_MB = 4  # Augmenter si besoin

# 3. Augmenter le timeout
TIMEOUT_IMAGE_DOWNLOAD = 30  # Augmenter si réseau lent

# 4. Tester directement
from app.crud_cards import url_to_base64
data_uri = url_to_base64("https://example.com/image.png")
print(len(data_uri))  # Voir la taille
```

---

### Problème 3: Cartes non créées ou mises à jour

**Symptôme:** `created: 0`, `updated: 0` dans le résultat

**Causes possibles:**

1. **Carte existe déjà** → Mais pas trouvée par la requête
2. **Erreur de matching** → La recherche `back.ilike()` échoue
3. **Erreur de commit** → Transaction échouée silencieusement
4. **Problème M2M** → Lien deck-card non créé

**Solutions:**

```python
# 1. Vérifier les logs détaillés
# batch_upsert_cards() logs chaque opération

# 2. Vérifier si carte existe vraiment
from app.crud_cards import get_cards
cards = await get_cards(db, search="mon_mot")
print(cards)

# 3. Vérifier la requête de matching
from sqlalchemy import select
stmt = select(Card).where(Card.back.ilike("mon_mot"))
result = await db.execute(stmt)
existing = result.scalars().first()
print(existing)

# 4. Vérifier les liens M2M
from app import models
stmt = select(models.deck_cards).where(
    models.deck_cards.c.card_pk == 42
)
result = await db.execute(stmt)
links = result.all()
print(links)
```

---

### Problème 4: Performance lente (scraping bloque)

**Symptôme:** Chaque carte prend 5-10s même avec cache

**Causes possibles:**

1. **Scraping synchrone** → Bloque le thread async
2. **Pas de cache** → Mêmes requêtes n'utilisent pas le cache
3. **Timeouts trop longs** → Attendre 15s pour chaque erreur
4. **Retries** → Réessayer augmente le temps

**Solutions:**

```python
# 1. Vérifier que le cache fonctionne
from app.core.image_scraper import _image_cache
print(_image_cache)  # Voir les entrées en cache

# 2. Utiliser le batch import au lieu de POST unique
# Meilleur que créer une carte à la fois

# 3. Optimiser les délais
# Dans image_scraper.py:
# time.sleep(random.uniform(0.3, 0.5))  # Réduit de 0.5-1.5

# 4. Ajouter un circuit breaker
# Si trop d'erreurs, skip le scraping

# 5. Augmenter la limite de retries?
# Non, réduire plutôt (max_retries=1 au lieu de 2)
```

---

## 🧪 Tests Diagnostiques

### Test 1: URLs valides

```bash
cd d:\dev\apprendiamo-italiano-backend
python test_image_handling.py

# Devrait passer le test "Validation URLs"
```

### Test 2: Scraping

```bash
python -c "
from app.core.image_scraper import fetch_icon_url, clear_image_cache
clear_image_cache()
url = fetch_icon_url('computer')
print('URL:', url)
print('Valide:', url.startswith('http'))
"
```

### Test 3: Conversion Base64

```bash
python -c "
from app.crud_cards import url_to_base64
url = 'https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4f7.svg'
result = url_to_base64(url)
print('Converti:', result is not None)
print('Taille:', len(result) if result else 0, 'chars')
"
```

### Test 4: Batch Upsert complet

```bash
# Voir ci-dessous
```

---

## 📊 Interprétation des Logs

### Logs Normaux

```
INFO     Début du batch upsert: 5 cartes
DEBUG    [1/5] ♻️ Mise à jour de la carte existante: pomme
DEBUG       Mise à jour front: Pomme
INFO     ✓ Carte mise à jour: pomme (id=42)
DEBUG    [2/5] 🖼️ Auto-recherche image pour 'apple' (orange)
INFO        ✅ Image trouvée: https://...
DEBUG       Conversion image URL → Base64
INFO     ✓ Image assignée à la carte existante
INFO     ✓ Nouvelle carte créée: banana (id=43)
INFO     ✅ Batch upsert complété: 1 créées, 4 mises à jour, 0 erreurs
INFO     📊 Images: 1 trouvées, 0 échouées
```

### Logs d'Erreur

```
ERROR    ❌ Erreur lors du traitement de apple: ValueError: ...
WARNING  Aucune image trouvée pour 'xyznonexistent'
ERROR    ❌ Erreur lors du commit: ...

# Actions:
# - Vérifier l'exception complète
# - Vérifier les errors_details dans le résultat
# - Vérifier la base de données
```

---

## 🔧 Configuration Recommandée

Pour production:

```python
# app/crud_cards.py
MAX_IMAGE_SIZE_MB = 3  # Images < 3MB
MAX_BASE64_SIZE_MB = 2  # Base64 < 2MB
TIMEOUT_IMAGE_DOWNLOAD = 20  # Timeout 20s

# app/core/image_scraper.py
# max_retries=1 au lieu de 2 (plus rapide)
# time.sleep(0.3-0.5) au lieu de 0.5-1.5
```

---

## 🛡️ Checklist de Debugging

- [ ] Vérifier les logs avec `logging.DEBUG`
- [ ] Tester `fetch_icon_url()` directement
- [ ] Tester `url_to_base64()` directement
- [ ] Vérifier le cache avec `_image_cache`
- [ ] Tester avec une seule carte d'abord
- [ ] Vérifier les limites de taille (MAX_IMAGE_SIZE_MB)
- [ ] Vérifier les timeouts réseau
- [ ] Vérifier la base de données directement
- [ ] Tester sans scraping (images pré-fournies)
- [ ] Tester le batch import via API REST

---

## 📝 Endpoints Importants

### POST /cards/batch_import

```json
{
  "cards": [
    {
      "front": "Pomme",
      "back": "Mela",
      "translation_en": "Apple",
      "deck_pk": 1,
      "created_at": "2024-01-01T00:00:00",
      "next_review": "2024-01-02T00:00:00",
      "image": null // Sera cherchée automatiquement si null
    }
  ]
}
```

Réponse:

```json
{
  "created": 1,
  "updated": 0,
  "errors": 0,
  "errors_details": [],
  "images_found": 1,
  "images_failed": 0
}
```

---

## 🚀 Optimisations Futures

1. **Async scraping** - Utiliser asyncio pour paralléliser
2. **Database cache** - Stocker les images trouvées en DB
3. **Worker queue** - Scraping en background (Celery/RQ)
4. **Image resize** - Compresser les images avant Base64
5. **Fallback URLs** - Utiliser des services comme Unsplash API
6. **ML classification** - Vérifier que l'image correspond au mot

---

**Version:** 1.0  
**Dernier update:** 2024-01-XX  
**Auteur:** Debug Squad
