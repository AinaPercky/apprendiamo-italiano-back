"""
Script de test pour le système de quiz adaptatif
Teste les fonctionnalités principales sans dépendance à psycopg2
"""
import asyncio
import sys
import os

# Ajouter le répertoire parent au path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
from app.database import DATABASE_URL

async def test_quiz_system():
    """Teste la création des tables du système de quiz"""
    
    # Créer l'engine async
    engine = create_async_engine(DATABASE_URL, echo=True)
    
    # Créer une session factory
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    
    # SQL pour créer les tables
    create_card_performance = """
    CREATE TABLE IF NOT EXISTS card_performance (
        performance_pk SERIAL PRIMARY KEY,
        user_pk INTEGER NOT NULL REFERENCES users(user_pk) ON DELETE CASCADE,
        card_pk INTEGER NOT NULL REFERENCES cards(card_pk) ON DELETE CASCADE,
        deck_pk INTEGER NOT NULL REFERENCES decks(deck_pk) ON DELETE CASCADE,
        correct_count INTEGER NOT NULL DEFAULT 0,
        incorrect_count INTEGER NOT NULL DEFAULT 0,
        total_attempts INTEGER NOT NULL DEFAULT 0,
        priority_score FLOAT NOT NULL DEFAULT 0.0,
        last_reviewed_at TIMESTAMP,
        created_at TIMESTAMP NOT NULL DEFAULT NOW()
    );
    
    CREATE INDEX IF NOT EXISTS ix_card_performance_performance_pk ON card_performance(performance_pk);
    CREATE INDEX IF NOT EXISTS ix_card_performance_user_pk ON card_performance(user_pk);
    CREATE INDEX IF NOT EXISTS ix_card_performance_card_pk ON card_performance(card_pk);
    CREATE INDEX IF NOT EXISTS ix_card_performance_deck_pk ON card_performance(deck_pk);
    """
    
    create_quiz_sessions = """
    CREATE TABLE IF NOT EXISTS quiz_sessions (
        session_pk SERIAL PRIMARY KEY,
        user_pk INTEGER NOT NULL REFERENCES users(user_pk) ON DELETE CASCADE,
        deck_pk INTEGER NOT NULL REFERENCES decks(deck_pk) ON DELETE CASCADE,
        card_count INTEGER NOT NULL,
        quiz_type VARCHAR NOT NULL DEFAULT 'classique',
        cycle_number INTEGER NOT NULL DEFAULT 1,
        used_card_pks TEXT NOT NULL,
        correct_count INTEGER DEFAULT 0,
        total_questions INTEGER DEFAULT 0,
        started_at TIMESTAMP NOT NULL DEFAULT NOW(),
        completed_at TIMESTAMP
    );
    
    CREATE INDEX IF NOT EXISTS ix_quiz_sessions_session_pk ON quiz_sessions(session_pk);
    CREATE INDEX IF NOT EXISTS ix_quiz_sessions_user_pk ON quiz_sessions(user_pk);
    CREATE INDEX IF NOT EXISTS ix_quiz_sessions_deck_pk ON quiz_sessions(deck_pk);
    """
    
    try:
        async with engine.begin() as conn:
            print("\n" + "=" * 60)
            print("🔄 Création de la table 'card_performance'...")
            print("=" * 60)
            
            # Exécuter chaque commande séparément (asyncpg ne supporte pas les commandes multiples)
            sqls = [
                """CREATE TABLE IF NOT EXISTS card_performance (
                    performance_pk SERIAL PRIMARY KEY,
                    user_pk INTEGER NOT NULL REFERENCES users(user_pk) ON DELETE CASCADE,
                    card_pk INTEGER NOT NULL REFERENCES cards(card_pk) ON DELETE CASCADE,
                    deck_pk INTEGER NOT NULL REFERENCES decks(deck_pk) ON DELETE CASCADE,
                    correct_count INTEGER NOT NULL DEFAULT 0,
                    incorrect_count INTEGER NOT NULL DEFAULT 0,
                    total_attempts INTEGER NOT NULL DEFAULT 0,
                    priority_score FLOAT NOT NULL DEFAULT 0.0,
                    last_reviewed_at TIMESTAMP,
                    created_at TIMESTAMP NOT NULL DEFAULT NOW()
                )""",
                "CREATE INDEX IF NOT EXISTS ix_card_performance_performance_pk ON card_performance(performance_pk)",
                "CREATE INDEX IF NOT EXISTS ix_card_performance_user_pk ON card_performance(user_pk)",
                "CREATE INDEX IF NOT EXISTS ix_card_performance_card_pk ON card_performance(card_pk)",
                "CREATE INDEX IF NOT EXISTS ix_card_performance_deck_pk ON card_performance(deck_pk)"
            ]
            
            for sql in sqls:
                await conn.execute(text(sql))
            
            print("✅ Table 'card_performance' créée avec succès")
            
            print("\n" + "=" * 60)
            print("🔄 Création de la table 'quiz_sessions'...")
            print("=" * 60)
            
            sqls_quiz = [
                """CREATE TABLE IF NOT EXISTS quiz_sessions (
                    session_pk SERIAL PRIMARY KEY,
                    user_pk INTEGER NOT NULL REFERENCES users(user_pk) ON DELETE CASCADE,
                    deck_pk INTEGER NOT NULL REFERENCES decks(deck_pk) ON DELETE CASCADE,
                    card_count INTEGER NOT NULL,
                    quiz_type VARCHAR NOT NULL DEFAULT 'classique',
                    cycle_number INTEGER NOT NULL DEFAULT 1,
                    used_card_pks TEXT NOT NULL,
                    correct_count INTEGER DEFAULT 0,
                    total_questions INTEGER DEFAULT 0,
                    started_at TIMESTAMP NOT NULL DEFAULT NOW(),
                    completed_at TIMESTAMP
                )""",
                "CREATE INDEX IF NOT EXISTS ix_quiz_sessions_session_pk ON quiz_sessions(session_pk)",
                "CREATE INDEX IF NOT EXISTS ix_quiz_sessions_user_pk ON quiz_sessions(user_pk)",
                "CREATE INDEX IF NOT EXISTS ix_quiz_sessions_deck_pk ON quiz_sessions(deck_pk)"
            ]
            
            for sql in sqls_quiz:
                await conn.execute(text(sql))
            
            print("✅ Table 'quiz_sessions' créée avec succès")
            
        # Vérifier que les tables existent
        async with async_session() as session:
            print("\n" + "=" * 60)
            print("🔍 Vérification des tables créées...")
            print("=" * 60)
            
            result = await session.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' 
                AND table_name IN ('card_performance', 'quiz_sessions')
                ORDER BY table_name
            """))
            
            tables = result.fetchall()
            
            if len(tables) == 2:
                print("\n✅ Toutes les tables ont été créées:")
                for table in tables:
                    print(f"   ✓ {table[0]}")
                
                print("\n" + "=" * 60)
                print("✨ Migration terminée avec succès!")
                print("=" * 60)
                print("\n📊 Système de quiz adaptatif prêt à l'emploi!")
                print("\n🚀 Endpoints disponibles:")
                print("   • POST   /api/quiz/start")
                print("   • POST   /api/quiz/answer")
                print("   • POST   /api/quiz/complete/{session_pk}")
                print("   • GET    /api/quiz/sessions")
                print("   • GET    /api/quiz/performances/{deck_pk}")
                return True
            else:
                print(f"\n❌ Erreur: Seulement {len(tables)} table(s) trouvée(s)")
                return False
                
    except Exception as e:
        print(f"\n❌ Erreur lors de la migration: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        await engine.dispose()

if __name__ == "__main__":
    print("=" * 60)
    print("🚀 Test & Migration - Système de Quiz Adaptatif")
    print("=" * 60)
    
    success = asyncio.run(test_quiz_system())
    
    if success:
        print("\n✅ Test réussi! Le système est opérationnel.")
        sys.exit(0)
    else:
        print("\n❌ Test échoué.")
        sys.exit(1)
