# Reproduce — issue #246 acceptance run

Build: `main@f5fa471` (deliverable PR #366 squash), Godot 4.7.2.stable, graphical on macOS
arm64 (Metal). A display is required; the run does not use Xvfb.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-246/2026-11-03-accept-graphical/tools
python3 expectations.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

`expectations.py` re-implements this issue's fixed fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma,
no per-image threshold) and checks each committed pixel against the committed pack row.
`nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-054 63 1 True True True True
pack-055 58 1 True True True True
pack-056 76 1 True True True True
pack-057 60 1 True True True True
expect.json written to .../expect.json
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-246/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_246.gd" game/probe_capture_246.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
godot --path game -s res://probe_capture_246.gd -- \
    --debug-seams --session-id=issue-246-accept --build-id=main@f5fa471 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_246.gd game/probe_capture_246.gd.uid
```

The probe exits 1 unless all 9 judged states were saved and every check passed, so a section
that dies early cannot report a pass. Gestures are real `InputEventMouseButton` /
`InputEventMouseMotion` events parsed through `Input`, over the real cells; `DBG.2` is read
after each one. The probe scrolls the gallery to the slice's tiles before each gallery shot.

A passing run reads `capture: RESULT pass (9 shots, 0 checks failed)` with 35 `capture: PASS`
lines. The run's own console and state dump are under `logs/`.
