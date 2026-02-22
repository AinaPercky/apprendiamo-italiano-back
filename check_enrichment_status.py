
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
import os

DATABASE_URL = "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db"

async def check_remaining():
    engine = create_async_engine(DATABASE_URL)
    async with engine.connect() as conn:
        print("Checking for cards with missing translations...")
        result = await conn.execute(text("SELECT count(*) FROM cards WHERE translation_en IS NULL"))
        count = result.scalar()
        print(f"Cards remaining to enrich: {count}")
        
        if count > 0:
            print("Some cards are still missing translations. A final run is needed.")
        else:
            print("All cards are enriched! 🎉")

    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(check_remaining())
