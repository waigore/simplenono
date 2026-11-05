#!/usr/bin/env python3
"""Issue #610 K5 pack-look closing audit: read the shipped pack and report the checks.

Run from the repo root:

    python3 docs/playtest/evidence/issue-610/2026-11-05-closing-audit/tools/pack_look_audit.py
    python3 .../pack_look_audit.py --json /tmp/pack-look-audit.json

What it reads (all from the tree it is run in, nothing from slice comments):

  A. every `pack-NNN` row's `V1` pair: two distinct ids, both catalogued,
     `approved`, `review` Pass, and resolvable through `assets/manifest.json`;
  B. the `TL.2` derive rule re-run from each committed square: flatten the outer
     5% frame to the median of the outer 1% ring, exact BOX downsample to N x N,
     fill at luma < 128 — the result must reproduce the committed pixel cells
     byte for byte and the committed `solution-fills` (S1, S2, S5, S6, K1–K3);
     the clues must have exactly one line-logic solution and it must be the
     committed fill set (S4, K3);
  C. variety across the 200 pictures (V2, K5): pairs that deliver the same N x N
     picture (equal under any rotation or flip), and pairs whose squares are
     perceptually close (normalised 32 x 32 RGB correlation), plus the groups of
     pairs generated from one identical prompt.

The derive and the judge here are written independently of
`.github/scripts/puzzle_derive.py`; they implement the same fixed rules, not the
same code. Exits 1 when A or B breaks, or when C finds a duplicated picture.
"""

from __future__ import annotations

import argparse
import collections
import itertools
import json
import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "..", ".."))
PACK = os.path.join(ROOT, "game", "data", "pack.json")
MANIFEST = os.path.join(ROOT, "assets", "manifest.json")
CATALOG = os.path.join(ROOT, "assets", "catalog")
ASSETS = os.path.join(ROOT, "game", "assets")
KIND = "AK-puzzle-pictures"
RECIPE = "AK-puzzle-pictures.R1"
BANDS = {10: (25, 45), 15: (56, 101), 20: (100, 180)}
FILL_LUMA = 128.0
EDGE_RING = 0.01
EDGE_BAND = 0.05
NEAR_TWIN = 0.95


def load(path: str):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def area_weights(source: int, target: int) -> np.ndarray:
    """target x source matrix of exact area-overlap weights for a BOX resize."""
    weights = np.zeros((target, source), dtype=np.float64)
    scale = source / target
    for cell in range(target):
        start, end = cell * scale, (cell + 1) * scale
        for pixel in range(int(start), min(source, int(end) + 1)):
            overlap = min(pixel + 1.0, end) - max(float(pixel), start)
            if overlap > 0:
                weights[cell, pixel] = overlap / scale
    return weights


