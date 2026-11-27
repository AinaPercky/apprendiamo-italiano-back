"""Administrative API for the client application registry."""
import json
from datetime import datetime
from typing import Literal, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field, field_validator, model_validator
from sqlalchemy import select, insert, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession
from urllib.parse import urlsplit

from ..client_applications import client_applications, validate_app_code
from ..database import get_db
from ..permissions import require_permission
from .. import models

router = APIRouter(prefix="/api/admin/client-applications", tags=["client applications"])


class ClientApplicationCreate(BaseModel):
    code: str = Field(..., min_length=2, max_length=64)
    name: str = Field(..., min_length=2, max_length=120)
    client_type: Literal["public_web", "mobile", "server"]
    description: Optional[str] = Field(default=None, max_length=2000)
    allowed_origins: list[str] = Field(default_factory=list, max_length=30)

    @field_validator("code")
    @classmethod
    def normalize_code(cls, value: str) -> str:
        return validate_app_code(value)

    @field_validator("allowed_origins")
    @classmethod
    def validate_origins(cls, values: list[str]) -> list[str]:
        normalized = []
        for value in values:
            origin = value.strip().rstrip("/")
            parsed = urlsplit(origin)
            local_http = parsed.scheme == "http" and parsed.hostname in {"localhost", "127.0.0.1"}
            if parsed.scheme != "https" and not local_http:
                raise ValueError("Chaque origine doit être HTTPS ou localhost.")
            if not parsed.hostname or parsed.path or parsed.query or parsed.fragment or parsed.username or parsed.password:
                raise ValueError("Une origine doit contenir uniquement un schéma et un hôte.")
            if origin not in normalized:
                normalized.append(origin)
        return normalized

    @model_validator(mode="after")
    def require_public_web_origins(self):
        if self.client_type == "public_web" and not self.allowed_origins:
            raise ValueError("Une application web publique doit déclarer au moins une origine autorisée.")
        return self


class ClientApplicationUpdate(BaseModel):
    is_active: Optional[bool] = None
    allowed_origins: Optional[list[str]] = Field(default=None, max_length=30)

    @field_validator("allowed_origins")
    @classmethod
    def validate_origins(cls, values):
        if values is None:
            return values
        return ClientApplicationCreate.validate_origins(values)


def _serialize(row):
    item = dict(row)
    item["allowed_origins"] = json.loads(item.get("allowed_origins") or "[]")
    return item


@router.get("")
async def list_client_applications(
    _admin=Depends(require_permission("client_apps:manage")),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(client_applications).order_by(client_applications.c.code))
    return [_serialize(row) for row in result.mappings().all()]


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_client_application(
    payload: ClientApplicationCreate,
    admin=Depends(require_permission("client_apps:manage")),
    db: AsyncSession = Depends(get_db),
):
    values = payload.model_dump()
    values["allowed_origins"] = json.dumps(values["allowed_origins"])
    now = datetime.utcnow()
    values.update({"created_at": now, "updated_at": now})
    try:
        result = await db.execute(insert(client_applications).values(**values).returning(client_applications))
        created = result.mappings().one()
        db.add(models.AuditLog(actor_user_pk=admin.user_pk, action="client_application_created", entity_type="client_application", entity_id=created["client_application_pk"], details=json.dumps({"code": created["code"], "client_type": created["client_type"]})))
        await db.commit()
    except IntegrityError as exc:
        await db.rollback()
        raise HTTPException(status_code=409, detail="Ce code d'application existe déjà") from exc
    return _serialize(created)


@router.patch("/{code}")
async def update_client_application(
    code: str,
    payload: ClientApplicationUpdate,
    admin=Depends(require_permission("client_apps:manage")),
    db: AsyncSession = Depends(get_db),
):
    try:
        code = validate_app_code(code)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail="Identifiant d'application invalide") from exc
    values = payload.model_dump(exclude_unset=True)
    if not values:
        raise HTTPException(status_code=400, detail="Aucune modification fournie")
    if any(value is None for value in values.values()):
        raise HTTPException(status_code=400, detail="Les champs de mise à jour ne peuvent pas être null")
    if values.get("allowed_origins") is not None:
        current = await db.execute(select(client_applications).where(client_applications.c.code == code))
        existing = current.mappings().first()
        if existing is None:
            raise HTTPException(status_code=404, detail="Application cliente introuvable")
        if existing["client_type"] == "public_web" and not values["allowed_origins"]:
            raise HTTPException(status_code=400, detail="Une application web publique doit conserver au moins une origine autorisée")
        values["allowed_origins"] = json.dumps(values["allowed_origins"])
    values["updated_at"] = datetime.utcnow()
    result = await db.execute(update(client_applications).where(client_applications.c.code == code).values(**values).returning(client_applications))
    row = result.mappings().first()
    if row is None:
        await db.rollback()
        raise HTTPException(status_code=404, detail="Application cliente introuvable")
    db.add(models.AuditLog(actor_user_pk=admin.user_pk, action="client_application_updated", entity_type="client_application", entity_id=row["client_application_pk"], details=json.dumps({"code": code, "changed_fields": sorted(payload.model_dump(exclude_unset=True).keys())})))
    await db.commit()
    return _serialize(row)
