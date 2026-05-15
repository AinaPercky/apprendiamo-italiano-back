# Documentation d'Intégration Frontend : Tableau de Bord & Statistiques (Points)

Cette section détaille le fonctionnement du système de points.

## 4. Système de Points (`total_points`)

### Logique de Calcul
- Chaque **bonne réponse** rapporte **10 points** à l'utilisateur pour le deck concerné.
- Les points sont accumulés dans le champ `user_deck.total_points`.
- Les mauvaises réponses ne rapportent aucun point (0).

### Mise à Jour (Backend)
Les points sont mis à jour en temps réel à chaque réponse via l'endpoint `/api/quiz/answer`.
- Si `is_correct` est `true` -> `points += 10`.

### Affichage (Frontend)
Le frontend affiche simplement la valeur brute retournée par l'API :

```tsx
<div className="stat-card">
  <span className="label">POINTS</span>
  <span className="value">{deck.total_points}</span>
</div>
```

### Dépannage
Si les points restent à 0 malgré des bonnes réponses :
1. **Historique** : Les points n'étaient pas calculés dans les versions précédentes du Quiz Adaptatif.
2. **Correction** : Un script de migration a été exécuté le 06/12/2025 pour attribuer rétroactivement 10 points par bonne réponse historique.
3. **Vérification** : Rechargez le dashboard. Si le problème persiste, vérifiez que `successful_attempts > 0`.
