"""Lecture et normalisation du corpus local MIT de conjugaisons italiennes."""

from __future__ import annotations

import hashlib
import json
import re
import unicodedata
from collections import OrderedDict
from pathlib import Path
from typing import Any

SOURCE_NAME = "leandrobhbr/coniugazione"
SOURCE_URL = "https://github.com/leandrobhbr/coniugazione"
SOURCE_LICENSE = "MIT"
CORPUS_PATH = Path(__file__).resolve().parents[1] / "data" / "coniugazione" / "verbi.json"

MOOD_ORDER = {
    "Indicativo": 1,
    "Congiuntivo": 2,
    "Condizionale": 3,
    "Imperativo": 4,
    "Infinito": 5,
    "Participio": 6,
    "Gerundio": 7,
}
TENSE_ORDER = {
    "Presente": 1,
    "Imperfetto": 2,
    "Passato prossimo": 3,
    "Passato remoto": 4,
    "Trapassato prossimo": 5,
    "Trapassato remoto": 6,
    "Futuro semplice": 7,
    "Futuro anteriore": 8,
    "Passato": 9,
    "Trapassato": 10,
}
_MARKUP_RE = re.compile(r"\[(?:\|?b|br)\]")
_SPACES_RE = re.compile(r"\s+")
_PERSON_PREFIXES = (
    ("che io ", "che io"), ("che tu ", "che tu"), ("che lui/lei ", "che lui/lei"),
    ("che lui ", "che lui"), ("che lei ", "che lei"), ("che noi ", "che noi"), ("che voi ", "che voi"),
    ("che loro ", "che loro"), ("io ", "io"), ("tu ", "tu"),
    ("lui/lei ", "lui/lei"), ("lui ", "lui"), ("lei ", "lei"), ("noi ", "noi"),
    ("voi ", "voi"), ("loro ", "loro"),
)
_FALLBACK_PERSONS = ("io", "tu", "lui/lei", "noi", "voi", "loro")
_IMPERATIVE_PERSONS = (None, "tu", "Lei", "noi", "voi", "loro")


def normalize_infinitive(value: str) -> str:
    return unicodedata.normalize("NFKC", value).strip().casefold()


def clean_source_text(value: Any) -> str:
    if not value:
        return ""
    cleaned = _MARKUP_RE.sub("", str(value).replace("\\/", "/"))
    return _SPACES_RE.sub(" ", cleaned).strip()


def parse_person_forms(mood: str, raw_italian: str) -> list[dict[str, Any]]:
    forms: list[dict[str, Any]] = []
    for index, raw_line in enumerate(str(raw_italian).split("[br]")):
        line = clean_source_text(raw_line)
        if not line:
            continue
        label = None
        form_text = line
        if mood == "Imperativo":
            label = _IMPERATIVE_PERSONS[index] if index < len(_IMPERATIVE_PERSONS) else None
        else:
            lower_line = line.casefold()
            for prefix, candidate_label in _PERSON_PREFIXES:
                if lower_line.startswith(prefix):
                    label = candidate_label
                    form_text = line[len(prefix):].strip()
                    break
            if label is None and index < len(_FALLBACK_PERSONS):
                label = _FALLBACK_PERSONS[index]
        forms.append({"person_order": index, "person_label": label, "form_text": form_text or line, "raw_line": raw_line})
    return forms


def parse_source_dataset(source_path: Path = CORPUS_PATH) -> tuple[list[dict[str, Any]], str, int]:
    payload_bytes = source_path.read_bytes()
    checksum = hashlib.sha256(payload_bytes).hexdigest()
    source = json.loads(payload_bytes)
    verbs: OrderedDict[str, dict[str, Any]] = OrderedDict()
    skipped = 0
    for raw_verb in source:
        infinitive = clean_source_text(raw_verb.get("verbi"))
        if not infinitive:
            skipped += 1
            continue
        normalized = normalize_infinitive(infinitive)
        verb = verbs.setdefault(normalized, {
            "infinitive": infinitive,
            "normalized_infinitive": normalized,
            "source_record_id": str(raw_verb.get("id")) if raw_verb.get("id") else None,
            "blocks": OrderedDict(),
        })
        for raw_block in raw_verb.get("coniugazione") or []:
            mood = clean_source_text(raw_block.get("modalita_verbale"))
            tense = clean_source_text(raw_block.get("tempo_verbale"))
            raw_italian = str(raw_block.get("italiano") or "")
            if not mood or not tense or not clean_source_text(raw_italian):
                skipped += 1
                continue
            key = (mood, tense)
            block = {
                "mood": mood, "tense": tense,
                "mood_order": MOOD_ORDER.get(mood, 99),
                "tense_order": TENSE_ORDER.get(tense, 99),
                "source_conjugation_id": str(raw_block.get("id")) if raw_block.get("id") else None,
                "raw_italian": raw_italian,
                "raw_portuguese": raw_block.get("portoghese") or None,
                "is_featured": bool(raw_block.get("chk")),
                "forms": parse_person_forms(mood, raw_italian),
            }
            existing = verb["blocks"].get(key)
            if existing is None or len(block["forms"]) > len(existing["forms"]):
                verb["blocks"][key] = block
    return list(verbs.values()), checksum, skipped
