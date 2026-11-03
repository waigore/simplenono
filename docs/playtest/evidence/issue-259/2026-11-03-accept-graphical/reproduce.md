# Reproduce — issue #259 acceptance run

Build: `main@8f66c6a`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 900×1200, no
`--headless`).

## 0. The build carries this slice's pictures

```bash
git diff --name-only 95a46c4 8f66c6a -- \
  game/assets/puzzle-pictures/pack-106* game/assets/puzzle-pictures/pack-107* \
  game/assets/puzzle-pictures/pack-108* game/assets/puzzle-pictures/pack-109*
```

Expected: no output for the eight picture files and their sidecars. `95a46c4` is PR #399's squash (the commit this
issue's implementation and verification comments cite). `game/data/pack.json` may differ in other rows only;
`pack-106`–`pack-109` compare equal row for row between `95a46c4` and `8f66c6a`, and the eight catalog entries are
unchanged too.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-259/2026-11-03-accept-graphical/tools
python3 expectations_259.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`.

Expected output (one line per puzzle, then `expect.json written to ...`):

```
pack-106 56 1 True True True True
pack-107 79 1 True True True True
pack-108 56 1 True True True True
pack-109 78 1 True True True True
```

Columns: filled / 225, solution count, line logic solves it, logic equals pixel, pixel equals pack `solution-fills`,
pixel equals pack `row-clues`/`col-clues`.

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-259/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_259.gd" game/probe_capture_259.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_259.gd -- \
    --debug-seams --session-id=issue-259-accept --build-id=main@8f66c6a \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log); the `DBG.2` dump lands in `logs/state-pack-109.json`.

## 3. Remove the probe

```bash
rm game/probe_capture_259.gd game/probe_capture_259.gd.uid
```

## 4. Look numbers and an independent square → pixel re-derive

```bash
cd docs/playtest/evidence/issue-259/2026-11-03-accept-graphical/tools
python3 recheck_259.py --root "$(git rev-parse --show-toplevel)" | tee ../logs/recheck.log
```

Prints per puzzle: filled count, connected masses and enclosed cells, luma mean/p5/p95, subject-versus-background
contrast, the flatten background recovered from the committed square, and the largest per-cell colour difference
against the committed pixel.

## 5. Collect the bar's own derive and judge record

```bash
for p in 106 107 108 109; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```

Expected: `cmp: identical` four times and `"verdict":"pass"` four times. Log of record:
[`logs/derive-judge.log`](logs/derive-judge.log).

## 6. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # Asset manifest: 0 error(s).
python3 .github/scripts/asset_catalog.py             # Asset catalog: 0 error(s).
python3 .github/scripts/spec_lint.py                 # Spec lint: 0 error(s), 1 warning(s)
```
