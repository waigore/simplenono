# Reproduce — issue #610 acceptance run

From the repo root, on the build under acceptance (`main@006de2c`):

```bash
# 1. Independent expectations from the committed pixels (writes expect.json).
python3 docs/playtest/evidence/issue-610/2026-11-05-accept-graphical/tools/expectations_610.py \
    --root . \
    --out docs/playtest/evidence/issue-610/2026-11-05-accept-graphical/expect.json

# 2. Import, then run the graphical capture (probe copied into game/ for the run).
godot --headless --path game --import
cp docs/playtest/evidence/issue-610/2026-11-05-accept-graphical/probe/probe_capture_610.gd game/
xvfb-run -a -s "-screen 0 1000x1300x24" godot --path game -s res://probe_capture_610.gd -- \
    --debug-seams \
    --session-id=issue-610-accept \
    --build-id=main@006de2c \
    --story-ids=PTU-play-puzzle,PTU-mark-input,PTD-ready-and-marks,PTD-crosses-and-fills,PTD-solve-and-pb \
    --shot-dir=/tmp/issue-610/screenshots \
    --run-folder=/tmp/issue-610 \
    --expect=docs/playtest/evidence/issue-610/2026-11-05-accept-graphical/expect.json
rm game/probe_capture_610.gd

# 3. The AC 4 commands and the regression suite.
python3 .github/scripts/asset_catalog.py
python3 .github/scripts/asset_manifest.py --check
python3 .github/scripts/generate_pack.py --check
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
.github/scripts/smoke_run.sh
```

The capture exits 0 and prints `capture: RESULT pass (12 shots, 0 checks failed)`.
Screenshots and the capture log are on the wiki page cited in `manifest.md`.
