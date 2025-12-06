# app/crud_decks.py
"""
CRUD operations spécifiques aux decks.
Séparé de crud_cards.py pour plus de clarté.
"""

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from . import models
from typing import Optional


async def delete_deck(db: AsyncSession, deck_pk: int) -> bool:
    """
    Supprime complètement un deck du système.
    
    Grâce au CASCADE dans les foreign keys (ondelete="CASCADE"), cela supprime automatiquement :
    - Toutes les cartes du deck (table cards)
    - Toutes les associations utilisateur-deck (table user_decks)
    - Tous les scores liés au deck (table user_scores)
    - Tous les audios liés aux cartes du deck (table user_audio)
    
    Args:
        db: Session de base de données
        deck_pk: ID du deck à supprimer
        
    Returns:
        True si le deck a été supprimé, False si le deck n'existe pas
    """
    result = await db.execute(
        select(models.Deck).where(models.Deck.deck_pk == deck_pk)
    )
    deck = result.scalar_one_or_none()
    
    if not deck:
        return False
    
    await db.delete(deck)
    await db.commit()
    return True


async def get_deck_creator(db: AsyncSession, deck_pk: int) -> Optional[int]:
    """
    Récupère l'ID du créateur d'un deck (si disponible).
    
    Note: Actuellement, le modèle Deck n'a pas de champ creator_user_pk.
    Cette fonction est un placeholder pour une future fonctionnalité.
    
    Pour l'instant, on considère qu'un deck est "créé par l'utilisateur" si :
    - Il existe un UserDeck pour cet utilisateur
    - Le deck n'est pas un deck système (id_json ne commence pas par 'sys_')
    
    Args:
        db: Session de base de données
        deck_pk: ID du deck
        
    Returns:
        L'ID du créateur ou None si c'est un deck système
    """
    result = await db.execute(
        select(models.Deck).where(models.Deck.deck_pk == deck_pk)
    )
    deck = result.scalar_one_or_none()
    
    if not deck:
        return None
    
    # Pour l'instant, on ne peut pas déterminer le créateur
    # TODO: Ajouter un champ creator_user_pk au modèle Deck
    return None
