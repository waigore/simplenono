# Reproduce — issue #282 acceptance run

Build: `main@1b5dbc9` (PR #489 squash), Godot 4.7.2.stable, graphical (`godot --path game`, no `--headless`),
900×1200 viewport.

## 0. The build carries this slice's pictures

```bash
git log --oneline 1b5dbc9..HEAD -- game/data/pack.json game/assets/puzzle-pictures
```

Run from a worktree at `1b5dbc9`. `1b5dbc9..HEAD` on `origin/main` is empty for these paths — nothing after the squash
touches this slice's rows or pictures.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-282/2026-11-03-accept/tools
python3 expectations_282.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024 → 20, no gamma, no per-image
threshold) and checks each committed pixel against the committed pack row. `nonogram.py` is its own line solver and
enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed output
([`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-282/2026-11-03-accept/logs/expectations.log)):

```
pack-196 112 1 True True True True | class multi-subject and/or holed / None | masses [92, 20] holes 0
pack-197 139 1 True True True True | class single-subject / None | masses [139] holes 0
pack-198 173 1 True True True True | class multi-subject and/or holed / None | masses [103, 70] holes 0
pack-199 148 1 True True True True | class multi-subject and/or holed / None | masses [148] holes 30
```

`class` is the index rule reported for the record; the catalog side reads `None` because #486 (option 3) dropped the
per-puzzle class and the tool no longer asserts it.

## 2. Derive reproduces the pixel

```bash
for p in pack-196 pack-197 pack-198 pack-199; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/$p-generated.png" \
    --pixel "/tmp/$p-derive.png" --size 20
  cmp "game/assets/puzzle-pictures/$p-pixel.png" "/tmp/$p-derive.png" && echo "$p byte-identical"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/$p-pixel.png" --size 20
done
```

All four `cmp` calls print byte-identical and all four judges print `"verdict":"pass"` with `in_band`, `unique`,
`logic_solved`, and `matches_pixel` true
([`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-282/2026-11-03-accept/logs/derive-judge.log)).

## 3. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-282/2026-11-03-accept
cp "$RUN/probe/probe_capture_282.gd" game/probe_capture_282.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
godot --path game -s res://probe_capture_282.gd -- \
    --debug-seams --session-id=issue-282-accept --build-id=main@1b5dbc9 \
    --story-ids=PTD-ready-and-marks,PTD-crosses-and-fills,PTD-solve-and-pb,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_282.gd game/probe_capture_282.gd.uid   # never committed
```

On a headless Linux host, wrap the capture in `xvfb-run -a -s "-screen 0 1440x1920x24"`, as #278–#280 did. Exit `0` and
the final line `capture: RESULT pass (9 shots, 0 checks failed)`, 47 `capture: PASS` lines
([`logs/capture.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-282/2026-11-03-accept/logs/capture.log)).
The probe drives the real shell, puzzle screen, and shipped input events over the shipped `pack.json` rows, so a wrong
clue, a wrong `solution-fills` set, or a picture that disagrees with its row shows up as a board that will not finish.
The probe's P2 check computes the empty-clue lines from `expect.json`'s grid, not from the shipped clues.

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s)
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing glossary warning
python3 -m pytest .github/scripts/tests -q           # 155 passed, 49 subtests
```

Observed output: [`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-282/2026-11-03-accept/logs/acceptance-checks.log).

## 5. Wiki

[Playtest-issue-282-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-282-2026-11-03-accept)
holds the nine screenshots under `screenshots/` and the run's logs under `logs/`.
