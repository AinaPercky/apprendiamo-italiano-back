import unittest

from app.conjugation_corpus import CORPUS_PATH, clean_source_text, parse_person_forms, parse_source_dataset


class ConjugationCorpusTests(unittest.TestCase):
    def test_source_corpus_has_expected_coverage(self):
        verbs, checksum, skipped = parse_source_dataset(CORPUS_PATH)
        self.assertGreaterEqual(len(verbs), 500)
        self.assertEqual(len(checksum), 64)
        self.assertGreater(skipped, 0)  # Entrées incomplètes volontairement écartées.
        essere = next(verb for verb in verbs if verb["normalized_infinitive"] == "essere")
        self.assertEqual(len(essere["blocks"]), 21)

    def test_markup_and_persons_are_normalized(self):
        self.assertEqual(clean_source_text("io [b]sono[|b]"), "io sono")
        forms = parse_person_forms("Indicativo", "io [b]sono[|b][br]tu [b]sei[|b][br]")
        self.assertEqual(forms[0]["person_label"], "io")
        self.assertEqual(forms[0]["form_text"], "sono")
        self.assertEqual(forms[1]["person_label"], "tu")
        self.assertEqual(forms[1]["form_text"], "sei")
