#!/usr/bin/env python3
"""Generate the shipped puzzle pack at game/data/pack.json.

The pack is the fixed local pack: 10 puzzles of 10x10, 170 of 15x15, and 20 of 20x20
(specs/design/entities/puzzle.md, placement and availability). Layout and entry fields
are fixed by specs/technical/contracts/pack.md (pack layout) and
specs/technical/schemata/puzzle-def.md (F1-F7); this script only decides content.

Content method (recorded in the pull request for #105): each puzzle is a deterministic
seeded silhouette grown from a seed cell nearest the center, with 180-degree rotational
symmetry so the board keeps a calm, readable shape. Clues are derived from the fills.
Picture ids are UUID version 7 per specs/assets/catalog.md, derived from a fixed epoch
and per-puzzle bytes so rerunning this script reproduces the pack byte for byte. No
picture files exist yet: they arrive with the Wave 3 asset pass (#98).

Usage: python3 .github/scripts/generate_pack.py [--check]
  --check  exit 1 when game/data/pack.json is not what this script would write
"""
from __future__ import annotations

import argparse
import hashlib
import json
import random
import sys
import uuid
from pathlib import Path

SIZES = [(10, 10), (15, 170), (20, 20)]
EPOCH_MS = 1_793_000_000_000  # fixed so asset ids are reproducible
GROWTH = {10: 0.42, 15: 0.55, 20: 0.55}
PACK = Path(__file__).resolve().parents[2] / "game" / "data" / "pack.json"
FIELDS = ("id", "size", "row-clues", "col-clues", "solution-fills", "picture-id", "pixel-picture-id")


def uuid7(seed: bytes) -> str:
    """RFC 9562 version 7 from the fixed epoch and deterministic bytes."""
    bits = hashlib.sha256(seed).digest()[:16]
    rand = int.from_bytes(bits, "big") & ((1 << 74) - 1)
    value = (EPOCH_MS & ((1 << 48) - 1)) << 80 | rand
    value = (value & ~(0xF << 76)) | (0x7 << 76)
    value = (value & ~(0x3 << 62)) | (0x2 << 62)
    return str(uuid.UUID(int=value))


def silhouette(size: int, rng: random.Random) -> set[tuple[int, int]]:
    """A symmetric blob grown from the center until the fill ratio is reached."""
    quarter = size // 2
    origin = (quarter - 1, quarter - 1)
    cells = {origin, (size - 1 - origin[0], size - 1 - origin[1])}
    target = max(4, int(size * size * GROWTH[size]))
    frontier = []
    for cell in list(cells):
        frontier.extend(neighbors(cell, size))
    while len(cells) < target and frontier:
        pick = rng.randrange(len(frontier))
        cell = frontier.pop(pick)
        frontier = [other for other in frontier if other != cell]
        if cell in cells:
            continue
        for twin in (cell, (size - 1 - cell[0], size - 1 - cell[1])):
            if twin not in cells:
                cells.add(twin)
                frontier.extend(neighbors(twin, size))
    return cells


def neighbors(cell: tuple[int, int], size: int) -> list[tuple[int, int]]:
    row, column = cell
    out = []
    for d_row, d_column in ((0, 1), (0, -1), (1, 0), (-1, 0)):
        r, c = row + d_row, column + d_column
        if 0 <= r < size and 0 <= c < size:
            out.append((r, c))
    return out


def runs(line: list[bool]) -> list[int]:
    out, length = [], 0
    for filled in line:
        if filled:
            length += 1
        elif length:
            out.append(length)
            length = 0
    if length:
        out.append(length)
    return out


def entry(index: int, size: int, rng: random.Random) -> dict:
    cells = silhouette(size, rng)
    grid = [[(row, column) in cells for column in range(size)] for row in range(size)]
    columns = [[grid[row][column] for row in range(size)] for column in range(size)]
    return {
        "id": f"pack-{index:03d}",
        "size": size,
        "row-clues": [runs(row) for row in grid],
        "col-clues": [runs(column) for column in columns],
        "solution-fills": sorted([row, column] for row, column in cells),
        "picture-id": uuid7(b"picture:" + index.to_bytes(4, "big") + b"\x01" * 6),
        "pixel-picture-id": uuid7(b"picture:" + index.to_bytes(4, "big") + b"\x02" * 6),
    }


def build() -> list[dict]:
    entries, index = [], 0
    for size, count in SIZES:
        for _ in range(count):
            rng = random.Random(f"pack-{index:03d}")
            entries.append(entry(index, size, rng))
            index += 1
    return entries


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    text = json.dumps(build(), separators=(",", ":"), ensure_ascii=False) + "\n"
    if args.check:
        current = PACK.read_text(encoding="utf-8") if PACK.exists() else ""
        if current != text:
            print(f"{PACK} is stale; run generate_pack.py", file=sys.stderr)
            return 1
        print(f"{PACK} is current")
        return 0
    PACK.parent.mkdir(parents=True, exist_ok=True)
    PACK.write_text(text, encoding="utf-8")
    print(f"wrote {PACK} ({len(json.loads(text))} entries)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
