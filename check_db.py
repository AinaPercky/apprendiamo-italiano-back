
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
import os

DATABASE_URL = "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db"

async def check_db():
    engine = create_async_engine(DATABASE_URL)
    async with engine.connect() as conn:
        print("Checking cards columns...")
        result = await conn.execute(text("SELECT column_name FROM information_schema.columns WHERE table_name = 'cards'"))
        columns = [row[0] for row in result.fetchall()]
        print("Columns:", columns)
        
        print("\nChecking alembic version...")
        try:
            result = await conn.execute(text("SELECT * FROM alembic_version"))
            versions = [row[0] for row in result.fetchall()]
            print("Versions:", versions)
        except Exception as e:
            print("Error checking version:", e)

    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(check_db())
