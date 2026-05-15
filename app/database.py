import asyncio
import logging
import os
from contextlib import asynccontextmanager
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.exc import SQLAlchemyError
import databases

logger = logging.getLogger(__name__)

def _normalize_db_url(url: str) -> str:
    if url.startswith("postgres://"):
        url = url.replace("postgres://", "postgresql://", 1)
    if url.startswith("postgresql://") and "+asyncpg" not in url:
        url = url.replace("postgresql://", "postgresql+asyncpg://", 1)
    return url

DATABASE_URL = _normalize_db_url(os.getenv("DATABASE_URL", "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db"))
database = databases.Database(DATABASE_URL)

engine = create_async_engine(
    DATABASE_URL,
    echo=os.getenv("SQL_ECHO", "0") == "1",
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
    max_retries = int(os.getenv("DB_MAX_RETRIES", "15"))
    retry_delay = int(os.getenv("DB_RETRY_DELAY", "2"))
    last_error = None
    for attempt in range(1, max_retries + 1):
        try:
            async with engine.connect() as conn:
                result = await conn.execute(text("SELECT 1"))
                logger.info(f"✅ DB connect ok: {result.scalar()}")
            async with engine.begin() as conn:
                from . import models
                await conn.run_sync(Base.metadata.create_all)
                logger.info("✅ Tables créées")
            return
        except Exception as e:
            last_error = e
            logger.error(f"❌ Connexion DB échouée (tentative {attempt}/{max_retries}): {e}")
            await asyncio.sleep(retry_delay)
    logger.error("💥 Échec de connexion DB après toutes les tentatives")
    raise last_error

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
