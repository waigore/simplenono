#!/usr/bin/env python3
"""Rebuild puzzles from existing flux/source_raw images (no API calls)."""

from __future__ import annotations

import json
import sys
from pathlib import Path

POC = Path(__file__).resolve().parent
OUT = POC / "out"
sys.path.insert(0, str(POC))
from pipeline import build_puzzle_from_image  # noqa: E402

# (slug, size)
SLUGS = (
    ("cat-sit", 15),
    ("teapot", 15),
    ("sailboat", 15),
    ("apple-10", 10),
    ("fish-10", 10),
)


def main() -> None:
    report = {
        "puzzles": [],
        "acceptable_count": 0,
        "style": "full-colour-pixelated",
        "requirement": "unique + line-logic only",
    }
    for slug, size in SLUGS:
        dest = OUT / slug
        raw = dest / "flux.png"
        if not raw.exists():
            raw = dest / "source_raw.png"
        if not raw.exists():
            raise SystemExit(f"missing flux image for {slug}")
        art = build_puzzle_from_image(raw, dest, slug=slug, size=size)
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
            f"{slug}: unique={art.unique} logic={art.logic_solved} "
            f"sweeps={art.sweeps} dfs={art.dfs_nodes} fill={art.fill_ratio:.0%} "
            f"ok={art.acceptable} ({art.reason})"
        )

    report["outcome_met"] = report["acceptable_count"] == len(SLUGS)
    (OUT / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))
    if not report["outcome_met"]:
        raise SystemExit(
            f"outcome not met: {report['acceptable_count']}/{len(SLUGS)} line-logic unique puzzles"
        )


if __name__ == "__main__":
    main()
