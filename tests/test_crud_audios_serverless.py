import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from app import crud_audios


class ServerlessAudioStorageTests(unittest.TestCase):
    def test_encode_and_decode_audio_data_uri(self):
        payload = b"ID3test-mp3"
        encoded = crud_audios._encode_audio_data(payload)
        self.assertTrue(encoded.startswith(crud_audios.AUDIO_DATA_URI_PREFIX))
        self.assertEqual(crud_audios._decode_audio_data(encoded), payload)

    def test_generate_tts_uses_tmp_and_cleans_file(self):
        payload = b"ID3generated-mp3"
        saved_paths: list[str] = []

        def fake_save(path: str) -> None:
            saved_paths.append(path)
            Path(path).write_bytes(payload)

        with patch.object(crud_audios, "gTTS") as tts_factory:
            tts_factory.return_value.save.side_effect = fake_save
            generated = crud_audios._generate_tts_bytes("Ciao", "it")

        self.assertEqual(generated, payload)
        self.assertEqual(len(saved_paths), 1)
        self.assertTrue(saved_paths[0].startswith("/tmp/apprendiamo-"))
        self.assertFalse(Path(saved_paths[0]).exists())
        tts_factory.assert_called_once_with("Ciao", lang="it")

    def test_invalid_audio_data_uri_is_rejected(self):
        with self.assertRaises(ValueError):
            crud_audios._decode_audio_data("data:audio/wav;base64,AAAA")


class PersistedAudioReadTests(unittest.IsolatedAsyncioTestCase):
    async def test_get_audio_bytes_reads_persisted_mp3(self):
        payload = b"ID3stored-mp3"
        item = SimpleNamespace(
            id=42,
            filename="42.mp3",
            audio_data=crud_audios._encode_audio_data(payload),
        )

        class FakeResult:
            def scalar_one_or_none(self):
                return item

        class FakeSession:
            async def execute(self, _statement):
                return FakeResult()

        result = await crud_audios.get_audio_bytes(FakeSession(), 42)
        self.assertEqual(result, (payload, "audio/mpeg"))


if __name__ == "__main__":
    unittest.main()
