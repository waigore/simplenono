# Reproduce — issue #274 acceptance run

Build: `main@ec135ed`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 1440×1920 screen, no
`--headless`) for the capture.

## 0. The build carries this slice's pictures

```bash
git diff --stat ac52f1a ec135ed -- \
  game/assets/puzzle-pictures/pack-166* game/assets/puzzle-pictures/pack-167* \
  game/assets/puzzle-pictures/pack-168* game/assets/puzzle-pictures/pack-169* \
  assets/catalog/01a17720-ca00-7362-96f7-c86824008714.json \
  assets/catalog/01a17720-ca00-7304-8c97-46449d619470.json \
  assets/catalog/01a17720-ca00-708d-b938-ba6422027a46.json \
  assets/catalog/01a17720-ca00-714f-9dda-cf843b95ff22.json \
  assets/catalog/01a17720-ca00-7287-9558-54ca6872ef03.json \
  assets/catalog/01a17720-ca00-703d-833a-cc52d9e2d36a.json \
  assets/catalog/01a17720-ca00-702d-a860-9ea10df256cf.json \
  assets/catalog/01a17720-ca00-7141-ac51-0e5575631b81.json
git diff ac52f1a ec135ed -- game/data/pack.json | grep -cE '^[-+].*pack-16[6-9]'
```

Expected: no output from the first command, `0` from the second. `ac52f1a` is PR #448's head.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-274/2026-11-03-accept-graphical/tools
python3 expectations_274.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output is in
[`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-274/2026-11-03-accept-graphical/logs/expectations.log):

```
pack-166 71 1 True True True True | masses [36, 35] holes 0 | ...
pack-167 57 1 True True True True | masses [57] holes 0 | ...
pack-168 90 1 True True True True | masses [54, 36] holes 0 | ...
pack-169 61 1 True True True True | masses [40, 21] holes 0 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-274/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_274.gd" game/probe_capture_274.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_274.gd -- \
    --debug-seams --session-id=issue-274-accept --build-id=main@ec135ed \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-274/2026-11-03-accept-graphical/logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_274.gd game/probe_capture_274.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s) — unfiltered, as run
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
python3 -m unittest discover -s .github/scripts/tests # OK (153 tests)
```

Observed output: [`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-274/2026-11-03-accept-graphical/logs/acceptance-checks.log).

The derive and judge of record are in
[`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-274/2026-11-03-accept-graphical/logs/derive-judge.log):

```bash
for p in 166 167 168 169; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
done
```

## 5. Deterministic quality record

```bash
Q=docs/quality/evidence/issue-274/2026-11-03-accept
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=app-start --run-dir="$PWD/$Q"
```

Expected: `HARNESS protocol=app-start outcome=pass`, and `time-to-playable` ≤ 3 s in `$Q/integration/results.md`.
