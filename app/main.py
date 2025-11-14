import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .database import lifespan
from .api import endpoints_cards, endpoints_audios
from .crud_audios import AUDIO_DIR

# -----------------------
# Logging
# -----------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# -----------------------
# Application FastAPI
# -----------------------
app = FastAPI(
    title="Apprendiamo Italiano Unified Backend",
    description="Backend unifié pour la gestion des flashcards et la génération audio (TTS).",
    version="1.0.0",
    lifespan=lifespan
)

# -----------------------
# CORS Middleware
# -----------------------
origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://localhost:8081",
    "http://127.0.0.1:8081",
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------
# Static files pour l'audio
# -----------------------
app.mount("/audios/files", StaticFiles(directory=AUDIO_DIR), name="audios_files")

# -----------------------
# Inclusion des Routers
# -----------------------
app.include_router(endpoints_cards.router)
app.include_router(endpoints_audios.router)

# -----------------------
# Route de base
# -----------------------
@app.get("/")
async def root():
    return {"message": "Bienvenue sur le Backend Unifié Apprendiamo Italiano"}
