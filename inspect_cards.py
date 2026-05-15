
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
import os

DATABASE_URL = "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db"

async def inspect_cards():
    engine = create_async_engine(DATABASE_URL)
    async with engine.connect() as conn:
        print("Fetching card count...")
        result = await conn.execute(text("SELECT count(*) FROM cards"))
        count = result.scalar()
        print(f"Total cards: {count}")
        
        print("\nFetching first 20 cards sample...")
        result = await conn.execute(text("SELECT card_pk, front, back FROM cards LIMIT 20"))
        rows = result.fetchall()
        for row in rows:
            print(f"ID: {row[0]}, Front: {row[1]}, Back: {row[2]}")

    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(inspect_cards())
