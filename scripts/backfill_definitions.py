import asyncio
import os
import sys

# Assurer que le répertoire racine est dans sys.path
ROOT = os.path.dirname(os.path.dirname(__file__))
if ROOT not in sys.path:
    sys.path.append(ROOT)

from app.database import SessionLocal, init_db
from app.crud_cards import backfill_card_definitions


async def main():
    await init_db()
    limit = None
    if len(sys.argv) > 1:
        try:
            limit = int(sys.argv[1])
        except ValueError:
            pass
    async with SessionLocal() as session:
        updated = await backfill_card_definitions(session, limit=limit)
        print(f"Backfill: {updated} cartes mises à jour")


if __name__ == "__main__":
    asyncio.run(main())
