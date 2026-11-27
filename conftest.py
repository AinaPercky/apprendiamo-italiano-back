"""Configuration minimale commune aux tests backend."""

import os

# Les tests utilisent une clé dédiée, jamais un secret de production.
os.environ.setdefault("SECRET_KEY", "test-only-secret-key-for-apprendiamo-backend")
