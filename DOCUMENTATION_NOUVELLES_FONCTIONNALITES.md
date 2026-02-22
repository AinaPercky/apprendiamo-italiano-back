## 4. Personnalisation de l'Impression (Flashcards)

Voici le code React et CSS pour imprimer les cartes en mode **Portrait** (vertical), sans le drapeau italien, et avec un fond blanc pour le texte français, conformément à votre demande.

### CSS (print.css)

Ajoutez ou modifiez ces styles dans votre fichier CSS dédié à l'impression :

```css
@media print {
  @page {
    size: portrait; /* Force le mode portrait pour la page */
    margin: 1cm;
  }

  /* Conteneur de la grille de cartes */
  .flashcards-print-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr); /* 3 cartes par ligne par exemple */
    gap: 10px;
    width: 100%;
  }

  /* Style de la carte individuelle */
  .flashcard-print-item {
    border: 1px dashed #ccc; /* Bordure de coupe pointillée */
    border-radius: 8px;
    padding: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;

    /* Dimensions fixes pour mode PORTRAIT (Vertical) */
    width: 6cm;
    height: 9cm;

    page-break-inside: avoid; /* Évite de couper une carte sur deux pages */
    background: white;
  }

  /* Masquer le drapeau italien (bande tricolore) */
  .card-flag-header,
  .italian-flag-border {
    display: none !important;
  }

  /* Mot en Italien (Haut) */
  .italian-word {
    color: #008f39; /* Vert */
    font-weight: bold;
    font-size: 1.2rem;
    text-align: center;
    margin-top: 10px;
  }

  /* Mot en Français (Bas) */
  .french-word {
    color: #ff0000; /* Rouge/Orange selon capture */
    font-size: 1rem;
    text-align: center;
    margin-bottom: 10px;

    /* SUPPRESSION DU FOND GRIS */
    background-color: transparent !important;
    background: white !important;
    border: none;
  }

  /* Image ou Icône centrale */
  .card-image {
    max-width: 80%;
    max-height: 40%;
    object-fit: contain;
  }
}
```

### Composant React (PrintView.tsx)

```tsx
import React from "react";
import { Card } from "./types";
import "./print.css"; // Assurez-vous d'importer le CSS ci-dessus

interface PrintViewProps {
  cards: Card[];
}

export const PrintFlashcards: React.FC<PrintViewProps> = ({ cards }) => {
  return (
    <div className="flashcards-print-container">
      <div className="no-print actions-bar">
        <button onClick={() => window.print()}>Imprimer</button>
      </div>

      <div className="flashcards-print-grid">
        {cards.map((card) => (
          <div key={card.card_pk} className="flashcard-print-item">
            {/* Partie supérieure : Mot Italien (Vert) */}
            <div className="italian-word">{card.back}</div>

            {/* Image centrale (si disponible) */}
            {card.image && <img src={card.image} alt={card.back} className="card-image" />}

            {/* Partie inférieure : Mot Français (Rouge) - Fond Blanc */}
            <div className="french-word">{card.front}</div>
          </div>
        ))}
      </div>
    </div>
  );
};
```
