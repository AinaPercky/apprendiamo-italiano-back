"""Generate Italian MP3 pronunciations from cards.back and store them in Neon."""

from __future__ import annotations

import argparse
import asyncio
import base64
import json
import os
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable

import asyncpg
from gtts import gTTS

AUDIO_PREFIX = "data:audio/mpeg;base64,"
DEFAULT_CONCURRENCY = 4
DEFAULT_RETRIES = 3


@dataclass(frozen=True)
class WordGroup:
    normalized: str
    text: str
    card_pks: tuple[int, ...]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=0, help="Maximum cards to process; 0 means all")
    parser.add_argument("--concurrency", type=int, default=DEFAULT_CONCURRENCY)
    parser.add_argument("--retries", type=int, default=DEFAULT_RETRIES)
    parser.add_argument("--delay", type=float, default=0.15, help="Delay between retries in seconds")
    parser.add_argument("--report", type=Path, default=Path("pronunciation_generation_report.json"))
    return parser.parse_args()


def group_cards(rows: Iterable[asyncpg.Record], limit: int) -> list[WordGroup]:
    grouped: dict[str, tuple[str, list[int]]] = {}
    seen_cards = 0
    for row in rows:
        if limit and seen_cards >= limit:
            break
        text = str(row["back"]).strip()
        if not text:
            continue
        seen_cards += 1
        normalized = text.casefold()
        if normalized not in grouped:
            grouped[normalized] = (text, [])
        grouped[normalized][1].append(int(row["card_pk"]))
    return [
        WordGroup(normalized=key, text=value[0], card_pks=tuple(value[1]))
        for key, value in grouped.items()
    ]


def generate_mp3(group: WordGroup, retries: int, delay: float, directory: Path) -> tuple[WordGroup, bytes]:
    last_error: Exception | None = None
    for attempt in range(1, retries + 1):
        path = directory / f"{abs(hash(group.normalized))}_{attempt}.mp3"
        try:
            gTTS(text=group.text, lang="it", slow=False).save(str(path))
            payload = path.read_bytes()
            if len(payload) < 100 or payload[:2] != b"\xff\xff" and payload[0] != 0xFF:
                raise ValueError("TTS did not produce a valid MP3-like payload")
            return group, payload
        except Exception as exc:  # gTTS raises several network-specific exception types
            last_error = exc
            if attempt < retries:
                time.sleep(delay * attempt)
    assert last_error is not None
    raise last_error


async def fetch_pending_cards(conn: asyncpg.Connection) -> list[asyncpg.Record]:
    return await conn.fetch(
        """
        SELECT c.card_pk, c.back
        FROM public.cards AS c
        LEFT JOIN public.card_audio AS ca ON ca.card_pk = c.card_pk
        WHERE ca.card_pk IS NULL
          AND NULLIF(BTRIM(c.back), '') IS NOT NULL
        ORDER BY c.card_pk
        """
    )


async def insert_group(
    conn: asyncpg.Connection,
    group: WordGroup,
    payload: bytes,
) -> int:
    data_uri = AUDIO_PREFIX + base64.b64encode(payload).decode("ascii")
    now = datetime.now(timezone.utc)
    rows = [
        (
            card_pk,
            f"pronunciation_{card_pk}.mp3",
            "audio/mpeg",
            len(payload),
            data_uri,
            now,
            now,
        )
        for card_pk in group.card_pks
    ]
    await conn.executemany(
        """
        INSERT INTO public.card_audio
            (card_pk, filename, content_type, size_bytes, audio_data, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        ON CONFLICT (card_pk) DO NOTHING
        """,
        rows,
    )
    return len(rows)


async def main() -> None:
    args = parse_args()
    if args.concurrency < 1 or args.concurrency > 8:
        raise SystemExit("--concurrency doit être compris entre 1 et 8")
    database_url = os.environ.get("DATABASE_URL")
    if not database_url:
        raise SystemExit("DATABASE_URL est obligatoire")

    conn = await asyncpg.connect(database_url)
    try:
        pending_rows = await fetch_pending_cards(conn)
        groups = group_cards(pending_rows, args.limit)
        report: dict[str, object] = {
            "language": "it",
            "source_field": "cards.back",
            "pending_cards": sum(len(group.card_pks) for group in groups),
            "unique_words": len(groups),
            "concurrency": args.concurrency,
            "generated_groups": 0,
            "inserted_cards": 0,
            "failed_groups": [],
        }
        print(json.dumps({k: report[k] for k in ("pending_cards", "unique_words", "concurrency")}, ensure_ascii=False))
        if not groups:
            args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
            return

        with tempfile.TemporaryDirectory(prefix="card-pronunciations-") as tmp:
            directory = Path(tmp)
            loop = asyncio.get_running_loop()
            with ThreadPoolExecutor(max_workers=args.concurrency) as executor:
                futures = [
                    loop.run_in_executor(
                        executor,
                        generate_mp3,
                        group,
                        args.retries,
                        args.delay,
                        directory,
                    )
                    for group in groups
                ]
                for index, future in enumerate(asyncio.as_completed(futures), start=1):
                    try:
                        group, payload = await future
                        inserted = await insert_group(conn, group, payload)
                        report["generated_groups"] = int(report["generated_groups"]) + 1
                        report["inserted_cards"] = int(report["inserted_cards"]) + inserted
                        print(
                            f"[{index}/{len(futures)}] {group.text!r}: "
                            f"{len(group.card_pks)} carte(s), {len(payload)} octets"
                        )
                    except Exception as exc:
                        failed_groups = report["failed_groups"]
                        assert isinstance(failed_groups, list)
                        failed_groups.append({"error": repr(exc), "index": index})
                        print(f"[{index}/{len(futures)}] ECHEC: {exc}")

        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        print(json.dumps(report, ensure_ascii=False))
    finally:
        await conn.close()


if __name__ == "__main__":
    asyncio.run(main())
