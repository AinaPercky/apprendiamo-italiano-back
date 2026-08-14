# Prononciation audio des flashcards — stockage temporaire PostgreSQL

Le backend prend en charge une prononciation MP3 par flashcard. Le fichier est temporairement converti en Data URI/base64 et stocké dans Neon PostgreSQL, dans la table `card_audio`. Le base64 n’est pas inclus dans les réponses JSON de liste ; il est décodé uniquement par l’endpoint de lecture audio.

## Endpoints

| Méthode | URL | Fonction |
|---|---|---|
| `POST` | `/cards/{card_pk}/audio` | Ajoute ou remplace le MP3 |
| `GET` | `/cards/{card_pk}/audio` | Renvoie le flux `audio/mpeg` |
| `DELETE` | `/cards/{card_pk}/audio` | Supprime la prononciation |
| `GET` | `/cards/{card_pk}` | Renvoie les métadonnées audio, sans le base64 |

Le champ multipart attendu pour l’upload est `audio_file`. Le backend accepte `audio/mpeg`, `audio/mp3` et `application/octet-stream` si le contenu possède une signature MP3 reconnue. La taille maximale par fichier est de **10 Mo** par défaut et peut être ajustée avec la variable `MAX_CARD_AUDIO_BYTES`.

## Exemple d’upload

```bash
curl -X POST \
  -F "audio_file=@prononciation.mp3;type=audio/mpeg" \
  https://apprendiamo-italiano-backend.vercel.app/cards/58/audio
```

Réponse :

```json
{
  "audio_pk": 12,
  "card_pk": 58,
  "filename": "prononciation.mp3",
  "content_type": "audio/mpeg",
  "size_bytes": 48231,
  "audio_url": "/cards/58/audio",
  "created_at": "2026-08-14T18:30:00Z",
  "updated_at": "2026-08-14T18:30:00Z"
}
```

Un nouvel upload sur la même carte remplace le fichier existant grâce à la contrainte unique sur `card_pk`. Il n’est donc pas nécessaire de supprimer l’ancien fichier avant d’en envoyer un nouveau.

## Utilisation frontend

Le frontend peut afficher un lecteur directement avec l’URL relative renvoyée par l’API :

```jsx
<audio controls preload="none" src={`${API_BASE_URL}/cards/${card.card_pk}/audio`} />
```

Il est également possible d’afficher le bouton uniquement lorsque `card.audio` n’est pas nul. Le champ `card.audio` contient les métadonnées suivantes : `audio_pk`, `card_pk`, `filename`, `content_type`, `size_bytes`, `audio_url`, `created_at` et `updated_at`.

## Limites temporaires et migration future

Le stockage base64 augmente la taille du fichier d’environ un tiers et sollicite directement la base PostgreSQL. Il convient donc de conserver des fichiers courts, idéalement une prononciation de quelques secondes. Aucun fichier audio de production n’a été ajouté pendant les tests ; la carte témoin utilisée pour la validation a été nettoyée après chaque test.

La table sépare déjà les métadonnées de la donnée binaire. Pour une migration future, il suffira de téléverser le contenu vers un stockage objet, de remplacer `audio_data` par une référence URL ou un chemin, et de conserver les mêmes endpoints publics. La relation `card_pk` et l’interface de l’API resteront inchangées.
