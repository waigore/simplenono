# Reproduce — issue #255 acceptance run

Build: `main@29a9295`, Godot 4.7.2.stable, graphical on macOS arm64 (Metal). A display is required; the run does not
use Xvfb. Run in a detached worktree at `29a9295` so the working tree's in-flight slice is not picked up.

## 0. The build carries this slice's pictures

```bash
python3 - <<'EOF'
import json, subprocess
def rows(rev):
    d = json.loads(subprocess.run(["git", "show", f"{rev}:game/data/pack.json"],
                                  capture_output=True, text=True).stdout)
    return {r["id"]: r for r in (d["puzzles"] if isinstance(d, dict) else d)}
a, b = rows("1e56ac1"), rows("29a9295")
for p in ["pack-090", "pack-091", "pack-092", "pack-093"]:
    print(p, "unchanged" if a[p] == b[p] else "CHANGED")
EOF
```

PR #381's squash (`1e56ac1`) landed `pack-090`–`pack-093`; the four rows are identical from `1e56ac1` to `29a9295`,
so this tree plays exactly the delivered rows.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-255/2026-11-03-accept-graphical/tools
python3 expectations_255.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma,
no per-image threshold) and checks each committed pixel against the committed pack row.
`nonogram.py` is its own line solver and enumerator; neither imports `.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-090 57 1 True True True True
pack-091 75 1 True True True True
pack-092 100 1 True True True True
pack-093 60 1 True True True True
expect.json written to .../expect.json
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-255/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_255.gd" game/probe_capture_255.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
godot --path game -s res://probe_capture_255.gd -- \
    --debug-seams --session-id=issue-255-accept --build-id=main@29a9295 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_255.gd game/probe_capture_255.gd.uid
```
