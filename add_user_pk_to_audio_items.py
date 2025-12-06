import asyncio
from sqlalchemy import text
from app.database import engine

async def add_column():
    async with engine.begin() as conn:
        try:
            # Vérifier si la colonne existe déjà (pour SQLite)
            # Note: Pour PostgreSQL, la syntaxe serait différente (IF NOT EXISTS)
            # Ici on tente l'ajout et on ignore l'erreur si elle existe
            await conn.execute(text("ALTER TABLE audio_items ADD COLUMN user_pk INTEGER REFERENCES users(user_pk) ON DELETE CASCADE"))
            print("Colonne user_pk ajoutée avec succès.")
        except Exception as e:
            print(f"Erreur (peut-être que la colonne existe déjà) : {e}")

if __name__ == "__main__":
    asyncio.run(add_column())
