import os
import pytest
import asyncio
from httpx import AsyncClient
from unittest.mock import patch, MagicMock
from app.main import app

# Ensure the audio directory exists for the test
AUDIO_DIR = "audios"
os.makedirs(AUDIO_DIR, exist_ok=True)

# Dummy gTTS class to avoid external network calls
class DummyGTTS:
    def __init__(self, text, lang="en"):
        self.text = text
        self.lang = lang
    def save(self, file_path):
        # Create an empty file to simulate audio generation
        with open(file_path, "wb") as f:
            f.write(b"")

@pytest.mark.asyncio
async def test_audio_endpoints():
    # Patch gTTS in the crud_audios module
    with patch("app.crud_audios.gTTS", DummyGTTS):
        async with AsyncClient(app=app, base_url="http://testserver") as client:
            # 1️⃣ Create an audio item
            create_data = {
                "title": "Test Audio",
                "text": "Ciao mondo",
                "category": "mot",
                "language": "it",
            }
            response = await client.post("/audios/", data=create_data)
            assert response.status_code == 200, f"Create failed: {response.text}"
            audio = response.json()
            audio_id = audio["id"]
            assert "audio_url" in audio

            # 2️⃣ List audios – should contain the newly created one
            response = await client.get("/audios/")
            assert response.status_code == 200
            audios = response.json()
            assert any(a["id"] == audio_id for a in audios)

            # 3️⃣ Retrieve the specific audio
            response = await client.get(f"/audios/{audio_id}")
            assert response.status_code == 200
            fetched = response.json()
            assert fetched["id"] == audio_id
            assert fetched["title"] == "Test Audio"

            # 4️⃣ Delete the audio
            response = await client.delete(f"/audios/{audio_id}")
            assert response.status_code == 200
            assert response.json()["detail"] == "Audio deleted"

            # 5️⃣ Ensure it is gone
            response = await client.get(f"/audios/{audio_id}")
            assert response.status_code == 404
