
import asyncio
import os
import sys
import time
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select, update, func
from deep_translator import GoogleTranslator

# Ensure root is in path
ROOT = os.path.dirname(os.path.dirname(__file__))
if ROOT not in sys.path:
    sys.path.append(ROOT)

from app.models import Card

# Database URL
DATABASE_URL = "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db"

# Manual data for high quality enrichment of known cards
MANUAL_DATA = {
    "Nervoso": {
        "explanation_it": "Uno stato di agitazione o ansia, mancanza di calma.",
        "translation_en": "Nervous",
        "translation_de": "Nervös",
        "translation_mg": "Natahotra",
        "example": "Oggi mi sento un po' nervoso per l'esame."
    },
    "Anziano": {
        "explanation_it": "Persona di età avanzata.",
        "translation_en": "Elderly",
        "translation_de": "Älter / Senior",
        "translation_mg": "Zokiolona",
        "example": "Bisogna portare rispetto alle persone anziane."
    },
    "Rilassarsi": {
        "explanation_it": "Riposarsi, sciogliere la tensione.",
        "translation_en": "To relax",
        "translation_de": "Sich entspannen",
        "translation_mg": "Miala sasatra",
        "example": "Nel weekend mi piace rilassarmi leggendo un libro."
    },
    "Leggero": {
        "explanation_it": "Che ha poco peso, non pesante.",
        "translation_en": "Light",
        "translation_de": "Leicht",
        "translation_mg": "Maivana",
        "example": "Questa valigia è molto leggera."
    },
    "Prepararsi": {
        "explanation_it": "Mettersi pronto per fare qualcosa.",
        "translation_en": "To get ready",
        "translation_de": "Sich vorbereiten",
        "translation_mg": "Miomana",
        "example": "Devo prepararmi per uscire."
    },
    "Pettinarsi": {
        "explanation_it": "Ordinare i capelli con il pettine.",
        "translation_en": "To comb one's hair",
        "translation_de": "Sich kämmen",
        "translation_mg": "Mibango volo",
        "example": "Si pettina davanti allo specchio."
    },
    "Asciugarsi": {
        "explanation_it": "Togliere l'acqua o l'umidità dal corpo.",
        "translation_en": "To dry oneself",
        "translation_de": "Sich abtrocknen",
        "translation_mg": "Hamaina",
        "example": "Usa l'asciugamano per asciugarti."
    },
    "Arrabbiarsi": {
        "explanation_it": "Diventare furioso o irritato.",
        "translation_en": "To get angry",
        "translation_de": "Wütend werden",
        "translation_mg": "Tezitra",
        "example": "Non arrabbiarti per queste sciocchezze."
    },
    "Coricarsi": {
        "explanation_it": "Andare a letto, sdraiarsi.",
        "translation_en": "To go to bed",
        "translation_de": "Zu Bett gehen",
        "translation_mg": "Mandry / Matory",
        "example": "È tardi, vado a coricarmi."
    },
    "Radersi": {
        "explanation_it": "Tagliare la barba o i peli.",
        "translation_en": "To shave",
        "translation_de": "Sich rasieren",
        "translation_mg": "Miharatra",
        "example": "Si rade ogni mattina prima di andare al lavoro."
    },
    "Ricordarsi": {
        "explanation_it": "Tenere a mente qualcosa.",
        "translation_en": "To remember",
        "translation_de": "Sich erinnern",
        "translation_mg": "Mahatsiaro",
        "example": "Ti ricordi di chiudere la porta?"
    },
    "Svegliarsi": {
        "explanation_it": "Uscire dal sonno.",
        "translation_en": "To wake up",
        "translation_de": "Aufwachen",
        "translation_mg": "Mifoha",
        "example": "Mi sveglio sempre alle 7:00."
    },
    "Corriere": {
        "explanation_it": "Chi trasporta e consegna pacchi o posta.",
        "translation_en": "Courier",
        "translation_de": "Kurier",
        "translation_mg": "Mpitondra entana",
        "example": "Il corriere ha appena consegnato il pacco."
    },
    "Elettricista": {
        "explanation_it": "Tecnico che installa e ripara impianti elettrici.",
        "translation_en": "Electrician",
        "translation_de": "Elektriker",
        "translation_mg": "Elektrisianina",
        "example": "Abbiamo chiamato l'elettricista per il guasto."
    },
    "Idraulico": {
        "explanation_it": "Tecnico che ripara tubature e impianti sanitari.",
        "translation_en": "Plumber",
        "translation_de": "Klempner / Installateur",
        "translation_mg": "Plombier",
        "example": "L'idraulico ha riparato il rubinetto che perdeva."
    },
    "Proteggere": {
        "explanation_it": "Difendere da un pericolo o danno.",
        "translation_en": "To protect",
        "translation_de": "Schützen",
        "translation_mg": "Miaro",
        "example": "Bisogna proteggere l'ambiente."
    },
    "Ridurre": {
        "explanation_it": "Rendere minore in quantità o dimensione.",
        "translation_en": "To reduce",
        "translation_de": "Reduzieren",
        "translation_mg": "Mampihena",
        "example": "Dobbiamo ridurre gli sprechi."
    },
    "Essere al settimo cielo": {
        "explanation_it": "Essere estremamente felici.",
        "translation_en": "To be over the moon",
        "translation_de": "Im siebten Himmel sein",
        "translation_mg": "Faly be / Any an-danitra fahafito",
        "example": "Quando ha vinto, era al settimo cielo."
    },
    "Gas": {
        "explanation_it": "Stato della materia, combustibile.",
        "translation_en": "Gas",
        "translation_de": "Gas",
        "translation_mg": "Entona / Gaz",
        "example": "Cuciniamo con il fornello a gas."
    },
    "Opinione": {
        "explanation_it": "Idea o giudizio personale su qualcosa.",
        "translation_en": "Opinion",
        "translation_de": "Meinung",
        "translation_mg": "Hevitra",
        "example": "Rispetto la tua opinione, anche se non sono d'accordo."
    }
}

