"""Client minimal Vercel Blob pour les médias de flashcards.

Le SDK officiel Vercel Blob est JavaScript. Ce module applique le même protocole
HTTP pour permettre au backend FastAPI Python d’utiliser le store connecté au
projet, via OIDC en production et via un jeton lecture-écriture en local.
"""

from __future__ import annotations

import base64
import hashlib
from contextlib import contextmanager
from contextvars import ContextVar
import mimetypes
import os
import re
import time
import uuid
from dataclasses import dataclass
from typing import Optional
from urllib.parse import quote, urlparse

import requests

BLOB_API_URL = os.getenv("VERCEL_BLOB_API_URL", "https://vercel.com/api/blob")
BLOB_API_VERSION = os.getenv("VERCEL_BLOB_API_VERSION_OVERRIDE", "12")
MAX_SERVER_UPLOAD_BYTES = int(os.getenv("BLOB_MAX_UPLOAD_BYTES", "4194304"))
_request_oidc_token: ContextVar[str] = ContextVar("vercel_oidc_token", default="")

IMAGE_CONTENT_TYPES = {
    "image/jpeg",
    "image/png",
    "image/webp",
    "image/gif",
    "image/svg+xml",
}


class BlobStorageError(RuntimeError):
    """Erreur de configuration ou de communication avec Vercel Blob."""


@dataclass(frozen=True)
class BlobObject:
    url: str
    pathname: str
    content_type: str
    size_bytes: int
    sha256: str
    original_filename: Optional[str] = None


def _normalise_store_id(store_id: str) -> str:
    return store_id.removeprefix("store_")


def _store_id_from_read_write_token(token: str) -> str:
    # Format émis par Vercel : vercel_blob_rw_<store-id>_<secret>.
    parts = token.split("_")
    if len(parts) < 5:
        raise BlobStorageError("Le format de BLOB_READ_WRITE_TOKEN est invalide.")
    return parts[3]


@contextmanager
def vercel_oidc_request_context(token: Optional[str]):
    """Expose le jeton OIDC injecté par Vercel à l’opération Blob courante."""
    context_token = _request_oidc_token.set((token or "").strip())
    try:
        yield
    finally:
        _request_oidc_token.reset(context_token)


def _resolve_auth() -> tuple[str, str]:
    """Retourne le jeton et l’identifiant de store employés par l’API Blob."""
    oidc_token = _request_oidc_token.get() or os.getenv("VERCEL_OIDC_TOKEN", "").strip()
    store_id = os.getenv("BLOB_STORE_ID", "").strip()
    if oidc_token and store_id:
        return oidc_token, _normalise_store_id(store_id)

    read_write_token = os.getenv("BLOB_READ_WRITE_TOKEN", "").strip()
    if read_write_token:
        return read_write_token, _normalise_store_id(_store_id_from_read_write_token(read_write_token))

    raise BlobStorageError(
        "Vercel Blob n’est pas configuré : BLOB_STORE_ID et le jeton OIDC de la "
        "requête Vercel sont requis en production ; BLOB_READ_WRITE_TOKEN est accepté en local."
    )


def _blob_headers(*, content_type: str) -> dict[str, str]:
    token, store_id = _resolve_auth()
    return {
        "Authorization": f"Bearer {token}",
        "x-vercel-blob-store-id": store_id,
        "x-api-version": BLOB_API_VERSION,
        "x-api-blob-request-id": f"{store_id}:{int(time.time() * 1000)}:{uuid.uuid4().hex[:12]}",
        "x-api-blob-request-attempt": "0",
        "x-vercel-blob-access": "public",
        "x-content-type": content_type,
        # Le pathname incorpore l’empreinte du contenu ; l’écrasement est donc
        # idempotent lors d’une reprise de migration.
        "x-allow-overwrite": "1",
        "x-cache-control-max-age": "31536000",
    }


def _extension_for(content_type: str, source_name: Optional[str] = None) -> str:
    if source_name:
        suffix = os.path.splitext(source_name)[1].lower()
        if suffix and re.fullmatch(r"\.[a-z0-9]{1,8}", suffix):
            return suffix
    extension = mimetypes.guess_extension(content_type, strict=False)
    if extension == ".jpe":
        return ".jpg"
    return extension or ".bin"


def _normalise_content_type(content_type: str) -> str:
    normalised = content_type.split(";", 1)[0].strip().lower()
    aliases = {
        "image/jpg": "image/jpeg",
        "image/pjpeg": "image/jpeg",
        "image/x-png": "image/png",
    }
    return aliases.get(normalised, normalised)


def _sniff_image_content_type(payload: bytes) -> Optional[str]:
    """Détecte les formats image acceptés lorsque l’ancien MIME est générique."""
    if payload.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if payload.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if payload.startswith((b"GIF87a", b"GIF89a")):
        return "image/gif"
    if len(payload) >= 12 and payload[:4] == b"RIFF" and payload[8:12] == b"WEBP":
        return "image/webp"

    # Les SVG étaient déjà acceptés explicitement ; cette détection est
    # réservée aux anciens flux binaires à MIME générique.
    prefix = payload.lstrip()[:4096].lower()
    if prefix.startswith(b"<svg") or b"<svg" in prefix[:512]:
        return "image/svg+xml"
    return None


