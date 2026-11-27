from datetime import datetime

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from . import models
from .schemas_google_oauth import VerifiedGoogleIdentity


class GoogleAccountConflictError(Exception):
    """Un compte local existe déjà et ne peut pas être lié implicitement."""


async def create_or_update_google_user(
    db: AsyncSession,
    identity: VerifiedGoogleIdentity,
) -> models.User:
    """Crée ou actualise un compte à partir d'une identité Google vérifiée.

    La correspondance se fait uniquement par le subject Google (sub).
    Une adresse email identique ne déclenche jamais une fusion de comptes.
    """
    result = await db.execute(
        select(models.User).where(models.User.google_id == identity.google_id)
    )
    user = result.scalar_one_or_none()

    if user:
        user.google_email = identity.google_email
        user.google_picture = identity.google_picture
        if identity.first_name:
            user.first_name = identity.first_name
        if identity.last_name:
            user.last_name = identity.last_name
        user.updated_at = datetime.utcnow()
    else:
        existing_email = await db.execute(
            select(models.User).where(
                func.lower(models.User.email) == identity.google_email.lower()
            )
        )
        if existing_email.scalar_one_or_none():
            raise GoogleAccountConflictError(
                "Un compte existe déjà avec cette adresse. Connectez-vous avec "
                "votre méthode habituelle ; la liaison Google devra être "
                "effectuée depuis une session authentifiée."
            )

        base_username = identity.google_email.split("@", 1)[0].strip() or "google-user"
        username = base_username
        counter = 1
        while True:
            username_result = await db.execute(
                select(models.User.user_pk).where(models.User.username == username)
            )
            if username_result.scalar_one_or_none() is None:
                break
            username = f"{base_username}{counter}"
            counter += 1

        user = models.User(
            email=identity.google_email,
            username=username,
            hashed_password=None,
            google_id=identity.google_id,
            google_email=identity.google_email,
            google_picture=identity.google_picture,
            first_name=identity.first_name,
            last_name=identity.last_name,
            is_active=True,
            role="etudiant",
            is_verified=True,
        )

    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user
