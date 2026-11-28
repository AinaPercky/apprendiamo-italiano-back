# P0-07.1 — Contrat de journalisation Outbox

## Objectif

Toute écriture exécutée par la façade `DualWriteSession` doit être traçable et rejouable après validation de la transaction principale, sans enregistrer du SQL exécutable dans l'outbox.

## Contrat d'événement

Un événement contient :
- un identifiant unique ;
- la base source (`neon` ou `supabase`) ;
- le nom de la table ;
- une opération (`upsert` ou `delete`) ;
- la clé primaire complète (y compris les clés composites) ;
- un instantané JSON de la ligne pour `upsert`, ou la seule clé primaire pour `delete` ;
- son statut et ses métadonnées de tentative.

Les écritures ORM et les écritures SQL Core sont enregistrées dans la même transaction que la modification métier. Les opérations Core sont exécutées avec `RETURNING` afin de journaliser les lignes réellement affectées. Le résultat SQL reste consommable par le code appelant.

## Ordre des mutations

Les mutations suivies par une même session sont rejouées dans l'ordre où la façade les observe. Les événements d'une transaction reçoivent des horodatages ordonnés pour préserver cet ordre lors de la reprise après redémarrage.

## Limites et règles de sécurité

- Les DML sans table ou clé primaire sont refusés avant leur exécution : aucune écriture non traçable ne doit être validée silencieusement.
- L'outbox contient les valeurs nécessaires à la réplication, potentiellement des champs sensibles comme les empreintes de mots de passe. Elle doit rester une table interne, inaccessible aux API publiques et aux applications clientes.
- Ne jamais journaliser le contenu des payloads ou les secrets dans les logs.
- Une table inconnue, une colonne absente des métadonnées, une clé primaire incomplète ou une opération inconnue provoque une erreur explicite ; aucun événement incompatible n'est ignoré silencieusement.
- Les conflits entre écritures concurrentes des deux bases, le backoff, la quarantaine et l'exécution durable du worker restent dans P0-07.2 et P0-07.3.
- Cette étape ne modifie pas le schéma de production et ne lance aucune migration.

## Validation

La suite `tests/test_sync_outbox_contract.py` vérifie les DML INSERT/UPDATE/DELETE, les clés primaires, le retour des valeurs `RETURNING` et le refus des tables non réplicables.