def _resolve_image_content_type(
    declared_content_type: str,
    payload: bytes,
    *,
    source: str,
) -> str:
    """Valide le MIME déclaré ou déduit les anciens flux octet-stream."""
    normalised = _normalise_content_type(declared_content_type)
    if normalised in IMAGE_CONTENT_TYPES:
        return normalised

    generic_types = {"", "application/octet-stream", "binary/octet-stream", "application/binary"}
    detected = _sniff_image_content_type(payload) if normalised in generic_types else None
    if detected:
        return detected

    raise BlobStorageError(
        f"Type de fichier image non autorisé pour {source}: {normalised or 'inconnu'}"
    )


def decode_image_source(source: str) -> tuple[bytes, str, Optional[str]]:
    """Convertit une Data URI ou une URL distante en octets d’image contrôlés."""
    if source.startswith("data:"):
        match = re.fullmatch(r"data:([^;,]+);base64,([A-Za-z0-9+/=\s]+)", source, flags=re.DOTALL)
        if not match:
            raise BlobStorageError("La Data URI de l’image est invalide.")
        try:
            payload = base64.b64decode(match.group(2), validate=False)
        except ValueError as exc:
            raise BlobStorageError("Le contenu Base64 de l’image est invalide.") from exc
        if not payload or len(payload) > MAX_SERVER_UPLOAD_BYTES:
            raise BlobStorageError("La taille de l’image dépasse la limite d’upload serveur.")
        content_type = _resolve_image_content_type(
            match.group(1),
            payload,
            source="Data URI",
        )
        return payload, content_type, None

    parsed = urlparse(source)
    if parsed.scheme not in {"http", "https"}:
        raise BlobStorageError("L’image doit être une Data URI, une URL HTTP(S) ou une URL Blob.")

    try:
        response = requests.get(
            source,
            headers={"User-Agent": "ApprendiamoItalianoMediaMigrator/1.0"},
            timeout=(5, 20),
            stream=True,
        )
        response.raise_for_status()
    except requests.RequestException as exc:
        raise BlobStorageError(f"Impossible de récupérer l’image distante : {exc}") from exc

    declared_content_type = response.headers.get("Content-Type", "")
    content = bytearray()
    for chunk in response.iter_content(chunk_size=64 * 1024):
        if not chunk:
            continue
        content.extend(chunk)
        if len(content) > MAX_SERVER_UPLOAD_BYTES:
            raise BlobStorageError("La taille de l’image dépasse la limite d’upload serveur.")

    if not content:
        raise BlobStorageError("L’image distante est vide.")
    payload = bytes(content)
    content_type = _resolve_image_content_type(
        declared_content_type,
        payload,
        source=source,
    )
    original_filename = os.path.basename(parsed.path) or None
    return payload, content_type, original_filename


def prepare_card_image(source: str) -> tuple[bytes, str, Optional[str], str]:
    """Prépare une image et retourne ses octets, métadonnées et empreinte."""
    payload, content_type, original_filename = decode_image_source(source)
    return payload, content_type, original_filename, hashlib.sha256(payload).hexdigest()


def upload_image_bytes(
    payload: bytes,
    content_type: str,
    sha256: str,
    original_filename: Optional[str] = None,
) -> BlobObject:
    """Charge un objet image immuable, nommé uniquement à partir de son empreinte."""
    extension = _extension_for(content_type, original_filename)
    pathname = f"flashcards/image/{sha256}{extension}"

    try:
        response = requests.put(
            f"{BLOB_API_URL}/?pathname={quote(pathname, safe='/')}",
            data=payload,
            headers=_blob_headers(content_type=content_type),
            timeout=(10, 60),
        )
        response.raise_for_status()
        result = response.json()
    except (requests.RequestException, ValueError) as exc:
        detail = getattr(getattr(exc, "response", None), "text", "")
        raise BlobStorageError(f"Échec de téléversement Vercel Blob : {detail or exc}") from exc

    url = result.get("url")
    returned_pathname = result.get("pathname", pathname)
    if not url:
        raise BlobStorageError("Vercel Blob n’a pas retourné d’URL de média.")

    return BlobObject(
        url=url,
        pathname=returned_pathname,
        content_type=result.get("contentType", content_type),
        size_bytes=int(result.get("size", len(payload))),
        sha256=sha256,
        original_filename=original_filename,
    )


def upload_card_image(card_pk: int, source: str) -> BlobObject:
    """Compatibilité : charge l’image sous un pathname immuable dédupliqué."""
    del card_pk  # Le contenu, plutôt que l’identifiant de carte, définit le pathname.
    payload, content_type, original_filename, sha256 = prepare_card_image(source)
    return upload_image_bytes(payload, content_type, sha256, original_filename)
