import unittest

from app.conjugation_categories import CATEGORY_ORDER, GRAMMAR_CATEGORY_ORDER, category_for_infinitive, grammar_category_for_infinitive
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

    def test_reflexive_verbs_are_present_and_have_normalized_forms(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        by_infinitive = {verb["infinitive"]: verb for verb in verbs}
        expected = {
            "alzarsi", "lavarsi", "vestirsi", "svegliarsi", "chiamarsi",
            "divertirsi", "sentirsi", "sedersi", "addormentarsi", "pentirsi",
            "accorgersi", "iscriversi", "servirsi", "sbrigarsi", "trasferirsi",
        }
        self.assertTrue(expected.issubset(by_infinitive))
        self.assertGreaterEqual(sum(infinitive.endswith("si") for infinitive in by_infinitive), 35)

        alzarsi = by_infinitive["alzarsi"]
        presente = alzarsi["blocks"][("Indicativo", "Presente")]["forms"]
        self.assertEqual([form["form_text"] for form in presente[:3]], ["mi alzo", "ti alzi", "si alza"])
        self.assertEqual(alzarsi["blocks"][("Infinito", "Presente")]["forms"][0]["form_text"], "alzarsi")

        pentirsi = by_infinitive["pentirsi"]
        pentirsi_presente = pentirsi["blocks"][("Indicativo", "Presente")]["forms"]
        self.assertEqual(pentirsi_presente[0]["form_text"], "mi pento")
        self.assertNotIn("mi mi", " ".join(form["form_text"] for form in pentirsi_presente))

        accorgersi = by_infinitive["accorgersi"]
        accorgersi_passato = accorgersi["blocks"][("Indicativo", "Passato prossimo")]["forms"]
        self.assertEqual(accorgersi_passato[0]["form_text"], "mi sono accorto")
        self.assertEqual(accorgersi_passato[3]["form_text"], "ci siamo accorti")

    def test_frontend_categories_cover_base_and_reflexive_verbs(self):
        self.assertEqual(
            list(CATEGORY_ORDER),
            ["Auxiliaires", "Mouvement", "Communication", "Vie quotidienne", "Modaux", "Actions"],
        )
        expected = {
            "essere": "Auxiliaires",
            "andare": "Mouvement",
            "chiamare": "Communication",
            "alzarsi": "Vie quotidienne",
            "potere": "Modaux",
            "pentirsi": "Actions",
        }
        for infinitive, category in expected.items():
            self.assertEqual(category_for_infinitive(infinitive), category)

    def test_grammar_categories_classify_regular_and_irregular_verbs(self):
        self.assertEqual(
            list(GRAMMAR_CATEGORY_ORDER),
            [
                "Verbes en -are (réguliers)",
                "Verbes en -ire (réguliers)",
                "Verbes en -ere (réguliers)",
                "Verbes irréguliers",
            ],
        )
        expected = {
            "parlare": "Verbes en -are (réguliers)",
            "capire": "Verbes en -ire (réguliers)",
            "scrivere": "Verbes en -ere (réguliers)",
            "alzarsi": "Verbes en -are (réguliers)",
            "dormirsi": "Verbes en -ire (réguliers)",
            "essere": "Verbes irréguliers",
            "andare": "Verbes irréguliers",
            "pentirsi": "Verbes irréguliers",
        }
        for infinitive, category in expected.items():
            self.assertEqual(grammar_category_for_infinitive(infinitive), category)
