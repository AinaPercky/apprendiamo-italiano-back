
import asyncio
import httpx
import uuid
from typing import Dict, Any

BASE_URL = "http://localhost:8001"

async def test_new_card_fields():
    print("🚀 Démarrage du test des nouveaux champs de carte...")

    async with httpx.AsyncClient(timeout=10.0) as client:
        # 1. Créer un deck temporaire
        deck_data = {
            "name": f"Test Deck {uuid.uuid4().hex[:8]}",
            "id_json": uuid.uuid4().hex[:7]
        }
        response = await client.post(f"{BASE_URL}/decks/", json=deck_data)
        if response.status_code != 200:
            print(f"❌ Échec de la création du deck: {response.text}")
            return

        deck = response.json()
        deck_pk = deck["deck_pk"]
        print(f"✅ Deck créé: {deck['name']} (PK: {deck_pk})")

        try:
            # 2. Créer une carte avec les nouveaux champs
            card_data = {
                "deck_pk": deck_pk,
                "front": "Gatto",
                "back": "Cat",
                "explanation_it": "Un animale domestico che miagola.",
                "translation_en": "Cat",
                "translation_de": "Katze",
                "translation_mg": "Saka",
                "example": "Il gatto dorme sul divano.",
                "box": 1,
                "created_at": "2024-01-01T12:00:00Z",
                "next_review": "2024-01-02T12:00:00Z"
            }

            response = await client.post(f"{BASE_URL}/cards/", json=card_data)
            if response.status_code != 200:
                print(f"❌ Échec de la création de la carte: {response.text}")
                return

            card = response.json()
            card_pk = card["card_pk"]
            print(f"✅ Carte créée: {card['front']} (PK: {card_pk})")

            # 3. Vérifier les champs
            print("🔍 Vérification des champs...")
            errors = []
            if card.get("explanation_it") != card_data["explanation_it"]:
                errors.append(f"explanation_it incorrect: {card.get('explanation_it')}")
            if card.get("translation_en") != card_data["translation_en"]:
                errors.append(f"translation_en incorrect: {card.get('translation_en')}")
            if card.get("translation_de") != card_data["translation_de"]:
                errors.append(f"translation_de incorrect: {card.get('translation_de')}")
            if card.get("translation_mg") != card_data["translation_mg"]:
                errors.append(f"translation_mg incorrect: {card.get('translation_mg')}")
            if card.get("example") != card_data["example"]:
                errors.append(f"example incorrect: {card.get('example')}")

            if errors:
                for error in errors:
                    print(f"❌ {error}")
            else:
                print("✅ Tous les champs sont corrects lors de la création.")

            # 4. Mettre à jour la carte
            update_data = {
                "front": "Gatto (Updated)",
                "back": "Cat (Updated)",
                "translation_mg": "Saka (Updated)",
                "example": "Il gatto mangia."
            }

            response = await client.put(f"{BASE_URL}/cards/{card_pk}", json=update_data)
            if response.status_code != 200:
                print(f"❌ Échec de la mise à jour de la carte: {response.text}")
            else:
                updated_card = response.json()
                print(f"✅ Carte mise à jour: {updated_card['front']}")

                # Vérifier la persistance des autres champs et la mise à jour
                if updated_card.get("translation_mg") == "Saka (Updated)" and \
                   updated_card.get("explanation_it") == card_data["explanation_it"]:
                    print("✅ Mise à jour vérifiée avec succès.")
                else:
                    print("❌ La mise à jour n'a pas renvoyé les valeurs attendues.")

        finally:
            # 5. Nettoyage
            await client.delete(f"{BASE_URL}/decks/{deck_pk}")
            print("🧹 Deck de test supprimé.")

if __name__ == "__main__":
    asyncio.run(test_new_card_fields())
