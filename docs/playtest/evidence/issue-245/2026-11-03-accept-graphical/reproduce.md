# Reproduce — issue #245 acceptance run

Build: `main@88f10ef` (PR #363 squash), Godot 4.7.2.stable, macOS arm64 (use `XDG_DATA_HOME` instead of `HOME`
on Linux). A display is required for the screenshots; the run does not use Xvfb on macOS.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-245/2026-11-03-accept-graphical/tools
python3 expectations.py          # writes ../expect.json and asserts fills/clues/uniqueness/band/look data
```

`expectations.py` re-implements the issue's fixed fill rule (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B`
on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image threshold) and checks each committed
pixel against the committed pack row, plus the 56–101 fill band, the 1024² stored square, the clear border, and a
warm-pixel ratio below 0.02%. `nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-050 94 1 True True True True True True [1024, 1024] 0.0
pack-051 93 1 True True True True True True [1024, 1024] 0.0
pack-052 69 1 True True True True True True [1024, 1024] 0.0
pack-053 72 1 True True True True True True [1024, 1024] 1.5e-05
```

(The columns are filled, solutions, line-logic, fill set vs pixel, vs pack fills, vs row clues, vs col clues,
band, generated size, warm ratio.)

## 2. Graphical capture

```bash
RUN="$PWD/docs/playtest/evidence/issue-245/2026-11-03-accept-graphical"
git worktree add --detach /tmp/acc245 88f10ef
cp "$RUN/probe/probe_capture_245.gd" /tmp/acc245/game/probe_capture_245.gd
export HOME="$RUN/logs/userdata/home"          # Linux: export XDG_DATA_HOME="$RUN/logs/userdata"
mkdir -p "$RUN/screenshots" "$HOME"

godot --headless --path /tmp/acc245/game --import > "$RUN/logs/godot-import.log" 2>&1
godot --path /tmp/acc245/game -s res://probe_capture_245.gd -- \
    --debug-seams --session-id=issue-245-accept --build-id=main@88f10ef \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input,PTU-gallery-reset \
    --shot-dir="$RUN/screenshots" --run-folder="$RUN" --expect="$RUN/expect.json" \
    2>&1 | tee "$RUN/logs/capture-console.log"

rm /tmp/acc245/game/probe_capture_245.gd /tmp/acc245/game/probe_capture_245.gd.uid
```

The probe exits 1 unless all 17 judged states were saved and every check passed, so a section that dies early
cannot report a pass. Gestures are real `InputEventMouseButton` / `InputEventMouseMotion` events parsed through
`Input`, over the real cells; `DBG.2` is read after each one. A passing run reads
`capture: RESULT pass (17 shots, 0 checks failed)` with 62 `capture: PASS` lines.

The run's `HOME` keeps the progress save out of the runner's real player data; delete
`logs/userdata/home` afterwards if a clean `user://` is wanted.

## 3. Quality record

The deterministic record for this tree is
[`docs/quality/evidence/issue-245/2026-11-03-verify/manifest.md`](../../../../quality/evidence/issue-245/2026-11-03-verify/manifest.md).
Re-run its one selected axis with:

```bash
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=app-start \
    --run-dir=docs/quality/evidence/issue-245/2026-11-03-verify
```

## 4. Defect observation

The blank `EX.confirm` card on first open (defect #380) reproduces on this build without this slice: open any
completed puzzle's Reset on the gallery, then resize the window by one pixel — the box appears correctly only
after the resize. Screenshot `08-gallery-050-reset-confirm.png` is the blank first-open state.
