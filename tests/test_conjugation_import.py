import re
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

    def test_all_verbs_have_french_and_english_translations(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        self.assertEqual(len(verbs), 584)
        for verb in verbs:
            self.assertTrue(verb["translation_fr"].strip(), verb["infinitive"])
            self.assertTrue(verb["translation_en"].strip(), verb["infinitive"])

    def test_english_translations_use_infinitive_to(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        for verb in verbs:
            self.assertRegex(verb["translation_en"].strip().casefold(), r"^to\s+", verb["infinitive"])

    def test_uccidere_and_soccombere_have_six_personal_forms(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        by_infinitive = {verb["normalized_infinitive"]: verb for verb in verbs}
        uccidere = by_infinitive["uccidere"]
        self.assertEqual(len(uccidere["blocks"]), 21)
        self.assertEqual(
            [form["form_text"] for form in uccidere["blocks"][("Indicativo", "Presente")]["forms"]],
            ["uccido", "uccidi", "uccide", "uccidiamo", "uccidete", "uccidono"],
        )
        soccombere = by_infinitive["soccombere"]
        self.assertEqual(
            [form["form_text"] for form in soccombere["blocks"][("Indicativo", "Presente")]["forms"]],
            ["soccombo", "soccombi", "soccombe", "soccombiamo", "soccombete", "soccombono"],
        )

    def test_reflexive_forms_do_not_duplicate_the_reflexive_pronoun(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        duplicate = re.compile(r"\b(mi|ti|si|ci|vi)\s+\1\b", re.IGNORECASE)
        for verb in verbs:
            if not verb["normalized_infinitive"].endswith("si"):
                continue
            for block in verb["blocks"].values():
                for form in block["forms"]:
                    self.assertIsNone(duplicate.search(form["form_text"]), f"Double pronom : {verb['infinitive']} / {form['form_text']}")

        arrabbiarsi = next(verb for verb in verbs if verb["normalized_infinitive"] == "arrabbiarsi")
        imperative = [form["form_text"] for form in arrabbiarsi["blocks"][("Imperativo", "Presente")]["forms"]]
        self.assertEqual(imperative, ["-", "arrabbiati", "si arrabbi", "arrabbiamoci", "arrabbiatevi", "si arrabbino"])
        self.assertEqual(arrabbiarsi["blocks"][("Infinito", "Presente")]["forms"][0]["form_text"], "arrabbiarsi")
        self.assertEqual(arrabbiarsi["blocks"][("Gerundio", "Presente")]["forms"][0]["form_text"], "arrabbiandosi")

    def test_non_personal_modes_have_no_personal_labels(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        non_personal_moods = {"Infinito", "Participio", "Gerundio"}
        checked = 0
        for verb in verbs:
            for (mood, _tense), block in verb["blocks"].items():
                if mood not in non_personal_moods:
                    continue
                for form in block["forms"]:
                    checked += 1
                    self.assertIsNone(form["person_label"], f"Label inattendu : {verb['infinitive']} / {mood} / {form['form_text']}")
        self.assertEqual(checked, 3430)

    def test_image_irregular_verbs_are_complete_and_classified(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        by_infinitive = {verb["normalized_infinitive"]: verb for verb in verbs}
        expected = {
            "assolvere", "dedurre", "distendere", "eleggere", "emergere", "erigere",
            "escludere", "esplodere", "estendere", "estinguere", "fungere", "illudere",
            "immergere", "imprimere", "incidere", "indurre", "influenzare", "infrangere",
            "persuadere", "pretendere", "pungere", "resistere", "respingere", "scalfire",
            "scommettere", "sconfiggere", "scorgere", "sospendere", "tingere", "ungere",
        }
        self.assertTrue(expected.issubset(by_infinitive))
        for infinitive in expected:
            verb = by_infinitive[infinitive]
            self.assertEqual(grammar_category_for_infinitive(infinitive), "Verbes irréguliers")
            self.assertEqual(len(verb["blocks"]), 21)
            self.assertEqual(
                len(verb["blocks"][("Indicativo", "Presente")]["forms"]),
                6,
            )
            for (mood, _tense), block in verb["blocks"].items():
                if mood in {"Infinito", "Participio", "Gerundio"}:
                    self.assertTrue(all(form["person_label"] is None for form in block["forms"]))

    def test_markup_and_persons_are_normalized(self):
        self.assertEqual(clean_source_text("io [b]sono[|b]"), "io sono")
        forms = parse_person_forms("Indicativo", "io [b]sono[|b][br]lui/lei [b]è fermato/a[|b][br]")
        self.assertEqual(forms[0]["person_label"], "io")
        self.assertEqual(forms[0]["form_text"], "sono")
        self.assertEqual(forms[1]["person_label"], "lui/lei")
        self.assertEqual(forms[1]["form_text"], "è fermato/a")

    def test_reflexive_verbs_are_present_and_have_normalized_forms(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        by_infinitive = {verb["infinitive"]: verb for verb in verbs}
        expected = {
            "alzarsi", "lavarsi", "vestirsi", "svegliarsi", "chiamarsi",
            "divertirsi", "sentirsi", "sedersi", "addormentarsi", "pentirsi",
            "accorgersi", "addirsi", "iscriversi", "servirsi", "sbrigarsi", "trasferirsi",
        }
        self.assertTrue(expected.issubset(by_infinitive))
        self.assertEqual(sum(infinitive.endswith("si") for infinitive in by_infinitive), 36)
        self.assertNotIn("accorgere", by_infinitive)

        alzarsi = by_infinitive["alzarsi"]
        presente = alzarsi["blocks"][("Indicativo", "Presente")]["forms"]
        self.assertEqual([form["form_text"] for form in presente[:3]], ["mi alzo", "ti alzi", "si alza"])
        self.assertEqual(alzarsi["blocks"][("Infinito", "Presente")]["forms"][0]["form_text"], "alzarsi")

        pentirsi = by_infinitive["pentirsi"]
        pentirsi_presente = pentirsi["blocks"][("Indicativo", "Presente")]["forms"]
        self.assertEqual(pentirsi_presente[0]["form_text"], "mi pento")
        self.assertNotIn("mi mi", " ".join(form["form_text"] for form in pentirsi_presente))

        for infinitive in ("arrabbiarsi", "vergognarsi", "addirsi"):
            self.assertEqual(
                by_infinitive[infinitive]["blocks"][("Infinito", "Presente")]["forms"][0]["form_text"],
                infinitive,
            )
            presente_forms = by_infinitive[infinitive]["blocks"][("Indicativo", "Presente")]["forms"]
            self.assertNotIn("mi mi", " ".join(form["form_text"] for form in presente_forms))

        accorgersi = by_infinitive["accorgersi"]
        accorgersi_passato = accorgersi["blocks"][("Indicativo", "Passato prossimo")]["forms"]
        self.assertEqual(accorgersi_passato[0]["form_text"], "mi sono accorto/a")
        self.assertEqual(accorgersi_passato[3]["form_text"], "ci siamo accorti/e")

    def test_essere_participles_include_gender_and_number_variants(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        essere_auxiliaries = {
            "sono", "sei", "è", "siamo", "siete", "ero", "eri", "era", "eravamo", "eravate", "erano",
            "sarò", "sarai", "sarà", "saremo", "sarete", "saranno", "fui", "fosti", "fu", "fummo", "foste", "furono",
            "sia", "siano", "siate", "fossi", "fosse", "fossimo", "fossero", "sarei", "saresti", "sarebbe", "saremmo", "sareste", "sarebbero",
            "essere", "essendo",
        }
        checked = 0
        for verb in verbs:
            for (mood, tense), block in verb["blocks"].items():
                for form in block["forms"]:
                    tokens = form["form_text"].casefold().split()
                    if len(tokens) < 2 or not any(token in essere_auxiliaries for token in tokens[:-1]):
                        continue
                    checked += 1
                    person = str(form["person_label"] or "").casefold()
                    participle = tokens[-1]
                    self.assertIn("/", participle, f"Genre absent : {verb['infinitive']} / {mood} / {tense} / {form['form_text']}")
                    if person.endswith(("noi", "voi", "loro")):
                        self.assertTrue(participle.endswith("/e"), f"Nombre absent : {form['form_text']}")
                    else:
                        self.assertTrue(participle.endswith("/a"), f"Genre absent : {form['form_text']}")
        self.assertGreater(checked, 1000)

    def test_essere_participles_agree_for_plural_persons(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        essere_auxiliaries = {
            "sono", "sei", "è", "siamo", "siete", "ero", "eri", "era", "eravamo", "eravate", "erano",
            "sarò", "sarai", "sarà", "saremo", "sarete", "saranno", "fui", "fosti", "fu", "fummo", "foste", "furono",
            "sia", "siano", "siate", "fossi", "fosse", "fossimo", "fossero", "sarei", "saresti", "sarebbe", "saremmo", "sareste", "sarebbero",
        }
        compound_tenses = {"Passato prossimo", "Trapassato prossimo", "Futuro anteriore", "Trapassato remoto", "Passato", "Trapassato"}
        for verb in verbs:
            for (mood, tense), block in verb["blocks"].items():
                if tense not in compound_tenses:
                    continue
                for form in block["forms"]:
                    if not form["person_label"]:
                        continue
                    person = str(form["person_label"]).casefold().split()[-1]
                    if person not in {"noi", "voi", "loro"}:
                        continue
                    clean_tokens = form["form_text"].casefold().split()
                    if not any(token in essere_auxiliaries for token in clean_tokens):
                        continue
                    alternatives = form["form_text"].split()[-1].casefold().split("/")
                    self.assertTrue(
                        any(alternative.endswith("i") for alternative in alternatives),
                        f"Participe non accordé : {verb['infinitive']} / {mood} / {tense} / {form['form_text']}",
                    )

    def test_non_reflexive_entries_do_not_expose_reflexive_infinitives(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        suspicious = []
        for verb in verbs:
            infinitive = verb["infinitive"]
            if infinitive.endswith("si"):
                continue
            block = verb["blocks"].get(("Infinito", "Presente"))
            if block and any(form["form_text"].endswith("si") for form in block["forms"]):
                suspicious.append((infinitive, [form["form_text"] for form in block["forms"]]))
        self.assertEqual(suspicious, [])

    def test_all_reflexive_verbs_have_a_thematic_frontend_category(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        expected_counts = {
            "Auxiliaires": 0,
            "Mouvement": 2,
            "Communication": 1,
            "Vie quotidienne": 13,
            "Modaux": 0,
            "Actions": 20,
        }
        actual_counts = {category: 0 for category in CATEGORY_ORDER}
        for verb in verbs:
            if verb["infinitive"].endswith("si"):
                category = category_for_infinitive(verb["infinitive"])
                self.assertIn(category, CATEGORY_ORDER)
                actual_counts[category] += 1
        self.assertEqual(actual_counts, expected_counts)

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

    def test_all_reflexive_verbs_have_a_grammar_category(self):
        verbs, _, _ = parse_source_dataset(CORPUS_PATH)
        reflexive_verbs = [verb["infinitive"] for verb in verbs if verb["infinitive"].endswith("rsi")]
        self.assertEqual(len(reflexive_verbs), 36)
        self.assertTrue(all(grammar_category_for_infinitive(verb) == "Verbes réfléchis" for verb in reflexive_verbs))

    def test_grammar_categories_classify_regular_and_irregular_verbs(self):
        self.assertEqual(
            list(GRAMMAR_CATEGORY_ORDER),
            [
                "Verbes en -are (réguliers)",
                "Verbes en -ire (réguliers)",
                "Verbes en -ere (réguliers)",
                "Verbes irréguliers",
                "Verbes réfléchis",
            ],
        )
        expected = {
            "parlare": "Verbes en -are (réguliers)",
            "capire": "Verbes en -ire (réguliers)",
            "scrivere": "Verbes irréguliers",
            "alzarsi": "Verbes réfléchis",
            "dormirsi": "Verbes réfléchis",
            "essere": "Verbes irréguliers",
            "andare": "Verbes irréguliers",
            "pentirsi": "Verbes réfléchis",
        }
        for infinitive, category in expected.items():
            self.assertEqual(grammar_category_for_infinitive(infinitive), category)
