from pydantic import BaseModel, Field


class GoogleLoginRequest(BaseModel):
    """Contrat public : le Studio transmet le credential Google brut."""
    token: str = Field(..., min_length=1, max_length=10000)


class VerifiedGoogleIdentity(BaseModel):
    """Identité interne construite exclusivement depuis un ID token vérifié."""
    google_id: str = Field(..., min_length=1, max_length=255)
    google_email: str = Field(..., min_length=3, max_length=320)
    first_name: str | None = None
    last_name: str | None = None
    google_picture: str | None = None
