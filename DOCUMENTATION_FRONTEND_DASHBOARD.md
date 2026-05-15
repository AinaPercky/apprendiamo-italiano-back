# Documentation Complète : Tableau de Bord Dynamique (Deck Dashboard)

Ce document fournit l'implémentation complète et la documentation du nouveau tableau de bord dynamique pour les decks. Il couvre à la fois l'intégration backend (déjà réalisée) et l'implémentation frontend requise.

## 1. Vue d'Ensemble

Le tableau de bord permet à l'utilisateur de visualiser sa progression sur un deck spécifique. Il affiche :
-   **Statistiques Clés** : Score total, nombre de réponses correctes, score moyen, et taux de réussite.
-   **Graphique d'Évolution** : Une courbe montrant la progression des scores au fil du temps.
-   **Historique** : Une liste paginée des derniers scores.

## 2. Intégration Backend

Les endpoints suivants ont été optimisés pour supporter ce tableau de bord :

### A. Récupérer les Statistiques du Deck
**Endpoint** : `GET /api/users/decks/{deck_pk}/stats`
**Description** : Retourne les statistiques accumulées pour le deck.
**Réponse** : Object `UserDeckResponse` (inclut `total_points`, `successful_attempts`, `success_rate`, etc.)
**Note** : Si le deck n'a jamais été joué, renvoie des valeurs à 0.

### B. Récupérer l'Historique des Scores
**Endpoint** : `GET /api/users/scores/deck/{deck_pk}?limit=50`
**Description** : Retourne la liste des scores individuels pour le deck, triés par date décroissante.
**Paramètres** : 
- `limit` : Nombre de scores à récupérer (défaut 100).
- `offset` : Pour la pagination.

## 3. Implémentation Frontend

### Dépendances Requises
Assurez-vous d'avoir les paquets suivants installés :
```bash
npm install recharts date-fns
```

### Code du Composant `DeckDashboard.tsx`

Créez ou mettez à jour le fichier `src/components/DeckDashboard.tsx` avec le code suivant. Ce composant est conçu avec Tailwind CSS pour un design moderne et "premium".

