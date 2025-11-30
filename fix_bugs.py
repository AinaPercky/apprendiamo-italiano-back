"""
Script de correction automatique des bugs identifiés
"""

import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text
import os
from dotenv import load_dotenv

load_dotenv()

# Configuration de la base de données
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:password@localhost/dbname")

engine = create_async_engine(DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def fix_missing_quiz_type_column():
    """Ajoute la colonne quiz_type si elle n'existe pas"""
    print("\n🔧 Vérification de la colonne quiz_type...")
    
    async with engine.begin() as conn:
        # Vérifier si la colonne existe
        result = await conn.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='user_scores' AND column_name='quiz_type'
        """))
        
        exists = result.fetchone() is not None
        
        if not exists:
            print("   ⚠️ Colonne quiz_type manquante, ajout en cours...")
            await conn.execute(text("""
                ALTER TABLE user_scores 
                ADD COLUMN quiz_type VARCHAR NOT NULL DEFAULT 'classique'
            """))
            print("   ✅ Colonne quiz_type ajoutée avec succès")
        else:
            print("   ✅ Colonne quiz_type déjà présente")


async def verify_user_deck_relationships():
    """Vérifie que toutes les relations UserDeck sont correctes"""
    print("\n🔧 Vérification des relations UserDeck...")
    
    async with AsyncSessionLocal() as session:
        # Vérifier les decks orphelins
        result = await session.execute(text("""
            SELECT COUNT(*) 
            FROM user_decks ud
            LEFT JOIN decks d ON ud.deck_pk = d.deck_pk
            WHERE d.deck_pk IS NULL
        """))
        
        orphan_count = result.scalar()
        
        if orphan_count > 0:
            print(f"   ⚠️ {orphan_count} UserDeck(s) orphelin(s) trouvé(s)")
            # Nettoyer les orphelins
            await session.execute(text("""
                DELETE FROM user_decks 
                WHERE deck_pk NOT IN (SELECT deck_pk FROM decks)
            """))
            await session.commit()
            print("   ✅ UserDecks orphelins supprimés")
        else:
            print("   ✅ Aucun UserDeck orphelin")


async def verify_card_anki_fields():
    """Vérifie que tous les champs Anki des cartes ont des valeurs valides"""
    print("\n🔧 Vérification des champs Anki des cartes...")
    
    async with AsyncSessionLocal() as session:
        # Vérifier les cartes avec des valeurs invalides
        result = await session.execute(text("""
            SELECT COUNT(*) 
            FROM cards 
            WHERE easiness < 1.3 OR easiness > 5.0
               OR interval < 0
               OR consecutive_correct < 0
        """))
        
        invalid_count = result.scalar()
        
        if invalid_count > 0:
            print(f"   ⚠️ {invalid_count} carte(s) avec des valeurs Anki invalides")
            # Corriger les valeurs
            await session.execute(text("""
                UPDATE cards 
                SET easiness = GREATEST(1.3, LEAST(5.0, easiness)),
                    interval = GREATEST(0, interval),
                    consecutive_correct = GREATEST(0, consecutive_correct)
                WHERE easiness < 1.3 OR easiness > 5.0
                   OR interval < 0
                   OR consecutive_correct < 0
            """))
            await session.commit()
            print("   ✅ Valeurs Anki corrigées")
        else:
            print("   ✅ Toutes les valeurs Anki sont valides")


async def verify_user_stats_consistency():
    """Vérifie la cohérence des statistiques utilisateur"""
    print("\n🔧 Vérification de la cohérence des statistiques utilisateur...")
    
    async with AsyncSessionLocal() as session:
        # Recalculer les stats pour chaque utilisateur
        result = await session.execute(text("""
            SELECT u.user_pk,
                   COALESCE(SUM(s.score), 0) as calculated_score,
                   u.total_score,
                   COALESCE(COUNT(DISTINCT CASE WHEN s.is_correct THEN s.card_pk END), 0) as calculated_learned,
                   u.total_cards_learned,
                   COALESCE(COUNT(s.score_pk), 0) as calculated_reviewed,
                   u.total_cards_reviewed
            FROM users u
            LEFT JOIN user_scores s ON u.user_pk = s.user_pk
            GROUP BY u.user_pk, u.total_score, u.total_cards_learned, u.total_cards_reviewed
            HAVING u.total_score != COALESCE(SUM(s.score), 0)
                OR u.total_cards_learned != COALESCE(COUNT(DISTINCT CASE WHEN s.is_correct THEN s.card_pk END), 0)
                OR u.total_cards_reviewed != COALESCE(COUNT(s.score_pk), 0)
        """))
        
        inconsistent_users = result.fetchall()
        
        if inconsistent_users:
            print(f"   ⚠️ {len(inconsistent_users)} utilisateur(s) avec des stats incohérentes")
            
            # Corriger les stats
            for user in inconsistent_users:
                await session.execute(text("""
                    UPDATE users 
                    SET total_score = (
                            SELECT COALESCE(SUM(score), 0) 
                            FROM user_scores 
                            WHERE user_pk = :user_pk
                        ),
                        total_cards_learned = (
                            SELECT COALESCE(COUNT(DISTINCT card_pk), 0) 
                            FROM user_scores 
                            WHERE user_pk = :user_pk AND is_correct = true
                        ),
                        total_cards_reviewed = (
                            SELECT COALESCE(COUNT(*), 0) 
                            FROM user_scores 
                            WHERE user_pk = :user_pk
                        )
                    WHERE user_pk = :user_pk
                """), {"user_pk": user[0]})
            
            await session.commit()
            print("   ✅ Statistiques utilisateur corrigées")
        else:
            print("   ✅ Toutes les statistiques utilisateur sont cohérentes")


async def verify_user_deck_stats_consistency():
    """Vérifie la cohérence des statistiques UserDeck"""
    print("\n🔧 Vérification de la cohérence des statistiques UserDeck...")
    
    async with AsyncSessionLocal() as session:
        # Recalculer les stats pour chaque UserDeck
        await session.execute(text("""
            UPDATE user_decks ud
            SET total_points = COALESCE((
                    SELECT SUM(score) 
                    FROM user_scores 
                    WHERE user_pk = ud.user_pk AND deck_pk = ud.deck_pk
                ), 0),
                total_attempts = COALESCE((
                    SELECT COUNT(*) 
                    FROM user_scores 
                    WHERE user_pk = ud.user_pk AND deck_pk = ud.deck_pk
                ), 0),
                successful_attempts = COALESCE((
                    SELECT COUNT(*) 
                    FROM user_scores 
                    WHERE user_pk = ud.user_pk AND deck_pk = ud.deck_pk AND is_correct = true
                ), 0),
                points_frappe = COALESCE((
                    SELECT SUM(score) 
                    FROM user_scores 
                    WHERE user_pk = ud.user_pk AND deck_pk = ud.deck_pk AND quiz_type = 'frappe'
                ), 0),
                points_association = COALESCE((
                    SELECT SUM(score) 
                    FROM user_scores 
                    WHERE user_pk = ud.user_pk AND deck_pk = ud.deck_pk AND quiz_type = 'association'
                ), 0),
                points_qcm = COALESCE((
                    SELECT SUM(score) 
                    FROM user_scores 
                    WHERE user_pk = ud.user_pk AND deck_pk = ud.deck_pk AND quiz_type = 'qcm'
                ), 0),
                points_classique = COALESCE((
                    SELECT SUM(score) 
                    FROM user_scores 
                    WHERE user_pk = ud.user_pk AND deck_pk = ud.deck_pk AND quiz_type = 'classique'
                ), 0)
        """))
        
        await session.commit()
        print("   ✅ Statistiques UserDeck recalculées")


async def main():
    """Exécute toutes les corrections"""
    print("""
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║           CORRECTION AUTOMATIQUE DES BUGS - APPRENDIAMO ITALIANO          ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
    """)
    
    try:
        await fix_missing_quiz_type_column()
        await verify_user_deck_relationships()
        await verify_card_anki_fields()
        await verify_user_stats_consistency()
        await verify_user_deck_stats_consistency()
        
        print("\n" + "="*80)
        print("✅ TOUTES LES CORRECTIONS ONT ÉTÉ APPLIQUÉES AVEC SUCCÈS")
        print("="*80)
        
    except Exception as e:
        print(f"\n❌ ERREUR lors de la correction: {e}")
        import traceback
        traceback.print_exc()
    
    finally:
        await engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())
