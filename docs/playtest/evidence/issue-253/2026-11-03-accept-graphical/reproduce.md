# Reproduce — issue #253 acceptance run

Build: `main@49dc0c6`, Godot 4.7.2.stable, graphical on macOS arm64 (Metal). A display is
required; the run does not use Xvfb.

## 0. The build carries this slice's pictures

```bash
python3 - <<'EOF'
import json, subprocess
rec = json.loads(subprocess.run(
    ["git", "show", "ddb453e:game/data/pack.json"], capture_output=True, text=True).stdout)
now = json.load(open("game/data/pack.json"))
a = {r["id"]: r for r in rec}; b = {r["id"]: r for r in now}
for p in ["pack-082", "pack-083", "pack-084", "pack-085"]:
    print(p, "unchanged" if a[p] == b[p] else "CHANGED")
EOF
```

PR #378's squash (`ddb453e`) landed `pack-082`–`pack-085`; the four rows are byte-identical
from `ddb453e` to `49dc0c6`, so this tree plays exactly the delivered rows. Later slices only
add their own pictures and rows.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-253/2026-11-03-accept-graphical/tools
python3 expectations_253.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma,
no per-image threshold) and checks each committed pixel against the committed pack row.
`nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-082 56 1 True True True True
pack-083 56 1 True True True True
pack-084 68 1 True True True True
pack-085 74 1 True True True True
expect.json written to .../expect.json
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-253/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_253.gd" game/probe_capture_253.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
godot --path game -s res://probe_capture_253.gd -- \
    --debug-seams --session-id=issue-253-accept --build-id=main@49dc0c6 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_253.gd game/probe_capture_253.gd.uid
```
