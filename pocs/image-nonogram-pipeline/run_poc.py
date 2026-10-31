#!/usr/bin/env python3
"""Generate three Flux silhouettes and run the image→nonogram pipeline."""

from __future__ import annotations

import json
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

SUBJECTS = [
    {
        "slug": "cat-sit",
        "prompt": (
            "High-contrast flat illustration of a sitting cat in pure side profile silhouette, "
            "solid dark charcoal shape on a plain light gray background, clear outer outline, "
            "no texture, no pattern, no text, no cuteness props, calm clinical graphic design, "
            "centered subject, square composition"
        ),
    },
    {
        "slug": "teapot",
        "prompt": (
            "High-contrast flat illustration of a classic teapot silhouette, solid dark shape "
            "on plain light gray background, clear outer outline with spout and handle readable, "
            "no texture, no text, calm clinical graphic design, centered, square composition"
        ),
    },
    {
        "slug": "sailboat",
        "prompt": (
            "High-contrast flat illustration of a large sailboat, thick solid black silhouette "
            "filling most of the frame, big triangular sail and chunky hull as one connected "
            "dark mass on plain light gray background, bold clear outline, no thin lines, "
            "no waves, no text, calm clinical graphic design, centered, square composition"
        ),
    },
]


def generate_image(prompt: str, out_path: Path) -> Path:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    env = dict(**{k: v for k, v in __import__("os").environ.items()})
    # macOS python.org builds often need certifi for TLS
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
    # script may rewrite extension
    if out_path.exists():
        return out_path
    for alt in out_path.parent.glob(out_path.stem + ".*"):
        return alt
    raise SystemExit(f"no image written for {out_path}")


def main() -> None:
    if OUT.exists():
        shutil.rmtree(OUT)
    OUT.mkdir(parents=True)

    report = {"puzzles": [], "acceptable_count": 0}
    for subj in SUBJECTS:
        slug = subj["slug"]
        dest = OUT / slug
        dest.mkdir(parents=True)
        source = generate_image(subj["prompt"], dest / "source.png")
        # normalize name
        if source.name != "source.png" and source.exists():
            fixed = dest / f"source{source.suffix}"
            if source != fixed:
                shutil.move(str(source), str(fixed))
                source = fixed
        art = build_puzzle_from_image(source, dest, slug=slug, size=15)
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
            "source": str(source.relative_to(POC)),
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
