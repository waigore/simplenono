# Reproduce — issue #269 acceptance run

Build: `main@ff5ae1f`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 900×1200, no
`--headless`).

## 0. The build carries this slice's pictures

```bash
git diff --name-only 1e75c62 ff5ae1f -- \
  game/assets/puzzle-pictures/pack-146* game/assets/puzzle-pictures/pack-147* \
  game/assets/puzzle-pictures/pack-148* game/assets/puzzle-pictures/pack-149*
```

Expected: no output for the eight picture files and their sidecars. `game/data/pack.json` may differ in other rows
only; `pack-146`–`pack-149` compare equal row for row between `1e75c62` and `ff5ae1f`, and the eight catalog entries
are unchanged too.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-269/2026-11-03-accept-graphical/tools
python3 expectations_269.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`.

Expected output (one line per puzzle, then `expect.json written to ...`):

```
pack-146 81 1 True True True True | masses [45, 36] holes 0 | ...
pack-147 59 1 True True True True | masses [59] holes 0 | ...
pack-148 95 1 True True True True | masses [55, 40] holes 0 | ...
pack-149 80 1 True True True True | masses [40, 40] holes 0 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-269/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_269.gd" game/probe_capture_269.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_269.gd -- \
    --debug-seams --session-id=issue-269-accept --build-id=main@ff5ae1f \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_269.gd game/probe_capture_269.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s)
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
```

The derive and judge of record are in [`logs/derive-judge.log`](logs/derive-judge.log):

```bash
for p in 146 147 148 149; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```
