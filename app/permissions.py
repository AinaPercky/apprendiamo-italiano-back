"""Central policy for human-user permissions.

Application identity is deliberately separate: a registered client application
never receives human-user permissions and cannot elevate the authenticated user.
"""
from fastapi import Depends, HTTPException, status

from . import models
from .security import get_current_active_user

ROLE_ADMIN = "admin"
ROLE_TEACHER = "professeur"
ROLE_STUDENT = "etudiant"

# Preserve current Studio behavior while making role policy explicit and testable.
ROLE_PERMISSIONS = {
    ROLE_ADMIN: frozenset({
        "content:read", "content:create", "content:update", "content:delete",
        "content:publish", "users:admin", "subscriptions:admin",
        "client_apps:manage", "activity:read:any", "activity:write",
    }),
    ROLE_TEACHER: frozenset({
        "content:read", "content:create", "content:update", "content:delete",
        "activity:read:own", "activity:write",
    }),
    ROLE_STUDENT: frozenset({
        "content:read", "activity:read:own", "activity:write",
    }),
}


def has_permission(user: models.User, permission: str) -> bool:
    """Role-level decision only; resource and subscription checks remain separate."""
    return permission in ROLE_PERMISSIONS.get(getattr(user, "role", None), ())


def require_permission(permission: str):
    """FastAPI dependency for a centralized role-level permission check."""
    async def dependency(current_user: models.User = Depends(get_current_active_user)) -> models.User:
        if not has_permission(current_user, permission):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Permission insuffisante")
        return current_user
    return dependency
