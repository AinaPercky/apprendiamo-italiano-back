# app/crud_cards.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete, or_, and_, func
from sqlalchemy.orm import joinedload
from . import models, schemas
import uuid
from typing import List, Optional
from datetime import datetime, timedelta, timezone
import base64
import requests
import anyio
import logging
from requests.exceptions import RequestException
from .core.image_scraper import fetch_icon_url, fetch_icon_urls # Import du scraper

logger = logging.getLogger(__name__)

def generate_id_json() -> str:
    return str(uuid.uuid4()).replace('-', '')[:7]

def clean_search_query(query: str) -> str:
    """
    Nettoie la requête de recherche :
    - Prend la première partie avant un '/'
    - Enlève le 'to ' initial pour les verbes anglais
    - Nettoie les espaces superflus
    """
    if not query:
        return ""

    # Séparer par '/' et prendre le premier élément
    query = query.split('/')[0].strip()

    # Enlever le 'to ' initial (insensible à la casse)
    if query.lower().startswith("to "):
        query = query[3:].strip()

    return query


# ==================== DECKS ====================

async def create_deck(db: AsyncSession, deck: schemas.DeckCreate) -> models.Deck:
    id_json = deck.id_json or generate_id_json()
    db_deck = models.Deck(id_json=id_json, name=deck.name)
    db.add(db_deck)
    await db.commit()
    await db.refresh(db_deck)
    return db_deck


async def get_decks(db: AsyncSession, skip: int = 0, limit: int = 10, search: Optional[str] = None) -> List[models.Deck]:
    stmt = select(models.Deck).options(joinedload(models.Deck.cards)).offset(skip).limit(limit)
    if search:
        stmt = stmt.where(models.Deck.name.ilike(f"%{search}%"))
    result = await db.execute(stmt)
    return result.unique().scalars().all()


async def get_deck(db: AsyncSession, deck_pk: int) -> Optional[models.Deck]:
    stmt = select(models.Deck).options(joinedload(models.Deck.cards)).where(models.Deck.deck_pk == deck_pk)
    result = await db.execute(stmt)
    return result.unique().scalar_one_or_none()


# ==================== UTILS ====================

def url_to_base64(url: str) -> Optional[str]:
    """Télécharge une image depuis une URL et la convertit en chaîne Base64 (Data URI)."""
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    try:
        response = requests.get(url, headers=headers, timeout=10)
        response.raise_for_status()  # Lève une exception pour les codes d'erreur HTTP (4xx ou 5xx)
        
        # Déterminer le type de contenu (Content-Type)
        content_type = response.headers.get('Content-Type', '').split(';')[0].strip()
        if not content_type or 'text' in content_type:
             # Fallback based on extension if content-type is missing or wrong
             if url.endswith('.png'): content_type = 'image/png'
             elif url.endswith('.svg'): content_type = 'image/svg+xml'
             elif url.endswith('.webp'): content_type = 'image/webp'
             else: content_type = 'image/jpeg'
        
        # Encoder le contenu en Base64
        base64_encoded_data = base64.b64encode(response.content)
        base64_string = base64_encoded_data.decode('utf-8')
        
        # Formater l'URI de données (Data URI scheme)
        return f"data:{content_type};base64,{base64_string}"
        
    except RequestException as e:
        print(f"Erreur lors du téléchargement de l'image depuis {url}: {e}")
        return None
    except Exception as e:
        print(f"Une erreur inattendue s'est produite lors de la conversion Base64 pour {url}: {e}")
        return None


# ==================== CARTES – MISE À JOUR ANKI CRITIQUE ====================

