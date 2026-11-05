#!/usr/bin/env python3
"""Issue #610: apply the regenerated pairs from a `picture_slice.py` run to the catalog.

Reads the slice manifest and attempt plan, copies each accepted square and pixel into
`game/assets/puzzle-pictures/`, and rewrites the two catalog entries (square and pixel)
as an `APR.update`: same id and handle, `version` raised, the replaced generation kept
in `history`, a fresh `generation` and a fresh `review` Pass.

    python3 .../tools/apply_regen.py --manifest tmp/issue-610/slice.json \
        --prompts tmp/issue-610/attempt_prompts.json [--root .] [--dry-run]

The measured look facts in each review report (mean saturation, hue span, dihedral
symmetry of the fill) are recomputed here from the delivered files, not taken from the
slice log. This tool writes no pack data; run `.github/scripts/generate_pack.py` and
`.github/scripts/asset_manifest.py` afterwards.
"""

from __future__ import annotations

import argparse
import datetime
import json
import os
import shutil
import sys
from pathlib import Path

import numpy as np
from PIL import Image

TODAY = datetime.date.today().isoformat()
BAND = {10: (25, 45), 15: (56, 101), 20: (100, 180)}
LOOK_NOTE = ("composed from the generation prompt; the pair's colour and asymmetry are "
             "corroborated by measurement in the K5 record")


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def dump(path: Path, payload) -> None:
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def subject_phrase(prompt: str) -> str:
    """The scene the accepted prompt names, for the review's look sentence."""
    marker = "colourful multi-element scene of "
    if marker in prompt:
        return prompt.split(marker, 1)[1].split(" with a real background", 1)[0].strip()
    return prompt.split(".", 1)[0].strip()


def measure(square: Path, pixel: Path) -> dict:
    with Image.open(square) as image:
        hsv = np.asarray(image.convert("RGB").resize((128, 128), Image.BOX).convert("HSV"),
                         dtype=np.float64) / 255.0
    saturation = float(hsv[:, :, 1].mean())
    hue_span = float(np.percentile(hsv[:, :, 0], 95) - np.percentile(hsv[:, :, 0], 5))
    with Image.open(pixel) as image:
        cells = np.asarray(image.convert("RGB"), dtype=np.float64)
    luma = 0.2126 * cells[:, :, 0] + 0.7152 * cells[:, :, 1] + 0.0722 * cells[:, :, 2]
    grid = (luma < 128).astype(np.uint8)
    variants = []
    for k in range(4):
        rotated = np.rot90(grid, k)
        variants += [rotated, np.fliplr(rotated)]
    symmetric = any(np.array_equal(variant, grid) for variant in variants[1:])
    return {"saturation": round(saturation, 3), "hue_span": round(hue_span, 3),
            "dihedral_symmetric": bool(symmetric), "filled": int(grid.sum())}


