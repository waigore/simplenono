#!/usr/bin/env python3
"""Generate the shipped puzzle pack at game/data/pack.json.

The pack is the fixed local pack: 10 puzzles of 10x10, 170 of 15x15, and 20 of 20x20
(specs/design/entities/puzzle.md, placement and availability). Layout and entry fields
are fixed by specs/technical/contracts/pack.md (pack layout) and
specs/technical/schemata/puzzle-def.md (F1-F9); this script only decides content.
Content of F8 (single-line) and F9 (one-level) fill-hint cells follows
specs/design/features/fill-hints.md R1-R2: the union of each line's own forcings,
then one propagation pass with those marks known.

Content method (recorded in the pull request for #105): a puzzle whose pixel picture is
approved and catalogued derives its fills from that pixel file, which is the source
specs/design/entities/puzzle.md P2 and specs/assets/kinds/puzzle-pictures.md S3
already require. Every other puzzle is a deterministic seeded silhouette grown from a
seed cell nearest the center, with 180-degree rotational symmetry so the board keeps a
calm, readable shape. Clues are derived from the fills. Picture ids are UUID version 7
per specs/assets/catalog.md, derived from a fixed epoch and per-puzzle bytes so
rerunning this script reproduces the pack byte for byte.

Pixel lookup (a rule local to this offline authoring script; it is not CMP-pack and
does not change CTR-pack O8, which still reads only res://data/pack.json):

  - Key: the row's pixel-picture-id (puzzle-def.md F7).
  - Entry: <repo>/assets/catalog/<pixel-picture-id>.json (ADR-0003 catalog root).
  - Eligible only when the entry's state is "approved" (catalog.md F5, I5). A missing
    entry, or a state that is absent, "draft", or "deprecated", means the seeded
    silhouette for that row, not an error.
  - The entry's files list must hold exactly one path, relative to the asset root
    game/assets/ (ADR-0003). Read <repo>/game/assets/<files[0]>.
  - That file is a non-interlaced 8-bit RGB or RGBA PNG. Alpha is composited over
    white (C = a*C + (1-a)*255) before luma. The image is exactly size x size, one
    colour per board cell (S1, S6). Row 0 is the top row, column 0 the left column.
  - A cell is filled when relative luma Y = 0.2126R + 0.7152G + 0.0722B on the 0-255
    sRGB channel values (no gamma linearization) is below 128. No other threshold, no
    hole-close, no per-image tuning.
  - An approved entry that is broken (zero or more than one file, an unreadable entry,
    a missing or unreadable file, a non-PNG, or an image that is not exactly size x
    size) exits non-zero naming the pixel-picture-id and the path. It never falls back
    to a seeded row, so a bad asset cannot ship silently.
  - K3/S4 unique line-logic is judged inside the picture-slice tasks. This script adds
    no solver; it only copies a pixel those tasks already accepted.

The shipped file is one compact JSON object per puzzle on one line, so a picture
slice can rewrite only its own rows (see --puzzle) and two slices that touch
different rows land in any order. Parsed content and entry order are the same as
the older one-line serialization; only whitespace differs.

Usage: python3 .github/scripts/generate_pack.py [--check | --puzzle PACK-ID ...] [--root DIR]
  --check       exit 1 when game/data/pack.json is not what this script would write
  --puzzle ID   rewrite only the named puzzle rows from their approved pixels
                (repeatable); write nothing and exit 1 when a row cannot be derived
  --root DIR    repository root (default: this checkout)
"""
from __future__ import annotations

import argparse
import hashlib
import json
import random
import sys
import uuid
import zlib
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
SIZES = [(10, 10), (15, 170), (20, 20)]
EPOCH_MS = 1_793_000_000_000  # fixed so asset ids are reproducible
GROWTH = {10: 0.42, 15: 0.55, 20: 0.55}
PACK_REL = Path("game") / "data" / "pack.json"
PACK = REPO_ROOT / PACK_REL
# ADR-0003: catalog entries at the repo root; cataloged files under the Godot project.
CATALOG_ROOT = Path("assets") / "catalog"
ASSET_ROOT = Path("game") / "assets"
PIXEL_APPROVED = "approved"
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
PNG_CHANNELS = {2: 3, 6: 4}  # colour type -> channels; the rule accepts RGB and RGBA only
FILL_LUMA = 128.0

