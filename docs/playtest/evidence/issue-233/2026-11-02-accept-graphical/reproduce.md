# Reproduce — issue #233 acceptance run

Build: `main@7192358` (deliverable `f082f98`; `git diff f082f98 7192358 -- game/` is empty, so the played tree is the
deliverable tree), Godot 4.7.2.stable, Linux, a display or Xvfb.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-233/2026-11-02-accept-graphical/tools
python3 expectations.py          # writes ../expect.json and asserts fills/clues/uniqueness/band
```

`expectations.py` re-implements this issue's fixed fill rule (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B`
on 0–255 sRGB, filled when `Y < 128`, BOX 1024→10, no gamma, no per-image threshold) and checks each committed pixel
against the committed pack row. `nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-004 40 1 True True True
pack-005 31 1 True True True
pack-006 30 1 True True True
pack-007 30 1 True True True
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-233/2026-11-02-accept-graphical
cp "$RUN/probe/probe_capture_233.gd" game/probe_capture_233.gd
export XDG_DATA_HOME="$PWD/$RUN/logs/userdata"   # keep the run's user:// out of ~/.local/share
mkdir -p "$RUN/screenshots"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1000x1300x24" godot --path game -s res://probe_capture_233.gd -- \
    --debug-seams --session-id=issue-233-accept --build-id=main@f082f98 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input,PTU-gallery-reset \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_233.gd game/probe_capture_233.gd.uid
```

The probe exits 1 unless all 11 judged states were saved and every check passed, so a section that dies early cannot
report a pass. Gestures are real `InputEventMouseButton` / `InputEventMouseMotion` events parsed through `Input`, over the
real cells; `DBG.2` is read after each one.

A passing run reads `capture: RESULT pass (11 shots, 0 checks failed)` with 41 `capture: PASS` lines.

## Quality record

The deterministic record for this tree is
[`docs/quality/evidence/issue-233/2026-11-02-verify/manifest.md`](../../../../quality/evidence/issue-233/2026-11-02-verify/manifest.md).
Re-run its one selected axis with:

```bash
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=app-start \
    --run-dir=docs/quality/evidence/issue-233/2026-11-02-verify
```
