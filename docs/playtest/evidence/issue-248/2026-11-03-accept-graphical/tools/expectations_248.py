"""Build the state the graphical capture probe expects for #248.

Derived with independent code (no `.github/scripts/puzzle_derive.py`, no `puzzle_derive`
import) from the committed artifacts in the tree under acceptance:

* the fill set of each committed `-pixel.png` read with the issue's fixed rule
  (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B` on 0-255 sRGB, filled when
  `Y < 128`);
* the measured subject class (4-connected masses and enclosed holes);
* the row/col clues recomputed from that fill set;
* uniqueness and line-logic reachability from those clues (see `judge`).

    python3 expectations.py --root <tree under acceptance> --out <run folder>/expect.json
"""

import argparse
import json
import struct
import zlib
from pathlib import Path

PUZZLES = ["pack-062", "pack-063", "pack-064", "pack-065"]


def read_png(path):
    data = Path(path).read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    pos, idat, w, h, ch = 8, b"", 0, 0, 0
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + length]
        if kind == b"IHDR":
            w, h, depth, colour_type = struct.unpack(">IIBB", body[:10])
            assert depth == 8 and colour_type in (2, 6), (depth, colour_type)
            ch = 3 if colour_type == 2 else 4
        elif kind == b"IDAT":
            idat += body
        pos += 12 + length
    raw = zlib.decompress(idat)
    stride = w * ch
    rows, prev, i = [], bytearray(stride), 0
    for _y in range(h):
        ftype = raw[i]
        i += 1
        line = bytearray(raw[i:i + stride])
        i += stride
        for x in range(stride):
            a = line[x - ch] if x >= ch else 0
            b = prev[x]
            c = prev[x - ch] if x >= ch else 0
            if ftype == 1:
                line[x] = (line[x] + a) & 255
            elif ftype == 2:
                line[x] = (line[x] + b) & 255
            elif ftype == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif ftype == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else (b if pb <= pc else c))) & 255
        rows.append(line)
        prev = line
    return w, h, ch, rows


def fills_of(path):
    w, h, ch, rows = read_png(path)
    fills = set()
    for y in range(h):
        for x in range(w):
            o = x * ch
            r, g, b = rows[y][o], rows[y][o + 1], rows[y][o + 2]
            a = rows[y][o + 3] if ch == 4 else 255
            r = (a * r + (255 - a) * 255) // 255
            g = (a * g + (255 - a) * 255) // 255
            b = (a * b + (255 - a) * 255) // 255
            if 0.2126 * r + 0.7152 * g + 0.0722 * b < 128:
                fills.add((x, y))
    return w, h, fills


def masses_and_holes(w, h, fills):
    seen, masses = set(), []
    for cell in fills:
        if cell in seen:
            continue
        stack, size = [cell], 0
        seen.add(cell)
        while stack:
            cx, cy = stack.pop()
            size += 1
            for nxt in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                if nxt in fills and nxt not in seen:
                    seen.add(nxt)
                    stack.append(nxt)
        masses.append(size)
    bg = {(x, y) for x in range(w) for y in range(h)} - fills
    border = {c for c in bg if c[0] in (0, w - 1) or c[1] in (0, h - 1)}
    reach, stack = set(border), list(border)
    while stack:
        cx, cy = stack.pop()
        for nxt in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
            if nxt in bg and nxt not in reach:
                reach.add(nxt)
                stack.append(nxt)
    return sorted(masses, reverse=True), len(bg - reach)


def runs(values):
    out, count = [], 0
    for bit in list(values) + [0]:
        if bit:
            count += 1
        elif count:
            out.append(count)
            count = 0
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    root = Path(args.root)
    pack = json.loads((root / "game/data/pack.json").read_text())
    rows = pack["puzzles"] if isinstance(pack, dict) and "puzzles" in pack else pack
    by_id = {row["id"]: row for row in rows}
    out = {}
    for pid in PUZZLES:
        w, h, fills = fills_of(root / f"game/assets/puzzle-pictures/{pid}-pixel.png")
        masses, holes = masses_and_holes(w, h, fills)
        row_clues = [runs([(x, y) in fills for x in range(w)]) for y in range(h)]
        col_clues = [runs([(x, y) in fills for y in range(h)]) for x in range(w)]
        row = by_id[pid]
        # The shipped encoding is [row, column] pairs.
        packed = {(c, r) for r, c in row["solution-fills"]}
        out[pid] = {
            "rows": ["".join("1" if (x, y) in fills else "0" for x in range(w)) for y in range(h)],
            "filled": len(fills),
            "masses": masses,
            "holes": holes,
            "subject_class": "single" if len(masses) == 1 and holes == 0 else "multi",
            "row_clues": row_clues,
            "col_clues": col_clues,
            "matches_pack_fills": packed == fills,
            "matches_pack_row_clues": row_clues == row["row-clues"],
            "matches_pack_col_clues": col_clues == row["col-clues"],
        }
    Path(args.out).write_text(json.dumps(out, indent=1) + "\n")
    for pid, data in out.items():
        print(
            pid,
            "filled", data["filled"],
            "masses", data["masses"],
            "holes", data["holes"],
            "class", data["subject_class"],
            "fills==pack", data["matches_pack_fills"],
            "row-clues==pack", data["matches_pack_row_clues"],
            "col-clues==pack", data["matches_pack_col_clues"],
        )


if __name__ == "__main__":
    main()
