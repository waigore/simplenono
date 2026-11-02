#!/usr/bin/env python3
"""Drive one puzzle-picture slice: generate squares, derive pixels, judge, retry.

Drop-in companion to `.github/scripts/puzzle_derive.py` for the picture-slice tasks
under epic #98. For each puzzle it:

  1. asks Cheaper Inference `flux-2-max` for a 1024x1024 square (TL.1, R1);
  2. converts the returned JPEG to PNG without resampling;
  3. runs `puzzle_derive.py derive` (TL.2): flatten the vignette, BOX-downsample to
     N x N, read the fill set with the fixed luma rule, and judge it;
  4. keeps the square only when the judge passes (25-45 filled, one solution, line
     logic reaches it, solution equals the pixel); otherwise it regenerates from a
     new prompt until an attempt passes.

Look review (K4, AES.P1) stays with `review-asset`; this script does not decide it.

Usage:
  python3 .github/scripts/picture_slice.py \
    --out-dir /tmp/pictures \
    --manifest /tmp/pictures/slice.json \
    pack-004=multi \
    pack-010=15x15:single

Each `KEY=CLASS` names the pack row id and its assigned subject class
(`single` or `multi`). An optional `WIDTHxHEIGHT:` prefix picks a board config:
`pack-010=15x15:single` uses the 15x15 prompt set. Without a prefix the 10x10
config applies, which is what the earlier slices used. The board config fixes the
derive size and the prompts, so the readable-at-NxN wording always matches the
board the picture is stored for.

The script prints one JSON line per attempt and writes the accepted squares,
pixels, and a per-puzzle record to the manifest.

Output PNGs written here are working files; the slice task copies the accepted four
files per puzzle into `game/assets/puzzle-pictures/` and catalogues them.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[2]
GENERATOR = REPO_ROOT / ".github" / "scripts" / "cheaperinference_image.py"
DERIVER = REPO_ROOT / ".github" / "scripts" / "puzzle_derive.py"
MODEL = "flux-2-max"
SIZE = "1024x1024"

MASTER = "Calm clinical still-life; clear silhouette; readable at {board}."
NEGATIVE = "playful chrome; gore; horror"

# Subject words for prompts that name a mass. Each attempt uses the next word, so a
# retry is always a new prompt.
SUBJECTS = ["L-shaped caliper block", "thick T-shaped brace", "short crossbar brace",
            "twisted column", "hook brace", "three-lobed clamp", "stepped wedge brace",
            "H-shaped spacer", "bold C-clamp", "short broad T-shaped bracket",
            "W-shaped bracket"]

_TAIL = ("plain smooth solid silhouette, one flat dark colour, no pattern, no highlight, "
         "no reflection, no gradient, no texture, plain even pale cool grey background, no "
         "vignette, no border, no shadow, flat even lighting, strong high contrast, calm "
         "clinical still-life, readable as a 10x10 icon, no text")

SINGLE_PROMPTS_10 = [
    # A cut-out paper grid is the only prompt family that reliably lands the subject
    # several cells thick: pixel art and voxel wording collapse to one cell. Attempts
    # 1-4 ask for a grid-wide shape, 5-8 for a wider-tile variant of it.
    "a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a pale cool "
    "grey background: one bold continuous ring six cells thick around a four-cell square hole, "
    "each cell about 7 percent of the frame width, hard crisp square edges, no shadow, no "
    "reflection, no gradient, no texture, flat even lighting, strong high contrast, calm "
    "clinical still-life, readable as a 10x10 icon, no text",
    "a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a pale cool "
    "grey background: a wide bar across the upper third and a narrow stem below it, the bar "
    "seven cells wide and three cells tall, the stem two cells wide and four cells tall, each "
    "cell about 7 percent of the frame width, hard crisp square edges, no shadow, no "
    "reflection, no gradient, no texture, flat even lighting, strong high contrast, calm "
    "clinical still-life, readable as a 10x10 icon, no text",
    "a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a pale cool "
    "grey background: a heavy thick C nine cells tall and seven cells wide with a clear three "
    "cell gap on its right side, each cell about 7 percent of the frame width, hard crisp "
    "square edges, no shadow, no reflection, no gradient, no texture, flat even lighting, "
    "strong high contrast, calm clinical still-life, readable as a 10x10 icon, no text",
    "a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a pale cool "
    "grey background: one solid tall block eight cells wide and eight cells tall with a "
    "two-cell-wide notch cut into its top edge, each cell about 7 percent of the frame width, "
    "hard crisp square edges, no shadow, no reflection, no gradient, no texture, flat even "
    "lighting, strong high contrast, calm clinical still-life, readable as a 10x10 icon, no text",
    "a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a pale cool "
    "grey background: one bold continuous ring five tiles thick around a two-tile square hole, "
    "tiles four times wider than the paper thickness, each tile about 10 percent of the frame "
    "width, hard crisp square edges, no shadow, no reflection, no gradient, no texture, flat "
    "even lighting, strong high contrast, calm clinical still-life, readable as a 10x10 icon, no text",
    "a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a pale cool "
    "grey background: a wide bar across the upper half and a narrow stem below it, the bar "
    "eight tiles wide and four tiles tall, the stem three tiles wide and four tiles tall, "
    "tiles about 10 percent of the frame width, hard crisp square edges, no shadow, no "
    "reflection, no gradient, no texture, flat even lighting, strong high contrast, calm "
    "clinical still-life, readable as a 10x10 icon, no text",
    "a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a pale cool "
    "grey background: a heavy C eight tiles tall and seven tiles wide with a clear three-tile "
    "gap on its right side, tiles about 10 percent of the frame width, hard crisp square "
    "edges, no shadow, no reflection, no gradient, no texture, flat even lighting, strong high "
    "contrast, calm clinical still-life, readable as a 10x10 icon, no text",
    "a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a pale cool "
    "grey background: one tall block seven tiles wide and eight tiles tall with a two-tile "
    "notch cut into its top edge, tiles about 10 percent of the frame width, hard crisp square "
    "edges, no shadow, no reflection, no gradient, no texture, flat even lighting, strong high "
    "contrast, calm clinical still-life, readable as a 10x10 icon, no text",
]

MULTI_PROMPTS_10 = [SINGLE_PROMPTS_10[0], SINGLE_PROMPTS_10[4], SINGLE_PROMPTS_10[5],
                    SINGLE_PROMPTS_10[2], SINGLE_PROMPTS_10[3], SINGLE_PROMPTS_10[6],
                    SINGLE_PROMPTS_10[7]]


def _prompt_15(shape: str) -> str:
    """A 15x15 cut-out paper grid prompt for one shape, sized in board cells."""
    return ("a flat top-down photograph of a dark slate blue-grey paper cut-out grid over a "
            "pale cool grey background: " + shape + ", each cell about 6.7 percent of the "
            "frame width, hard crisp square edges, no shadow, no reflection, no gradient, no "
            "texture, flat even lighting, strong high contrast, calm clinical still-life, "
            "readable as a 15x15 icon, no text")


# 15x15 prompt set. A cell is only about 4.7 percent of frame area, and the generator
# draws a subject smaller than asked, so shapes are named large: a mass spanning ten or
# more of the fifteen cells to read as twenty-five per cent or more after the box
# downsample, and clear of the frame edge so the flattened band does not eat it.
# Attempts 1-4 are single masses, 5-8 keep a second mass or a hole for the
# multi-subject slices, 9-12 are wider-tile variants, 13-16 leave a margin.
SINGLE_PROMPTS_15 = [
    _prompt_15("one tall block that fills most of the frame, about fourteen cells wide and "
               "fourteen cells tall, with a four-cell notch cut out of its right side"),
    _prompt_15("a heavy C filling most of the frame, about fifteen cells tall and fourteen "
               "cells wide, its arms four cells thick, with a clear eight-cell opening on its "
               "right side"),
    _prompt_15("a bold square outline filling most of the frame, about fifteen cells across, "
               "its frame four cells thick, around an eight-cell square hole in the middle"),
    _prompt_15("a solid stepped tower that fills most of the frame, fifteen cells tall, "
               "twelve cells wide at its base, ten in the middle band, six at its top"),
    _prompt_15("two thick separate blocks filling the frame, a ten-cell tall block on the left "
               "and an eight-cell tall block on the right, three cells apart"),
    _prompt_15("a large square outline filling most of the frame, fifteen cells on a side with "
               "four-cell-thick walls and a six-cell hole low in its left wall, and a six-cell "
               "cube on the right"),
    _prompt_15("a wide flat slab filling most of the frame, fifteen cells across and six cells "
               "tall, with two four-cell square holes cut through it and one column standing "
               "below it on the right"),
    _prompt_15("a wide flat cap fifteen cells across and five cells tall standing on a "
               "six-cell-wide base, with two four-cell rectangular holes cut through the cap"),
    _prompt_15("one very thick continuous ring filling most of the frame, fifteen cells "
               "across, six cells of the frame, around a nine-cell square hole"),
    _prompt_15("a wide bar across the top two thirds of the frame and a thick stem below it, "
               "the bar fifteen cells wide and eight tiles tall, the stem six cells wide"),
    _prompt_15("a very thick C filling most of the frame, fifteen tiles tall and fourteen "
               "tiles wide, tiles four cells thick, with a clear eight-cell opening on its "
               "right side"),
    _prompt_15("one very thick tall block filling most of the frame, fourteen tiles wide and "
               "fifteen tiles tall with a six-tile notch cut into its top edge, tiles four "
               "cells thick"),
    _prompt_15("one heavy solid mass filling most of the frame and split by a wide clear "
               "cross-shaped channel, two thick arms twelve cells long and five cells thick"),
    _prompt_15("two heavy separate solid blocks filling the frame with a clear gap between "
               "them, one tall block on the left and a shorter wide block on the right, a "
               "four-cell gap through the middle"),
    _prompt_15("two solid masses on a pale background, a tall narrow block on the left about "
               "fourteen cells tall and six cells wide and a wide flat slab on the right about "
               "eight cells tall and seven cells wide, a clear four-cell gap between them"),
    _prompt_15("a solid horizontal bar about twelve cells long and five cells tall near the "
               "top and a separate square mass about six cells on a side below its right end, "
               "a clear three-cell gap between them"),
]

# 15x15 single-subject attempts, tried before the FRAME set. A mass that fills the
# frame passes the fill band but downsamples to a solid slab with no silhouette, so
# these ask for a single outline whose own hole or channel survives at NxN, with the
# shape well inside the frame.
SINGLE_ONLY_15 = [
    _prompt_15("the outline of one bold squarish ring eleven cells across and eleven cells "
               "tall, its frame four cells thick, on a pale background, with one clear "
               "seven-cell square hole in the middle"),
    _prompt_15("the outline of a bold plus sign eleven cells tall and eleven cells wide "
               "standing on a pale background, its arms four cells thick"),
    _prompt_15("the outline of a bold keyhole standing on a pale background: a ring about "
               "nine cells across on a flaring four-cell-wide stem, with one clear hole in "
               "the ring"),
    _prompt_15("the outline of a bold arch standing on a pale background, twelve cells tall "
               "and eleven cells wide, four cells thick, with one clear opening beneath it"),
    _prompt_15("the outline of a bold letter E standing on a pale background, twelve cells "
               "tall and eleven cells wide, its bars four cells thick"),
    _prompt_15("the outline of a bold right-pointing arrow standing on a pale background, a "
               "shaft in the middle with a triangular head four cells thick"),
    _prompt_15("the outline of a bold stair step silhouette rising to the right in four steps "
               "on a pale background, each step four cells wide and four cells tall"),
]

# Board configs: derive size and the single/multi prompt sets. The 10x10 config is
# the default so the earlier slices re-run unchanged.
BOARDS = {
    "10x10": {"size": 10, "single": SINGLE_PROMPTS_10, "multi": MULTI_PROMPTS_10},
    "15x15": {
        "size": 15,
        "single": SINGLE_PROMPTS_15,
        "single": SINGLE_ONLY_15 + SINGLE_PROMPTS_15,
        "multi": [SINGLE_PROMPTS_15[index]
                  for index in (14, 15, 13, 12, 4, 6, 5, 7, 0, 2, 8)],
    },
}
DEFAULT_BOARD = "10x10"



def compose(prompt: str, board: str = DEFAULT_BOARD) -> str:
    return f"{prompt}. {MASTER.format(board=board)} Avoid: {NEGATIVE}."


def api_key() -> str:
    for name in ("CHEAPERINFERENCE_API_KEY", "CHEAPER_INFERENCE_API_KEY"):
        value = os.environ.get(name, "").strip()
        if value:
            return value
    raise SystemExit("CHEAPERINFERENCE_API_KEY is not set in this shell")


def parse_target(raw: str) -> tuple[str, str, str]:
    """`KEY=CLASS` or `KEY=BOARD:CLASS` -> (key, class, board)."""
    key, _, rest = raw.partition("=")
    board = DEFAULT_BOARD
    if ":" in rest:
        board, _, klass = rest.partition(":")
    else:
        klass = rest
    if not key or klass not in ("single", "multi"):
        raise SystemExit(f"bad target {raw!r}; expected KEY=single or KEY=[BOARD:]multi")
    if board not in BOARDS:
        raise SystemExit(f"bad board {board!r}; expected one of {', '.join(sorted(BOARDS))}")
    return key, klass, board


def prompts_for(klass: str, board: str = DEFAULT_BOARD) -> list[str]:
    """One prompt per attempt: each template with a different subject word."""
    templates = BOARDS[board][klass]
    out = []
    for index, template in enumerate(templates):
        word = SUBJECTS[index % len(SUBJECTS)]
        out.append(template.replace("{subject}", word))
    return out


def generate(prompt: str, out_dir: Path, key: str, attempt: int, key_env: str) -> tuple[Path, dict]:
    raw = out_dir / f"{key}-attempt{attempt}.jpg"
    env = dict(os.environ, CHEAPERINFERENCE_API_KEY=key_env)
    proc = subprocess.run(
        [sys.executable, str(GENERATOR), "generate", "--prompt", compose(prompt),
         "--out", str(raw), "--model", MODEL, "--size", SIZE],
        capture_output=True, text=True, env=env,
    )
    if proc.returncode != 0:
        raise SystemExit(f"generation failed for {key}: {proc.stderr.strip()[:500]}")
    meta = json.loads(proc.stdout.strip().splitlines()[-1])
    square = Path(meta["out"])
    png = out_dir / f"{key}-attempt{attempt}.png"
    with Image.open(square) as image:
        image.convert("RGB").save(png, format="PNG")
    if square != png:
        square.unlink(missing_ok=True)
    return png, meta


def derive(square: Path, pixel: Path, size: int = BOARDS[DEFAULT_BOARD]["size"]) -> dict:
    proc = subprocess.run(
        [sys.executable, str(DERIVER), "derive", "--square", str(square),
         "--pixel", str(pixel), "--size", str(size)],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        return {"verdict": "error", "error": proc.stderr.strip()[:500]}
    return json.loads(proc.stdout.strip().splitlines()[-1])


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("targets", nargs="+")
    parser.add_argument("--fresh", action="store_true",
                        help="ignore an existing manifest and start these targets over")
    args = parser.parse_args(argv)
    key_env = api_key()
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    manifest = Path(args.manifest)
    record: dict[str, dict] = {}
    if manifest.is_file() and not args.fresh:
        record = json.loads(manifest.read_text() or "{}")
    for raw in args.targets:
        key, klass, board = parse_target(raw)
        if record.get(key, {}).get("accepted"):
            continue
        attempts = []
        accepted = None
        for attempt, prompt in enumerate(prompts_for(klass, board), start=1):
            composed = compose(prompt, board)
            square, meta = generate(composed, out_dir, key, attempt, key_env)
            pixel = out_dir / f"{key}-attempt{attempt}-pixel.png"
            report = derive(square, pixel, BOARDS[board]["size"])
            ok = report.get("verdict") == "pass"
            flatten = next((step for step in report.get("steps", [])
                            if isinstance(step, dict) and "background_rgb" in step), {})
            entry = {
                "attempt": attempt,
                "board": board,
                "prompt": composed,
                "square": str(square),
                "pixel": str(pixel),
                "request_id": meta.get("request_id"),
                "billing": meta.get("billing"),
                "judge": {k: report.get(k) for k in
                          ("filled", "in_band", "unique", "solutions", "logic_solved",
                           "matches_pixel", "verdict")},
                "flatten": flatten,
            }
            attempts.append(entry)
            print(json.dumps({"puzzle": key, "attempt": attempt,
                              "filled": report.get("filled"),
                              "unique": report.get("unique"),
                              "logic_solved": report.get("logic_solved"),
                              "matches_pixel": report.get("matches_pixel"),
                              "in_band": report.get("in_band"),
                              "ok": ok}), flush=True)
            if ok:
                accepted = entry
                break
        record[key] = {"class": klass, "board": board, "accepted": accepted,
                       "attempts": len(attempts), "log": attempts}
        manifest.write_text(json.dumps(record, indent=2) + "\n")
    missing = [k for k in record if not record[k]["accepted"]]
    if missing:
        print(f"no accepted picture for: {', '.join(missing)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