FIELDS = (
    "id", "size", "row-clues", "col-clues", "solution-fills", "picture-id",
    "pixel-picture-id", "single-fill-hint-cells", "multi-fill-hint-cells",
)

# ADR-0003: catalog entries at the repo root; cataloged files under the Godot project.
CATALOG_ROOT = Path("assets") / "catalog"
ASSET_ROOT = Path("game") / "assets"
PIXEL_APPROVED = "approved"
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
PNG_CHANNELS = {2: 3, 6: 4}  # colour type -> channels; the rule accepts RGB and RGBA only
FILL_LUMA = 128.0


class PixelError(Exception):
    """An approved pixel file cannot be read by the fixed rule."""


def uuid7(seed: bytes) -> str:
    """RFC 9562 version 7 from the fixed epoch and deterministic bytes."""
    bits = hashlib.sha256(seed).digest()[:16]
    rand = int.from_bytes(bits, "big") & ((1 << 74) - 1)
    value = (EPOCH_MS & ((1 << 48) - 1)) << 80 | rand
    value = (value & ~(0xF << 76)) | (0x7 << 76)
    value = (value & ~(0x3 << 62)) | (0x2 << 62)
    return str(uuid.UUID(int=value))


def picture_ids(index: int) -> tuple[str, str]:
    """The generated-square and pixel picture ids for a pack row."""
    return (
        uuid7(b"picture:" + index.to_bytes(4, "big") + b"\x01" * 6),
        uuid7(b"picture:" + index.to_bytes(4, "big") + b"\x02" * 6),
    )


def read_png(path: Path) -> list[list[tuple[int, int, int, int]]]:
    """Rows of RGBA pixels from a non-interlaced 8-bit RGB or RGBA PNG."""
    try:
        data = path.read_bytes()
    except OSError as exc:
        raise PixelError(f"cannot read the file ({exc.strerror})") from exc
    if not data.startswith(PNG_SIGNATURE):
        raise PixelError("not a PNG")
    header: tuple[int, int, int, int, int] | None = None
    payloads = bytearray()
    offset = len(PNG_SIGNATURE)
    while offset + 8 <= len(data):
        length = int.from_bytes(data[offset:offset + 4], "big")
        kind = data[offset + 4:offset + 8]
        start, end = offset + 8, offset + 8 + length
        if end + 4 > len(data):
            raise PixelError("truncated PNG chunk")
        chunk = data[start:end]
        offset = end + 4
        if kind == b"IHDR":
            if len(chunk) != 13:
                raise PixelError("malformed PNG header")
            header = (int.from_bytes(chunk[0:4], "big"), int.from_bytes(chunk[4:8], "big"),
                      chunk[8], chunk[9], chunk[12])
        elif kind == b"IDAT":
            payloads += chunk
        elif kind == b"IEND":
            break
    if header is None:
        raise PixelError("no PNG header")
    width, height, depth, colour, interlace = header
    if depth != 8:
        raise PixelError(f"bit depth {depth} is not 8")
    if colour not in PNG_CHANNELS:
        raise PixelError(f"colour type {colour} is not RGB or RGBA")
    if interlace != 0:
        raise PixelError("interlaced PNG")
    if width == 0 or height == 0:
        raise PixelError(f"empty image {width}x{height}")
    try:
        raw = zlib.decompress(bytes(payloads))
    except zlib.error as exc:
        raise PixelError(f"corrupt PNG data ({exc})") from exc
    channels = PNG_CHANNELS[colour]
    stride = width * channels
    if len(raw) != height * (stride + 1):
        raise PixelError(f"bad PNG byte count for {width}x{height}")
    rows: list[list[tuple[int, int, int, int]]] = []
    prior = bytearray(stride)
    for row in range(height):
        base = row * (stride + 1)
        method = raw[base]
        line = bytearray(raw[base + 1:base + 1 + stride])
        unfilter(method, line, prior, channels)
        pixels = []
        for column in range(width):
            cell = line[column * channels:(column + 1) * channels]
            alpha = cell[3] if channels == 4 else 255
            pixels.append((cell[0], cell[1], cell[2], alpha))
        rows.append(pixels)
        prior = line
    return rows


