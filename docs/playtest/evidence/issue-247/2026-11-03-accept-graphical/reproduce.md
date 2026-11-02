# Reproduce — issue #247 acceptance run

Build: `main@12f2c8f` (deliverable PR #368 squash), Godot 4.7.2.stable, graphical on macOS
arm64 (Metal). A display is required; the run does not use Xvfb.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-247/2026-11-03-accept-graphical/tools
python3 expectations.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

`expectations.py` re-implements this issue's fixed fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma,
no per-image threshold) and checks each committed pixel against the committed pack row.
`nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-058 89 1 True True True True masses=45+44 holes=0
pack-059 70 1 True True True True masses=48+22 holes=0
pack-060 57 1 True True True True masses=57 holes=1
pack-061 73 1 True True True True masses=45+28 holes=0
expect.json written to .../expect.json
```

## 2. Derived-file checks on the same build

```bash
cd "$(git rev-parse --show-toplevel)"
python3 .github/scripts/generate_pack.py --check
python3 .github/scripts/asset_manifest.py --check
python3 .github/scripts/asset_catalog.py
python3 .github/scripts/spec_lint.py
```

`puzzle_derive.py` reproduces each committed pixel from its committed square and judges it; the
run's output is in [`logs/derive-judge.log`](logs/derive-judge.log):

```bash
for p in 058 059 060 061; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```

## 3. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-247/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_247.gd" game/probe_capture_247.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
godot --path game -s res://probe_capture_247.gd -- \
    --debug-seams --session-id=issue-247-accept --build-id=main@12f2c8f \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_247.gd game/probe_capture_247.gd.uid
```

The probe exits 1 unless all 9 judged states were saved and every check passed, so a section
that dies early cannot report a pass. Gestures are real `InputEventMouseButton` /
`InputEventMouseMotion` events parsed through `Input`, over the real cells; `DBG.2` is read
after each one. The probe scrolls the gallery to the slice's tiles before each gallery shot.

A passing run reads `capture: RESULT pass (9 shots, 0 checks failed)` with 36 `capture: PASS`
lines. The run's own console and state dump are under `logs/`.
