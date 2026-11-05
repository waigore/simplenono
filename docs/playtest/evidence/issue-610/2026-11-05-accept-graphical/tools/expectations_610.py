"""Build the state the graphical capture probe expects for #610.

Slice copy of `expectations_565.py`: same independent derivation, this issue's 17
regenerated rows (one 10x10, fourteen 15x15, two 20x20), each at its own size. The
coefficients are the kind spec's exact `Y = 0.2126R + 0.7152G + 0.0722B`.

Derives everything from the committed artifacts with independent code:

* the fill set of each committed pixel file, with the fixed fill rule re-implemented
  here (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B` on 0-255 sRGB, filled when
  `Y < 128`, BOX 1024->N, no gamma, no per-image threshold);
* the clue lists from that fill set;
* uniqueness and line-logic reachability from those clues (`nonogram565.py`);
* the K2 fill band at each size (25-45%: 25-45 / 56-101 / 100-180);
* axis-asymmetry of the derived pixel grid (horizontal flip, vertical flip,
  transpose) as corroboration for the K4 asymmetry row;
* colour statistics of the committed square (hue spread and saturation means) as
  corroboration for the K4 colourful look — the K4 itself is the accept run's look
  review, recorded as sentences, not a threshold in this tool.

Writes `expect.json` next to the run folder; the probe loads it.

    python3 expectations_610.py --root <tree under acceptance> --out ../expect.json
"""

import argparse
import json
import struct
import zlib
from pathlib import Path

from nonogram610 import count_solutions, line_logic

HERE = Path(__file__).resolve().parent

# The 17 pairs the K5 closing review regenerated (PR #621): one 10x10, fourteen
# 15x15, two 20x20. Every other pair keeps its files and catalog row untouched.
PUZZLES = ["pack-002",
           "pack-049", "pack-058", "pack-081", "pack-083", "pack-092", "pack-098",
           "pack-111", "pack-137", "pack-140", "pack-144", "pack-146", "pack-151",
           "pack-160", "pack-167",
           "pack-184", "pack-188"]

# Kind row K2, per size: 25-45% of size^2.
BANDS = {10: (25, 45), 15: (56, 101), 20: (100, 180)}


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


def cell_colour(rows, channels, width, height, row, column, size):
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
    return 0.2126 * cr + 0.7152 * cg + 0.0722 * cb


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


def mass_stats(fills, size):
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
    background = {(r, c) for r in range(size) for c in range(size)} - set(fills)
    outside = {cell for cell in background
               if cell[0] in (0, size - 1) or cell[1] in (0, size - 1)}
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