async def create_card(db: AsyncSession, card: schemas.CardCreate) -> models.Card:
    # 1. Vérifier si la carte existe déjà (basé sur le mot italien 'back' GLOBALEMENT)
    # L'utilisateur veut partager les cartes entre les decks (Many-to-Many)
    stmt = select(models.Card).where(
        models.Card.back.ilike(card.back)  # Recherche insensible à la casse
    )
    result = await db.execute(stmt)
    existing_card = result.scalars().first()

    # === AUTO-IMAGE LOGIC (Before creation/update) ===
    # Si aucune image fournie, on essaie de la trouver via scraping
    # IMPORTANT: Ne pas remplacer une image déjà existante sur une carte existante
    if not card.image and (not existing_card or not existing_card.image):
        search_query = clean_search_query(card.translation_en or card.front)
        if search_query:
            logger.info(f"🖼️ Auto-fetching icon for '{search_query}'...")
            # On utilise anyio.to_thread.run_sync pour ne pas bloquer l'event loop
            candidate_urls = await anyio.to_thread.run_sync(fetch_icon_urls, search_query)

            scraped_url = None
            for url in candidate_urls[:5]: # Essayer les 5 premiers
                # Vérifier si l'URL est accessible et non interdite (403)
                converted = await anyio.to_thread.run_sync(url_to_base64, url)
                if converted:
                    scraped_url = converted # On stocke directement le base64
                    break

            if scraped_url:
                logger.info(f"   ✅ Found and downloaded: {candidate_urls[0][:50]}...")
                card.image = scraped_url # card.image contient déjà le base64
            else:
                logger.info("   ❌ No reachable icon found.")

    if existing_card:
        # === LOGIQUE D'ENRICHISSEMENT ET DE LIAISON (MANY-TO-MANY) ===
        
        # A. Lier la carte existante au nouveau deck si ce n'est pas déjà fait
        # On vérifie si le lien existe déjà
        stmt_link = select(models.deck_cards).where(
            and_(
                models.deck_cards.c.deck_pk == card.deck_pk,
                models.deck_cards.c.card_pk == existing_card.card_pk
            )
        )
        result_link = await db.execute(stmt_link)
        link_exists = result_link.first()
        
        if not link_exists:
            # Créer le lien Many-to-Many
            await db.execute(
                models.deck_cards.insert().values(
                    deck_pk=card.deck_pk,
                    card_pk=existing_card.card_pk
                )
            )
            print(f"🔗 Carte existante (ID {existing_card.card_pk}) liée au deck {card.deck_pk}")

        # B. Enrichissement des données (Upsert partiel)
        changes = False
        fields_to_check = [
            'explanation_it', 'translation_en', 'translation_de', 
            'translation_mg', 'example', 'pronunciation', 'image'
        ]

        for field in fields_to_check:
            new_val = getattr(card, field)
            current_val = getattr(existing_card, field)
            
            # Si une nouvelle valeur est fournie ET que la valeur actuelle est vide/nulle
            if new_val and not current_val:
                # Cas spécial pour l'image (conversion URL -> Base64)
                if field == 'image' and new_val.startswith('http'):
                    converted_image = await anyio.to_thread.run_sync(url_to_base64, new_val)
                    if converted_image:
                        setattr(existing_card, field, converted_image)
                        changes = True
                else:
                    setattr(existing_card, field, new_val)
                    changes = True
        
        # Commit des changements (liaison + enrichissement)
        await db.commit()
        await db.refresh(existing_card)
            
        # Pour maintenir la compatibilité avec le frontend qui attend deck_pk sur l'objet retourné
        # on l'injecte manuellement dans l'instance (ce n'est pas persisté dans cards.deck_pk si on veut être puriste,
        # mais ici on peut le laisser si on garde la colonne pour compatibilité)
        existing_card.deck_pk = card.deck_pk 
        return existing_card

    # 2. Création normale si la carte n'existe pas
    id_json = card.id_json or generate_id_json()
    now = datetime.now(timezone.utc)
    
    # Conversion image
    image_val = await anyio.to_thread.run_sync(url_to_base64, card.image) if card.image and card.image.startswith('http') else card.image

    db_card = models.Card(
        id_json=id_json,
        # deck_pk=card.deck_pk, # ON NE LE SET PAS DIRECTEMENT ICI SI ON VEUT ETRE FULL M2M
        # Mais pour la compatibilité transitionnelle, on le met.
        # Attention : si une carte a plusieurs decks, ce champ ne reflète que le "premier" ou "principal".
        deck_pk=card.deck_pk, 
        
        front=card.front,
        back=card.back,
        pronunciation=card.pronunciation,
        image=image_val,
        
        # Nouveaux champs optionnels
        explanation_it=card.explanation_it,
        translation_en=card.translation_en,
        translation_de=card.translation_de,
        translation_mg=card.translation_mg,
        example=card.example,
        
        created_at=now,
        next_review=now + timedelta(days=1),
        box=0,
        tags=card.tags or [],

        # === CHAMPS ANKI OBLIGATOIRES ===
        easiness=2.5,
        interval=0,
        consecutive_correct=0,
        last_reviewed_at=None,
    )
    
    db.add(db_card)
    await db.flush() # Pour avoir l'ID
    
    # Créer le lien Many-to-Many
    await db.execute(
        models.deck_cards.insert().values(
            deck_pk=card.deck_pk,
            card_pk=db_card.card_pk
        )
    )
    
    await db.commit()
    await db.refresh(db_card)
    return db_card


