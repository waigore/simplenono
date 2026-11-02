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
    pack-007=single

Each `KEY=CLASS` names the pack row id and its assigned subject class
(`single` or `multi`). The script prints one JSON line per attempt and writes the
accepted squares, pixels, and a per-puzzle record to the manifest.

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

MASTER = "Calm clinical still-life; clear silhouette; readable at 10x10."
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

SINGLE_PROMPTS = [
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

MULTI_PROMPTS = [SINGLE_PROMPTS[0], SINGLE_PROMPTS[4], SINGLE_PROMPTS[5], SINGLE_PROMPTS[2],
                 SINGLE_PROMPTS[3], SINGLE_PROMPTS[6], SINGLE_PROMPTS[7]]



def compose(prompt: str) -> str:
    return f"{prompt}. {MASTER} Avoid: {NEGATIVE}."


def api_key() -> str:
    for name in ("CHEAPERINFERENCE_API_KEY", "CHEAPER_INFERENCE_API_KEY"):
        value = os.environ.get(name, "").strip()
        if value:
            return value
    raise SystemExit("CHEAPERINFERENCE_API_KEY is not set in this shell")


def parse_target(raw: str) -> tuple[str, str]:
    key, _, klass = raw.partition("=")
    if not key or klass not in ("single", "multi"):
        raise SystemExit(f"bad target {raw!r}; expected KEY=single or KEY=multi")
    return key, klass


def prompts_for(klass: str) -> list[str]:
    """One prompt per attempt: each template with a different subject word."""
    templates = SINGLE_PROMPTS if klass == "single" else MULTI_PROMPTS
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


def derive(square: Path, pixel: Path) -> dict:
    proc = subprocess.run(
        [sys.executable, str(DERIVER), "derive", "--square", str(square),
         "--pixel", str(pixel), "--size", "10"],
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
    args = parser.parse_args(argv)
    key_env = api_key()
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    manifest = Path(args.manifest)
    record: dict[str, dict] = {}
    if manifest.is_file():
        record = json.loads(manifest.read_text() or "{}")
    for raw in args.targets:
        key, klass = parse_target(raw)
        if record.get(key, {}).get("accepted"):
            continue
        attempts = []
        accepted = None
        for attempt, prompt in enumerate(prompts_for(klass), start=1):
            square, meta = generate(prompt, out_dir, key, attempt, key_env)
            pixel = out_dir / f"{key}-attempt{attempt}-pixel.png"
            report = derive(square, pixel)
            ok = report.get("verdict") == "pass"
            flatten = next((step for step in report.get("steps", [])
                            if isinstance(step, dict) and "background_rgb" in step), {})
            entry = {
                "attempt": attempt,
                "prompt": compose(prompt),
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
        record[key] = {"class": klass, "accepted": accepted,
                       "attempts": len(attempts), "log": attempts}
        manifest.write_text(json.dumps(record, indent=2) + "\n")
    missing = [k for k in record if not record[k]["accepted"]]
    if missing:
        print(f"no accepted picture for: {', '.join(missing)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
