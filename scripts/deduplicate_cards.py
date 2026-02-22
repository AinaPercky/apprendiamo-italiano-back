
import asyncio
import os
import sys
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, func, and_, delete

# Ensure root is in path
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.append(ROOT)

from app.models import Card, deck_cards, Deck

DATABASE_URL = "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db"

async def deduplicate_cards():
    print(f"🔌 Connecting to database: {DATABASE_URL}")
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        print("🔍 Searching for duplicates based on 'back' (Italian word)...")
        
        # Trouver les doublons (même mot italien 'back')
        # On regroupe par 'back' et on compte les occurrences > 1
        stmt = select(Card.back, func.count(Card.card_pk)).group_by(Card.back).having(func.count(Card.card_pk) > 1)
        result = await session.execute(stmt)
        duplicates = result.fetchall()
        
        if not duplicates:
            print("✅ No duplicates found.")
            await engine.dispose()
            return

        print(f"⚠️ Found {len(duplicates)} sets of duplicates.")
        
        total_merged_sets = 0
        total_deleted_cards = 0

        for row in duplicates:
            back_word = row[0]
            count = row[1]
            
            print(f"\nProcessing '{back_word}' ({count} copies)...")
            
            # Récupérer toutes les instances de cette carte, triées par ID (le plus petit ID est le plus ancien -> master)
            cards_stmt = select(Card).where(Card.back == back_word).order_by(Card.card_pk)
            cards_result = await session.execute(cards_stmt)
            cards = cards_result.scalars().all()
            
            if not cards:
                continue

            # La première carte est le "maître"
            master_card = cards[0]
            duplicates_list = cards[1:]
            
            print(f"  👑 Master Card ID: {master_card.card_pk} (Original Deck: {master_card.deck_pk})")
            
            # Assurer que le master est lié à son propre deck_pk via la table d'association (si deck_pk est présent)
            if master_card.deck_pk:
                link_check = await session.execute(
                    select(deck_cards).where(
                        and_(
                            deck_cards.c.deck_pk == master_card.deck_pk,
                            deck_cards.c.card_pk == master_card.card_pk
                        )
                    )
                )
                if not link_check.first():
                    print(f"    🔗 Linking Master to its original Deck {master_card.deck_pk}")
                    await session.execute(
                        deck_cards.insert().values(
                            deck_pk=master_card.deck_pk,
                            card_pk=master_card.card_pk
                        )
                    )

            # Pour chaque doublon, on transfère ses liens de deck vers le maître et on fusionne les infos
            for dup in duplicates_list:
                print(f"  🔻 Processing duplicate ID: {dup.card_pk} (Deck: {dup.deck_pk})")
                
                # 1. Gestion du lien Deck (Many-to-Many)
                # Si le doublon avait un deck_pk, on doit lier le master à ce deck
                target_deck_pk = dup.deck_pk
                if target_deck_pk:
                    # Vérifier si le lien existe déjà pour le master
                    link_check = await session.execute(
                        select(deck_cards).where(
                            and_(
                                deck_cards.c.deck_pk == target_deck_pk,
                                deck_cards.c.card_pk == master_card.card_pk
                            )
                        )
                    )
                    if not link_check.first():
                        print(f"     ✅ Creating new link: Master {master_card.card_pk} <-> Deck {target_deck_pk}")
                        await session.execute(
                            deck_cards.insert().values(
                                deck_pk=target_deck_pk,
                                card_pk=master_card.card_pk
                            )
                        )
                    else:
                        print(f"     ℹ️ Link already exists: Master {master_card.card_pk} <-> Deck {target_deck_pk}")
                
                # 2. Vérifier s'il y a d'autres liens dans deck_cards pour ce doublon (si la migration a déjà couru partiellement)
                dup_links = await session.execute(
                    select(deck_cards).where(deck_cards.c.card_pk == dup.card_pk)
                )
                for link in dup_links.fetchall():
                    dup_deck_pk = link.deck_pk
                    # On transfère ce lien au master
                    link_check_master = await session.execute(
                        select(deck_cards).where(
                            and_(
                                deck_cards.c.deck_pk == dup_deck_pk,
                                deck_cards.c.card_pk == master_card.card_pk
                            )
                        )
                    )
                    if not link_check_master.first():
                         print(f"     ✅ Transferring existing M2M link: Deck {dup_deck_pk} -> Master {master_card.card_pk}")
                         await session.execute(
                            deck_cards.insert().values(
                                deck_pk=dup_deck_pk,
                                card_pk=master_card.card_pk
                            )
                        )

                # 3. Enrichir le master avec les infos du doublon si manquantes (Merge intelligent)
                fields_to_merge = [
                    'image', 'pronunciation', 'explanation_it', 
                    'translation_en', 'translation_de', 'translation_mg', 
                    'example'
                ]
                
                modified = False
                for field in fields_to_merge:
                    master_val = getattr(master_card, field)
                    dup_val = getattr(dup, field)
                    if not master_val and dup_val:
                        setattr(master_card, field, dup_val)
                        print(f"     ✨ Enriched master field '{field}' from duplicate")
                        modified = True
                
                if modified:
                    session.add(master_card)

                # 4. Supprimer le doublon
                # Note: La suppression en cascade devrait nettoyer deck_cards automatiquement
                print(f"     🗑️ Deleting duplicate card {dup.card_pk}")
                await session.delete(dup)
                total_deleted_cards += 1
            
            total_merged_sets += 1
            
        await session.commit()
        print(f"\n🎉 Done! Processed {total_merged_sets} sets. Deleted {total_deleted_cards} duplicate cards.")

    await engine.dispose()

if __name__ == "__main__":
    if sys.platform == "win32":
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    asyncio.run(deduplicate_cards())
