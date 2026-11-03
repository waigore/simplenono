# Reproduce — issue #262 acceptance run

Build: `main@1161953`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 900×1200, no
`--headless`).

## 0. The build carries this slice's pictures

```bash
git diff --name-only fdbfa63 1161953 -- \
  game/assets/puzzle-pictures/pack-118* game/assets/puzzle-pictures/pack-119* \
  game/assets/puzzle-pictures/pack-120* game/assets/puzzle-pictures/pack-121* game/data/pack.json
```

Expected: no output for the eight picture files and their sidecars; `game/data/pack.json` may differ only in other
rows (`pack-118`–`pack-121` compare equal row for row).

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-262/2026-11-03-accept-graphical/tools
python3 expectations_262.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`.

Expected output (one line per puzzle, then `expect.json written to ...`):

```
pack-118 62 1 True True True True | masses [36, 26] holes 0 | ...
pack-119 79 1 True True True True | masses [47, 32] holes 0 | ...
pack-120 84 1 True True True True | masses [84] holes 0 | ...
pack-121 73 1 True True True True | masses [43, 30] holes 0 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-262/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_262.gd" game/probe_capture_262.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_262.gd -- \
    --debug-seams --session-id=issue-262-accept --build-id=main@1161953 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_262.gd game/probe_capture_262.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s)
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
```
