# Documentation des Nouvelles Fonctionnalités Flashcards (Frontend React + TS)

Cette documentation décrit les modifications apportées au backend pour supporter les nouvelles fonctionnalités des cartes (traductions, explications, exemples) et comment les intégrer dans le frontend React TypeScript.

## 1. Mises à jour du Modèle de Données

L'objet `Card` a été enrichi avec 5 nouveaux champs optionnels.

### Interface TypeScript mise à jour

Veuillez mettre à jour votre fichier de types (ex: `types.ts` ou `api.ts`) :

```typescript
export interface Card {
  card_pk: number;
  deck_pk: number;
  id_json: string;
  front: string;
  back: string;
  pronunciation?: string | null;
  image?: string | null; // URL ou Base64
  
  // === NOUVEAUX CHAMPS ===
  explanation_it?: string | null; // Explication en italien
  translation_en?: string | null; // Traduction en anglais
  translation_de?: string | null; // Traduction en allemand
  translation_mg?: string | null; // Traduction en malgache
  example?: string | null;        // Exemple d'utilisation
  // ======================

  box: number;
  tags: string[];
  
  // Champs Anki
  easiness: number;
  interval: number;
  consecutive_correct: number;
  next_review: string; // ISO Date string
  created_at: string;  // ISO Date string
}

export interface CardCreate {
  deck_pk: number;
  front: string;
  back: string;
  pronunciation?: string;
  image?: string;
  
  // Nouveaux champs pour la création
  explanation_it?: string;
  translation_en?: string;
  translation_de?: string;
  translation_mg?: string;
  example?: string;
  
  tags?: string[];
  // id_json, created_at, next_review sont souvent gérés automatiquement ou par le backend
}
```

## 2. Intégration dans les Composants

### Affichage des Détails de la Carte

Exemple de composant pour afficher les détails supplémentaires d'une carte (par exemple, au dos de la carte ou dans une modale de détails) :

```tsx
import React from 'react';
import { Card } from './types';

interface CardDetailsProps {
  card: Card;
}

export const CardDetails: React.FC<CardDetailsProps> = ({ card }) => {
  return (
    <div className="card-details p-4 bg-white shadow rounded">
      <h3 className="text-xl font-bold mb-2">{card.front}</h3>
      <p className="text-gray-600 mb-4">{card.back}</p>
      
      {/* Affichage conditionnel des nouveaux champs */}
      <div className="space-y-2 text-sm">
        {card.explanation_it && (
          <div className="bg-blue-50 p-2 rounded">
            <span className="font-semibold text-blue-800">Spiegazione (IT):</span>
            <p className="text-blue-900">{card.explanation_it}</p>
          </div>
        )}

        {card.example && (
          <div className="bg-green-50 p-2 rounded">
            <span className="font-semibold text-green-800">Esempio:</span>
            <p className="text-green-900 italic">"{card.example}"</p>
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-2 mt-4">
          {card.translation_en && (
            <div className="border p-2 rounded">
              <span className="block text-xs text-gray-500 uppercase">English</span>
              <span>{card.translation_en}</span>
            </div>
          )}
          {card.translation_de && (
            <div className="border p-2 rounded">
              <span className="block text-xs text-gray-500 uppercase">Deutsch</span>
              <span>{card.translation_de}</span>
            </div>
          )}
          {card.translation_mg && (
            <div className="border p-2 rounded">
              <span className="block text-xs text-gray-500 uppercase">Malagasy</span>
              <span>{card.translation_mg}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
```

### Formulaire d'Ajout/Édition

Lors de la création ou de l'édition d'une carte, ajoutez simplement des champs de saisie pour ces nouvelles propriétés.

```tsx
// Extrait d'un formulaire Formik ou React Hook Form
<div className="form-group">
  <label>Explication (Italien)</label>
  <textarea 
    name="explanation_it" 
    value={values.explanation_it} 
    onChange={handleChange} 
    className="w-full border p-2 rounded"
    placeholder="Spiegazione del termine..."
  />
</div>

<div className="form-group">
  <label>Exemple</label>
  <textarea 
    name="example" 
    value={values.example} 
    onChange={handleChange} 
    className="w-full border p-2 rounded"
    placeholder="Frase di esempio..."
  />
</div>

<div className="grid grid-cols-3 gap-4">
  <div>
    <label>Trad. EN</label>
    <input name="translation_en" value={values.translation_en} onChange={handleChange} />
  </div>
  <div>
    <label>Trad. DE</label>
    <input name="translation_de" value={values.translation_de} onChange={handleChange} />
  </div>
  <div>
    <label>Trad. MG</label>
    <input name="translation_mg" value={values.translation_mg} onChange={handleChange} />
  </div>
</div>
```

## 3. Appels API

Aucun changement n'est nécessaire dans la structure des appels API si vous envoyez l'objet JSON complet. Le backend acceptera automatiquement les nouveaux champs s'ils sont présents dans le corps de la requête `POST` ou `PUT`.

Exemple :

```typescript
const updateCard = async (cardPk: number, data: Partial<CardCreate>) => {
  const response = await fetch(\`/cards/\${cardPk}\`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  });
  return response.json();
};
```
