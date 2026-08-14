import base64
import hashlib
import os
import unittest
from unittest.mock import patch

# Évite toute tentative de connexion réelle lors de l’import des modèles.
os.environ.setdefault("DATABASE_URL", "postgresql+asyncpg://postgres:admin@localhost:5432/apprendiamo_db")

from app import blob_storage, models  # noqa: E402


class CardMediaStorageTests(unittest.TestCase):
    def test_prepare_data_uri_image(self):
        payload = b"tiny-png-placeholder"
        source = "data:image/png;base64," + base64.b64encode(payload).decode("ascii")
        decoded, content_type, filename, checksum = blob_storage.prepare_card_image(source)

        self.assertEqual(decoded, payload)
        self.assertEqual(content_type, "image/png")
        self.assertIsNone(filename)
        self.assertEqual(checksum, hashlib.sha256(payload).hexdigest())

    def test_prepare_octet_stream_data_uri_by_image_signature(self):
        payload = b"\x89PNG\r\n\x1a\nlegacy-png"
        source = "data:application/octet-stream;base64," + base64.b64encode(payload).decode("ascii")
        decoded, content_type, filename, checksum = blob_storage.prepare_card_image(source)

        self.assertEqual(decoded, payload)
        self.assertEqual(content_type, "image/png")
        self.assertIsNone(filename)
        self.assertEqual(checksum, hashlib.sha256(payload).hexdigest())

    def test_prepare_normalises_image_jpg_alias(self):
        payload = b"legacy-jpeg-placeholder"
        source = "data:image/jpg;base64," + base64.b64encode(payload).decode("ascii")
        decoded, content_type, filename, checksum = blob_storage.prepare_card_image(source)

        self.assertEqual(decoded, payload)
        self.assertEqual(content_type, "image/jpeg")
        self.assertIsNone(filename)
        self.assertEqual(checksum, hashlib.sha256(payload).hexdigest())

    def test_prepare_rejects_non_image_data_uri(self):
        source = "data:text/plain;base64," + base64.b64encode(b"not an image").decode("ascii")
        with self.assertRaises(blob_storage.BlobStorageError):
            blob_storage.prepare_card_image(source)

    def test_blob_path_is_content_addressed(self):
        payload = b"same-content"
        checksum = hashlib.sha256(payload).hexdigest()
        expected_path = f"flashcards/image/{checksum}.png"
        response = {
            "url": "https://example.public.blob.vercel-storage.com/" + expected_path,
            "pathname": expected_path,
            "contentType": "image/png",
            "size": len(payload),
        }
        with patch.object(blob_storage, "_blob_headers", return_value={}):
            with patch.object(blob_storage.requests, "put") as put:
                put.return_value.json.return_value = response
                put.return_value.raise_for_status.return_value = None
                result = blob_storage.upload_image_bytes(payload, "image/png", checksum)

        self.assertEqual(result.pathname, expected_path)
        self.assertEqual(result.sha256, checksum)
        self.assertEqual(put.call_count, 1)

    def test_card_media_model_contains_audio_extension(self):
        columns = {column.name for column in models.CardMedia.__table__.columns}
        self.assertTrue({"kind", "url", "pathname", "content_type", "sha256"}.issubset(columns))


if __name__ == "__main__":
    unittest.main()
