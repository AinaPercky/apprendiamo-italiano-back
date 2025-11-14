import sys
import os
import logging

# Ajouter le répertoire parent au path pour les imports relatifs
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), 'app')))

try:
    from app.main import app
    from app.database import get_db, lifespan
    from app.models import Deck, Card, AudioItem
    from app.schemas import Deck, Card, AudioItem
    from app.crud_cards import create_deck, get_card
    from app.crud_audios import create_audio_item, generate_ipa
    from fastapi.testclient import TestClient
    
    # Vérifier la présence de espeak-ng (dépendance système)
    try:
        import subprocess
        subprocess.run(["espeak-ng", "--version"], check=True, capture_output=True)
        espeak_status = "OK"
    except (subprocess.CalledProcessError, FileNotFoundError):
        espeak_status = "Non trouvé ou erreur d'exécution. La génération IPA pourrait échouer."

    print("--- Vérification des Imports ---")
    print("✅ Imports FastAPI et modules internes: OK")
    print(f"✅ Modèles SQLAlchemy: Deck, Card, AudioItem")
    print(f"✅ Fonctions CRUD: create_deck, get_card, create_audio_item, generate_ipa")
    print(f"✅ Dépendance système espeak-ng: {espeak_status}")
    print("\nLe projet semble structurellement correct.")
    
except ImportError as e:
    print(f"❌ Erreur d'importation: {e}")
    print("Le projet n'est pas correctement structuré ou des dépendances manquent.")
except Exception as e:
    print(f"❌ Erreur inattendue: {e}")

finally:
    # Retirer le répertoire parent du path
    sys.path.pop(0)
