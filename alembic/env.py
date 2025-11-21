# alembic/env.py
import os
import sys
from logging.config import fileConfig

# AJOUTE TON PROJET AU PYTHONPATH (c’est ÇA qui manquait sous Windows)
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context

# Maintenant l'import marche
from app.models import Base  # ← maintenant ça trouve 'app'

# this is the Alembic Config object
config = context.config

# Force UTF-8 pour le ini (même si on l’a simplifié)
fileConfig(config.config_file_name, encoding="utf-8")

target_metadata = Base.metadata