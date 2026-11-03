"""Re-measure the committed pictures for #259: fills, masses, look numbers, and an
independent re-derive of each pixel from its committed square.

Nothing here imports `.github/scripts/puzzle_derive.py`; acceptance must not reuse the
tool it is judging. `read_png`/`cell_colour` are the run's own PNG reader (see
`expectations_259.py`).

    python3 recheck_259.py --root <tree under acceptance>
"""

import argparse
import statistics
import sys
from pathlib import Path

from expectations_259 import PUZZLES, SIZE, cell_colour, read_png


def rgb_cell(w, h, ch, rows, r, c):
    """BOX mean colour of one cell, alpha composited over white."""
    y0, y1 = h * r // SIZE, h * (r + 1) // SIZE
    x0, x1 = w * c // SIZE, w * (c + 1) // SIZE
    tr = tg = tb = ta = 0
    for y in range(y0, y1):
        line = rows[y]
        for x in range(x0, x1):
            px = x * ch
            alpha = line[px + 3] if ch == 4 else 255
            tr += alpha * line[px]
            tg += alpha * line[px + 1]
            tb += alpha * line[px + 2]
            ta += alpha
    count = (y1 - y0) * (x1 - x0)
    if not ta:
        return (255.0, 255.0, 255.0)
    alpha_f = ta / (count * 255.0)
    out = []
    for total in (tr, tg, tb):
        value = total / ta
        out.append(alpha_f * value + (1 - alpha_f) * 255)
    return tuple(out)


def luma(rgb):
    return 0.2126 * rgb[0] + 0.7152 * rgb[1] + 0.0722 * rgb[2]


def masses_and_holes(fills):
    seen, sizes = set(), []
    for cell in fills:
        if cell in seen:
            continue
        stack, n = [cell], 0
        seen.add(cell)
        while stack:
            r, c = stack.pop()
            n += 1
            for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nb = (r + dr, c + dc)
                if nb in fills and nb not in seen:
                    seen.add(nb)
                    stack.append(nb)
        sizes.append(n)
    border = [(r, c) for r in range(SIZE) for c in range(SIZE)
              if r in (0, SIZE - 1) or c in (0, SIZE - 1)]
    outside = {cell for cell in border if cell not in fills}
    stack = list(outside)
    while stack:
        r, c = stack.pop()
        for dr, dc in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nb = (r + dr, c + dc)
            if (0 <= nb[0] < SIZE and 0 <= nb[1] < SIZE and nb not in fills
                    and nb not in outside):
                outside.add(nb)
                stack.append(nb)
    holes = sum(1 for r in range(SIZE) for c in range(SIZE)
                if (r, c) not in fills and (r, c) not in outside)
    return sorted(sizes, reverse=True), holes


def rederive(square_path, pixel_path):
    """Flatten the outer 5% frame to the outer 1% ring's median, BOX down, compare."""
    w, h, ch, rows = read_png(square_path)
    pw, ph, pch, prows = read_png(pixel_path)
    band, ring = int(round(w * 0.05)), int(round(w * 0.01))
    ring_rgb = []
    for y in range(h):
        for x in range(w):
            if x < ring or y < ring or x >= w - ring or y >= h - ring:
                px = x * ch
                if (rows[y][px + 3] if ch == 4 else 255) > 0:
                    ring_rgb.append((rows[y][px], rows[y][px + 1], rows[y][px + 2]))
    background = tuple(int(statistics.median(s[i] for s in ring_rgb)) for i in range(3))
    flat = [bytearray(line) for line in rows]
    for y in range(h):
        for x in range(w):
            if x < band or y < band or x >= w - band or y >= h - band:
                px = x * ch
                flat[y][px:px + 3] = bytes(background)
                if ch == 4:
                    flat[y][px + 3] = 255
    worst_delta, flipped = 0.0, 0
    for r in range(SIZE):
        for c in range(SIZE):
            mine = rgb_cell(w, h, ch, flat, r, c)
            theirs = rgb_cell(pw, ph, pch, prows, r, c)
            worst_delta = max(worst_delta, max(abs(mine[i] - theirs[i]) for i in range(3)))
            if (luma(mine) < 128) != (luma(theirs) < 128):
                flipped += 1
    return background, worst_delta, flipped


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=".")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    for puzzle_id in PUZZLES:
        square = root / f"game/assets/puzzle-pictures/{puzzle_id}-generated.png"
        pixel = root / f"game/assets/puzzle-pictures/{puzzle_id}-pixel.png"
        w, h, ch, rows = read_png(pixel)
        colours = [[rgb_cell(w, h, ch, rows, r, c) for c in range(SIZE)] for r in range(SIZE)]
        fills = {(r, c) for r in range(SIZE) for c in range(SIZE) if luma(colours[r][c]) < 128}
        subject = [luma(colours[r][c]) for (r, c) in fills]
        ground = [luma(colours[r][c]) for r in range(SIZE) for c in range(SIZE)
                  if (r, c) not in fills]
        values = sorted(luma(colours[r][c]) for r in range(SIZE) for c in range(SIZE))
        sizes, holes = masses_and_holes(fills)
        background, worst, flipped = rederive(square, pixel)
        print(
            f"{puzzle_id} filled={len(fills)} masses={len(sizes)}{sizes} holes={holes} "
            f"luma mean/p5/p95={sum(values) / len(values):.1f}/{values[int(0.05 * (len(values) - 1))]:.1f}/"
            f"{values[int(0.95 * (len(values) - 1))]:.1f} "
            f"contrast={abs(sum(subject) / len(subject) - sum(ground) / len(ground)):.1f} "
            f"rederive_bg={background} max_cell_delta={worst:.2f} flipped_cells={flipped}"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