async def get_cards(
    db: AsyncSession,
    skip: int = 0,
    limit: int = 1000,
    deck_pk: Optional[int] = None,
    search: Optional[str] = None,
    min_box: Optional[int] = None,
    tags_filter: Optional[List[str]] = None,
    due_only: bool = False,
) -> List[models.Card]:
    # On commence par sélectionner les cartes
    stmt = select(models.Card)

    # JOINTURE IMPORTANTE : Si on filtre par deck, on passe par la table d'association
    if deck_pk:
        stmt = stmt.join(models.deck_cards, models.Card.card_pk == models.deck_cards.c.card_pk)\
                   .where(models.deck_cards.c.deck_pk == deck_pk)
    
    if search:
        stmt = stmt.where(or_(
            models.Card.front.ilike(f"%{search}%"),
            models.Card.back.ilike(f"%{search}%")
        ))
    if min_box is not None:
        stmt = stmt.where(models.Card.box >= min_box)
    if tags_filter:
        stmt = stmt.where(models.Card.tags.contains(tags_filter))
    if due_only:
        stmt = stmt.where(models.Card.next_review <= datetime.now(timezone.utc))

    stmt = stmt.offset(skip).limit(limit).order_by(models.Card.next_review)

    result = await db.execute(stmt)
    cards = result.scalars().all()
    
    # Pour la compatibilité Frontend : Si on a filtré par un deck spécifique,
    # on s'assure que l'attribut .deck_pk de chaque objet carte renvoyé correspond à ce deck.
    # C'est une "vue" contextuelle de la carte.
    if deck_pk:
        for card in cards:
            card.deck_pk = deck_pk
            
    return cards


async def get_card(db: AsyncSession, card_pk: int) -> Optional[models.Card]:
    result = await db.execute(select(models.Card).where(models.Card.card_pk == card_pk))
    return result.scalar_one_or_none()


async def update_card(db: AsyncSession, card_pk: int, card_update: schemas.CardBase) -> Optional[models.Card]:
    update_data = card_update.model_dump(exclude_unset=True)
    if not update_data:
        return await get_card(db, card_pk)

    stmt = update(models.Card)\
        .where(models.Card.card_pk == card_pk)\
        .values(**update_data)
        # .returning(models.Card) # Pas nécessaire car on recharge après

    await db.execute(stmt)
    await db.commit()
    
    # Recharger la carte pour éviter MissingGreenlet après commit
    return await get_card(db, card_pk)


async def delete_card(db: AsyncSession, card_pk: int) -> bool:
    result = await db.execute(
        delete(models.Card)
        .where(models.Card.card_pk == card_pk)
        .returning(models.Card.card_pk)
    )
    await db.commit()
    return result.scalar_one_or_none() is not None


# ==================== FONCTION BONUS : Cartes dues aujourd'hui (pour le mode révision) ====================

async def get_due_cards(db: AsyncSession, user_pk: int, limit: int = 50) -> List[models.Card]:
    """Retourne les cartes à réviser aujourd'hui pour l'utilisateur (via user_decks)."""
    # M2M Support: User -> UserDeck -> Deck -> deck_cards -> Card
    stmt = select(models.Card)\
        .join(models.deck_cards, models.deck_cards.c.card_pk == models.Card.card_pk)\
        .join(models.UserDeck, models.UserDeck.deck_pk == models.deck_cards.c.deck_pk)\
        .where(
            models.UserDeck.user_pk == user_pk,
            models.Card.next_review <= datetime.now(timezone.utc)
        )\
        .order_by(models.Card.next_review)\
        .limit(limit)

    result = await db.execute(stmt)
    return result.scalars().all()


# ==================== IMPORTATION EN LOT (UPSERT) ====================

