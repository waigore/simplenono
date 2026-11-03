# Reproduce — issue #268 acceptance run

Build: `main@62a3d52`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 900×1200, no
`--headless`) for the capture, headless for the profile run.

## 0. The build carries this slice's pictures

```bash
git diff --name-only dafc87c 62a3d52 -- \
  game/assets/puzzle-pictures/pack-142* game/assets/puzzle-pictures/pack-143* \
  game/assets/puzzle-pictures/pack-144* game/assets/puzzle-pictures/pack-145*
```

Expected: no output for the eight picture files and their sidecars, and nothing for `assets/catalog/` or the four
`pack.json` rows.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-268/2026-11-03-accept-graphical/tools
python3 expectations_268.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output is in
[`logs/expectations.log`](logs/expectations.log):

```
pack-142 65 1 True True True True | masses [36, 29] holes 0 | ...
pack-143 71 1 True True True True | masses [71] holes 0 | ...
pack-144 90 1 True True True True | masses [45, 45] holes 0 | ...
pack-145 66 1 True True True True | masses [66] holes 8 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-268/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_268.gd" game/probe_capture_268.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_268.gd -- \
    --debug-seams --session-id=issue-268-accept --build-id=main@62a3d52 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_268.gd game/probe_capture_268.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s) — unfiltered, as run
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
python3 -m unittest discover -s .github/scripts/tests  # 142 tests OK
```

Observed output: [`logs/acceptance-checks.log`](logs/acceptance-checks.log).

The derive and judge of record are in [`logs/derive-judge.log`](logs/derive-judge.log):

```bash
for p in 142 143 144 145; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```

## 5. Profile (`time-to-playable`)

No passing `deterministic` record covers `game/` at the delivery commit. The rebuild-window tree `ff5ae1f` that a
passing record does cover has the same `game/` bytes as `dafc87c`, and the slice is unchanged from `dafc87c` to
`62a3d52`, so the profile was re-observed here and recorded beside this folder:

```bash
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=app-start \
    --run-dir="$PWD/../../../../quality/evidence/issue-268/2026-11-03-accept"
```

Observed: `app-start` pass, cold launch to the interactive gallery 1982.3 ms against ≤ 3 s.