```tsx
import React, { useEffect, useState, useMemo } from 'react';
import { 
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer 
} from 'recharts';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
// Importez vos services d'API ici
// ex: import { getUserDeckStats, getUserDeckScores } from '../services/userApi';

interface DeckDashboardProps {
  deckId: number;
  deckName: string;
  onClose: () => void;
}

// Interfaces basées sur votre API
interface UserDeckStats {
  total_points: number;
  successful_attempts: number;
  total_attempts: number;
  success_rate: number;
  progress: number;
}

interface UserScore {
  score_pk: number;
  score: number;
  created_at: string; // ISO date string
  is_correct: boolean;
}

const DeckDashboard: React.FC<DeckDashboardProps> = ({ deckId, deckName, onClose }) => {
  const [stats, setStats] = useState<UserDeckStats | null>(null);
  const [scores, setScores] = useState<UserScore[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        // Remplacez ces appels par vos vrais services API
        const token = localStorage.getItem('token'); // Ou utilisez votre contexte d'auth
        const headers = { Authorization: `Bearer ${token}` };

        // 1. Fetch Stats
        const statsRes = await fetch(`/api/users/decks/${deckId}/stats`, { headers });
        if (!statsRes.ok) throw new Error("Erreur chargement stats");
        const statsData = await statsRes.json();
        setStats(statsData);

        // 2. Fetch History (Graph needs reverse order usually, but API gives desc)
        const scoresRes = await fetch(`/api/users/scores/deck/${deckId}?limit=20`, { headers });
        if (!scoresRes.ok) throw new Error("Erreur chargement historique");
        const scoresData = await scoresRes.json();
        setScores(scoresData);

      } catch (err) {
        console.error(err);
        setError("Impossible de charger les données du tableau de bord.");
      } finally {
        setLoading(false);
      }
    };

    if (deckId) {
      fetchData();
    }
  }, [deckId]);

  // Calcul du Score Moyen Dynamique
  const averageScore = useMemo(() => {
    if (scores.length === 0) return 0;
    const total = scores.reduce((acc, curr) => acc + curr.score, 0);
    return Math.round(total / scores.length);
  }, [scores]);

  // Préparation des données pour le Graphique (ordre chronologique)
  const chartData = useMemo(() => {
    return [...scores].reverse().map(s => ({
      date: format(new Date(s.created_at), 'dd/MM HH:mm', { locale: fr }),
      score: s.score
    }));
  }, [scores]);

  if (loading) return <div className="p-8 text-center text-gray-500 animate-pulse">Chargement du tableau de bord...</div>;
  if (error) return <div className="p-8 text-center text-red-500">{error}</div>;

  return (
    <div className="bg-white rounded-xl shadow-lg p-6 max-w-5xl mx-auto animate-fade-in-up">
      <div className="flex justify-between items-center mb-8 border-b pb-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-800 font-serif">{deckName}</h2>
          <p className="text-sm text-gray-500 mt-1">Détails des scores et progression</p>
        </div>
        <button 
          onClick={onClose}
          className="text-gray-400 hover:text-gray-600 transition-colors p-2"
        >
          ✕
        </button>
      </div>

      {/* Cartes de Statistiques */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <StatCard 
          label="Total des scores" 
          value={stats?.total_points.toLocaleString() || '0'} 
          color="text-emerald-500" 
          subtext="Points cumulés"
        />
        <StatCard 
          label="Correctes" 
          value={stats?.successful_attempts.toString() || '0'} 
          color="text-blue-500" 
          subtext={`Sur ${stats?.total_attempts || 0} essais`}
        />
        <StatCard 
          label="Score moyen" 
          value={averageScore.toString()} 
          color="text-indigo-500" 
          subtext="Moyenne des 20 derniers quiz"
        />
        <StatCard 
          label="Taux de réussite" 
          value={`${stats?.success_rate || 0}%`} 
          color="text-orange-500" 
          subtext="Précision globale"
        />
      </div>

      {/* Graphique d'Évolution */}
      <div className="bg-gray-50 rounded-xl p-6 mb-8 shadow-inner border border-gray-100">
        <h3 className="text-xl font-bold text-gray-700 mb-2 font-serif">Évolution des scores</h3>
        <p className="text-xs text-gray-400 mb-6">Progression sur les 20 derniers quiz</p>
        
        <div className="h-64 w-full">
          {scores.length > 0 ? (
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E5E7EB" />
                <XAxis 
                  dataKey="date" 
                  tick={{fontSize: 12, fill: '#9CA3AF'}} 
                  axisLine={false}
                  tickLine={false}
                  dy={10}
                />
                <YAxis 
                  domain={[0, 100]} 
                  tick={{fontSize: 12, fill: '#9CA3AF'}} 
                  axisLine={false}
                  tickLine={false}
                />
                <Tooltip 
                  contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                />
                <Line 
                  type="monotone" 
                  dataKey="score" 
                  stroke="#6366f1" 
                  strokeWidth={3}
                  dot={{ r: 4, fill: '#6366f1', strokeWidth: 2, stroke: '#fff' }}
                  activeDot={{ r: 6, strokeWidth: 0 }}
                />
              </LineChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-full flex items-center justify-center text-gray-400 text-sm">
              Aucune donnée d'historique disponible
            </div>
          )}
        </div>
      </div>

      {/* Historique Récent */}
      <div className="border rounded-xl overflow-hidden">
        <div className="bg-gray-50 p-4 border-b">
          <h3 className="font-bold text-gray-700 font-serif">Historique des scores</h3>
        </div>
        <div className="max-h-60 overflow-y-auto">
          {scores.length > 0 ? (
            <table className="w-full text-left text-sm">
              <thead className="bg-white text-gray-500 sticky top-0">
                <tr>
                  <th className="p-4 font-medium">Date</th>
                  <th className="p-4 font-medium">Score</th>
                  <th className="p-4 font-medium">Résultat</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {scores.map((score) => (
                  <tr key={score.score_pk} className="hover:bg-gray-50 transition-colors">
                    <td className="p-4 text-gray-600">
                      {format(new Date(score.created_at), 'dd MMM yyyy à HH:mm', { locale: fr })}
                    </td>
                    <td className="p-4 font-medium text-gray-800">
                      {score.score}
                    </td>
                    <td className="p-4">
                      {score.is_correct ? (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          Réussite
                        </span>
                      ) : (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                          Échec
                        </span>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <div className="p-8 text-center text-gray-400 text-sm">
              Aucun score enregistré pour l'instant. Lancez un quiz !
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

// Composant Helper pour les cartes
const StatCard = ({ label, value, color, subtext }: { label: string, value: string, color: string, subtext?: string }) => (
  <div className="bg-white border rounded-xl p-5 shadow-sm hover:shadow-md transition-shadow">
    <p className="text-gray-500 text-sm font-medium mb-1">{label}</p>
    <p className={`text-4xl font-bold ${color} mb-2`}>{value}</p>
    {subtext && <p className="text-gray-400 text-xs">{subtext}</p>}
  </div>
);

export default DeckDashboard;
```

## 4. Intégration dans le Projet

1.  Placez le fichier dans `src/components/DeckDashboard.tsx`.
2.  Importez-le dans votre page principale (ex: `Flashcards.tsx` ou une page de détails).
3.  Utilisez-le comme ceci :

```tsx
{showDashboard && selectedDeck && (
  <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
    <DeckDashboard 
      deckId={selectedDeck.deck_pk} 
      deckName={selectedDeck.name} 
      onClose={() => setShowDashboard(false)} 
    />
  </div>
)}
```

## 5. Fonctionnalités "Dynamiques"

-   **Chargement Asynchrone** : Les données sont chargées à l'ouverture, garantissant qu'elles sont toujours à jour.
-   **Animations** : Utilisation de `recharts` pour une visualisation fluide.
-   **Calcul en Temps Réel** : Le "Score Moyen" est recalculé côté client basé sur les 20 derniers scores pour refléter la performance récente.
