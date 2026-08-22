import logging
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .database import lifespan
from .api import endpoints_cards, endpoints_audios, endpoints_users, endpoints_quiz, endpoints_conjugations, endpoints_access
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
local_origins = {
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "http://localhost:8081",
    "http://127.0.0.1:8081",
}
production_origins = {
    origin.strip().rstrip("/")
    for origin in os.getenv("CORS_ORIGINS", "").split(",")
    if origin.strip()
}
# L’origine de production reste autorisée même si la variable CORS_ORIGINS
# n’a pas été configurée dans l’environnement Vercel.
known_frontend_origins = {
    "https://bella-design-lab.vercel.app",
}
origins = sorted(local_origins | production_origins | known_frontend_origins)
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_origin_regex=r"^https://bella-design-lab(?:-[a-z0-9-]+)?\.vercel\.app$",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------
# Static files pour l'audio
# -----------------------
# Compatibilité avec les anciens MP3 présents dans le package. Les nouveaux
# audios utilisent la route DB-backed /audios/{id}/file.
app.mount("/audios/files", StaticFiles(directory=str(AUDIO_DIR), check_dir=False), name="audios_files")

# -----------------------
# Inclusion des Routers
# -----------------------
app.include_router(endpoints_users.router)
app.include_router(endpoints_cards.router)
app.include_router(endpoints_audios.router)
app.include_router(endpoints_quiz.router)
app.include_router(endpoints_conjugations.router)
app.include_router(endpoints_access.router)

# -----------------------
# Route de base
# -----------------------
@app.get("/")
async def root():
    return {"message": "Bienvenue sur le Backend Unifié Apprendiamo Italiano"}
