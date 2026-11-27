"""Registry and optional identity resolver for consuming applications.

X-Client-App is an identifier, not a credential. It is suitable for routing,
origin checks and audit attribution only; it must never grant authorization.
"""
import re
from datetime import datetime
from typing import Optional

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy import Boolean, Column, DateTime, Integer, String, Table, Text, select
from sqlalchemy.ext.asyncio import AsyncSession

from .database import Base, get_db

client_applications = Table(
    "client_applications", Base.metadata,
    Column("client_application_pk", Integer, primary_key=True, autoincrement=True),
    Column("code", String(64), nullable=False, unique=True, index=True),
    Column("name", String(120), nullable=False),
    Column("client_type", String(24), nullable=False),
    Column("description", Text, nullable=True),
    Column("allowed_origins", Text, nullable=False, default="[]", server_default="[]"),
    Column("is_active", Boolean, nullable=False, default=True, server_default="true", index=True),
    Column("created_at", DateTime(timezone=True), nullable=False, default=datetime.utcnow),
    Column("updated_at", DateTime(timezone=True), nullable=False, default=datetime.utcnow),
)

_CODE_PATTERN = re.compile(r"^[a-z][a-z0-9-]{1,63}$")


def validate_app_code(code: str) -> str:
    normalized = code.strip().lower()
    if not _CODE_PATTERN.fullmatch(normalized):
        raise ValueError("Le code doit contenir 2 à 64 caractères : minuscules, chiffres et tirets.")
    return normalized


async def get_client_application(
    x_client_app: Optional[str] = Header(default=None, alias="X-Client-App"),
    origin: Optional[str] = Header(default=None),
    db: AsyncSession = Depends(get_db),
) -> Optional[dict]:
    """Resolve optional app identity. No header keeps existing clients compatible."""
    if not x_client_app:
        return None
    try:
        code = validate_app_code(x_client_app)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail="Identifiant d'application invalide") from exc
    result = await db.execute(select(client_applications).where(client_applications.c.code == code))
    row = result.mappings().first()
    if row is None or not row["is_active"]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Application cliente inconnue ou désactivée")
    try:
        allowed_origins = json.loads(row["allowed_origins"] or "[]")
    except (TypeError, json.JSONDecodeError):
        raise HTTPException(status_code=503, detail="Configuration d'application invalide")
    if origin and allowed_origins and origin.rstrip("/") not in {item.rstrip("/") for item in allowed_origins}:
        raise HTTPException(status_code=403, detail="Origine non autorisée pour cette application")
    return dict(row)


import json
