
import asyncio
import httpx
import uuid

BASE_URL = "http://localhost:8000"

async def test_upsert_logic():
    print("🚀 Démarrage du test UPSERT (Enrichissement sans écrasement)...")
    
    async with httpx.AsyncClient(timeout=10.0) as client:
        # 1. Créer un deck temporaire
        deck_data = {
            "name": f"Test Upsert {uuid.uuid4().hex[:8]}",
            "id_json": uuid.uuid4().hex[:7]
        }
        response = await client.post(f"{BASE_URL}/decks/", json=deck_data)
        if response.status_code != 200:
            print(f"❌ Échec création deck: {response.text}")
            return
        
        deck_pk = response.json()["deck_pk"]
        print(f"✅ Deck créé: {deck_pk}")
        
        try:
            # 2. Créer une carte INITIALE (sans exemple)
            card_data_1 = {
                "deck_pk": deck_pk,
                "front": "Maison",
                "back": "Casa",
                "example": None,  # Pas d'exemple au début
                "created_at": "2024-01-01T12:00:00Z",
                "next_review": "2024-01-02T12:00:00Z"
            }
            
            resp1 = await client.post(f"{BASE_URL}/cards/", json=card_data_1)
            if resp1.status_code != 200:
                print(f"❌ Erreur création carte 1: {resp1.status_code} - {resp1.text}")
                return
            card1 = resp1.json()
            print(f"✅ Carte 1 créée: ID={card1['card_pk']}, Back='{card1['back']}', Example='{card1['example']}'")
            
            if card1['example'] is not None:
                print("❌ Erreur: L'exemple devrait être null")

            # 3. Tenter de créer la MÊME carte mais AVEC un exemple (Enrichissement)
            card_data_2 = {
                "deck_pk": deck_pk,
                "front": "Maison",
                "back": "Casa",
                "example": "Sono a casa.",  # Nouvel exemple
                "created_at": "2024-01-01T12:00:00Z",
                "next_review": "2024-01-02T12:00:00Z"
            }
            
            print("🔄 Tentative d'ajout de la même carte avec un exemple...")
            resp2 = await client.post(f"{BASE_URL}/cards/", json=card_data_2)
            card2 = resp2.json()
            
            # VÉRIFICATION 1 : Pas de doublon
            if card1['card_pk'] != card2['card_pk']:
                print(f"❌ Erreur: Une nouvelle carte a été créée (ID1={card1['card_pk']}, ID2={card2['card_pk']}) au lieu de mettre à jour.")
            else:
                print(f"✅ OK: Même ID de carte conservé ({card1['card_pk']}).")

            # VÉRIFICATION 2 : Mise à jour de l'exemple (car il était vide)
            if card2['example'] == "Sono a casa.":
                print(f"✅ OK: L'exemple a été ajouté: '{card2['example']}'")
            else:
                print(f"❌ Erreur: L'exemple n'a pas été mis à jour. Valeur actuelle: '{card2['example']}'")

            # 4. Tenter de créer la MÊME carte avec un AUTRE exemple (Ne doit PAS écraser)
            card_data_3 = {
                "deck_pk": deck_pk,
                "front": "Maison",
                "back": "Casa",
                "example": "Ecrasement interdit.",  # Ne devrait pas être pris en compte
                "created_at": "2024-01-01T12:00:00Z",
                "next_review": "2024-01-02T12:00:00Z"
            }
            
            print("🛡️ Tentative d'écrasement de l'exemple existant...")
            resp3 = await client.post(f"{BASE_URL}/cards/", json=card_data_3)
            card3 = resp3.json()
            
            # VÉRIFICATION 3 : Pas d'écrasement
            if card3['example'] == "Sono a casa.":
                print(f"✅ OK: L'exemple existant a été préservé: '{card3['example']}'")
            elif card3['example'] == "Ecrasement interdit.":
                print(f"❌ Erreur: L'exemple a été écrasé !")
            else:
                print(f"❌ Erreur: Valeur inattendue: '{card3['example']}'")

        finally:
            # Nettoyage
            await client.delete(f"{BASE_URL}/decks/{deck_pk}")
            print("🧹 Deck supprimé.")

if __name__ == "__main__":
    asyncio.run(test_upsert_logic())
