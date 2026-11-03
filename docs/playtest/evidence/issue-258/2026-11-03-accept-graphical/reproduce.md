# Reproduce — issue #258 acceptance run

Build: `main@7d3cd10`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 900×1200, no
`--headless`).

## 0. The build carries this slice's pictures

```bash
git diff --name-only 84082e1 7d3cd10 -- \
  game/assets/puzzle-pictures/pack-102* game/assets/puzzle-pictures/pack-103* \
  game/assets/puzzle-pictures/pack-104* game/assets/puzzle-pictures/pack-105* game/data/pack.json
```

Expected: no output for the eight picture files and their sidecars; `game/data/pack.json` may differ only in other
rows (`pack-102`–`pack-105` compare equal row for row).

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-258/2026-11-03-accept-graphical/tools
python3 expectations_258.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-102 89 1 True True True True
pack-103 75 1 True True True True
pack-104 61 1 True True True True
pack-105 93 1 True True True True
expect.json written to .../expect.json
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-258/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_258.gd" game/probe_capture_258.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_258.gd -- \
    --debug-seams --session-id=issue-258-accept --build-id=main@7d3cd10 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_258.gd game/probe_capture_258.gd.uid
```
