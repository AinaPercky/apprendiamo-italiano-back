import base64
import unittest
from unittest.mock import patch

from app import crud_card_audio


class FakeUpload:
    def __init__(self, payload: bytes, content_type: str = "audio/mpeg", filename: str = "pronunciation.mp3"):
        self.payload = payload
        self.content_type = content_type
        self.filename = filename

    async def read(self, limit: int = -1) -> bytes:
        return self.payload[:limit] if limit >= 0 else self.payload


class CardAudioValidationTests(unittest.IsolatedAsyncioTestCase):
    async def test_accepts_id3_mp3_and_normalises_content_type(self):
        payload = b"ID3" + b"\x04\x00" + b"test-mp3-payload"
        content, content_type, filename = await crud_card_audio._read_and_validate_upload(
            FakeUpload(payload, "audio/mp3", "folder/pronunciation.mp3")
        )
        self.assertEqual(content, payload)
        self.assertEqual(content_type, "audio/mpeg")
        self.assertEqual(filename, "pronunciation.mp3")

    async def test_accepts_mpeg_frame(self):
        payload = b"\xff\xfb\x90\x64" + b"test-mp3-payload"
        content, content_type, _ = await crud_card_audio._read_and_validate_upload(FakeUpload(payload))
        self.assertEqual(content_type, "audio/mpeg")
        self.assertEqual(len(content), len(payload))

    async def test_rejects_non_mp3_content(self):
        with self.assertRaises(crud_card_audio.CardAudioValidationError):
            await crud_card_audio._read_and_validate_upload(FakeUpload(b"not-an-mp3"))

    async def test_rejects_wrong_content_type(self):
        with self.assertRaises(crud_card_audio.CardAudioValidationError):
            await crud_card_audio._read_and_validate_upload(FakeUpload(b"ID3valid", "audio/wav"))

    async def test_enforces_size_limit(self):
        with patch.object(crud_card_audio, "MAX_CARD_AUDIO_BYTES", 4):
            with self.assertRaises(crud_card_audio.CardAudioValidationError):
                await crud_card_audio._read_and_validate_upload(FakeUpload(b"ID3too-large"))

    def test_data_uri_round_trip(self):
        payload = b"ID3pronunciation"
        data_uri = crud_card_audio.AUDIO_DATA_URI_PREFIX + base64.b64encode(payload).decode("ascii")
        self.assertEqual(crud_card_audio._decode_audio_data_uri(data_uri), payload)


if __name__ == "__main__":
    unittest.main()