def unfilter(method: int, line: bytearray, prior: bytearray, channels: int) -> None:
    """Reverse one PNG scanline filter in place."""
    for i in range(len(line)):
        left = line[i - channels] if i >= channels else 0
        up = prior[i]
        up_left = prior[i - channels] if i >= channels else 0
        if method == 0:
            continue
        if method == 1:
            line[i] = (line[i] + left) & 0xFF
        elif method == 2:
            line[i] = (line[i] + up) & 0xFF
        elif method == 3:
            line[i] = (line[i] + (left + up) // 2) & 0xFF
        elif method == 4:
            line[i] = (line[i] + paeth(left, up, up_left)) & 0xFF
        else:
            raise PixelError(f"unknown PNG filter {method}")


def paeth(left: int, up: int, up_left: int) -> int:
    """The PNG Paeth predictor."""
    estimate = left + up - up_left
    distances = (abs(estimate - left), abs(estimate - up), abs(estimate - up_left))
    return (left, up, up_left)[distances.index(min(distances))]


def filled_cells(rows: list[list[tuple[int, int, int, int]]]) -> set[tuple[int, int]]:
    """Cells darker than mid-grey once alpha is composited over white."""
    cells = set()
    for row, pixels in enumerate(rows):
        for column, (red, green, blue, alpha) in enumerate(pixels):
            opacity = alpha / 255.0
            luma = (0.2126 * (opacity * red + (1.0 - opacity) * 255.0)
                    + 0.7152 * (opacity * green + (1.0 - opacity) * 255.0)
                    + 0.0722 * (opacity * blue + (1.0 - opacity) * 255.0))
            if luma < FILL_LUMA:
                cells.add((row, column))
    return cells


def pixel_fills(root: Path, pixel_id: str, size: int) -> set[tuple[int, int]] | None:
    """Fills from an approved catalogued pixel, or None to keep the seeded silhouette."""
    entry_path = root / CATALOG_ROOT / f"{pixel_id}.json"
    if not entry_path.is_file():
        return None
    try:
        entry = json.loads(entry_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise PixelError(f"pixel-picture-id {pixel_id}: {entry_path}: unreadable catalog entry ({exc})") from exc
    if not isinstance(entry, dict):
        raise PixelError(f"pixel-picture-id {pixel_id}: {entry_path}: catalog entry is not an object")
    if entry.get("state") != PIXEL_APPROVED:
        return None
    files = entry.get("files")
    if not isinstance(files, list) or len(files) != 1 or not isinstance(files[0], str):
        raise PixelError(f"pixel-picture-id {pixel_id}: {entry_path}: an approved entry must list exactly one file")
    path = root / ASSET_ROOT / files[0]
    try:
        rows = read_png(path)
    except PixelError as exc:
        raise PixelError(f"pixel-picture-id {pixel_id}: {path}: {exc}") from exc
    if len(rows) != size or any(len(row) != size for row in rows):
        raise PixelError(f"pixel-picture-id {pixel_id}: {path}: is not exactly {size}x{size}")
    return filled_cells(rows)


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


FILL = "fill"
CROSS = "cross"


def line_arrangements(
    runs_of_line: list[int], size: int, known: dict[int, str] | None = None
) -> list[int]:
    """One bitmask per valid arrangement of a line's runs; bit c is that cell filled.

    `known` maps crosses known at a cell (`cross`) so arrangements that ignore them
    drop out — the second puzzle-def pass ([F9](specs/technical/schemata/puzzle-def-fields.md)).
    A line whose known marks admit no arrangement is a pack defect.
    """
    states = known or {}
    results: list[int] = []

    def place(index: int, start: int, board: int) -> None:
        if index == len(runs_of_line):
            for cell in range(start, size):
                board &= ~(1 << cell)
            for cell in range(size):
                bit = board >> cell & 1
                if bit and states.get(cell) == CROSS:
                    return
                if not bit and states.get(cell) == FILL:
                    return
            results.append(board)
            return
        run_length = runs_of_line[index]
        tail = sum(runs_of_line[index:]) + (len(runs_of_line) - index - 1)
        for s in range(start, size - tail + 1):
            board_next = board
            broken = False
            for cell in range(start, s):
                if states.get(cell) == FILL:
                    broken = True
                    break
                board_next &= ~(1 << cell)
            if broken:
                continue
            for cell in range(s, s + run_length):
                if states.get(cell) == CROSS:
                    broken = True
                    break
                board_next |= 1 << cell
            if broken:
                continue
            if index == len(runs_of_line) - 1:
                ok = True
                for cell in range(s + run_length, size):
                    if states.get(cell) == FILL:
                        ok = False
                        break
                    board_next &= ~(1 << cell)
                if ok:
                    results.append(board_next)
            else:
                if states.get(s + run_length) == FILL:
                    continue
                board_next &= ~(1 << (s + run_length))
                place(index + 1, s + run_length + 1, board_next)

    place(0, 0, (1 << size) - 1)
    return results


def line_forced(
    runs_of_line: list[int], size: int, known: dict[int, str] | None = None
) -> dict[int, str]:
    """Cells one line's runs force; a mark present in all (no) arrangements is fill (cross)."""
    arrangements = line_arrangements(runs_of_line, size, known)
    if not arrangements:
        raise ValueError(f"known marks admit no arrangement: {runs_of_line}")
    total = len(arrangements)
    marks: dict[int, str] = {}
    for cell in range(size):
        fills = sum(board >> cell & 1 for board in arrangements)
        if fills == total:
            marks[cell] = FILL
        elif fills == 0:
            marks[cell] = CROSS
    return marks


def fill_hint_cells(
    row_clues: list[list[int]], col_clues: list[list[int]], size: int
) -> tuple[list[list], list[list]]:
    """The [F8](specs/technical/schemata/puzzle-def-fields.md) and F9 cell triples of one entry.

    F8 unions the single-line forcings over both directions; F9 re-solves each line
    with F8 known and keeps the additional forcings ([features/fill-hints.md](specs/design/features/fill-hints.md)).
    Conflicting marks between two lines of an entry are a pack defect (`ValueError`).
    """
    def union(known: dict[tuple[int, int], str]) -> dict[tuple[int, int], str]:
        forced: dict[tuple[int, int], str] = {}
        for row in range(size):
            line_known = {c: known[(row, c)] for c in range(size) if (row, c) in known}
            for cell, mark in line_forced(row_clues[row], size, line_known).items():
                position = (row, cell)
                if forced.get(position, mark) != mark:
                    raise ValueError(f"pack entry rows disagree at {position}")
                forced[position] = mark
        for column in range(size):
            line_known = {r: known[(r, column)] for r in range(size) if (r, column) in known}
            for row, mark in line_forced(col_clues[column], size, line_known).items():
                position = (row, column)
                if forced.get(position, mark) != mark:
                    raise ValueError(f"pack entry columns disagree at {position}")
                forced[position] = mark
        return forced

    single = union({})
    base = set(single)
    multi = {position: mark for position, mark in union(single).items() if position not in base}
    to_cells = lambda marks: [[r, c, mark] for (r, c), mark in sorted(marks.items())]
    return to_cells(single), to_cells(multi)


def entry(index: int, size: int, rng: random.Random, fills: set[tuple[int, int]] | None = None) -> dict:
    cells = silhouette(size, rng) if fills is None else fills
    grid = [[(row, column) in cells for column in range(size)] for row in range(size)]
    columns = [[grid[row][column] for row in range(size)] for column in range(size)]
    picture_id, pixel_id = picture_ids(index)
    single, multi = fill_hint_cells(
        [runs(row) for row in grid], [runs(column) for column in columns], size
    )
    return {
        "id": f"pack-{index:03d}",
        "size": size,
        "row-clues": [runs(row) for row in grid],
        "col-clues": [runs(column) for column in columns],
        "solution-fills": sorted([row, column] for row, column in cells),
        "picture-id": picture_id,
        "pixel-picture-id": pixel_id,
        "single-fill-hint-cells": single,
        "multi-fill-hint-cells": multi,
    }


def build(root: Path = REPO_ROOT) -> list[dict]:
    entries, index = [], 0
    for size, count in SIZES:
        for _ in range(count):
            rng = random.Random(f"pack-{index:03d}")
            fills = pixel_fills(root, picture_ids(index)[1], size)
            entries.append(entry(index, size, rng, fills))
            index += 1
    return entries


def render(entries: list[dict]) -> str:
    """One compact entry per line, in order, with a trailing newline.

    The blank line after each entry keeps two adjacent rows in separate merge
    hunks: without it, two picture slices that touch neighbouring rows conflict
    even though each rewrote only its own line.
    """
    lines = [json.dumps(puzzle, separators=(",", ":"), ensure_ascii=False) for puzzle in entries]
    return "[\n" + ",\n\n".join(lines) + "\n]\n"


class PackError(Exception):
    """The committed pack file cannot be used for a targeted write."""


def parse(text: str) -> list[dict]:
    """The entries of a pack file, or PackError when it is not a JSON array of objects."""
    try:
        entries = json.loads(text)
    except json.JSONDecodeError as exc:
        raise PackError(f"not valid JSON ({exc})") from exc
    if not isinstance(entries, list) or not all(isinstance(item, dict) for item in entries):
        raise PackError("must be a JSON array of objects")
    return entries


def derive_row(row: dict, root: Path) -> dict:
    """The same row with fills and clues from its approved pixel, or PackError."""
    puzzle_id, size = row.get("id"), row.get("size")
    pixel_id = row.get("pixel-picture-id")
    if not isinstance(puzzle_id, str) or not isinstance(size, int) or not isinstance(pixel_id, str):
        raise PackError("row is missing a string 'id'/'pixel-picture-id' or an integer 'size'")
    fills = pixel_fills(root, pixel_id, size)
    if fills is None:
        raise PackError(f"pixel-picture-id {pixel_id} has no approved pixel; nothing to derive")
    grid = [[(r, c) in fills for c in range(size)] for r in range(size)]
    columns = [[grid[r][c] for r in range(size)] for c in range(size)]
    row_clues, col_clues = [runs(r) for r in grid], [runs(c) for c in columns]
    single, multi = fill_hint_cells(row_clues, col_clues, size)
    return {
        **row,
        "row-clues": row_clues,
        "col-clues": col_clues,
        "solution-fills": sorted([r, c] for r, c in fills),
        "single-fill-hint-cells": single,
        "multi-fill-hint-cells": multi,
    }


def targeted_entries(root: Path, ids: list[str]) -> list[dict]:
    """Every entry, with only the named rows re-derived; PackError when one cannot be."""
    path = root / PACK_REL
    if not path.is_file():
        raise PackError(f"{path} does not exist; run generate_pack.py first")
    text = path.read_text(encoding="utf-8")
    entries = parse(text)
    if text != render(entries):
        raise PackError(f"{path} is not in the per-line format; run generate_pack.py once to migrate it")
    by_id = {puzzle.get("id"): index for index, puzzle in enumerate(entries)}
    missing = [puzzle_id for puzzle_id in ids if puzzle_id not in by_id]
    if missing:
        raise PackError(f"not in {path}: {', '.join(missing)}")
    for puzzle_id in dict.fromkeys(ids):
        index = by_id[puzzle_id]
        try:
            entries[index] = derive_row(entries[index], root)
        except PixelError as exc:
            raise PackError(f"{puzzle_id}: broken approved pixel picture: {exc}") from exc
    return entries


def run(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="fail when the committed pack is stale")
    mode.add_argument("--puzzle", action="append", default=[], metavar="PACK-ID",
                      help="rewrite only this puzzle row (repeatable)")
    parser.add_argument("--root", type=Path, default=REPO_ROOT, help="repository root")
    args = parser.parse_args(argv)
    path = args.root / PACK_REL
    try:
        if args.puzzle:
            text = render(targeted_entries(args.root, args.puzzle))
            path.write_text(text, encoding="utf-8")
            print(f"wrote {path} ({len(args.puzzle)} of {len(json.loads(text))} entries re-derived)")
            return 0
        text = render(build(args.root))
    except PixelError as exc:
        print(f"error: broken approved pixel picture: {exc}", file=sys.stderr)
        return 1
    except (PackError, OSError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    if args.check:
        current = path.read_text(encoding="utf-8") if path.exists() else ""
        if current != text:
            print(f"{path} is stale; run generate_pack.py", file=sys.stderr)
            return 1
        print(f"{path} is current")
        return 0
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")
    print(f"wrote {path} ({len(json.loads(text))} entries)")
    return 0


def main() -> int:
    return run(sys.argv[1:])


if __name__ == "__main__":
    raise SystemExit(main())
