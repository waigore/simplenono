#!/usr/bin/env python3
"""Drive one puzzle-picture slice: generate squares, derive pixels, judge, retry.

Drop-in companion to `.github/scripts/puzzle_derive.py` for the picture-slice
tasks. For each puzzle it:

  1. asks Cheaper Inference `flux-2-max` for a 1024x1024 square (TL.1, R1);
  2. converts the returned JPEG to PNG without resampling;
  3. runs `puzzle_derive.py derive` (TL.2): flatten the vignette, BOX-downsample to
     N x N, read the fill set with the fixed luma rule, and judge it;
  4. keeps the square only when the judge passes (25-45 filled, one solution, line
     logic reaches it, solution equals the pixel); otherwise it regenerates from a
     new prompt until the plan runs out.

Prompts are not built here. Since the #564 / #570 spec amendment the composed
prompt comes from the kind recipe (`specs/assets/kinds/puzzle-pictures/recipes.md`
R1) and the kind's `prompt_policy` (`specs/assets/kinds/puzzle-pictures/style-series.md`),
written per puzzle and supplied through an attempt-plan file:

    {"pack-004": {"board": "10x10", "prompts": ["…", "…"]},
     "pack-010": {"board": "15x15", "prompts": ["…"]}}

Each prompt is one composed attempt (a retry is always a new prompt). A board's
derive size comes from the file's `board` key or the `KEY=BOARD` target form look-up
in BOARDS. Look review (K4) stays with `review-asset`; this script does not decide
it.

Usage:
  python3 .github/scripts/picture_slice.py \
    --out-dir /tmp/pictures \
    --manifest /tmp/pictures/slice.json \
    --attempt-prompts /tmp/pictures/attempt_prompts.json \
    pack-004 pack-010=15x15

The script prints one JSON line per attempt and writes the accepted squares,
pixels, and a per-puzzle record to the manifest.

Output PNGs written here are working files; the slice task copies the accepted
files per puzzle into `game/assets/puzzle-pictures/` and catalogues them.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
GENERATOR = REPO_ROOT / ".github" / "scripts" / "cheaperinference_image.py"
DERIVER = REPO_ROOT / ".github" / "scripts" / "puzzle_derive.py"
MODEL = "flux-2-max"
SIZE = "1024x1024"

# Board configs: the derive size per board name. Prompts live in the attempt-plan
# file so the slice's composed wording stays with the issue that authored it.
BOARDS = {"10x10": {"size": 10}, "15x15": {"size": 15}, "20x20": {"size": 20}}
DEFAULT_BOARD = "10x10"


def api_key() -> str:
    for name in ("CHEAPERINFERENCE_API_KEY", "CHEAPER_INFERENCE_API_KEY"):
        value = os.environ.get(name, "").strip()
        if value:
            return value
    raise SystemExit("CHEAPERINFERENCE_API_KEY is not set in this shell")


def load_attempt_plan(path: Path) -> dict[str, dict]:
    """{key: {"board": board, "prompts": [str, …]}} from an attempt-plan file.

    Board defaults to `10x10` when the entry omits it; every omitted or wrong key
    fails loudly here instead of sending the wrong board's derive size later.
    """
    plan = json.loads(path.read_text())
    if not isinstance(plan, dict) or not plan:
        raise SystemExit(f"{path} is not a non-empty JSON object")
    for key, entry in plan.items():
        if not isinstance(entry, dict) or not isinstance(entry.get("prompts"), list) \
                or not entry["prompts"]:
            raise SystemExit(f"{path}: key {key!r} needs a non-empty 'prompts' list")
        if not all(isinstance(prompt, str) and prompt.strip()
                   for prompt in entry["prompts"]):
            raise SystemExit(f"{path}: key {key!r} has an empty attempt prompt")
        board = entry.get("board", DEFAULT_BOARD)
        if board not in BOARDS:
            raise SystemExit(f"{path}: key {key!r} has board {board!r}; "
                             f"expected one of {', '.join(sorted(BOARDS))}")
        entry["board"] = board
    return plan


def parse_target(raw: str, plan: dict[str, dict]) -> tuple[str, str, list[str]]:
    """`KEY` or `KEY=BOARD` -> (key, board, attempt prompts)."""
    key, _, board = raw.partition("=")
    if not key:
        raise SystemExit(f"bad target {raw!r}; expected KEY or KEY=BOARD")
    entry = plan.get(key)
    if entry is None:
        raise SystemExit(f"no attempt plan for {key!r} in the attempt-prompts file")
    board = board or entry.get("board", DEFAULT_BOARD)
    if board not in BOARDS:
        raise SystemExit(f"bad board {board!r}; expected one of {', '.join(sorted(BOARDS))}")
    return key, board, entry["prompts"]


TRANSIENT_HTTP_CODES = ("HTTP 429", "HTTP 500", "HTTP 502", "HTTP 503", "HTTP 504")
TRANSIENT_RETRIES = 5
TRANSIENT_WAIT_SECONDS = 20.0


def is_transient(stderr: str) -> bool:
    """A provider error worth asking again for; anything else aborts the slice."""
    return any(code in stderr for code in TRANSIENT_HTTP_CODES)


def generate(composed: str, out_dir: Path, key: str, attempt: int, key_env: str,
             retries: int = TRANSIENT_RETRIES,
             wait: float = TRANSIENT_WAIT_SECONDS) -> tuple[Path, dict]:
    """Generate one square from an already-composed prompt (the caller composes).

    A transient provider error (rate limit or gateway) is not a judge failure: the
    slice asks again for the same prompt, so a 503 does not throw away the run.
    """
    raw = out_dir / f"{key}-attempt{attempt}.jpg"
    env = dict(os.environ, CHEAPERINFERENCE_API_KEY=key_env)
    for remaining in range(retries + 1):
        proc = subprocess.run(
            [sys.executable, str(GENERATOR), "generate", "--prompt", composed,
             "--out", str(raw), "--model", MODEL, "--size", SIZE],
            capture_output=True, text=True, env=env,
        )
        if proc.returncode == 0:
            break
        stderr = proc.stderr.strip()
        if remaining == retries or not is_transient(stderr):
            raise SystemExit(f"generation failed for {key}: {stderr[:500]}")
        print(json.dumps({"puzzle": key, "attempt": attempt, "transient_error": stderr[:200],
                          "retry_in_seconds": wait}), flush=True)
        time.sleep(wait)
    meta = json.loads(proc.stdout.strip().splitlines()[-1])
    square = Path(meta["out"])
    png = out_dir / f"{key}-attempt{attempt}.png"
    # Pillow is only needed for this conversion, so import it here: the pure helpers
    # stay importable (and testable) without it, as the stdlib-only linter CI expects.
    from PIL import Image

    with Image.open(square) as image:
        image.convert("RGB").save(png, format="PNG")
    if square != png:
        square.unlink(missing_ok=True)
    return png, meta


def derive(square: Path, pixel: Path, size: int) -> dict:
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
    parser.add_argument("--attempt-prompts", required=True, dest="attempt_prompts")
    parser.add_argument("targets", nargs="+")
    parser.add_argument("--fresh", action="store_true",
                        help="ignore an existing manifest and start these targets over")
    args = parser.parse_args(argv)
    key_env = api_key()
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    manifest = Path(args.manifest)
    plan_path = Path(args.attempt_prompts)
    plan = load_attempt_plan(plan_path)
    record: dict[str, dict] = {}
    if manifest.is_file() and not args.fresh:
        record = json.loads(manifest.read_text() or "{}")
    failed: list[str] = []
    for raw in args.targets:
        key, board, prompts = parse_target(raw, plan)
        if record.get(key, {}).get("accepted"):
            continue
        attempts = []
        accepted = None
        size = BOARDS[board]["size"]
        for attempt, composed in enumerate(prompts, start=1):
            square, meta = generate(composed, out_dir, key, attempt, key_env)
            pixel = out_dir / f"{key}-attempt{attempt}-pixel.png"
            report = derive(square, pixel, size)
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
        if accepted is None:
            failed.append(key)
            print(json.dumps({"puzzle": key, "attempts": len(attempts),
                              "rejected": True}), flush=True)
        record[key] = {"attempt_prompts": str(plan_path), "board": board,
                       "accepted": accepted, "attempts": len(attempts),
                       "log": attempts}
        manifest.write_text(json.dumps(record, indent=2) + "\n")
    missing = [key for key in record if not record[key].get("accepted")]
    if failed:
        print(f"no accepted picture for: {', '.join(failed)}", file=sys.stderr)
    if missing:
        print(f"manifest has no accepted picture for: {', '.join(missing)}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