async def batch_upsert_cards(db: AsyncSession, cards: List[schemas.CardCreate]) -> dict:
    """
    Importe une liste de cartes avec logique Upsert (Mise à jour si existe, sinon Création).
    - Basé sur le mot italien ('back') pour l'unicité.
    - Met à jour les champs si une nouvelle valeur est fournie (écrasement).
    - Assure le lien avec le deck spécifié.
    """
    results = {"created": 0, "updated": 0, "errors": 0}
    
    for card in cards:
        try:
            # 1. Vérifier si la carte existe déjà (basé sur le mot italien 'back')
            stmt = select(models.Card).where(models.Card.back.ilike(card.back))
            result = await db.execute(stmt)
            existing_card = result.scalars().first()

            # === AUTO-IMAGE LOGIC ===
            # Si aucune image fournie, on essaie de la trouver via scraping
            # IMPORTANT: Ne pas remplacer une image déjà existante sur une carte existante
            if not card.image and (not existing_card or not existing_card.image):
                search_query = clean_search_query(card.translation_en or card.front)
                if search_query:
                    logger.info(f"🖼️ Auto-fetching icon for '{search_query}'...")
                    candidate_urls = await anyio.to_thread.run_sync(fetch_icon_urls, search_query)

                    scraped_url = None
                    for url in candidate_urls[:5]:
                        converted = await anyio.to_thread.run_sync(url_to_base64, url)
                        if converted:
                            scraped_url = converted
                            break

                    if scraped_url:
                        logger.info(f"   ✅ Found and downloaded: {candidate_urls[0][:50]}...")
                        card.image = scraped_url
                    else:
                        logger.info("   ❌ No reachable icon found.")

            if existing_card:
                # === UPDATE LOGIC (Merge/Overwrite) ===
                updated = False
                fields_to_check = [
                    'explanation_it', 'translation_en', 'translation_de', 
                    'translation_mg', 'example', 'pronunciation',
                    'front' # On met à jour le recto (français) aussi si changé
                ]

                for field in fields_to_check:
                    new_val = getattr(card, field)
                    # Si une nouvelle valeur est fournie (non vide/null)
                    if new_val:
                         # Gestion spéciale Image
                        # (image est traitée séparément ci-dessous)
                        # Comparaison et mise à jour
                        if getattr(existing_card, field) != new_val:
                            setattr(existing_card, field, new_val)
                            updated = True
                
                # === IMAGE: ne pas écraser si déjà présente ===
                if card.image:
                    # Convertir si nécessaire
                    image_val = await anyio.to_thread.run_sync(url_to_base64, card.image) if card.image.startswith('http') else card.image
                    if not existing_card.image and image_val and existing_card.image != image_val:
                        existing_card.image = image_val
                        updated = True
                
                # === M2M LINK CHECK ===
                stmt_link = select(models.deck_cards).where(
                    and_(
                        models.deck_cards.c.deck_pk == card.deck_pk,
                        models.deck_cards.c.card_pk == existing_card.card_pk
                    )
                )
                link_exists = (await db.execute(stmt_link)).first()
                
                if not link_exists:
                    await db.execute(
                        models.deck_cards.insert().values(
                            deck_pk=card.deck_pk,
                            card_pk=existing_card.card_pk
                        )
                    )
                    updated = True # On compte le lien comme une mise à jour
                
                if updated:
                    results["updated"] += 1
                    # On ajoute à la session pour être sûr que les modifs sont trackées
                    db.add(existing_card)
                    
            else:
                # === CREATE LOGIC ===
                id_json = card.id_json or generate_id_json()
                now = datetime.now(timezone.utc)
                
                image_val = await anyio.to_thread.run_sync(url_to_base64, card.image) if card.image and card.image.startswith('http') else card.image

                db_card = models.Card(
                    id_json=id_json,
                    deck_pk=card.deck_pk,
                    front=card.front,
                    back=card.back,
                    pronunciation=card.pronunciation,
                    image=image_val,
                    explanation_it=card.explanation_it,
                    translation_en=card.translation_en,
                    translation_de=card.translation_de,
                    translation_mg=card.translation_mg,
                    example=card.example,
                    created_at=now,
                    next_review=now + timedelta(days=1),
                    box=0,
                    tags=card.tags or [],
                    easiness=2.5,
                    interval=0,
                    consecutive_correct=0,
                    last_reviewed_at=None,
                )
                db.add(db_card)
                await db.flush() # Pour avoir l'ID
                
                # Création du lien
                await db.execute(
                    models.deck_cards.insert().values(
                        deck_pk=card.deck_pk,
                        card_pk=db_card.card_pk
                    )
                )
                results["created"] += 1

        except Exception as e:
            print(f"Error processing card {card.back}: {e}")
            results["errors"] += 1

    await db.commit()
    return results
