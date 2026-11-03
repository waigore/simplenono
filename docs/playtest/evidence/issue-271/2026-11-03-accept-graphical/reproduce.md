# Reproduce — issue #271 acceptance run

Build: `main@b3f8e82`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 1440×1920 screen, no
`--headless`) for the capture.

## 0. The build carries this slice's pictures

```bash
git diff --name-only 8c2a6db b3f8e82 -- \
  game/assets/puzzle-pictures/pack-154* game/assets/puzzle-pictures/pack-155* \
  game/assets/puzzle-pictures/pack-156* game/assets/puzzle-pictures/pack-157* \
  assets/catalog/01a17720-ca00-7030-878f-4748a2df498a.json \
  assets/catalog/01a17720-ca00-7144-b8d8-30d0d6076c72.json \
  assets/catalog/01a17720-ca00-71ee-8caf-df88f840bc32.json \
  assets/catalog/01a17720-ca00-7221-8c8f-fd69378d455c.json \
  assets/catalog/01a17720-ca00-7274-a2ad-e0c51b28bcf8.json \
  assets/catalog/01a17720-ca00-72e1-ae8b-145202931296.json \
  assets/catalog/01a17720-ca00-72ed-b6ad-28ff029f3921.json \
  assets/catalog/01a17720-ca00-73db-97e1-f683c3e9b74d.json
```

Expected: no output. `8c2a6db` is PR #414's squash.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-271/2026-11-03-accept-graphical/tools
python3 expectations_271.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output is in
[`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-271/2026-11-03-accept-graphical/logs/expectations.log):

```
pack-154 81 1 True True True True | masses [45, 36] holes 0 | ...
pack-155 56 1 True True True True | masses [31, 25] holes 27 | ...
pack-156 65 1 True True True True | masses [33, 32] holes 0 | ...
pack-157 76 1 True True True True | masses [76] holes 45 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-271/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_271.gd" game/probe_capture_271.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_271.gd -- \
    --debug-seams --session-id=issue-271-accept --build-id=main@b3f8e82 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-271/2026-11-03-accept-graphical/logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_271.gd game/probe_capture_271.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s) — unfiltered, as run
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
python3 -m unittest discover -s .github/scripts/tests # 153 tests, OK
```

Observed output: [`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-271/2026-11-03-accept-graphical/logs/acceptance-checks.log)
and [`logs/unittests.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-271/2026-11-03-accept-graphical/logs/unittests.log).

The derive and judge of record are in [`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-271/2026-11-03-accept-graphical/logs/derive-judge.log):

```bash
for p in 154 155 156 157; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/pack-$p-pixel.png" --size 15
  cmp "/tmp/pack-$p-pixel.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```
