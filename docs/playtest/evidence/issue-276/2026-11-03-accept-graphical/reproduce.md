# Reproduce — issue #276 acceptance run

Build: `main@a8b3848`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 1440x1920 screen, no
`--headless`) for the capture.

## 0. The build carries this slice's pictures

```bash
git diff --stat 5b260e8 a8b3848 -- \
  game/assets/puzzle-pictures/pack-174* game/assets/puzzle-pictures/pack-175* \
  game/assets/puzzle-pictures/pack-176* game/assets/puzzle-pictures/pack-177* \
  assets/catalog/01a17720-ca00-737f-aaa2-35c0bef71010.json \
  assets/catalog/01a17720-ca00-70bf-bea5-ca341d7fc682.json \
  assets/catalog/01a17720-ca00-72f9-bacb-ca5eca9fcbff.json \
  assets/catalog/01a17720-ca00-71e6-8778-a4033744a066.json \
  assets/catalog/01a17720-ca00-7118-99a0-395b4d6bf49e.json \
  assets/catalog/01a17720-ca00-7319-bdc1-1d039e4ee577.json \
  assets/catalog/01a17720-ca00-70a3-ab5f-fc11a19c9b2b.json \
  assets/catalog/01a17720-ca00-7200-92aa-4a8969edcb81.json
git diff 5b260e8 a8b3848 -- game/data/pack.json | grep -cE '^[-+].*pack-17[4-7]'
```

Expected: no output from the first command, `0` from the second. `5b260e8` is PR #467's head.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-276/2026-11-03-accept-graphical/tools
python3 expectations_276.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0-255 sRGB, filled when `Y < 128`, BOX 1024 -> 15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output is in
[`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-276/2026-11-03-accept-graphical/logs/expectations.log):

```
pack-174 88 1 True True True True | masses [44, 44] holes 0 | ...
pack-175 68 1 True True True True | masses [40, 28] holes 0 | ...
pack-176 73 1 True True True True | masses [45, 28] holes 0 | ...
pack-177 64 1 True True True True | masses [64] holes 0 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-276/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_276.gd" game/probe_capture_276.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_276.gd -- \
    --debug-seams --session-id=issue-276-accept --build-id=main@a8b3848 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-276/2026-11-03-accept-graphical/logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_276.gd game/probe_capture_276.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s)
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
python3 -m unittest discover -s .github/scripts/tests # OK (153 tests)
```

Observed output: [`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-276/2026-11-03-accept-graphical/logs/acceptance-checks.log).

The derive and judge of record are in
[`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-276/2026-11-03-accept-graphical/logs/derive-judge.log):

```bash
for p in 174 175 176 177; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/re-pack-$p.png" --size 15
  cmp "/tmp/re-pack-$p.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```

## 5. Deterministic quality record

Not run by this pass for the record. `app-start` was run as a sanity check (I6 2064.2 ms <= 3 s, pass), but
`docs/quality/evidence/README.md` and `docs/issues/workflow-deterministic-record.md` reserve the `deterministic` mode
for verification; acceptance cites a record and does not write one. Verification supplies the record for `a8b3848`.
