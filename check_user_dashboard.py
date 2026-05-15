"""
Script de vérification du dashboard utilisateur

Vérifie :
- Les données UserDeck en base
- Les scores et tentatives
- Le calcul du success_rate
"""

import asyncio
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import select
from app.database import DATABASE_URL
from app.models import UserDeck, User, Deck

async def check_user_dashboard(email: str = "jean@gmail.com"):
    """Vérifie le dashboard d'un utilisateur"""
    
    engine = create_async_engine(DATABASE_URL, echo=False)
    async_session = sessionmaker(engine, class_=AsyncSession)
    
    async with async_session() as db:
        print(f"\n{'='*80}")
        print(f"🔍 VÉRIFICATION DU DASHBOARD")
        print(f"{'='*80}")
        
        # Trouver l'utilisateur
        stmt = select(User).where(User.email == email)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        
        if not user:
            print(f"\n❌ Utilisateur '{email}' non trouvé!")
            return
        
        print(f"\n✅ Utilisateur trouvé:")
        print(f"   • Email: {user.email}")
        print(f"   • Username: {user.username}")
        print(f"   • ID: {user.user_pk}")
        
        # Récupérer les UserDecks
        stmt = select(UserDeck).where(UserDeck.user_pk == user.user_pk)
        result = await db.execute(stmt)
        user_decks = result.scalars().all()
        
        print(f"\n📊 UserDecks trouvés: {len(user_decks)}")
        
        if len(user_decks) == 0:
            print("\n⚠️  Aucun UserDeck trouvé!")
            print("   Cela signifie que l'utilisateur n'a jamais terminé de quiz.")
            return
        
        # Statistiques globales
        total_attempts = sum(ud.attempt_count for ud in user_decks)
        total_correct = sum(ud.correct_count for ud in user_decks)
        global_success_rate = (total_correct / total_attempts * 100) if total_attempts > 0 else 0
        decks_started = sum(1 for ud in user_decks if ud.attempt_count > 0)
        
        print(f"\n📈 Statistiques Globales:")
        print(f"   • Total tentatives: {total_attempts}")
        print(f"   • Total correctes: {total_correct}")
        print(f"   • Success rate global: {global_success_rate:.1f}%")
        print(f"   • Decks commencés: {decks_started}")
        
        # Détails par deck
        print(f"\n📚 Détails par Deck:")
        print(f"{'='*80}")
        
        for ud in user_decks:
            # Récupérer le nom du deck
            stmt_deck = select(Deck).where(Deck.deck_pk == ud.deck_pk)
            result_deck = await db.execute(stmt_deck)
            deck = result_deck.scalar_one_or_none()
            
            deck_name = deck.name if deck else f"Deck {ud.deck_pk}"
            
            success_rate = (ud.correct_count / ud.attempt_count * 100) if ud.attempt_count > 0 else 0
            
            print(f"\n🎯 {deck_name} (ID: {ud.deck_pk})")
            print(f"   • Tentatives: {ud.attempt_count}")
            print(f"   • Correctes: {ud.correct_count}")
            print(f"   • Success Rate: {success_rate:.1f}%")
            print(f"   • Cartes maîtrisées: {ud.cards_mastered}")
            print(f"   • Dernière révision: {ud.last_studied}")
            
            if ud.attempt_count == 0:
                print(f"   ⚠️  Aucune tentative enregistrée!")
            elif success_rate == 0:
                print(f"   ⚠️  Success rate à 0% (toutes les réponses incorrectes)")
        
        # Recommandations
        print(f"\n{'='*80}")
        print(f"💡 RECOMMANDATIONS:")
        print(f"{'='*80}")
        
        if total_attempts == 0:
            print("\n❌ PROBLÈME: Aucune tentative enregistrée!")
            print("   Solution:")
            print("   1. Vérifier que le quiz appelle bien completeQuiz()")
            print("   2. Vérifier que UserDeck est mis à jour après le quiz")
            print("   3. Exécuter le test: python test_quiz_marathon_enhanced.py")
        elif total_correct == 0:
            print("\n⚠️  ATTENTION: Aucune réponse correcte!")
            print("   Cela peut être normal si l'utilisateur a tout raté.")
        else:
            print("\n✅ Les données semblent correctes!")
            print(f"   Le dashboard devrait afficher:")
            print(f"   • Total scores: {total_correct}")
            print(f"   • Score moyen: {global_success_rate:.1f}")
            print(f"   • Decks: {decks_started}")
        
        # Vérifier l'endpoint
        print(f"\n{'='*80}")
        print(f"🔌 VÉRIFICATION ENDPOINT:")
        print(f"{'='*80}")
        print(f"\nPour vérifier l'endpoint /api/users/decks/all:")
        print(f"curl -X GET http://localhost:8000/api/users/decks/all \\")
        print(f"  -H \"Authorization: Bearer YOUR_TOKEN\"")
        
    await engine.dispose()


async def main():
    """Point d'entrée"""
    import sys
    
    email = sys.argv[1] if len(sys.argv) > 1 else "jean@gmail.com"
    await check_user_dashboard(email)


if __name__ == "__main__":
    print("🔍 Vérification du Dashboard Utilisateur\n")
    asyncio.run(main())
