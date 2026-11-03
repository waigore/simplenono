"""Build the state the graphical capture probe expects for #273.

Slice copy of `expectations_270.py`: same independent derivation, this slice's four rows
(pack-166, pack-167, pack-168, pack-169).

Derives everything from the committed artifacts with independent code:

* the fill set of each committed pixel file, with the shared picture bar's fixed rule
  re-implemented here (alpha over white, `Y = 0.2126R + 0.7160G + 0.0722B` on 0-255
  sRGB, filled when `Y < 128`, BOX 1024->15, no gamma, no per-image threshold);
* the clue lists from that fill set;
* uniqueness and line-logic reachability from those clues (`nonogram.py`);
* the look measurements the bar's item 6 records (warm pixels, luma, contrast,
  connected masses).

Writes `expect.json` next to the run folder; the probe loads it.

    python3 expectations_274.py --root <tree under acceptance> --out ../expect.json
"""

import argparse
import json
import struct
import zlib
from pathlib import Path

from nonogram import SIZE, count_solutions, line_logic

HERE = Path(__file__).resolve().parent
PUZZLES = ["pack-162", "pack-163", "pack-164", "pack-165"]


def _repo_root(start):
    for candidate in [start, *start.parents]:
        if (candidate / "game/data/pack.json").is_file():
            return candidate
    raise SystemExit("expected to live inside the repo")


