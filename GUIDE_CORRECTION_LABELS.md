# Guide de Mise à Jour : Gestion des Labels de Cartes (Statuts)

Ce guide détaille les changements appliqués pour corriger la logique des statuts des cartes ("Maîtrisée", "En cours", "Non maîtrisée") afin de correspondre exactement à votre demande.

## 1. Changements Backend (Appliqués)

Le schéma de réponse de l'API (`CardPerformanceResponse`) correspondant à l'endpoint `/api/quiz/performances/{deck_pk}` a été mis à jour dans `app/schemas.py`.

Un nouveau champ dynamique `label` a été ajouté avec la logique suivante :

| Label Backend | Condition (Logique) | Signification |
| :--- | :--- | :--- |
| **"En cours"** | `total_attempts == 0` | La carte n'a jamais été jouée (état initial). |
| **"Non maîtrisée"** | `incorrect_count > 0` | L'utilisateur a fait au moins une erreur sur cette carte. |
| **"Maîtrisée"** | `correct_count > 0` (et `incorrect_count == 0`) | L'utilisateur a réussi la carte sans erreur. |

*Note : Cette logique est désormais centralisée côté serveur, garantissant une cohérence parfaite.*

## 2. Instructions Frontend

Vous devez mettre à jour votre hook `useCards.ts` et votre composant d'affichage pour utiliser ce nouveau standard.

### A. Mise à jour de l'interface TypeScript
Dans votre fichier de types (ex: `src/types.ts` ou `src/features/quiz/api/types.ts`), ajoutez le champ `label` à l'interface `CardPerformance` :

```typescript
export interface CardPerformance {
    card_pk: number;
    correct_count: number;
    incorrect_count: number;
    total_attempts: number;
    label?: "Maîtrisée" | "En cours" | "Non maîtrisée"; // Nouveau champ
    // ... autres champs
}
```

### B. Mise à jour de `useCards.ts`

Dans `src/features/flashcards/hooks/useCards.ts`, lors de la fusion des cartes et des performances, privilégiez le label retourné par l'API (ou répliquez la logique si vous ne rechargez pas le backend immédiatement).

```typescript
// Extrait de loadCards dans useCards.ts

const cardsWithStatus = cards.map(card => {
    const perf = performances.find(p => p.card_pk === card.card_pk);
    
    // Logique Prioritaire (celle du Backend)
    let statusLabel = 'En cours'; // Défaut (Création)
    
    if (perf) {
        if (perf.label) {
            // Utiliser le label calculé par le backend (RECOMMANDÉ)
            statusLabel = perf.label;
        } else {
            // Fallback (Logique Client)
            if (perf.total_attempts === 0) {
                statusLabel = 'En cours';
            } else if (perf.incorrect_count > 0) {
                statusLabel = 'Non maîtrisée';
            } else if (perf.correct_count > 0) {
                statusLabel = 'Maîtrisée';
            }
        }
    }

    return {
        ...card,
        status: statusLabel, // Utilisez ce champ pour l'affichage
        // Conservez box si nécessaire pour d'autres logiques
        box: perf ? perf.correct_count : 0 
    };
});
```

### C. Mise à jour de `CardListView` (Affichage)

Mettez à jour la logique des couleurs (Badges) pour correspondre aux labels :

```tsx
const getStatusColor = (status: string) => {
    switch (status) {
        case 'Maîtrisée':
            return 'bg-green-100 text-green-800 border-green-200'; // Vert
        case 'Non maîtrisée':
            return 'bg-red-100 text-red-800 border-red-200';     // Rouge
        case 'En cours':
        default:
            return 'bg-orange-100 text-orange-800 border-orange-200'; // Orange (Défaut)
    }
};

// Utilisation dans le composant
<span className={`px-2 py-1 rounded-full text-xs font-medium border ${getStatusColor(card.status)}`}>
    {card.status}
</span>
```

## Résumé
- **Backend OK** : Le `label` est calculé automatiquement.
- **Frontend** : Il suffit de lire ce `label` ou d'appliquer la logique simple (`attempts=0` -> En cours, `error>0` -> Non maîtrisée, `correct>0` -> Maîtrisée).
