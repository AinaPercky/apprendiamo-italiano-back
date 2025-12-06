import asyncio
import httpx

# Configuration
BASE_URL = "http://localhost:8000"

async def cleanup_decks():
    print("🧹 Démarrage du nettoyage des decks de test...")
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        # 1. Récupérer tous les decks
        response = await client.get(f"{BASE_URL}/decks/")
        if response.status_code != 200:
            print(f"❌ Impossible de récupérer les decks: {response.text}")
            return

        decks = response.json()
        print(f"📋 {len(decks)} decks trouvés au total.")

        # 2. Identifier les decks de test
        test_decks = [d for d in decks if d['name'].startswith("Test Deck")]
        
        if not test_decks:
            print("✅ Aucun deck de test résiduel trouvé.")
            return

        print(f"⚠️ {len(test_decks)} decks de test trouvés à supprimer.")

        # 3. Supprimer chaque deck de test
        for deck in test_decks:
            deck_id = deck['deck_pk']
            deck_name = deck['name']
            print(f"   🗑️ Suppression de '{deck_name}' (ID: {deck_id})...")
            
            del_response = await client.delete(f"{BASE_URL}/decks/{deck_id}")
            
            if del_response.status_code == 200:
                print(f"      ✅ Supprimé.")
            else:
                print(f"      ❌ Échec suppression: {del_response.status_code}")

    print("\n✨ Nettoyage terminé.")

if __name__ == "__main__":
    asyncio.run(cleanup_decks())
