"""Configuration minimale commune aux tests backend."""

import os

# Les tests utilisent une clé dédiée, jamais un secret de production.
if not os.getenv("SECRET_KEY", "").strip():
    os.environ["SECRET_KEY"] = "test-only-secret-key-for-apprendiamo-backend"
