#!/usr/bin/env python3
"""Generate three full-colour Flux subjects, pixelate to grid, build nonograms."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
POC = Path(__file__).resolve().parent
OUT = POC / "out"
SCRIPT = ROOT / ".github" / "scripts" / "cheaperinference_image.py"

sys.path.insert(0, str(POC))
from pipeline import build_puzzle_from_image  # noqa: E402

# Full colour, clear subjects, flat even background (no vignette) for clean pixelation.
SUBJECTS = [
    {
        "slug": "cat-sit",
        "prompt": (
            "Full-color flat illustration of a sitting cat in side profile, soft teal and coral "
            "clinical palette, solid readable outer shape, simple cel-shaded colour blocks, "
            "plain even light gray background with no vignette and no border, centered, "
            "square composition, no text, calm graphic design"
        ),
    },
    {
        "slug": "teapot",
        "prompt": (
            "Full-color flat illustration of a classic teapot, muted blue body with warm accent "
            "lid knob, clear spout and handle silhouette, simple cel-shaded colour blocks, "
            "plain even light gray background with no vignette and no border, centered, "
            "square composition, no text, calm clinical graphic design"
        ),
    },
    {
        "slug": "sailboat",
        "prompt": (
            "Full-color flat illustration of a sailboat with two sails and a hull, navy and "
            "cream sails, teal hull, large connected shapes filling the frame, simple cel-shaded "
            "colour blocks, plain even light gray background with no vignette and no border, "
            "centered, square composition, no text, calm clinical graphic design"
        ),
    },
]


def generate_image(prompt: str, out_path: Path) -> Path:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ)
    try:
        import certifi

        env.setdefault("SSL_CERT_FILE", certifi.where())
    except ImportError:
        pass
    cmd = [
        sys.executable,
        str(SCRIPT),
        "generate",
        "--prompt",
        prompt,
        "--out",
        str(out_path),
        "--size",
        "1024x1024",
        "--model",
        "flux-2-max",
    ]
    print("RUN", " ".join(cmd[:6]), "...")
    proc = subprocess.run(cmd, cwd=str(ROOT), capture_output=True, text=True, env=env)
    if proc.returncode != 0:
        print(proc.stdout)
        print(proc.stderr, file=sys.stderr)
        raise SystemExit(f"image generate failed for {out_path}")
    if proc.stdout.strip():
        print("META", proc.stdout.strip())
    if out_path.exists():
        return out_path
    for alt in out_path.parent.glob(out_path.stem + ".*"):
        return alt
    raise SystemExit(f"no image written for {out_path}")


def main() -> None:
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)

    report = {"puzzles": [], "acceptable_count": 0, "style": "full-colour-pixelated"}
    for subj in SUBJECTS:
        slug = subj["slug"]
        dest = OUT / slug
        dest.mkdir(parents=True)
        raw_path = generate_image(subj["prompt"], dest / "flux.png")
        art = build_puzzle_from_image(raw_path, dest, slug=slug, size=15)
        entry = {
            "slug": slug,
            "size": art.size,
            "fill_ratio": round(art.fill_ratio, 4),
            "unique": art.unique,
            "logic_solved": art.logic_solved,
            "sweeps": art.sweeps,
            "dfs_nodes": art.dfs_nodes,
            "acceptable": art.acceptable,
            "reason": art.reason,
            "threshold": art.threshold,
            "adapt_flips": art.adapt_flips,
            "source": f"out/{slug}/source.png",
            "source_raw": f"out/{slug}/source_raw.png",
            "morph_preview": f"out/{slug}/morph_preview.png",
        }
        report["puzzles"].append(entry)
        if art.acceptable:
            report["acceptable_count"] += 1
        print(
            f"PUZZLE {slug}: size={art.size} fill={art.fill_ratio:.0%} "
            f"unique={art.unique} logic={art.logic_solved} dfs={art.dfs_nodes} "
            f"ok={art.acceptable} ({art.reason})"
        )

    report["outcome_met"] = report["acceptable_count"] >= 3
    (OUT / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))
    if not report["outcome_met"]:
        raise SystemExit(
            f"outcome not met: {report['acceptable_count']}/3 acceptable puzzles"
        )


if __name__ == "__main__":
    main()
