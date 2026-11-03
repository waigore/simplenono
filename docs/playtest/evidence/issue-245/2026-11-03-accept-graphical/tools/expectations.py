"""Build the state the graphical capture probe expects for #245.

Derives everything from the committed artifacts with independent code:

* the fill set of each committed pixel file, with the issue's fixed rule
  re-implemented here (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B` on 0-255
  sRGB, filled when `Y < 128`, BOX 1024->15, no gamma, no per-image threshold);
* the clue lists from that fill set, compared with the committed `row-clues` /
  `col-clues` on the pack row;
* uniqueness and line-logic reachability from those clues (`nonogram.py`);
* the fill band the shared picture bar on #294 sets for a 15x15 slice (56-101).

Writes `expect.json` next to this script; the probe loads it.
"""

import json
import struct
import zlib
from pathlib import Path

from nonogram import SIZE, count_solutions, line_logic

HERE = Path(__file__).resolve().parent

FILL_BAND = (56, 101)
CLUE_ORDER = "cover"


def _repo_root(start):
    for candidate in [start, *start.parents]:
        if (candidate / "game/data/pack.json").is_file():
            return candidate
    raise SystemExit("expected to live inside the repo")


ROOT = _repo_root(HERE)
OUT = HERE.parent / "expect.json"
PUZZLES = ["pack-050", "pack-051", "pack-052", "pack-053"]


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


def generated_warm_ratio(width, height, channels, rows):
    """Share of pixels whose red channel clearly leads green and blue."""
    warm = total = 0
    for y in range(0, height, 4):
        line = rows[y]
        for x in range(0, width, 4):
            px = x * channels
            r, g, b = line[px], line[px + 1], line[px + 2]
            total += 1
            if r > g + 12 and r > b + 12:
                warm += 1
    return warm / total if total else 0.0


def main():
    pack = {row["id"]: row for row in json.loads((ROOT / "game/data/pack.json").read_text())}
    expect = {}
    for puzzle_id in PUZZLES:
        width, height, channels, rows = read_png(
            ROOT / f"game/assets/puzzle-pictures/{puzzle_id}-pixel.png")
        assert (width, height) == (SIZE, SIZE), (width, height)
        fills = {(r, c) for r in range(SIZE) for c in range(SIZE)
                 if cell_colour(rows, channels, width, height, r, c) < 128}
        grid = ["".join("1" if (r, c) in fills else "0" for c in range(SIZE)) for r in range(SIZE)]
        row_clues = clues([[ch == "1" for ch in line] for line in grid])
        col_clues = clues([[grid[r][c] == "1" for r in range(SIZE)] for c in range(SIZE)])
        solved = line_logic(row_clues, col_clues)
        logic_fills = {(r, c) for r in range(SIZE) for c in range(SIZE) if solved and solved[r][c]}
        row = pack[puzzle_id]
        gen_width, gen_height, gen_channels, gen_rows = read_png(
            ROOT / f"game/assets/puzzle-pictures/{puzzle_id}-generated.png")
        expect[puzzle_id] = {
            "rows": grid,
            "filled": len(fills),
            "solutions": count_solutions(row_clues, col_clues),
            "line_logic_solves": bool(solved) and all(v is not None for line in solved for v in line),
            "logic_matches_pixel": logic_fills == fills,
            "matches_pack_fills": fills == {(r, c) for r, c in row["solution-fills"]},
            "matches_pack_row_clues": row_clues == row["row-clues"],
            "matches_pack_col_clues": col_clues == row["col-clues"],
            "band": FILL_BAND[0] <= len(fills) <= FILL_BAND[1],
            "generated_size": [gen_width, gen_height],
            "generated_warm_ratio": round(generated_warm_ratio(
                gen_width, gen_height, gen_channels, gen_rows), 6),
            "border_background": all(
                (r, c) not in fills
                for r in range(SIZE) for c in range(SIZE)
                if r in (0, SIZE - 1) or c in (0, SIZE - 1)),
        }
    OUT.write_text(json.dumps(expect, indent=1) + "\n")
    for puzzle_id, value in expect.items():
        print(puzzle_id, value["filled"], value["solutions"], value["line_logic_solves"],
              value["logic_matches_pixel"], value["matches_pack_fills"],
              value["matches_pack_row_clues"], value["matches_pack_col_clues"],
              value["band"], value["generated_size"], value["generated_warm_ratio"])
    assert all(
        v["solutions"] == 1 and v["line_logic_solves"] and v["logic_matches_pixel"]
        and v["matches_pack_fills"] and v["matches_pack_row_clues"]
        and v["matches_pack_col_clues"] and v["band"]
        and v["generated_size"] == [1024, 1024] and v["generated_warm_ratio"] < 0.0002
        and v["border_background"]
        for v in expect.values())
    print("expect.json written to", OUT)


if __name__ == "__main__":
    main()
