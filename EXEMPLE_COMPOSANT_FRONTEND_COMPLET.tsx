// ============================================================================
// EXEMPLE COMPLET - Composant "Mes Decks" avec la Solution
// ============================================================================

import React, { useEffect, useState } from 'react';

// ============================================================================
// TYPES
// ============================================================================

interface Deck {
    deck_pk: number;
    name: string;
    id_json: string;
    total_correct: number;
    total_attempts: number;
}

interface UserDeck {
    user_deck_pk: number;
    user_pk: number;
    deck_pk: number;
    deck: Deck;

    // Stats Anki
    mastered_cards: number;
    learning_cards: number;
    review_cards: number;

    // Scoring
    total_points: number;
    total_attempts: number;
    successful_attempts: number;

    // Scoring par mode
    points_frappe: number;
    points_association: number;
    points_qcm: number;
    points_classique: number;

    // Dates
    added_at: string;
    last_studied: string | null;

    // Champs calculés
    success_rate: number;  // Pourcentage de réussite
    progress: number;      // Pourcentage de progression
}

// ============================================================================
// COMPOSANT PRINCIPAL
// ============================================================================

export const MyDecksPage: React.FC = () => {
    const [decks, setDecks] = useState<UserDeck[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        fetchAllDecks();
    }, []);

    const fetchAllDecks = async () => {
        try {
            setLoading(true);
            const token = localStorage.getItem('access_token');

            if (!token) {
                throw new Error('Non authentifié');
            }

            // ✅ UTILISER LE NOUVEAU ENDPOINT
            const response = await fetch('http://localhost:8000/api/users/decks/all', {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                throw new Error(`Erreur HTTP: ${response.status}`);
            }

            const data = await response.json();

            // ✅ LOG POUR VÉRIFIER
            console.log('Decks récupérés:', data);
            console.log('Nombre de decks:', data.length);

            setDecks(data);
            setError(null);
        } catch (err) {
            console.error('Erreur lors du chargement des decks:', err);
            setError(err instanceof Error ? err.message : 'Erreur inconnue');
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return (
            <div className="loading-container">
                <div className="spinner"></div>
                <p>Chargement des decks...</p>
            </div>
        );
    }

    if (error) {
        return (
            <div className="error-container">
                <h2>Erreur</h2>
                <p>{error}</p>
                <button onClick={fetchAllDecks}>Réessayer</button>
            </div>
        );
    }

    return (
        <div className="my-decks-page">
            <header className="page-header">
                <h1>Mes Decks</h1>
                <p className="subtitle">
                    {decks.length} deck{decks.length > 1 ? 's' : ''} disponible{decks.length > 1 ? 's' : ''}
                </p>
            </header>

            <div className="decks-grid">
                {decks.map(deck => (
                    <DeckCard key={deck.deck_pk} deck={deck} />
                ))}
            </div>
        </div>
    );
};

// ============================================================================
// COMPOSANT CARTE DE DECK
// ============================================================================

interface DeckCardProps {
    deck: UserDeck;
}

const DeckCard: React.FC<DeckCardProps> = ({ deck }) => {
    const totalCards = deck.mastered_cards + deck.learning_cards + deck.review_cards;
    const isStarted = deck.total_attempts > 0;

    // Couleur de la précision
    const getPrecisionColor = (rate: number): string => {
        if (rate === 0) return '#999';
        if (rate >= 80) return '#22c55e';  // Vert
        if (rate >= 50) return '#f59e0b';  // Orange
        return '#ef4444';  // Rouge
    };

    return (
        <div className={`deck-card ${!isStarted ? 'not-started' : ''}`}>
            {/* En-tête */}
            <div className="deck-header">
                <div className="deck-icon">📚</div>
                <h3 className="deck-name">{deck.deck.name}</h3>
            </div>

            {/* Statistiques */}
            <div className="deck-stats">
                {/* Nombre de cartes */}
                <div className="stat">
                    <span className="stat-label">Cartes</span>
                    <span className="stat-value">{totalCards}</span>
                </div>

                {/* Précision */}
                <div className="stat">
                    <span className="stat-label">Précision</span>
                    <span
                        className="stat-value"
                        style={{ color: getPrecisionColor(deck.success_rate) }}
                    >
                        {deck.success_rate.toFixed(1)}%
                    </span>
                </div>

                {/* Points */}
                <div className="stat">
                    <span className="stat-label">Points</span>
                    <span className="stat-value">{deck.total_points}</span>
                </div>
            </div>

            {/* Barre de progression */}
            <div className="progress-bar-container">
                <div
                    className="progress-bar-fill"
                    style={{
                        width: `${deck.success_rate}%`,
                        backgroundColor: getPrecisionColor(deck.success_rate)
                    }}
                />
            </div>

            {/* Détails des cartes */}
            <div className="card-breakdown">
                <div className="card-stat mastered">
                    <span className="dot"></span>
                    <span>{deck.mastered_cards} maîtrisées</span>
                </div>
                <div className="card-stat learning">
                    <span className="dot"></span>
                    <span>{deck.learning_cards} en cours</span>
                </div>
                <div className="card-stat review">
                    <span className="dot"></span>
                    <span>{deck.review_cards} à revoir</span>
                </div>
            </div>

            {/* Actions */}
            <div className="deck-actions">
                <button
                    className="btn-primary"
                    onClick={() => window.location.href = `/quiz/${deck.deck_pk}`}
                >
                    {isStarted ? 'Continuer' : 'Commencer'}
                </button>

                {isStarted && (
                    <button
                        className="btn-secondary"
                        onClick={() => window.location.href = `/deck/${deck.deck_pk}/stats`}
                    >
                        Statistiques
                    </button>
                )}
            </div>

            {/* Badge "Nouveau" pour les decks non commencés */}
            {!isStarted && (
                <div className="badge-new">Nouveau</div>
            )}
        </div>
    );
};

// ============================================================================
// STYLES CSS
// ============================================================================

const styles = `
.my-decks-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.page-header {
  margin-bottom: 2rem;
}

.page-header h1 {
  font-size: 2rem;
  font-weight: bold;
  color: #1f2937;
  margin-bottom: 0.5rem;
}

.subtitle {
  color: #6b7280;
  font-size: 1rem;
}

.decks-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.deck-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.deck-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  transform: translateY(-2px);
}

.deck-card.not-started {
  border: 2px dashed #e5e7eb;
}

.deck-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.deck-icon {
  font-size: 2rem;
}

.deck-name {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.deck-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
  margin-bottom: 1rem;
}

.stat {
  text-align: center;
}

.stat-label {
  display: block;
  font-size: 0.75rem;
  color: #6b7280;
  text-transform: uppercase;
  margin-bottom: 0.25rem;
}

.stat-value {
  display: block;
  font-size: 1.5rem;
  font-weight: bold;
  color: #1f2937;
}

.progress-bar-container {
  width: 100%;
  height: 8px;
  background: #e5e7eb;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 1rem;
}

.progress-bar-fill {
  height: 100%;
  transition: width 0.3s ease;
}

.card-breakdown {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  padding: 1rem;
  background: #f9fafb;
  border-radius: 8px;
}

.card-stat {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #4b5563;
}

.card-stat .dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.card-stat.mastered .dot {
  background: #22c55e;
}

.card-stat.learning .dot {
  background: #f59e0b;
}

.card-stat.review .dot {
  background: #ef4444;
}

.deck-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-primary,
.btn-secondary {
  flex: 1;
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary {
  background: #3b82f6;
  color: white;
}

.btn-primary:hover {
  background: #2563eb;
}

.btn-secondary {
  background: #f3f4f6;
  color: #4b5563;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

.badge-new {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: #3b82f6;
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.loading-container,
.error-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 400px;
  text-align: center;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
`;

// ============================================================================
// EXPORT
// ============================================================================

export default MyDecksPage;
