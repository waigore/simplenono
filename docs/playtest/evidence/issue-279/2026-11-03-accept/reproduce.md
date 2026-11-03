# Reproduce — issue #279 acceptance run

Build: `main@05ef321`, Godot 4.7.2.stable, graphical through `xvfb-run` (software OpenGL, 1440x1920 screen, 900x1200
viewport, no `--headless`) for the capture.

## 0. The build carries this slice's pictures

```bash
git log --oneline 58e6637..05ef321
git diff --stat 58e6637 05ef321 -- game/ assets/catalog assets/manifest.json
```

Expected: the only commits are #277's evidence PR and #279's deterministic-evidence PR, and the diff prints nothing —
neither touches `game/`, the catalog, or the asset manifest, so the delivered slice (PR #478, merged `58e6637`) is what
the run tested.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-279/2026-11-03-accept/tools
python3 expectations_279.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0-255 sRGB, filled when `Y < 128`, BOX 1024 -> 20, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output
([`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-279/2026-11-03-accept/logs/expectations.log)):

```
pack-184 101 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [67, 34] holes 0
pack-185 144 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [144] holes 30
pack-186 175 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [96, 79] holes 0
pack-187 129 1 True True True True | class single-subject / single-subject | masses [129] holes 0
```

## 2. Derive reproduces the pixel

```bash
for p in pack-184 pack-185 pack-186 pack-187; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/$p-generated.png" \
    --pixel "/tmp/$p-derive.png" --size 20
  cmp "game/assets/puzzle-pictures/$p-pixel.png" "/tmp/$p-derive.png" && echo "$p byte-identical"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/$p-pixel.png" --size 20
done
```

All four `cmp` calls print byte-identical and all four judges print `"verdict":"pass"` with `in_band`, `unique`,
`logic_solved`, and `matches_pixel` true ([`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-279/2026-11-03-accept/logs/derive-judge.log)).

## 3. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-279/2026-11-03-accept
cp "$RUN/probe/probe_capture_279.gd" game/probe_capture_279.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
xvfb-run -a -s "-screen 0 1440x1920x24" \
godot --path game -s res://probe_capture_279.gd -- \
    --debug-seams --session-id=issue-279-accept --build-id=main@05ef321 \
    --story-ids=US1.6,US1.6b,US1.7,US1.8,PTD-solve-and-pb,PTD-crosses-and-fills,PTD-ready-and-marks,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_279.gd   # never committed
```

Exit `0` and the final line `capture: RESULT pass (9 shots, 0 checks failed)`
([`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-279/2026-11-03-accept/logs/capture.log)).
The probe drives the real shell, puzzle screen, and shipped input events over the shipped `pack.json` rows, so a wrong
clue, a wrong `solution-fills` set, or a picture that disagrees with its row shows up as a board that will not finish.

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check
python3 .github/scripts/asset_manifest.py --check
python3 .github/scripts/asset_catalog.py
python3 .github/scripts/spec_lint.py
python3 -m pytest .github/scripts/tests -q
```

`pack.json is current`, 0 errors, 0 errors, 0 errors with 1 pre-existing glossary warning, and 155 passed with 49
subtests ([`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-279/2026-11-03-accept/logs/acceptance-checks.log)).

## 5. Wiki

[Playtest-issue-279-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-279-2026-11-03-accept)
holds the nine screenshots under `screenshots/` and the run's logs under `logs/`.
