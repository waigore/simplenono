#!/usr/bin/env python3
"""Epic #294 closing audit: read the shipped pack on `main` and print the four pack-wide checks.

Run from the repo root:

    python3 docs/playtest/evidence/issue-294/2026-11-04-closing-audit/tools/pack_audit.py

Exits non-zero when any delivered picture breaks the kind spec. Read-only.
"""

from __future__ import annotations

import collections
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "..", ".."))
PACK = os.path.join(ROOT, "game", "data", "pack.json")
MANIFEST = os.path.join(ROOT, "assets", "manifest.json")
CATALOG = os.path.join(ROOT, "assets", "catalog")
KIND = "AK-puzzle-pictures"
RECIPE = "AK-puzzle-pictures.R1"

# Kind spec S2/K2: 25-45 of 100, 25-45% of 225, 25-45% of 400.
FILL_BAND = {10: (25, 45), 15: (56, 101), 20: (100, 180)}


def runs(values: list[bool]) -> list[int]:
    out, cur = [], 0
    for v in values:
        if v:
            cur += 1
        elif cur:
            out.append(cur)
            cur = 0
    if cur:
        out.append(cur)
    return out


def load(path: str) -> dict:
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def main() -> int:
    rows = [r for r in load(PACK) if str(r.get("id", "")).startswith("pack-")]
    manifest = load(MANIFEST)
    problems: list[str] = []
    band: dict[int, collections.Counter] = collections.defaultdict(collections.Counter)
    fills: dict[int, list[int]] = collections.defaultdict(list)
    classes: dict[int, collections.Counter] = collections.defaultdict(collections.Counter)

    for row in rows:
        pid, size = row["id"], row["size"]
        picture, pixel = row["picture-id"], row["pixel-picture-id"]
        band[size]["pairs"] += 1
        if picture == pixel:
            problems.append(f"{pid}: picture-id equals pixel-picture-id (I5)")

        for role, asset_id in (("square", picture), ("pixel", pixel)):
            entry_path = os.path.join(CATALOG, f"{asset_id}.json")
            if not os.path.exists(entry_path):
                problems.append(f"{pid}: no catalog entry for {role} {asset_id}")
                continue
            entry = load(entry_path)
            review = entry.get("review") or {}
            generation = entry.get("generation") or {}
            settings = generation.get("settings") or {}
            if entry.get("kind_spec") != KIND:
                problems.append(f"{pid}: {role} kind_spec {entry.get('kind_spec')!r}")
            if entry.get("recipe") != RECIPE:
                problems.append(f"{pid}: {role} recipe {entry.get('recipe')!r}")
            if entry.get("state") != "approved":
                problems.append(f"{pid}: {role} state {entry.get('state')!r}")
            if review.get("verdict") != "Pass":
                problems.append(f"{pid}: {role} review verdict {review.get('verdict')!r}")
            paths = manifest.get(asset_id)
            if paths is None:
                problems.append(f"{pid}: {role} {asset_id} missing from assets/manifest.json")
            else:
                for rel in [paths] if isinstance(paths, str) else paths:
                    if not rel.startswith("res://") or not os.path.exists(
                        os.path.join(ROOT, "game", rel[len("res://"):])
                    ):
                        problems.append(f"{pid}: {role} manifest path {rel!r} does not resolve")
                    band[size]["files"] += 1
            if role == "square":
                band[size]["square_ok"] += 1
                classes[size][settings.get("subject_class") or "unlabelled"] += 1
                if review.get("verdict") == "Pass":
                    band[size]["square_pass"] += 1
            else:
                band[size]["pixel_ok"] += 1

        grid = {tuple(cell) for cell in row["solution-fills"]}
        count = len(grid)
        fills[size].append(count)
        lo, hi = FILL_BAND[size]
        if not lo <= count <= hi:
            problems.append(f"{pid}: {count} fills outside {lo}-{hi}")
        row_clues = [runs([(i, j) in grid for j in range(size)]) for i in range(size)]
        col_clues = [runs([(i, j) in grid for i in range(size)]) for j in range(size)]
        if row_clues != row["row-clues"]:
            problems.append(f"{pid}: row-clues are not the run lengths of solution-fills")
        if col_clues != row["col-clues"]:
            problems.append(f"{pid}: col-clues are not the run lengths of solution-fills")

    total = collections.Counter()
    print(f"puzzles: {len(rows)}")
    print("| Size | Puzzles | Approved pairs | Pass on both | Resolving manifest ids | Files | Fill range | single / multi / unlabelled |")
    print("|---|---|---|---|---|---|---|---|")
    for size in sorted(band):
        b = band[size]
        total.update(b)
        f = fills[size]
        cls = classes[size]
        print(
            f"| {size}x{size} | {b['pairs']} | {b['square_ok']}/{b['pairs']} | "
            f"{b['square_pass'] + b['pixel_ok']}/{b['pairs'] * 2} | {b['pairs'] + b['pixel_ok']}/{b['pairs'] * 2} | "
            f"{b['files']} | {min(f)}-{max(f)} | {cls['single-subject']} / "
            f"{cls['multi-subject and/or holed']} / {cls['unlabelled']} |"
        )
    print(
        f"| all | {total['pairs']} | {total['square_ok']}/{total['pairs']} | "
        f"{total['square_pass'] + total['pixel_ok']}/{total['pairs'] * 2} | "
        f"{total['pairs'] + total['pixel_ok']}/{total['pairs'] * 2} | {total['files']} | - | - |"
    )

    if problems:
        print(f"\n{len(problems)} problem(s):")
        for problem in problems:
            print(f"  - {problem}")
        return 1

    print("\n0 problem(s): every delivered pair is approved, in band, and clue-consistent.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
