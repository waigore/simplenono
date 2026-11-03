# Reproduce — issue #281 acceptance run

Build: `main@3f8e524`, Godot 4.7.2.stable, graphical (`godot --path game`, no `--headless`), 900×1200 viewport.

## 0. The build carries this slice's pictures

```bash
git log --oneline 3f8e524..origin/main -- game/data/pack.json game/assets/puzzle-pictures
```

Run from a worktree at `3f8e524`. The range is empty, so nothing after the delivering squash touches this slice's rows
or pictures. Note that the slice landed in `3f8e524` (PR #493), not in `02c332e` (PR #491), which is an empty squash.

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-281/2026-11-03-accept/tools
python3 expectations_281.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the shared picture bar's fill rule (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB,
filled when `Y < 128`, BOX 1024 → 20, no gamma, no per-image threshold) and checks each committed pixel against the
committed pack row. `nonogram.py` is its own line solver and enumerator; neither imports
`.github/scripts/puzzle_derive.py`. Observed output (`logs/expectations.log`):

```
pack-192 131 1 True True True True | masses [121, 10] holes 23
pack-193 126 1 True True True True | masses [112, 14] holes 16
pack-194 139 1 True True True True | masses [139] holes 0
pack-195 118 1 True True True True | masses [118] holes 0
```

`class` is still printed for the record; no catalog entry asserts one, because #486 (option 3) dropped the per-puzzle
class.

## 2. Derive reproduces the pixel

```bash
for p in pack-192 pack-193 pack-194 pack-195; do
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/$p-generated.png" \
    --pixel "/tmp/$p-derive.png" --size 20
  cmp "game/assets/puzzle-pictures/$p-pixel.png" "/tmp/$p-derive.png" && echo "$p byte-identical"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/$p-pixel.png" --size 20
done
```

All four `cmp` calls are byte-identically equal and all four judges print `"verdict":"pass"` with `in_band`, `unique`,
`logic_solved`, and `matches_pixel` true (`logs/derive-judge.log`).

## 3. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-281/2026-11-03-accept
cp "$RUN/probe/probe_capture_281.gd" game/probe_capture_281.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

godot --headless --path game --import
godot --path game -s res://probe_capture_281.gd -- \
    --debug-seams --session-id=issue-281-accept --build-id=main@3f8e524 \
    --story-ids=PTD-ready-and-marks,PTD-crosses-and-fills,PTD-solve-and-pb,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_281.gd game/probe_capture_281.gd.uid   # never committed
```

On a headless Linux host, wrap the capture in `xvfb-run -a -s "-screen 0 1440x1920x24"`, as #278–#280 did. Exit `0` and
the final line `capture: RESULT pass (9 shots, 0 checks failed)`, 47 `capture: PASS` lines (`logs/capture.log`).

The probe drives the real shell, puzzle screen, and shipped input events over the shipped `pack.json` rows, so a wrong
clue, a wrong `solution-fills` set, or a picture that disagrees with its row shows up as a board that will not finish.

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s)
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 pre-existing glossary warning
```

## 5. Wiki

[Playtest-issue-281-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-281-2026-11-03-accept)
holds the nine screenshots under `screenshots/` and the run's logs under `logs/`.
