# Reproduce — issue #252 acceptance run

Build: `main@c41c104`, Godot 4.7.2.stable, graphical on macOS arm64 (Metal). A display is
required; the run does not use Xvfb.

## 0. The build carries this slice's pictures

```bash
git diff --stat ee57b38 c41c104 -- game/assets/puzzle-pictures game/data/pack.json
```

Empty: PR #372's squash (`ee57b38`) is still the change to `pack-078`–`pack-081` on `main`, so
this tree plays exactly the delivered rows.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-252/2026-11-03-accept-graphical/tools
python3 expectations_252.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

`expectations_252.py` re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma,
no per-image threshold) and checks each committed pixel against the committed pack row.
`nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`.

Expected output:

```
pack-078 84 1 True True True True
pack-079 91 1 True True True True
pack-080 72 1 True True True True
pack-081 90 1 True True True True
expect.json written to .../expect.json
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-252/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_252.gd" game/probe_capture_252.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
godot --path game -s res://probe_capture_252.gd -- \
    --debug-seams --session-id=issue-252-accept --build-id=main@c41c104 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_252.gd game/probe_capture_252.gd.uid
```

The probe exits 1 unless all 9 judged states were saved and every check passed, so a section
that dies early cannot report a pass. Gestures are real `InputEventMouseButton` /
`InputEventMouseMotion` events parsed through `Input`, over the real cells; `DBG.2` is read
after each one. The probe scrolls the gallery to the slice's tiles before each gallery shot.

A passing run reads `capture: RESULT pass (9 shots, 0 checks failed)` with 35 `capture: PASS`
lines. The run's own console and state dump are under `logs/`.

## 3. Offline bar checks

```bash
python3 .github/scripts/generate_pack.py --check
python3 .github/scripts/asset_manifest.py --check
python3 .github/scripts/asset_catalog.py
python3 -m pytest .github/scripts/tests -q
for n in 078 079 080 081; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square game/assets/puzzle-pictures/pack-$n-generated.png \
    --pixel /tmp/reextract-$n.png --size 15
  cmp /tmp/reextract-$n.png game/assets/puzzle-pictures/pack-$n-pixel.png
done
```

Captured in `logs/acceptance-checks.log` and `logs/derive-judge.log`.

## 4. `time-to-playable` observation

```bash
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=app-start --run-dir="$PWD/$RUN/quality-app-start"
```

Result folder: `quality-app-start/integration/` (307.5 ms against the ≤ 3 s bar).