async def enrich_database():
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        # Fetch all cards that need enrichment (where translation_en is NULL)
        # We start with NULL fields to avoid overwriting existing work unless specified
        stmt = select(Card).where(Card.translation_en.is_(None))
        result = await session.execute(stmt)
        cards = result.scalars().all()
        
        print(f"🔍 Found {len(cards)} cards to enrich.")
        
        count = 0
        translator_en = GoogleTranslator(source='it', target='en')
        translator_de = GoogleTranslator(source='it', target='de')
        translator_mg = GoogleTranslator(source='it', target='mg')

        for card in cards:
            # Clean up back text (sometimes has extra info in parens)
            italian_word = card.back.strip()
            
            # 1. Check Manual Dictionary
            if italian_word in MANUAL_DATA:
                data = MANUAL_DATA[italian_word]
                card.explanation_it = data["explanation_it"]
                card.translation_en = data["translation_en"]
                card.translation_de = data["translation_de"]
                card.translation_mg = data["translation_mg"]
                card.example = data["example"]
                print(f"✅ [MANUAL] Enriched: {italian_word}")
            
            # 2. Automatic Translation
            else:
                try:
                    # Simple translation
                    # Note: We do not generate explanation/example automatically to avoid bad quality
                    # But we fill translations
                    
                    # English
                    en_trans = translator_en.translate(italian_word)
                    card.translation_en = en_trans
                    
                    # German
                    de_trans = translator_de.translate(italian_word)
                    card.translation_de = de_trans
                    
                    # Malagasy
                    mg_trans = translator_mg.translate(italian_word)
                    card.translation_mg = mg_trans
                    
                    print(f"🤖 [AUTO] Translated: {italian_word} -> {en_trans}, {de_trans}, {mg_trans}")
                    
                    # Add delay to avoid rate limiting
                    time.sleep(0.2)
                    
                except Exception as e:
                    print(f"❌ Error translating {italian_word}: {e}")
            
            count += 1
            # Commit every 10 cards to save progress
            if count % 10 == 0:
                await session.commit()
                print(f"💾 Saved progress: {count}/{len(cards)}")

        await session.commit()
        print(f"🎉 Finished! Enriched {count} cards.")

    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(enrich_database())
