# Reproduce — issue #275 acceptance run

Build: `main@ef1c0b7`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 1440x1920 screen, no
`--headless`) for the capture.

## 0. The build carries this slice's pictures

```bash
git diff --stat d688934 ef1c0b7 -- \
  'game/assets/puzzle-pictures/pack-17[0-3]*' \
  assets/catalog/01a17720-ca00-71bd-99c3-6fde94b2ea89.json \
  assets/catalog/01a17720-ca00-73c6-a967-248a100cb106.json \
  assets/catalog/01a17720-ca00-7270-abc6-67b38fc14e86.json \
  assets/catalog/01a17720-ca00-716d-bae3-6aad11389d3d.json \
  assets/catalog/01a17720-ca00-7288-9f32-650dc062c7bd.json \
  assets/catalog/01a17720-ca00-7348-8fb7-09dfd3558415.json \
  assets/catalog/01a17720-ca00-7149-999e-babb7f234fcb.json \
  assets/catalog/01a17720-ca00-7014-b4c7-ba63b68014d5.json \
  assets/manifest.json
git diff d688934 ef1c0b7 -- game/data/pack.json | grep -cE '^[-+].*pack-17[0-3]'
```

Expected: the first command lists only `assets/manifest.json` (it is global and gained the sibling slices' ids); the
second prints `0`. `d688934` is PR #453's merge commit, `ef1c0b7` the acceptance build.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-275/2026-11-03-accept-graphical/tools
python3 expectations_275.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0-255 sRGB, filled when `Y < 128`, BOX 1024 -> 15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output is in
[`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-275/2026-11-03-accept-graphical/logs/expectations.log):

```
pack-170 56 1 True True True True | masses [56] holes 0 | ...
pack-171 72 1 True True True True | masses [36, 36] holes 0 | ...
pack-172 98 1 True True True True | masses [98] holes 0 | ...
pack-173 62 1 True True True True | masses [62] holes 0 | ...
```

## 2. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-275/2026-11-03-accept-graphical
cp "$RUN/probe/probe_capture_275.gd" game/probe_capture_275.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_275.gd -- \
    --debug-seams --session-id=issue-275-accept --build-id=main@ef1c0b7 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"
```

Expected final line: `capture: RESULT pass (9 shots, 0 checks failed)`. Full log in
[`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-275/2026-11-03-accept-graphical/logs/capture.log).

## 3. Remove the probe

```bash
rm game/probe_capture_275.gd game/probe_capture_275.gd.uid
```

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s)
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing warning
python3 -m unittest discover -s .github/scripts/tests # OK (153 tests)
```

Observed output: [`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-275/2026-11-03-accept-graphical/logs/acceptance-checks.log).

The derive and judge of record are in
[`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-275/2026-11-03-accept-graphical/logs/derive-judge.log):

```bash
for p in 170 171 172 173; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/pack-$p-generated.png" \
    --pixel "/tmp/re-pack-$p.png" --size 15
  cmp "/tmp/re-pack-$p.png" "game/assets/puzzle-pictures/pack-$p-pixel.png"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/pack-$p-pixel.png" --size 15
done
```

## 5. Deterministic quality record

Not run by this pass, for the record. `docs/quality/evidence/README.md` and
`docs/issues/workflow-deterministic-record.md` reserve the `deterministic` mode for verification; acceptance cites a
record and does not write one. The record under `docs/quality/evidence/issue-275/2026-11-03-verify/` names `cf9b4d1`,
and `git diff cf9b4d1 ef1c0b7 -- game/` is not empty, so no passing record covers this tree and the issue returns to
`pending-verification`.