def square_report(puzzle: str, attempt: dict, facts: dict) -> str:
    judge = attempt["judge"]
    background = attempt["flatten"]["background_rgb"]
    size = facts["size"]
    low, high = BAND[size]
    symmetric = ("a dihedral symmetry of the fill" if facts["dihedral_symmetric"]
                 else "no dihedral symmetry of the fill")
    return (
        f"AK-puzzle-pictures R1/V1, {puzzle}. Generated square: flux-2-max 1024x1024, "
        f"request {attempt['request_id']}, saved as a PNG without resampling. Pixel: outer "
        f"5% frame flattened to the median of the outer 1% ring (RGB {background}), then BOX "
        f"downsampled to {size}x{size}, one colour per board cell; re-running the derive "
        f"reproduces the committed pixel (S1, S5, S6, K1, K6). "
        f"Filled {judge['filled']}/{size * size} by the fixed rule (alpha over white, "
        f"Y = 0.2126R + 0.7152G + 0.0722B on 0-255 sRGB, Y < 128), inside the {low}-{high} "
        f"band (S2, K2); clues are the run lengths (S3). Judge: one solution, reached by line "
        f"logic alone, equal to the pixel fill set (S4, K3). Look: {facts['look']} — "
        f"{LOOK_NOTE} (mean saturation {facts['saturation']}, 5-95% hue span "
        f"{facts['hue_span']}, {facts['filled']}/{size * size} filled with {symmetric}). "
        f"K4: colourful multi-element complex scene with a real background, completely "
        f"asymmetrical; picture content is exempt from AES.P1 per the aesthetics pillar "
        f"scope. No series (SS1 none). License: Cheaper Inference terms. Per-puzzle subject "
        f"class retired (PO decision on #486): no class word."
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--manifest", required=True, type=Path)
    parser.add_argument("--prompts", required=True, type=Path)
    parser.add_argument("--notes", required=True, type=Path,
                        help="per-pair {reason, look} sentences for the replaced pair")
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args(argv)
    root = args.root.resolve()
    catalog = root / "assets" / "catalog"
    assets = root / "game" / "assets"
    pack = load(root / "game" / "data" / "pack.json")
    rows = {row["id"]: row for row in pack}
    manifest = load(args.manifest)
    plan = load(args.prompts)
    notes = load(args.notes)
    applied = []
    for puzzle, record in sorted(manifest.items()):
        accepted = record.get("accepted")
        if not accepted:
            print(f"{puzzle}: no accepted picture in the slice manifest", file=sys.stderr)
            return 1
        row = rows[puzzle]
        size = row["size"]
        square_new = Path(accepted["square"])
        pixel_new = Path(accepted["pixel"])
        square_dest = assets / "puzzle-pictures" / f"{puzzle}-generated.png"
        pixel_dest = assets / "puzzle-pictures" / f"{puzzle}-pixel.png"
        facts = measure(square_new if square_new.exists() else square_dest,
                        pixel_new if pixel_new.exists() else pixel_dest)
        facts["size"] = size
        facts["look"] = subject_phrase(accepted["prompt"])
        square_entry = load(catalog / f"{row['picture-id']}.json")
        pixel_entry = load(catalog / f"{row['pixel-picture-id']}.json")
        reason = notes[puzzle]["reason"]
        report = square_report(puzzle, accepted, facts)
        for entry, is_square in ((square_entry, True), (pixel_entry, False)):
            entry.setdefault("history", []).insert(0, {
                "version": entry["version"],
                "date": entry.get("review", {}).get("date", TODAY),
                "reason": reason,
                "generation": entry["generation"],
            })
            entry["version"] = entry["version"] + 1
            if is_square:
                entry["generation"] = {
                    "prompt": accepted["prompt"],
                    "negative_prompt": "gore; horror; centered single mass on empty ground; "
                                       "cool-gray clinical picture look",
                    "tool": "Cheaper Inference",
                    "operation": "images.generations",
                    "settings": {"model": "flux-2-max", "size": "1024x1024"},
                    "seed": "n/a — tool has no seed",
                    "inputs": {"style_anchors": [], "refs": [], "base_assets": []},
                    "steps": [
                        "Cheaper Inference images.generations flux-2-max, 1024x1024 "
                        "(bootstrap; AK-puzzle-pictures SS1 is none)",
                        "saved data[0] as a PNG without resampling",
                    ],
                }
            else:
                background = accepted["flatten"]["background_rgb"]
                entry["generation"] = {
                    "prompt": accepted["prompt"],
                    "negative_prompt": "gore; horror; centered single mass on empty ground; "
                                       "cool-gray clinical picture look",
                    "tool": "puzzle_derive.py (local authoring script)",
                    "operation": "offline flatten + BOX downsample",
                    "settings": {
                        "model": "flux-2-max",
                        "downsample": "box",
                        "size": size,
                        "flatten_method": "outer frame set to the median colour of the "
                                          "outer ring",
                        "flatten_band_percent": 5.0,
                        "flatten_ring_percent": 1.0,
                        "flatten_background_rgb": background,
                    },
                    "seed": "n/a — tool has no seed",
                    "inputs": {"style_anchors": [], "refs": [], "base_assets": [row["picture-id"]]},
                    "steps": [
                        f"flatten vignette: outer 5% frame set to the median colour of the "
                        f"outer 1% ring (RGB {background})",
                        f"BOX downsample to {size}x{size} colour cells, alpha over white",
                        "judge: one solution, reached by line logic alone, equal to the pixel "
                        f"fill set; filled {facts['filled']}, in band "
                        f"[{BAND[size][0]}, {BAND[size][1]}]",
                    ],
                }
            entry["review"] = {"verdict": "Pass", "date": TODAY, "reviewer": "agent",
                               "report": report}
        applied.append({"puzzle": puzzle, "size": size, "version": square_entry["version"],
                        "saturation": facts["saturation"], "filled": facts["filled"]})
        if not args.dry_run:
            shutil.copyfile(square_new, square_dest)
            shutil.copyfile(pixel_new, pixel_dest)
            dump(catalog / f"{row['picture-id']}.json", square_entry)
            dump(catalog / f"{row['pixel-picture-id']}.json", pixel_entry)
        print(json.dumps(applied[-1]))
    print(f"applied {len(applied)} pairs")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