def colour_breadth(rows, channels, width, height, grid_cells):
    """Per-grid-cell saturation stats of the committed square, for the K4 corroboration.

    One sample cell per grid row band, mean HSV saturation and the share of cells whose
    per-cell pixel variance (a crude 'multi-element' signal) exceeds a spread of 8.
    """
    sats, spread_cells = [], 0
    seen_y = set()
    for r in range(grid_cells):
        line = rows[min(height - 1, height * (2 * r + 1) // (2 * grid_cells))]
        y = line
        for c in range(grid_cells):
            px = min(width - 1, width * c // grid_cells) * channels
            r_, g_, b_ = (y[px] / 255.0, y[px + 1] / 255.0, y[px + 2] / 255.0)
            mx, mn = max(r_, g_, b_), min(r_, g_, b_)
            sats.append(0.0 if mx == 0 else (mx - mn) / mx)
            if mx - mn > 8 / 255.0 and (r, c) not in seen_y:
                pass
        # count cells with visible hue spread along their own row band
        y0, y1 = height * r // grid_cells, height * (r + 1) // grid_cells
        for c in range(grid_cells):
            x0, x1 = width * c // grid_cells, width * (c + 1) // grid_cells
            vals = []
            for y_ in range(y0, y1):
                line_ = rows[y_]
                for x_ in range(max(x0, x1 - 4), x1):
                    px = x_ * channels
                    vals.append(line_[px] + line_[px + 1] + line_[px + 2])
            if vals and (max(vals) - min(vals)) > 3 * 8:
                spread_cells += 1
    total = len(sats) or 1
    return {
        "grid_cells": grid_cells,
        "mean_saturation": round(sum(sats) / total, 3),
        "min_saturation": round(min(sats), 3),
        "spread_cells_share": round(spread_cells / (grid_cells * grid_cells), 3),
    }


def asymmetry(fills, size):
    """Grid mirror asymmetry, recorded as corroboration for the K4 asymmetry row.

    A nonogram rule (any mirrored/derived twin carries the same clues) only yields a
    *different* puzzle when the grid is asymmetric under horizontal flip, vertical
    flip, and transpose, so a mirror-degenerate pixel cannot be a distinct K4 scene.
    True means the grid differs from its mirror on that axis.

    The flip test is whole-grid: the mirrored grid equals the original only when every
    line maps onto its mirror line, so the lists compare directly.
    """
    rows = ["".join("1" if (r, c) in fills else "0" for c in range(size))
            for r in range(size)]
    cols = ["".join(rows[r][c] for r in range(size)) for c in range(size)]
    return {
        "horizontal": rows != rows[::-1],
        "vertical": cols != cols[::-1],
        "diagonal": any(cols[c] != rows[c] for c in range(size)),
    }


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
        pack_row = pack[puzzle_id]
        size = int(pack_row["size"])
        width, height, channels, rows = read_png(
            root / f"game/assets/puzzle-pictures/{puzzle_id}-pixel.png")
        assert (width, height) == (size, size), (puzzle_id, width, height)
        fills = {(r, c) for r in range(size) for c in range(size)
                 if cell_colour(rows, channels, width, height, r, c, size) < 128}
        grid = ["".join("1" if (r, c) in fills else "0" for c in range(size))
                for r in range(size)]
        row_clues = clues([[ch == "1" for ch in line] for line in grid])
        col_clues = clues([[grid[r][c] == "1" for r in range(size)] for c in range(size)])
        solved = line_logic(row_clues, col_clues, size)
        logic_fills = {(r, c) for r in range(size) for c in range(size) if solved and solved[r][c]}
        masses, holes = mass_stats(fills, size)
        band = BANDS[size]
        square = read_png(root / f"game/assets/puzzle-pictures/{puzzle_id}-generated.png")
        entry = json.loads((root / f"assets/catalog/{pack_row['picture-id']}.json").read_text())
        expect[puzzle_id] = {
            "size": size,
            "rows": grid,
            "row_clues": row_clues,
            "col_clues": col_clues,
            "filled": len(fills),
            "in_band": band[0] <= len(fills) <= band[1],
            "solutions": count_solutions(row_clues, col_clues, size),
            "line_logic_solves": bool(solved) and all(
                v is not None for line in solved for v in line),
            "logic_matches_pixel": logic_fills == fills,
            "matches_pack_fills": fills == {(r, c) for r, c in pack_row["solution-fills"]},
            "matches_pack_clues": row_clues == pack_row["row-clues"]
            and col_clues == pack_row["col-clues"],
            "empty_clue_rows": [r for r, runs in enumerate(row_clues) if not runs],
            "empty_clue_cols": [c for c, runs in enumerate(col_clues) if not runs],
            "asymmetry": asymmetry(fills, size),
            "pixel_size": [width, height],
            "square_size": [square[0], square[1]],
            "square_colour": colour_breadth(square[3], square[2], square[0], square[1], size),
            "masses": masses,
            "enclosed_background": holes,
            "catalog_version": entry.get("state_cards", {}).get("approved", {}).get("version")
            or entry.get("version"),
            "prompt": (entry.get("generation") or {}).get("prompt"),
        }
    out.write_text(json.dumps(expect, indent=1) + "\n")
    for puzzle_id, value in expect.items():
        print(puzzle_id, "size", value["size"], value["filled"], "in_band",
              value["in_band"], "solutions", value["solutions"],
              "line_logic_solves", value["line_logic_solves"],
              "logic_matches_pixel", value["logic_matches_pixel"],
              "matches_pack_fills", value["matches_pack_fills"],
              "matches_pack_clues", value["matches_pack_clues"],
              "| asymmetric", value["asymmetry"],
              "| masses", value["masses"], "holes", value["enclosed_background"],
              "| empty lines", value["empty_clue_rows"], value["empty_clue_cols"],
              "| square_colour", value["square_colour"])
    assert all(
        v["solutions"] == 1 and v["line_logic_solves"] and v["logic_matches_pixel"]
        and v["matches_pack_fills"] and v["matches_pack_clues"] and v["in_band"]
        and v["pixel_size"] == [v["size"], v["size"]]
        for v in expect.values()), "some row failed its independent checks"
    print("expect.json written to", out,
          "| 10x10:", sum(1 for v in expect.values() if v["size"] == 10),
          "15x15:", sum(1 for v in expect.values() if v["size"] == 15),
          "20x20:", sum(1 for v in expect.values() if v["size"] == 20))


if __name__ == "__main__":
    main()
