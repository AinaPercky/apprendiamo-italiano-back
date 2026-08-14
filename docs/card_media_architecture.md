# Architecture de stockage des médias de flashcards

## Décision

Les octets de médias ne sont plus stockés dans PostgreSQL. Les images, puis les futurs fichiers MP3 de prononciation, sont placés dans le store public Vercel Blob `apprendiamo-card-media` (IAD1). Neon ne conserve que des métadonnées et une URL de livraison.

> Les objets publics Vercel Blob sont lus directement par URL via le CDN. Ils conviennent aux illustrations de flashcards et aux enregistrements de prononciation qui ne portent pas de donnée personnelle.

## Schéma relationnel

La table `card_media` devient la source de vérité des fichiers attachés aux cartes.

| Colonne | Rôle |
|---|---|
| `media_pk` | Identifiant technique du média. |
| `card_pk` | Référence à `cards.card_pk`, supprimée en cascade avec la carte. |
| `kind` | Catégorie contrôlée : `image` ou `audio`. |
| `storage_provider` | Fournisseur de stockage, initialement `vercel_blob`. |
| `url` | URL publique Vercel Blob, utilisée par le frontend. |
| `pathname` | Chemin Blob stable et unique, utile à la suppression et au diagnostic. |
| `content_type` | Type MIME, par exemple `image/webp` ou `audio/mpeg`. |
| `size_bytes` | Taille réelle du fichier hors base. |
| `sha256` | Empreinte de contenu pour dédupliquer les uploads. |
| `original_filename` | Nom indicatif, sans rôle de sécurité. |
| `is_primary` | Indique l’illustration ou l’audio principal pour une catégorie. |
| `created_at`, `updated_at` | Audit des références. |

Une contrainte garantit qu’une carte n’a qu’un média principal par type. Les doublons physiques sont évités via l’empreinte SHA-256 et peuvent être référencés par plusieurs cartes si nécessaire.

## Compatibilité API

Le champ historique `cards.image` est conservé temporairement comme **cache de compatibilité d’URL uniquement**. Après migration, il ne contient plus jamais de Data URI ni de Blob PostgreSQL : il reprend l’URL du média image principal. Le frontend existant continue donc d’utiliser `card.image` sans changement d’affichage.

Les réponses de cartes exposent aussi `media`, une liste de références structurées. Un futur client pourra choisir `kind=audio` sans changer le stockage ni le schéma principal.

## Écriture et suppression

Pour une nouvelle image, le backend télécharge ou décode l’entrée une seule fois, calcule l’empreinte SHA-256, charge un objet immuable dans Blob puis enregistre uniquement la référence dans `card_media`. Les noms suivent le préfixe :

```text
flashcards/{card_pk}/{kind}/{sha256}.{extension}
```

Une mise à jour crée un nouveau pathname au lieu d’écraser l’ancien, ce qui évite les incohérences de cache CDN. La suppression d’un média enlève ensuite l’objet Blob si aucune autre référence `card_media` n’emploie la même URL.

## Authentification Blob

En Vercel, le client Python envoie les mêmes en-têtes que le SDK officiel : `Authorization: Bearer <VERCEL_OIDC_TOKEN>`, `x-vercel-blob-store-id` et `x-api-version: 12`. Pour les scripts locaux de migration, `BLOB_READ_WRITE_TOKEN` est accepté comme repli. Aucun secret Blob n’est versionné dans Git.

## Migration

L’inventaire initial contient 2 470 cartes : 1 924 valeurs Base64 représentant 1 816 contenus uniques, 312 URL externes représentant 239 sources uniques et 234 cartes sans illustration. La migration déduplique par empreinte, charge les contenus dans Blob, crée ou met à jour `card_media`, remplace `cards.image` par l’URL Blob et vérifie qu’aucune Data URI ne subsiste. Les URL externes sont également importées dans Blob afin de supprimer la dépendance à des hôtes tiers.

## MP3 futurs

L’ajout d’un MP3 de prononciation consiste uniquement à créer une ligne `card_media` avec `kind='audio'`, `content_type='audio/mpeg'` et une URL Blob. Les fichiers plus grands que 4,5 Mo ne devront pas transiter par une Function Vercel : le frontend utilisera alors un upload direct signé. Les fichiers audio normaux peuvent emprunter la même route serveur que les images.

## Références

[1]: https://vercel.com/docs/vercel-blob "Documentation Vercel Blob"
[2]: https://vercel.com/docs/vercel-blob/server-upload "Téléversements serveur Vercel Blob"
