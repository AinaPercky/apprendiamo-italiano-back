import asyncio
import logging
from contextlib import asynccontextmanager
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import SQLAlchemyError
import databases

logger = logging.getLogger(__name__)

import os

# URL de connexion unifiée (à adapter selon l'environnement de déploiement)
# Utilisation des paramètres du projet audio car il est asynchrone
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db")
database = databases.Database(DATABASE_URL)

engine = create_async_engine(
    DATABASE_URL,
    echo=True,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    class_=AsyncSession
)

Base = declarative_base()

async def init_db():
    """Initialise la base de données et crée les tables."""
    max_retries = 10
    retry_delay = 3
    for attempt in range(max_retries):
        try:
            # Vérification de la connexion
            async with engine.connect() as conn:
                result = await conn.execute(text("SELECT 1"))
                logger.info(f"✅ DB connect ok: {result.scalar()}")
            
            # Création des tables
            async with engine.begin() as conn:
                # Importation des modèles pour que Base.metadata les connaisse
                from . import models
                await conn.run_sync(Base.metadata.create_all)
                logger.info("✅ Tables créées")
            return
        except SQLAlchemyError as e:
            logger.error(f"❌ Erreur SQLAlchemy (tentative {attempt+1}): {str(e)}")
            await asyncio.sleep(retry_delay)
        except Exception as e:
            logger.error(f"💥 Erreur inattendue: {str(e)}")
            raise

@asynccontextmanager
async def lifespan(app):
    """Cycle de vie de l'application FastAPI pour la connexion/déconnexion DB."""
    logger.info("🚀 Démarrage application...")
    await init_db()
    await database.connect()
    logger.info("✅ Application démarrée")
    yield
    await database.disconnect()
    logger.info("👋 Application arrêtée")

async def get_db() -> AsyncSession:
    """Dépendance pour obtenir une session de base de données asynchrone."""
    async with SessionLocal() as session:
        yield session
