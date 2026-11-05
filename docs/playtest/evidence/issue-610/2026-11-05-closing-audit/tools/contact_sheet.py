#!/usr/bin/env python3
"""Issue #610: build the K5 review's per-band thumbnail contact sheets.

    python3 .../tools/contact_sheet.py --out-dir tmp/issue-610/sheets [--root .]

Writes one sheet per size band (`contact-10x10.png`, `contact-15x15.png`,
`contact-20x20.png`) and one for the groups this review resolved
(`contact-resolved.png`): every committed square at thumbnail size with its pack id
and catalog version drawn on the tile, plus the N x N pixel picture under it, so a
reviewer can see the whole pack and the replaced pairs without opening 400 files.

Media belongs on the wiki (docs/playtest/wiki-evidence.md); this script only writes
working files.
"""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path

from PIL import Image, ImageDraw

SQUARE = 120
PIXEL = 60
LABEL = 18
COLUMNS = 10


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def tile(puzzle: str, version: int, square: Path, pixel: Path) -> Image.Image:
    cell = Image.new("RGB", (SQUARE, SQUARE + LABEL + PIXEL + 4), "white")
    with Image.open(square) as image:
        cell.paste(image.convert("RGB").resize((SQUARE, SQUARE), Image.BOX), (0, 0))
    with Image.open(pixel) as image:
        small = image.convert("RGB")
        scale = max(1, PIXEL // max(1, small.width))
        small = small.resize((small.width * scale, small.height * scale), Image.NEAREST)
        cell.paste(small, (0, SQUARE + LABEL + 4))
    draw = ImageDraw.Draw(cell)
    draw.text((2, SQUARE + 2), f"{puzzle} v{version}", fill="black")
    return cell


def sheet(puzzles: list[str], root: Path, versions: dict[str, int],
          columns: int = COLUMNS) -> Image.Image:
    cells = [tile(puzzle, versions[puzzle],
                  root / "game" / "assets" / "puzzle-pictures" / f"{puzzle}-generated.png",
                  root / "game" / "assets" / "puzzle-pictures" / f"{puzzle}-pixel.png")
             for puzzle in puzzles]
    width, height = (SQUARE, SQUARE + LABEL + PIXEL + 4)
    rows = (len(cells) + columns - 1) // columns
    out = Image.new("RGB", (columns * width, rows * height), "white")
    for index, cell in enumerate(cells):
        out.paste(cell, ((index % columns) * width, (index // columns) * height))
    return out


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--out-dir", required=True, type=Path)
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--resolved", nargs="*", default=[],
                        help="pack ids this review replaced (for the resolved sheet)")
    args = parser.parse_args(argv)
    root = args.root.resolve()
    args.out_dir.mkdir(parents=True, exist_ok=True)
    rows = load(root / "game" / "data" / "pack.json")
    versions = {row["id"]: load(root / "assets" / "catalog" / f"{row['picture-id']}.json")["version"]
                for row in rows}
    bands: dict[int, list[str]] = {}
    for row in rows:
        bands.setdefault(row["size"], []).append(row["id"])
    written = []
    for size in sorted(bands):
        path = args.out_dir / f"contact-{size}x{size}.png"
        sheet(sorted(bands[size]), root, versions).save(path)
        written.append(path)
    if args.resolved:
        path = args.out_dir / "contact-resolved.png"
        sheet(sorted(args.resolved), root, versions, columns=6).save(path)
        written.append(path)
    for path in written:
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
