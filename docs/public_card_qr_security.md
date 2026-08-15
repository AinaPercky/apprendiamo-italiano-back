# Liens QR publics sécurisés

Les QR de consultation de flashcards utilisent une capacité opaque : le jeton aléatoire n’est jamais stocké en clair et sa signature HMAC-SHA-256 est vérifiée avant toute lecture de la carte.

La variable sensible `QR_LINK_SECRET` doit être définie dans les environnements Production et Preview. Toute rotation de cette clé invalide les URL QR précédemment émises ; les nouveaux PDF génèrent alors de nouveaux liens valides.
