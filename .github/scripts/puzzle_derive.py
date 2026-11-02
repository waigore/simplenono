#!/usr/bin/env python3
"""Derive an N x N pixel picture from a generated square, then judge its nonogram.

This is an offline TL.2 authoring script (specs/assets/tools.md). It does not run
in the game and it does not edit pack data; it only produces the stored pixel
file and reports the checks a picture-slice task needs:

  - flatten the square's vignette so a dark edge is not a false fill
    (kinds/puzzle-pictures.md S5);
  - BOX-downsample that copy to exactly N x N colour cells, one per board cell
    (S1, S6);
  - read the fill set with the fixed rule: each cell's alpha composited over
    white, relative luma Y = 0.2126R + 0.7152G + 0.0722B on the 0-255 sRGB
    values with no gamma linearization, filled when Y < 128 (S2);
  - judge that the clues have exactly one solution, line logic alone reaches it,
    and that solution is this pixel's fill set (S4).

Nothing here is tuned per image: the band, downsample, and threshold are fixed.

Usage:
  python3 .github/scripts/puzzle_derive.py derive --square IN --pixel OUT --size N
  python3 .github/scripts/puzzle_derive.py judge --pixel IN --size N

Both commands print one JSON line. `derive` also runs the judge.
"""
from __future__ import annotations

import argparse
import json
import sys
import zlib
from pathlib import Path

PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"
PNG_CHANNELS = {2: 3, 6: 4}  # colour type -> channels; RGB or RGBA only
FILL_LUMA = 128.0
FILL_MIN = 25  # 10x10 task bar: 25-45 filled cells
FILL_MAX = 45
EDGE_RING = 0.01  # median background sample: the outer 1% ring
EDGE_BAND = 0.05  # flattened frame: the outer 5% band


class PictureError(Exception):
    """A square or pixel file cannot be read by the fixed rules."""


def read_png(path: Path) -> list[list[tuple[int, int, int, int]]]:
    """Rows of RGBA pixels from a non-interlaced 8-bit RGB or RGBA PNG."""
    try:
        data = path.read_bytes()
    except OSError as exc:
        raise PictureError(f"cannot read {path} ({exc.strerror})") from exc
    if not data.startswith(PNG_SIGNATURE):
        raise PictureError(f"{path} is not a PNG")
    header: tuple[int, int, int, int, int] | None = None
    payloads = bytearray()
    offset = len(PNG_SIGNATURE)
    while offset + 8 <= len(data):
        length = int.from_bytes(data[offset:offset + 4], "big")
        kind = data[offset + 4:offset + 8]
        start, end = offset + 8, offset + 8 + length
        if end + 4 > len(data):
            raise PictureError(f"{path} has a truncated PNG chunk")
        chunk = data[start:end]
        offset = end + 4
        if kind == b"IHDR":
            if len(chunk) != 13:
                raise PictureError(f"{path} has a malformed PNG header")
            header = (int.from_bytes(chunk[0:4], "big"), int.from_bytes(chunk[4:8], "big"),
                      chunk[8], chunk[9], chunk[12])
        elif kind == b"IDAT":
            payloads += chunk
        elif kind == b"IEND":
            break
    if header is None:
        raise PictureError(f"{path} has no PNG header")
    width, height, depth, colour, interlace = header
    if depth != 8:
        raise PictureError(f"{path} has bit depth {depth}, not 8")
    if colour not in PNG_CHANNELS:
        raise PictureError(f"{path} is not RGB or RGBA")
    if interlace != 0:
        raise PictureError(f"{path} is interlaced")
    if width == 0 or height == 0:
        raise PictureError(f"{path} is empty")
    try:
        raw = zlib.decompress(bytes(payloads))
    except zlib.error as exc:
        raise PictureError(f"{path} has corrupt PNG data ({exc})") from exc
    channels = PNG_CHANNELS[colour]
    stride = width * channels
    if len(raw) != height * (stride + 1):
        raise PictureError(f"{path} has a bad byte count for {width}x{height}")
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
            raise PictureError(f"unknown PNG filter {method}")