def read_png(path):
    data = Path(path).read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    pos, idat, w, h, channels = 8, b"", 0, 0, 0
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + length]
        if kind == b"IHDR":
            w, h, depth, colour_type = struct.unpack(">IIBB", body[:10])
            assert depth == 8 and colour_type in (2, 6), (depth, colour_type)
            channels = 3 if colour_type == 2 else 4
        elif kind == b"IDAT":
            idat += body
        pos += 12 + length
    raw = zlib.decompress(idat)
    stride = w * channels
    rows, prev, i = [], bytearray(stride), 0
    for _y in range(h):
        filter_type = raw[i]
        i += 1
        line = bytearray(raw[i:i + stride])
        i += stride
        for x in range(stride):
            a = line[x - channels] if x >= channels else 0
            b = prev[x]
            c = prev[x - channels] if x >= channels else 0
            if filter_type == 1:
                line[x] = (line[x] + a) & 0xFF
            elif filter_type == 2:
                line[x] = (line[x] + b) & 0xFF
            elif filter_type == 3:
                line[x] = (line[x] + (a + b) // 2) & 0xFF
            elif filter_type == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[x] = (line[x] + pred) & 0xFF
        rows.append(line)
        prev = line
    return w, h, channels, rows


def cell_colour(rows, channels, width, height, row, column, size=SIZE):
    tr = tg = tb = ta = 0
    y0, y1 = height * row // size, height * (row + 1) // size
    x0, x1 = width * column // size, width * (column + 1) // size
    for y in range(y0, y1):
        line = rows[y]
        for x in range(x0, x1):
            px = x * channels
            alpha = line[px + 3] if channels == 4 else 255
            tr += alpha * line[px]
            tg += alpha * line[px + 1]
            tb += alpha * line[px + 2]
            ta += alpha
    count = (y1 - y0) * (x1 - x0)
    if ta:
        r, g, b = tr / ta, tg / ta, tb / ta
    else:
        r = g = b = 255.0
    alpha_f = ta / (count * 255.0)
    cr = alpha_f * r + (1 - alpha_f) * 255
    cg = alpha_f * g + (1 - alpha_f) * 255
    cb = alpha_f * b + (1 - alpha_f) * 255
    return 0.2126 * cr + 0.7160 * cg + 0.0722 * cb


def clues(lines):
    out = []
    for line in lines:
        runs, count = [], 0
        for filled in line:
            if filled:
                count += 1
            elif count:
                runs.append(count)
                count = 0
        if count:
            runs.append(count)
        out.append(runs)
    return out


def colour_stats(rows, channels):
    """Look measurements: warm-pixel share and per-pixel luma percentiles."""
    total = warm = 0
    lumas = []
    for line in rows:
        for px in range(0, len(line), channels):
            alpha = line[px + 3] if channels == 4 else 255
            a = alpha / 255.0
            r = a * line[px] + (1 - a) * 255
            g = a * line[px + 1] + (1 - a) * 255
            b = a * line[px + 2] + (1 - a) * 255
            if r > b + 8:
                warm += 1
            total += 1
            lumas.append(0.2126 * r + 0.7160 * g + 0.0722 * b)
    lumas.sort()
    return {
        "warm_percent": round(100.0 * warm / total, 2),
        "luma_mean": round(sum(lumas) / len(lumas), 1),
        "luma_p5": round(lumas[int(len(lumas) * 0.05)], 1),
        "luma_p95": round(lumas[int(len(lumas) * 0.95)], 1),
    }


def mass_stats(fills):
    """Connected masses (4-connectivity) and enclosed background cells."""
    remaining = set(fills)
    masses = []
    while remaining:
        seed = remaining.pop()
        stack, members = [seed], 1
        while stack:
            r, c = stack.pop()
            for nr, nc in ((r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1)):
                if (nr, nc) in remaining:
                    remaining.remove((nr, nc))
                    stack.append((nr, nc))
                    members += 1
        masses.append(members)
    background = {(r, c) for r in range(SIZE) for c in range(SIZE)} - set(fills)
    outside = {cell for cell in background if cell[0] in (0, SIZE - 1) or cell[1] in (0, SIZE - 1)}
    seen = set(outside)
    stack = list(outside)
    while stack:
        r, c = stack.pop()
        for nr, nc in ((r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1)):
            cell = (nr, nc)
            if cell in background and cell not in seen:
                seen.add(cell)
                stack.append(cell)
    return sorted(masses, reverse=True), len(background - seen)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=str(_repo_root(HERE)))
    parser.add_argument("--out", default=str(HERE.parent / "expect.json"))
    args = parser.parse_args()

    root = Path(args.root).resolve()
    out = Path(args.out).resolve()
    pack = {row["id"]: row for row in json.loads((root / "game/data/pack.json").read_text())}
    expect = {}
    for puzzle_id in PUZZLES:
        width, height, channels, rows = read_png(
            root / f"game/assets/puzzle-pictures/{puzzle_id}-pixel.png")
        assert (width, height) == (SIZE, SIZE), (width, height)
        fills = {(r, c) for r in range(SIZE) for c in range(SIZE)
                 if cell_colour(rows, channels, width, height, r, c) < 128}
        grid = ["".join("1" if (r, c) in fills else "0" for c in range(SIZE)) for r in range(SIZE)]
        row_clues = clues([[ch == "1" for ch in line] for line in grid])
        col_clues = clues([[grid[r][c] == "1" for r in range(SIZE)] for c in range(SIZE)])
        solved = line_logic(row_clues, col_clues)
        logic_fills = {(r, c) for r in range(SIZE) for c in range(SIZE) if solved and solved[r][c]}
        masses, holes = mass_stats(fills)
        square = read_png(root / f"game/assets/puzzle-pictures/{puzzle_id}-generated.png")
        expect[puzzle_id] = {
            "rows": grid,
            "filled": len(fills),
            "solutions": count_solutions(row_clues, col_clues),
            "line_logic_solves": bool(solved) and all(v is not None for line in solved for v in line),
            "logic_matches_pixel": logic_fills == fills,
            "matches_pack_fills": fills == {(r, c) for r, c in pack[puzzle_id]["solution-fills"]},
            "matches_pack_clues": row_clues == pack[puzzle_id]["row-clues"]
            and col_clues == pack[puzzle_id]["col-clues"],
            "pixel_size": [width, height],
            "square_size": [square[0], square[1]],
            "pixel_look": colour_stats(rows, channels),
            "square_look": colour_stats(square[3], square[2]),
            "masses": masses,
            "enclosed_background": holes,
        }
    out.write_text(json.dumps(expect, indent=1) + "\n")
    for puzzle_id, value in expect.items():
        print(puzzle_id, value["filled"], value["solutions"],
              value["line_logic_solves"], value["logic_matches_pixel"],
              value["matches_pack_fills"], value["matches_pack_clues"],
              "| masses", value["masses"], "holes", value["enclosed_background"],
              "| pixel look", value["pixel_look"], "| square look", value["square_look"])
    assert all(v["solutions"] == 1 and v["line_logic_solves"] and v["logic_matches_pixel"]
               and v["matches_pack_fills"] and v["matches_pack_clues"]
               and 56 <= v["filled"] <= 101 for v in expect.values())
    print("expect.json written to", out)


if __name__ == "__main__":
    main()
