import pytest
from fastapi.testclient import TestClient
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from datetime import datetime, timedelta
import os
import shutil

# Importations du projet unifié
from app.main import app
from app.database import Base, get_db
from app.crud_audios import AUDIO_DIR

# Configuration de la base de données de test (SQLite en mémoire)
SQLALCHEMY_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

engine = create_async_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(
    autocommit=False, autoflush=False, bind=engine, class_=AsyncSession
)

# Surcharge de la dépendance get_db pour utiliser la DB de test
async def override_get_db():
    async with TestingSessionLocal() as session:
        yield session

app.dependency_overrides[get_db] = override_get_db

# Client de test
client = TestClient(app)

@pytest.fixture(scope="module", autouse=True)
async def setup_db():
    """Crée les tables et assure la propreté du dossier audio avant et après les tests."""
    # Nettoyage du dossier audio
    if os.path.exists(AUDIO_DIR):
        shutil.rmtree(AUDIO_DIR)
    os.makedirs(AUDIO_DIR)
    
    # Création des tables
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    
    yield
    
    # Suppression des tables
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.drop_all)
        
    # Nettoyage du dossier audio
    if os.path.exists(AUDIO_DIR):
        shutil.rmtree(AUDIO_DIR)

# --- Tests pour les Cartes (Decks et Cards) ---

@pytest.mark.asyncio
async def test_create_deck(setup_db):
    response = client.post(
        "/decks/",
        json={"name": "Vocabulaire de base"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "Vocabulaire de base"
    assert "deck_pk" in data
    assert "id_json" in data
    
@pytest.mark.asyncio
async def test_read_decks(setup_db):
    response = client.get("/decks/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["name"] == "Vocabulaire de base"

@pytest.mark.asyncio
async def test_create_card(setup_db):
    # Récupérer le deck_pk créé
    deck_response = client.get("/decks/")
    deck_pk = deck_response.json()[0]["deck_pk"]
    
    now = datetime.now().isoformat()
    next_review = (datetime.now() + timedelta(days=1)).isoformat()
    
    response = client.post(
        "/cards/",
        json={
            "deck_pk": deck_pk,
            "front": "Ciao",
            "back": "Salut",
            "created_at": now,
            "next_review": next_review,
            "tags": ["salutations"]
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["front"] == "Ciao"
    assert data["deck_pk"] == deck_pk
    assert "card_pk" in data

@pytest.mark.asyncio
async def test_read_cards(setup_db):
    response = client.get("/cards/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["front"] == "Ciao"

# --- Tests pour l'Audio (TTS) ---

@pytest.mark.asyncio
async def test_create_audio(setup_db):
    response = client.post(
        "/audios/",
        data={
            "title": "Test Audio",
            "text": "Questo è un test audio.",
            "category": "phrase",
            "language": "it"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Audio"
    assert "audio_url" in data
    assert os.path.exists(os.path.join(AUDIO_DIR, data["filename"]))

@pytest.mark.asyncio
async def test_list_audios(setup_db):
    response = client.get("/audios/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1 # Seulement l'audio créé dans test_create_audio
    assert data[0]["title"] == "Test Audio"

@pytest.mark.asyncio
async def test_delete_audio(setup_db):
    # Créer un second audio pour le supprimer
    response_create = client.post(
        "/audios/",
        data={
            "title": "Audio à supprimer",
            "text": "Supprime moi.",
            "category": "mot",
            "language": "it"
        }
    )
    audio_id = response_create.json()["id"]
    filename = response_create.json()["filename"]
    
    # Supprimer l'audio
    response_delete = client.delete(f"/audios/{audio_id}")
    assert response_delete.status_code == 200
    assert response_delete.json()["detail"] == "Audio deleted"
    
    # Vérifier que le fichier a été supprimé
    assert not os.path.exists(os.path.join(AUDIO_DIR, filename))
    
    # Vérifier qu'il n'est plus dans la liste
    response_list = client.get("/audios/")
    assert len(response_list.json()) == 1 # Le premier audio est toujours là
    
    # Tenter de supprimer un audio inexistant
    response_delete_404 = client.delete(f"/audios/{audio_id}")
    assert response_delete_404.status_code == 404
