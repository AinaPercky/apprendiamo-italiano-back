# Guide d'Intégration Frontend : Importation en Lot (Batch Import)

Ce document décrit comment intégrer la nouvelle fonctionnalité d'importation en masse (Batch Import) côté Frontend. Cette fonctionnalité remplace l'ancienne méthode d'envoi carte par carte et gère automatiquement la mise à jour des cartes existantes ("Upsert").

## 1. Nouvel Endpoint API

| Méthode | URL | Description |
| :--- | :--- | :--- |
| **POST** | `/cards/batch_import` | Importe une liste de cartes. Met à jour les cartes existantes et crée les nouvelles. |

### Pourquoi utiliser cet endpoint ?
*   **Performance** : Une seule requête HTTP au lieu de centaines (N+1).
*   **Intelligence** : Détecte automatiquement les doublons basés sur le mot italien (`back`).
*   **Mise à jour (Upsert)** : Si une carte existe déjà, elle est mise à jour avec les nouvelles informations (ex: ajout d'une traduction allemande manquante) sans créer de doublon.
*   **Auto-Icon** : Si l'image est manquante, le système cherche automatiquement une icône (Flaticon/Google) basée sur la traduction anglaise (`translation_en`) ou le recto (`front`).
*   **Multi-Deck** : Si la carte existe dans un autre deck, elle est liée au deck actuel sans être dupliquée.

---

## 2. Structure des Données (Payload)

Le corps de la requête doit être un **tableau JSON** d'objets carte.

### Exemple de JSON
```json
[
  {
    "front": "Maison",
    "back": "Casa",
    "deck_pk": 12,
    "translation_en": "House",
    "translation_de": "Haus",
    "explanation_it": "Luogo dove si abita",
    "created_at": "2023-10-27T10:00:00Z",
    "next_review": "2023-10-28T10:00:00Z"
  },
  {
    "front": "Chat",
    "back": "Gatto",
    "deck_pk": 12,
    "created_at": "2023-10-27T10:00:00Z",
    "next_review": "2023-10-28T10:00:00Z"
  }
]
```

### Réponse API (Succès 200 OK)
```json
{
  "created": 1,
  "updated": 1,
  "errors": 0
}
```

---

## 3. Implémentation TypeScript (Exemple)

Voici comment adapter votre service d'API (`api.ts` ou similaire) et votre composant d'importation (`CardImport.tsx`).

### A. Mise à jour du Service API

Ajoutez cette fonction à votre fichier de gestion des appels API (ex: `src/services/api.ts`) :

```typescript
// src/services/api.ts
import axios from 'axios';

const API_URL = "http://localhost:8000"; // ou votre URL de prod

export interface CardCreate {
  front: string;
  back: string;
  deck_pk: number;
  pronunciation?: string;
  image?: string;
  explanation_it?: string;
  translation_en?: string;
  translation_de?: string;
  translation_mg?: string;
  example?: string;
  created_at: string; // ISO String
  next_review: string; // ISO String
  tags?: string[];
}

export interface BatchImportResponse {
  created: number;
  updated: number;
  errors: number;
}

export const batchImportCards = async (cards: CardCreate[]): Promise<BatchImportResponse> => {
  try {
    const response = await axios.post<BatchImportResponse>(
      `${API_URL}/cards/batch_import`, 
      cards
    );
    return response.data;
  } catch (error) {
    console.error("Erreur lors de l'import en lot:", error);
    throw error;
  }
};
```

### B. Mise à jour du Composant `CardImport.tsx`

Remplacez la boucle `for...of` qui envoyait les cartes une par une par un seul appel à `batchImportCards`.

```tsx
// src/components/CardImport.tsx (Extrait)
import React, { useState } from 'react';
import { batchImportCards, CardCreate } from '../services/api';

const CardImport = ({ deckId }: { deckId: number }) => {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<string | null>(null);

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setLoading(true);
    const reader = new FileReader();

    reader.onload = async (e) => {
      try {
        const jsonContent = e.target?.result as string;
        const rawData = JSON.parse(jsonContent);

        // Transformation des données pour correspondre au format attendu par le backend
        // Assurez-vous d'ajouter deck_pk et les dates si elles manquent dans le JSON
        const cardsToImport: CardCreate[] = rawData.map((item: any) => ({
          front: item.front,
          back: item.back,
          deck_pk: deckId, // ID du deck actuel
          pronunciation: item.pronunciation,
          image: item.image,
          explanation_it: item.explanation_it,
          translation_en: item.translation_en,
          translation_de: item.translation_de,
          translation_mg: item.translation_mg,
          example: item.example,
          // Dates obligatoires (mettre la date actuelle si absente)
          created_at: item.created_at || new Date().toISOString(),
          next_review: item.next_review || new Date().toISOString(),
          tags: item.tags || []
        }));

        // APPEL UNIQUE AU BACKEND
        const response = await batchImportCards(cardsToImport);

        setResult(
          `Import terminé avec succès ! \n` +
          `✅ Créées : ${response.created} \n` +
          `🔄 Mises à jour : ${response.updated} \n` +
          `❌ Erreurs : ${response.errors}`
        );

      } catch (error) {
        setResult("Erreur lors de l'importation. Vérifiez le format du fichier.");
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    reader.readAsText(file);
  };

  return (
    <div className="import-container">
      <h3>Importer des cartes (JSON)</h3>
      <input type="file" accept=".json" onChange={handleFileUpload} disabled={loading} />
      {loading && <p>Importation en cours...</p>}
      {result && <pre className="import-result">{result}</pre>}
    </div>
  );
};

export default CardImport;
```

---

## 4. Points d'Attention

1.  **Champs Obligatoires** : Le backend attend impérativement `created_at` et `next_review`. Si votre fichier JSON ne les contient pas, générez-les à la volée comme dans l'exemple ci-dessus (`new Date().toISOString()`).
2.  **Images** : Le champ `image` peut être une URL (http...) ou une chaîne Base64. Le backend gérera la conversion automatiquement.
3.  **Taille du fichier** : Pour des fichiers très volumineux (> 1000 cartes), l'appel peut prendre quelques secondes. L'interface doit afficher un état de chargement clair.