def paeth(left: int, up: int, up_left: int) -> int:
    """The PNG Paeth predictor."""
    estimate = left + up - up_left
    distances = (abs(estimate - left), abs(estimate - up), abs(estimate - up_left))
    return (left, up, up_left)[distances.index(min(distances))]


def write_png(path: Path, rows: list[list[tuple[int, int, int]]]) -> None:
    """Write an 8-bit RGB PNG with filter 0 on every scanline."""
    height, width = len(rows), len(rows[0])
    raw = b"".join(b"\x00" + bytes(channel for pixel in row for channel in pixel) for row in rows)
    chunks = [
        (b"IHDR", width.to_bytes(4, "big") + height.to_bytes(4, "big") + bytes((8, 2, 0, 0, 0))),
        (b"IDAT", zlib.compress(raw, 9)),
        (b"IEND", b""),
    ]
    data = bytearray(PNG_SIGNATURE)
    for kind, payload in chunks:
        data += len(payload).to_bytes(4, "big") + kind + payload
        data += zlib.crc32(kind + payload).to_bytes(4, "big")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(bytes(data))


def median(values: list[int]) -> int:
    """Middle value; for an even count, the lower middle (deterministic)."""
    ordered = sorted(values)
    return ordered[(len(ordered) - 1) // 2]


def flatten_vignette(rows: list[list[tuple[int, int, int, int]]]) -> tuple[
        list[list[tuple[int, int, int, int]]], dict]:
    """Flatten the outer frame to the median colour of the outer 1% ring.

    The frame is the outer 5% band of the square. A generator's vignette darkens
    that band; replacing it with the sampled background keeps a dark edge from
    reading as a false fill before the BOX downsample (S5).
    """
    height, width = len(rows), len(rows[0])
    ring = max(1, round(min(height, width) * EDGE_RING))
    band = max(1, round(min(height, width) * EDGE_BAND))
    samples = [[], [], []]
    for row in range(height):
        for column in range(width):
            if row < ring or row >= height - ring or column < ring or column >= width - ring:
                for channel in range(3):
                    samples[channel].append(rows[row][column][channel])
    background = tuple(median(channel) for channel in samples)
    out = []
    for row in range(height):
        line = list(rows[row])
        for column in range(width):
            if row < band or row >= height - band or column < band or column >= width - band:
                line[column] = (*background, 255)
        out.append(line)
    return out, {
        "operation": "flatten vignette",
        "method": "outer frame set to the median colour of the outer ring",
        "band_percent": EDGE_BAND * 100,
        "band_pixels": band,
        "ring_percent": EDGE_RING * 100,
        "ring_pixels": ring,
        "background_rgb": list(background),
    }


def span_weights(source: int, target: int) -> list[list[tuple[int, float]]]:
    """Exact area-overlap weights for one axis of a BOX resize."""
    scale = source / target
    out = []
    for cell in range(target):
        start, end = cell * scale, (cell + 1) * scale
        weights = []
        for pixel in range(int(start), min(source, int(end) + 1)):
            overlap = min(pixel + 1, end) - max(pixel, start)
            if overlap > 0:
                weights.append((pixel, overlap / scale))
        out.append(weights)
    return out


def box_downsample(rows: list[list[tuple[int, int, int, int]]], size: int) -> list[list[tuple[int, int, int]]]:
    """BOX average the square to size x size colour cells, alpha over white."""
    height, width = len(rows), len(rows[0])
    row_weights, column_weights = span_weights(height, size), span_weights(width, size)
    composited = [[tuple(round((pixel[3] / 255.0) * channel + (1.0 - pixel[3] / 255.0) * 255.0)
                         for channel in pixel[:3])
                   for pixel in line]
                  for line in rows]
    out = []
    for row_weights_cell in row_weights:
        line = []
        for column_weights_cell in column_weights:
            totals = [0.0, 0.0, 0.0]
            area = 0.0
            for row, row_weight in row_weights_cell:
                for column, column_weight in column_weights_cell:
                    weight = row_weight * column_weight
                    red, green, blue = composited[row][column]
                    totals[0] += red * weight
                    totals[1] += green * weight
                    totals[2] += blue * weight
                    area += weight
            line.append(tuple(min(255, max(0, round(total / area))) for total in totals))
        out.append(line)
    return out


def fills(rows: list[list[tuple[int, int, int, int]]], size: int) -> set[tuple[int, int]]:
    """Cells darker than mid-grey once alpha is composited over white."""
    if len(rows) != size or any(len(row) != size for row in rows):
        raise PictureError(f"pixel picture is not exactly {size}x{size}")
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


def runs(line: list[bool]) -> list[int]:
    """Run lengths of filled cells in one line."""
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


def clues(fill_set: set[tuple[int, int]], size: int) -> tuple[list[list[int]], list[list[int]]]:
    """Row and column clues of a fill set."""
    grid = [[(row, column) in fill_set for column in range(size)] for row in range(size)]
    row_clues = [runs(line) for line in grid]
    col_clues = [runs([grid[row][column] for row in range(size)]) for column in range(size)]
    return row_clues, col_clues


def line_placements(clue: list[int], n: int, known: list[bool | None]) -> list[tuple[bool, ...]]:
    """Every arrangement of this line's blocks that agrees with the known cells."""
    blocks = [block for block in clue if block > 0]
    if not blocks:
        return [] if any(cell is True for cell in known) else [tuple([False] * n)]
    if sum(blocks) + len(blocks) - 1 > n:
        return []
    out: list[tuple[bool, ...]] = []

    def place(index: int, start: int, cells: list[bool]) -> None:
        if index == len(blocks):
            line = cells + [False] * (n - start)
            if all(value is None or value == filled for value, filled in zip(known, line)):
                out.append(tuple(line))
            return
        block = blocks[index]
        rest = sum(blocks[index + 1:]) + (len(blocks) - index - 1)
        for begin in range(start, n - rest - block + 1):
            line = cells + [False] * (begin - start) + [True] * block
            if all(known[i] is None or known[i] == filled for i, filled in enumerate(line)):
                place(index + 1, len(line), line)

    place(0, 0, [])
    return out


def propagate(row_clues: list[list[int]], col_clues: list[list[int]], size: int,
              grid: list[list[bool | None]] | None = None) -> list[list[bool | None]] | None:
    """Line-logic propagation; None means the clues contradict each other."""
    grid = [[None] * size for _ in range(size)] if grid is None else [list(line) for line in grid]
    changed = True
    while changed:
        changed = False
        for row in range(size):
            known = grid[row]
            placements = line_placements(row_clues[row], size, known)
            if not placements:
                return None
            for column in range(size):
                values = {placement[column] for placement in placements}
                if len(values) == 1 and known[column] is None:
                    known[column] = values.pop()
                    changed = True
        for column in range(size):
            known = [grid[row][column] for row in range(size)]
            placements = line_placements(col_clues[column], size, known)
            if not placements:
                return None
            for row in range(size):
                values = {placement[row] for placement in placements}
                if len(values) == 1 and known[row] is None:
                    grid[row][column] = values.pop()
                    changed = True
    return grid


def count_solutions(row_clues: list[list[int]], col_clues: list[list[int]], size: int,
                    limit: int = 2) -> int:
    """How many solutions exist, stopping at `limit`."""
    grid = propagate(row_clues, col_clues, size)
    if grid is None:
        return 0

    def search(current: list[list[bool | None]]) -> int:
        pending = [(index, "row") for index, line in enumerate(current) if None in line]
        pending += [(index, "col") for index in range(size)
                    if any(current[row][index] is None for row in range(size))]
        if not pending:
            return 1
        best, best_count, best_placements = pending[0], None, None
        for index, kind in pending:
            if kind == "row":
                known = current[index]
                placements = line_placements(row_clues[index], size, known)
            else:
                known = [current[row][index] for row in range(size)]
                placements = line_placements(col_clues[index], size, known)
            if not placements:
                return 0
            if best_count is None or len(placements) < best_count:
                best, best_count, best_placements = (index, kind), len(placements), placements
        total = 0
        for placement in best_placements:
            trial = [list(line) for line in current]
            index, kind = best
            if kind == "row":
                trial[index] = list(placement)
            else:
                for row in range(size):
                    trial[row][index] = placement[row]
            solved = propagate(row_clues, col_clues, size, trial)
            if solved is None:
                continue
            total += search(solved)
            if total >= limit:
                return limit
        return total

    return search(grid)


def judge(fill_set: set[tuple[int, int]], size: int) -> dict:
    """Report uniqueness, line-logic reach, and the fill band for one puzzle."""
    row_clues, col_clues = clues(fill_set, size)
    grid = propagate(row_clues, col_clues, size)
    logic_solved = grid is not None and all(cell is not None for line in grid for cell in line)
    logic_fills = None
    if logic_solved:
        logic_fills = {(row, column) for row in range(size) for column in range(size)
                       if grid[row][column]}
    unique_count = count_solutions(row_clues, col_clues, size)
    filled = len(fill_set)
    return {
        "row_clues": row_clues,
        "col_clues": col_clues,
        "filled": filled,
        "in_band": FILL_MIN <= filled <= FILL_MAX,
        "band": [FILL_MIN, FILL_MAX],
        "unique": unique_count == 1,
        "solutions": unique_count,
        "logic_solved": logic_solved,
        "matches_pixel": logic_fills == fill_set if logic_solved else False,
    }


def report_for(pixel_path: Path, size: int) -> dict:
    rows = read_png(pixel_path)
    fill_set = fills(rows, size)
    result = judge(fill_set, size)
    result["pixel"] = str(pixel_path)
    result["size"] = size
    result["verdict"] = "pass" if (
        result["in_band"] and result["unique"] and result["logic_solved"]
        and result["matches_pixel"]) else "fail"
    return result


def derive(square: Path, pixel: Path, size: int) -> dict:
    rows = read_png(square)
    height, width = len(rows), len(rows[0])
    if height != width:
        raise PictureError(f"{square} is {width}x{height}, not square")
    flat, flatten_report = flatten_vignette(rows)
    cells = box_downsample(flat, size)
    write_png(pixel, cells)
    result = report_for(pixel, size)
    return {
        "square": str(square),
        "square_size": [width, height],
        "pixel": str(pixel),
        "size": size,
        "steps": [
            flatten_report,
            {
                "operation": "BOX downsample",
                "resample": "box",
                "to": f"{size}x{size}",
                "alpha": "composited over white",
            },
        ],
        "filled": result["filled"],
        "in_band": result["in_band"],
        "unique": result["unique"],
        "solutions": result["solutions"],
        "logic_solved": result["logic_solved"],
        "matches_pixel": result["matches_pixel"],
        "verdict": result["verdict"],
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="command", required=True)
    d = sub.add_parser("derive", help="flatten, BOX downsample, write the pixel, and judge")
    d.add_argument("--square", required=True, type=Path)
    d.add_argument("--pixel", required=True, type=Path)
    d.add_argument("--size", required=True, type=int)
    j = sub.add_parser("judge", help="judge an existing N x N pixel picture")
    j.add_argument("--pixel", required=True, type=Path)
    j.add_argument("--size", required=True, type=int)
    args = parser.parse_args(argv)
    try:
        if args.command == "derive":
            print(json.dumps(derive(args.square, args.pixel, args.size), separators=(",", ":")))
        else:
            print(json.dumps(report_for(args.pixel, args.size), separators=(",", ":")))
    except PictureError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
