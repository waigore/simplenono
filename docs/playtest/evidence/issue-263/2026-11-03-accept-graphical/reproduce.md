# Reproduce — issue #263 acceptance run

Build: `main@fb99b16`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 900×1200, no
`--headless`).

## 0. The build carries this slice's pictures

```bash
git diff --name-only 9053c8c fb99b16 -- \
  game/assets/puzzle-pictures/pack-122* game/assets/puzzle-pictures/pack-123* \
  game/assets/puzzle-pictures/pack-124* game/assets/puzzle-pictures/pack-125*
```

Expected: no output for the eight picture files and their sidecars. `game/data/pack.json` may differ in other rows
only; `pack-122`–`pack-125` compare equal row for row between `9053c8c` and `fb99b16`.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-263/2026-11-03-accept-graphical/tools
python3 expectations_263.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`.

Expected output (one line per puzzle, then `expect.json written to ...`):

```
pack-122 61 1 True True True True | masses [46, 15] holes 0 | ...
pack-123 84 1 True True True True | masses [84] holes 0 | ...
pack-124 85 1 True True True True | masses [85] holes 0 | ...
pack-125 61 1 True True True True | masses [37, 24] holes 0 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-263/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_263.gd" game/probe_capture_263.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_263.gd -- \
    --debug-seams --session-id=issue-263-accept --build-id=main@fb99b16 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_263.gd game/probe_capture_263.gd.uid
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
for p in 122 123 124 125; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```
