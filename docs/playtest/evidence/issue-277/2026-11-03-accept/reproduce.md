# Reproduce — issue #277 acceptance run

Build: `main@58e6637`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 1440x1920 screen, no
`--headless`) for the capture.

## 0. The build carries this slice's pictures

```bash
git diff --stat 0eb2d1d 58e6637 -- \
  'game/assets/puzzle-pictures/pack-17[89]*' \
  assets/catalog/01a17720-ca00-7395-8a33-121cd2e5791b.json \
  assets/catalog/01a17720-ca00-7384-a9f4-e9a3bca90447.json \
  assets/catalog/01a17720-ca00-7003-85ad-38419a9d7aec.json \
  assets/catalog/01a17720-ca00-7273-9b96-e8bafb0452b2.json
git diff 0eb2d1d 58e6637 -- game/data/pack.json | grep -cE '^[-+].*pack-17[89]'
```

Expected: the first command prints nothing; the second prints `0`. `0eb2d1d` is PR #469's merge commit, `58e6637` the
acceptance build. The only shared file that moved between them is `assets/manifest.json`, which gained sibling slices'
ids.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-277/2026-11-03-accept/tools
python3 expectations_277.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0-255 sRGB, filled when `Y < 128`, BOX 1024 -> 15, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output
([`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-277/2026-11-03-accept/logs/expectations.log)):

```
pack-178 67 1 True True True True | masses [67] holes 4 | ...
pack-179 69 1 True True True True | masses [36, 33] holes 0 | ...
```

## 2. Derive reproduces the pixel

```bash
for p in pack-178 pack-179; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/$p-generated.png" \
    --pixel "/tmp/$p-derive.png" --size 15
  cmp "game/assets/puzzle-pictures/$p-pixel.png" "/tmp/$p-derive.png" && echo "$p byte-identical"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/$p-pixel.png" --size 15
done
```

Both `cmp` calls print byte-identical and both judges print `"verdict":"pass"` with `in_band`, `unique`,
`logic_solved`, and `matches_pixel` true ([`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-277/2026-11-03-accept/logs/derive-judge.log)).

## 3. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-277/2026-11-03-accept
cp "$RUN/probe/probe_capture_277.gd" game/probe_capture_277.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_277.gd -- \
    --debug-seams --session-id=issue-277-accept --build-id=main@58e6637 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_277.gd   # never committed
```

Exit `0` and the final line `capture: RESULT pass (9 shots, 0 checks failed)`
([`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-277/2026-11-03-accept/logs/capture.log)).
The probe drives the real shell, puzzle screen, and shipped input events over the shipped `pack.json` rows, so a wrong
clue, a wrong `solution-fills` set, or a picture that disagrees with its row shows up as a board that will not finish.

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check
python3 .github/scripts/asset_manifest.py --check
python3 .github/scripts/asset_catalog.py
python3 .github/scripts/spec_lint.py
```

`pack.json is current`, 0 errors, 0 errors, and 0 errors with 1 pre-existing glossary warning
([`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-277/2026-11-03-accept/logs/acceptance-checks.log)).

## 5. Wiki

[Playtest-issue-277-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-277-2026-11-03-accept)
holds the nine screenshots under `screenshots/` and the run's logs under `logs/`.
