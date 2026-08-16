"""Importe le corpus local de conjugaisons dans la base configurée.

Usage : DATABASE_URL=... python scripts/import_italian_conjugations.py
Le script ne télécharge aucune donnée et peut être exécuté plusieurs fois.
"""

import asyncio
import json
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from app.crud_conjugations import import_packaged_conjugations
from app.database import SessionLocal


async def main() -> None:
    async with SessionLocal() as session:
        report = await import_packaged_conjugations(session)
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    asyncio.run(main())
