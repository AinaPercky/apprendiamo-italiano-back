"""Chargement optionnel de `.env.local` pour le développement hors Docker.

Les variables déjà présentes dans l'environnement ne sont jamais remplacées :
Vercel et Docker Compose restent donc les sources prioritaires en production
et en conteneur.
"""

from __future__ import annotations

import os
from pathlib import Path


_LOCAL_ENV_FILE = Path(__file__).resolve().parent.parent / ".env.local"


def _unquote(value: str) -> str:
    """Retire les guillemets englobants simples ou doubles d'une valeur."""
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def load_local_env() -> None:
    """Charge `.env.local` s'il existe, sans écraser l'environnement courant."""
    if not _LOCAL_ENV_FILE.is_file():
        return

    for raw_line in _LOCAL_ENV_FILE.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line.removeprefix("export ").lstrip()
        if "=" not in line:
            continue

        key, value = line.split("=", 1)
        key = key.strip()
        if key.isidentifier():
            os.environ.setdefault(key, _unquote(value.strip()))
