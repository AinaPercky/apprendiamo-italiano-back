// ============================================================================
// EXEMPLE DE CODE FRONTEND CORRIGÉ
// ============================================================================

// 1. INTERFACE TYPESCRIPT (types.ts ou api/userDecksApi.ts)
// ============================================================================

export interface Deck {
    deck_pk: number;
    id_json: string;
    name: string;
    total_correct: number;
    total_attempts: number;
}

export interface UserDeck {
    user_deck_pk: number;
    user_pk: number;
    deck_pk: number;
    deck: Deck;

    // Stats Anki
    mastered_cards: number;
    learning_cards: number;
    review_cards: number;

    // Scoring global
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

    // ✅ CHAMPS CALCULÉS (AJOUTÉS)
    success_rate: number;  // Pourcentage de réussite
    progress: number;      // Pourcentage de progression
}


// 2. COMPOSANT REACT - AFFICHAGE DU DECK
// ============================================================================

import React from 'react';
import { UserDeck } from './types';

interface DeckCardProps {
    deck: UserDeck;
}

export const DeckCard: React.FC<DeckCardProps> = ({ deck }) => {
    return (
        <div className="deck-card">
            <h3>{deck.deck.name}</h3>

            <div className="deck-stats">
                {/* ✅ UTILISER success_rate du backend */}
                <div className="stat">
                    <span className="label">Précision:</span>
                    <span className="value">
                        {deck.success_rate !== undefined
                            ? `${deck.success_rate.toFixed(1)}%`
                            : '0%'
                        }
                    </span>
                </div>

                {/* ✅ UTILISER progress du backend */}
                <div className="stat">
                    <span className="label">Progression:</span>
                    <span className="value">
                        {deck.progress !== undefined
                            ? `${deck.progress.toFixed(1)}%`
                            : '0%'
                        }
                    </span>
                </div>

                <div className="stat">
                    <span className="label">Cartes:</span>
                    <span className="value">
                        {deck.mastered_cards + deck.learning_cards + deck.review_cards}
                    </span>
                </div>

                <div className="stat">
                    <span className="label">Points:</span>
                    <span className="value">{deck.total_points}</span>
                </div>
            </div>

            {/* Barre de progression visuelle */}
            <div className="progress-bar">
                <div
                    className="progress-fill"
                    style={{ width: `${deck.success_rate}%` }}
                />
            </div>
        </div>
    );
};


// 3. DASHBOARD - LISTE DES DECKS
// ============================================================================

import React, { useEffect, useState } from 'react';
import { UserDeck } from './types';
import { getUserDecks } from './api/userDecksApi';
import { DeckCard } from './components/DeckCard';

export const Dashboard: React.FC = () => {
    const [decks, setDecks] = useState<UserDeck[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchDecks = async () => {
            try {
                setLoading(true);
                const token = localStorage.getItem('access_token');

                if (!token) {
                    throw new Error('Non authentifié');
                }

                const userDecks = await getUserDecks(token);

                // ✅ LOG POUR DÉBUGGER
                console.log('Decks reçus:', userDecks);
                console.log('Success rate du premier deck:', userDecks[0]?.success_rate);

                setDecks(userDecks);
                setError(null);
            } catch (err) {
                console.error('Erreur lors du chargement des decks:', err);
                setError(err instanceof Error ? err.message : 'Erreur inconnue');
            } finally {
                setLoading(false);
            }
        };

        fetchDecks();
    }, []);

    if (loading) {
        return <div>Chargement...</div>;
    }

    if (error) {
        return <div>Erreur: {error}</div>;
    }

    return (
        <div className="dashboard">
            <h1>Mes Decks</h1>

            {decks.length === 0 ? (
                <p>Aucun deck dans votre collection</p>
            ) : (
                <div className="decks-grid">
                    {decks.map(deck => (
                        <DeckCard key={deck.user_deck_pk} deck={deck} />
                    ))}
                </div>
            )}
        </div>
    );
};


// 4. API CLIENT - APPEL BACKEND
// ============================================================================

const API_BASE_URL = 'http://127.0.0.1:8000';

export const getUserDecks = async (token: string): Promise<UserDeck[]> => {
    const response = await fetch(`${API_BASE_URL}/api/users/decks`, {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        }
    });

    if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const decks = await response.json();

    // ✅ VÉRIFICATION - À retirer en production
    console.log('=== VÉRIFICATION API ===');
    console.log('Nombre de decks:', decks.length);
    if (decks.length > 0) {
        console.log('Premier deck:', decks[0]);
        console.log('success_rate présent?', 'success_rate' in decks[0]);
        console.log('Valeur success_rate:', decks[0].success_rate);
    }

    return decks;
};


// 5. EXEMPLE AVEC AXIOS (Alternative)
// ============================================================================

import axios from 'axios';

const api = axios.create({
    baseURL: 'http://127.0.0.1:8000',
    headers: {
        'Content-Type': 'application/json'
    }
});

// Intercepteur pour ajouter le token
api.interceptors.request.use(config => {
    const token = localStorage.getItem('access_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

export const getUserDecksAxios = async (): Promise<UserDeck[]> => {
    const response = await api.get<UserDeck[]>('/api/users/decks');

    // ✅ LOG POUR DÉBUGGER
    console.log('Decks reçus (Axios):', response.data);

    return response.data;
};


// 6. HOOK PERSONNALISÉ (Optionnel mais recommandé)
// ============================================================================

import { useState, useEffect } from 'react';

export const useUserDecks = () => {
    const [decks, setDecks] = useState<UserDeck[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<Error | null>(null);

    const refetch = async () => {
        try {
            setLoading(true);
            const token = localStorage.getItem('access_token');

            if (!token) {
                throw new Error('Non authentifié');
            }

            const data = await getUserDecks(token);
            setDecks(data);
            setError(null);
        } catch (err) {
            setError(err instanceof Error ? err : new Error('Erreur inconnue'));
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        refetch();
    }, []);

    return { decks, loading, error, refetch };
};

// Utilisation dans un composant:
// const { decks, loading, error, refetch } = useUserDecks();


// ============================================================================
// NOTES IMPORTANTES
// ============================================================================

/*
1. VIDER LE CACHE:
   - Chrome: Ctrl+Shift+R ou DevTools > Network > Disable cache
   - Firefox: Ctrl+Shift+R
   - Edge: Ctrl+Shift+R

2. VÉRIFIER DANS DEVTOOLS:
   - F12 > Network
   - Chercher la requête GET /api/users/decks
   - Vérifier la Response contient success_rate

3. ERREURS TYPESCRIPT COMMUNES:
   - Si TypeScript se plaint que success_rate n'existe pas:
     → Vérifier que l'interface UserDeck est à jour
     → Redémarrer le serveur de développement (npm run dev)

4. PROBLÈMES DE CACHE:
   - Le navigateur peut cacher l'ancienne réponse API
   - Solution: Ajouter un timestamp à l'URL ou désactiver le cache

5. CORS:
   - Si vous avez des erreurs CORS, vérifier que le backend autorise
     votre domaine frontend dans les CORS settings
*/
