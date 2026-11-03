# Reproduce — issue #272 acceptance run

Build: `main@5b260e8`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 1440×1920 screen, no
`--headless`) for the capture.

## 0. The build carries this slice's pictures

```bash
git diff --name-only b2046dd 5b260e8 -- \
  game/assets/puzzle-pictures/pack-158* game/assets/puzzle-pictures/pack-159* \
  game/assets/puzzle-pictures/pack-160* game/assets/puzzle-pictures/pack-161*
```

Expected: no output. `b2046dd` is PR #419's squash. The four `pack.json` rows and the eight catalog entries named by
those rows were checked the same way (comparing each row and each `picture-id` / `pixel-picture-id` entry against
`b2046dd`) and are identical too.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-272/2026-11-03-accept-graphical/tools
python3 expectations_272.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output is in
[`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-272/2026-11-03-accept-graphical/logs/expectations.log):

```
pack-158 82 1 True True True True | masses [82] holes 8 | ...
pack-159 83 1 True True True True | masses [54, 29] holes 0 | ...
pack-160 57 1 True True True True | masses [57] holes 0 | ...
pack-161 75 1 True True True True | masses [75] holes 6 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-272/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_272.gd" game/probe_capture_272.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_272.gd -- \
    --debug-seams --session-id=issue-272-accept --build-id=main@5b260e8 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-272/2026-11-03-accept-graphical/logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_272.gd game/probe_capture_272.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s) — unfiltered, as run
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
python3 -m unittest discover -s .github/scripts/tests # OK
```

Observed output: [`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-272/2026-11-03-accept-graphical/logs/acceptance-checks.log)
and [`logs/unittests.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-272/2026-11-03-accept-graphical/logs/unittests.log).

The derive and judge of record are in [`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-272/2026-11-03-accept-graphical/logs/derive-judge.log):

```bash
for p in 158 159 160 161; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```