def flatten_and_downsample(square: str, size: int) -> np.ndarray:
    """S5 flatten + S6 BOX copy of one committed square, as N x N RGB cells."""
    with Image.open(square) as image:
        pixels = np.asarray(image.convert("RGB"), dtype=np.float64)
    height, width = pixels.shape[:2]
    ring = max(1, round(min(height, width) * EDGE_RING))
    band = max(1, round(min(height, width) * EDGE_BAND))
    frame = np.ones((height, width), dtype=bool)
    frame[ring:height - ring, ring:width - ring] = False
    background = [sorted(pixels[:, :, channel][frame]) for channel in range(3)]
    background = np.array([sample[(len(sample) - 1) // 2] for sample in background])
    flat = pixels.copy()
    flat[:band, :] = background
    flat[height - band:, :] = background
    flat[:, :band] = background
    flat[:, width - band:] = background
    rows = np.einsum("ih,hwc->iwc", area_weights(height, size), flat)
    cells = np.einsum("jw,iwc->ijc", area_weights(width, size), rows)
    return np.round(cells).clip(0, 255)


def fills_of(cells: np.ndarray) -> set[tuple[int, int]]:
    luma = 0.2126 * cells[:, :, 0] + 0.7152 * cells[:, :, 1] + 0.0722 * cells[:, :, 2]
    return {(row, column) for row, column in zip(*np.where(luma < FILL_LUMA))}


def runs(values) -> list[int]:
    out, length = [], 0
    for value in values:
        if value:
            length += 1
        elif length:
            out.append(length)
            length = 0
    if length:
        out.append(length)
    return out


def clues(fill_set: set[tuple[int, int]], size: int):
    grid = [[(row, column) in fill_set for column in range(size)] for row in range(size)]
    rows = [runs(line) for line in grid]
    cols = [runs([grid[row][column] for row in range(size)]) for column in range(size)]
    return rows, cols


def placements(clue, size: int, known) -> list[tuple[bool, ...]]:
    blocks = [block for block in clue if block > 0]
    if not blocks:
        return [] if any(cell is True for cell in known) else [tuple([False] * size)]
    if sum(blocks) + len(blocks) - 1 > size:
        return []
    out: list[tuple[bool, ...]] = []

    def place(index: int, start: int, line: list[bool]) -> None:
        if index == len(blocks):
            candidate = line + [False] * (size - start)
            if all(value is None or value == cell for value, cell in zip(known, candidate)):
                out.append(tuple(candidate))
            return
        block = blocks[index]
        rest = sum(blocks[index + 1:]) + (len(blocks) - index - 1)
        for begin in range(start, size - rest - block + 1):
            candidate = line + [False] * (begin - start) + [True] * block
            if all(known[i] is None or known[i] == cell for i, cell in enumerate(candidate)):
                place(index + 1, len(candidate), candidate)

    place(0, 0, [])
    return out


def propagate(row_clues, col_clues, size: int, grid=None):
    grid = [[None] * size for _ in range(size)] if grid is None else [list(line) for line in grid]
    changed = True
    while changed:
        changed = False
        for row in range(size):
            found = placements(row_clues[row], size, grid[row])
            if not found:
                return None
            for column in range(size):
                values = {line[column] for line in found}
                if len(values) == 1 and grid[row][column] is None:
                    grid[row][column] = values.pop()
                    changed = True
        for column in range(size):
            known = [grid[row][column] for row in range(size)]
            found = placements(col_clues[column], size, known)
            if not found:
                return None
            for row in range(size):
                values = {line[row] for line in found}
                if len(values) == 1 and grid[row][column] is None:
                    grid[row][column] = values.pop()
                    changed = True
    return grid


def count_solutions(row_clues, col_clues, size: int, limit: int = 2) -> int:
    grid = propagate(row_clues, col_clues, size)
    if grid is None:
        return 0

    def search(current) -> int:
        open_lines = [(index, "row") for index, line in enumerate(current) if None in line]
        open_lines += [(index, "col") for index in range(size)
                       if any(current[row][index] is None for row in range(size))]
        if not open_lines:
            return 1
        best, best_found = None, None
        for index, kind in open_lines:
            known = (current[index] if kind == "row"
                     else [current[row][index] for row in range(size)])
            clue = row_clues[index] if kind == "row" else col_clues[index]
            found = placements(clue, size, known)
            if not found:
                return 0
            if best_found is None or len(found) < len(best_found):
                best, best_found = (index, kind), found
        total = 0
        for line in best_found:
            trial = [list(row) for row in current]
            index, kind = best
            if kind == "row":
                trial[index] = list(line)
            else:
                for row in range(size):
                    trial[row][index] = line[row]
            solved = propagate(row_clues, col_clues, size, trial)
            if solved is None:
                continue
            total += search(solved)
            if total >= limit:
                return limit
        return total

    return search(grid)


def dihedral_key(fill_set: set[tuple[int, int]], size: int) -> bytes:
    """Smallest byte string among this picture's 8 rotations and flips."""
    grid = np.zeros((size, size), dtype=np.uint8)
    for row, column in fill_set:
        grid[row, column] = 1
    variants = []
    for k in range(4):
        rotated = np.rot90(grid, k)
        variants += [rotated, np.fliplr(rotated)]
    return min(variant.tobytes() for variant in variants)


def is_symmetric(fill_set: set[tuple[int, int]], size: int) -> bool:
    """True when any rotation or flip of the fill reproduces the fill itself."""
    grid = np.zeros((size, size), dtype=np.uint8)
    for row, column in fill_set:
        grid[row, column] = 1
    for k in range(4):
        rotated = np.rot90(grid, k)
        if k and np.array_equal(rotated, grid):
            return True
        if np.array_equal(np.fliplr(rotated), grid):
            return True
    return False


def square_signature(square: str) -> np.ndarray:
    with Image.open(square) as image:
        small = np.asarray(image.convert("RGB").resize((32, 32), Image.BOX), dtype=np.float64)
    vector = small.reshape(-1)
    vector -= vector.mean()
    norm = np.linalg.norm(vector)
    return vector / norm if norm else vector


def colour_stats(square: str) -> tuple[float, float]:
    """Mean HSV saturation and the 5–95% hue span of one square."""
    with Image.open(square) as image:
        hsv = np.asarray(image.convert("RGB").resize((128, 128), Image.BOX).convert("HSV"),
                         dtype=np.float64) / 255.0
    return float(hsv[:, :, 1].mean()), float(np.percentile(hsv[:, :, 0], 95)
                                             - np.percentile(hsv[:, :, 0], 5))


def named_scene(prompt: str) -> str | None:
    """The scene a prompt names: its subject phrase, when it names one.

    The colour-picture policy composes `colourful multi-element scene of <subject> with a
    real background`; the retired clinical prompts describe cut-out geometry instead of a
    scene, so they name none.
    """
    marker = "colourful multi-element scene of "
    if marker not in prompt:
        return None
    tail = prompt.split(marker, 1)[1]
    return tail.split(" with a real background", 1)[0].strip().lower()


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--json", help="also write the findings as JSON here")
    args = parser.parse_args(argv)

    rows = [row for row in load(PACK) if str(row.get("id", "")).startswith("pack-")]
    manifest = load(MANIFEST)
    problems: list[str] = []
    derived: dict[str, dict] = {}
    grids: dict[str, set[tuple[int, int]]] = {}
    signatures: dict[str, np.ndarray] = {}
    prompts: dict[str, str] = {}
    bands: dict[int, list[str]] = collections.defaultdict(list)

    for row in rows:
        puzzle, size = row["id"], row["size"]
        bands[size].append(puzzle)
        picture, pixel = row["picture-id"], row["pixel-picture-id"]
        if picture == pixel:
            problems.append(f"{puzzle}: picture-id equals pixel-picture-id (I5)")
        for role, asset_id in (("square", picture), ("pixel", pixel)):
            path = os.path.join(CATALOG, f"{asset_id}.json")
            if not os.path.exists(path):
                problems.append(f"{puzzle}: no catalog entry for {role} {asset_id}")
                continue
            entry = load(path)
            if entry.get("kind_spec") != KIND:
                problems.append(f"{puzzle}: {role} kind_spec {entry.get('kind_spec')!r}")
            if entry.get("recipe") != RECIPE:
                problems.append(f"{puzzle}: {role} recipe {entry.get('recipe')!r}")
            if entry.get("state") != "approved":
                problems.append(f"{puzzle}: {role} state {entry.get('state')!r}")
            if (entry.get("review") or {}).get("verdict") != "Pass":
                problems.append(f"{puzzle}: {role} review {entry.get('review')!r}")
            listed = manifest.get(asset_id)
            if listed is None:
                problems.append(f"{puzzle}: {role} {asset_id} absent from assets/manifest.json")
            else:
                for res_path in listed:
                    disk = os.path.join(ROOT, "game", res_path.split("res://", 1)[-1])
                    if not os.path.exists(disk):
                        problems.append(f"{puzzle}: {role} file missing on disk: {res_path}")

        square_path = os.path.join(ASSETS, "puzzle-pictures", f"{puzzle}-generated.png")
        pixel_path = os.path.join(ASSETS, "puzzle-pictures", f"{puzzle}-pixel.png")
        cells = flatten_and_downsample(square_path, size)
        with Image.open(pixel_path) as stored:
            committed = np.asarray(stored.convert("RGB"), dtype=np.int16)
        reproduced = np.abs(committed - cells.astype(np.int16)).max() <= 1
        fill_set = fills_of(committed.astype(np.float64))
        fill_grid = {(row_, column) for row_, column in row["solution-fills"]}
        row_clues, col_clues = clues(fill_set, size)
        low, high = BANDS[size]
        logic = propagate(row_clues, col_clues, size)
        solved = logic is not None and all(cell is not None for line in logic for cell in line)
        logic_fills = ({(r, c) for r in range(size) for c in range(size) if logic[r][c]}
                       if solved else None)
        derived[puzzle] = {
            "size": size,
            "reproduced": bool(reproduced),
            "pixel_matches_solution": fill_set == fill_grid,
            "filled": len(fill_set),
            "in_band": low <= len(fill_set) <= high,
            "solutions": count_solutions(row_clues, col_clues, size),
            "logic_solved": solved,
            "logic_matches": logic_fills == fill_set,
            "clues_match": row_clues == [list(c) for c in row["row-clues"]]
            and col_clues == [list(c) for c in row["col-clues"]],
            "dihedral_symmetric": is_symmetric(fill_set, size),
        }
        if not all(derived[puzzle][key] for key in
                   ("reproduced", "pixel_matches_solution", "in_band", "logic_solved",
                    "logic_matches", "clues_match")):
            problems.append(f"{puzzle}: derive/judge facts disagree — {derived[puzzle]}")
        if derived[puzzle]["solutions"] != 1:
            problems.append(f"{puzzle}: {derived[puzzle]['solutions']} solutions, not 1 (K3)")
        grids[puzzle] = fill_grid
        signatures[puzzle] = square_signature(square_path)
        prompts[puzzle] = load(os.path.join(CATALOG, f"{picture}.json"))["generation"]["prompt"]

    # C. variety across the 200 pictures
    by_key: dict[bytes, list[str]] = collections.defaultdict(list)
    for puzzle, grid in grids.items():
        by_key[dihedral_key(grid, derived[puzzle]["size"])].append(puzzle)
    duplicates = [sorted(group) for group in by_key.values() if len(group) > 1]

    pairs_in_pack = {r["id"]: load(os.path.join(CATALOG, f"{r['picture-id']}.json"))["version"]
                     for r in rows}
    same_prompt: dict[str, list[str]] = collections.defaultdict(list)
    for puzzle, prompt in prompts.items():
        same_prompt[prompt].append(puzzle)
    prompt_groups = sorted((sorted(g) for g in same_prompt.values() if len(g) > 1),
                           key=len, reverse=True)

    scenes: dict[tuple[str, int], list[str]] = collections.defaultdict(list)
    for puzzle, prompt in prompts.items():
        scene = named_scene(prompt)
        if scene:
            scenes[(scene, derived[puzzle]["size"])].append(puzzle)
    scene_groups = sorted((sorted(g) for g in scenes.values() if len(g) > 1),
                          key=len, reverse=True)

    near_twins = []
    ids = sorted(signatures)
    for a, b in itertools.combinations(ids, 2):
        if derived[a]["size"] != derived[b]["size"]:
            continue
        score = float(signatures[a] @ signatures[b])
        if score >= NEAR_TWIN:
            near_twins.append((round(score, 3), a, b))
    near_twins.sort(reverse=True)

    band_summary = {}
    for size in sorted(bands):
        stats = [colour_stats(os.path.join(ASSETS, "puzzle-pictures", f"{p}-generated.png"))
                 for p in bands[size]]
        band_summary[size] = {
            "pairs": len(bands[size]),
            "mean_saturation": round(float(np.mean([s for s, _ in stats])), 3),
            "mean_hue_span": round(float(np.mean([h for _, h in stats])), 3),
            "versions": dict(collections.Counter(pairs_in_pack[p] for p in bands[size])),
        }

    report = {
        "pack": {"pairs": len(rows), "unique_pictures": len(by_key),
                 "manifest_entries": len(manifest)},
        "bands": band_summary,
        "problems": problems,
        "duplicate_pictures": duplicates,
        "near_twins": near_twins,
        "prompt_groups": prompt_groups,
        "scene_groups": scene_groups,
        "symmetric_fills": sorted(p for p, facts in derived.items()
                                  if facts["dihedral_symmetric"]),
        "per_pair": derived,
    }

    print(f"Pack rows: {len(rows)}; distinct N x N pictures: {len(by_key)}; "
          f"manifest entries: {len(manifest)}")
    for size in sorted(bands):
        info = band_summary[size]
        print(f"  {size}x{size}: {info['pairs']} pairs, mean saturation "
              f"{info['mean_saturation']:.3f}, mean 5-95% hue span {info['mean_hue_span']:.3f}, "
              f"catalog versions {info['versions']}")
    print(f"A+B problems: {len(problems)}")
    for line in problems:
        print(f"  ! {line}")
    print(f"C duplicated pictures (same grid under rotation/flip): {len(duplicates)}")
    for group in duplicates:
        print(f"  dup {group}")
    print(f"C near-twin square pairs (correlation >= {NEAR_TWIN}): {len(near_twins)}")
    for score, a, b in near_twins:
        print(f"  twin {score:.3f} {a} {b}")
    print(f"C identical-prompt groups: {len(prompt_groups)}; "
          f"pairs sharing a prompt with another pair: "
          f"{sum(len(g) for g in prompt_groups)}")
    for group in prompt_groups[:8]:
        print(f"  prompt x{len(group)} {group[:10]}{' …' if len(group) > 10 else ''}")
    print(f"C named-scene groups repeated within a size band: {len(scene_groups)}")
    for group in scene_groups:
        print(f"  scene x{len(group)} {group}")
    print(f"C pairs whose fill has a dihedral symmetry (K4 asymmetry): "
          f"{len(report['symmetric_fills'])} {report['symmetric_fills'][:10]}")

    if args.json:
        with open(args.json, "w", encoding="utf-8") as fh:
            json.dump(report, fh, indent=2)
            fh.write("\n")

    return 1 if problems or duplicates or scene_groups else 0


if __name__ == "__main__":
    raise SystemExit(main())
