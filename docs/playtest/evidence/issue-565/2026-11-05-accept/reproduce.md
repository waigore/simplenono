# Reproduce — issue #565 acceptance run

Build: `main@78e9766` (HEAD when the run started; `git diff e8a03ea 78e9766 -- game/` is
empty, so `game/` is exactly the #595 deliverable merge), Godot 4.7.2.stable, graphical
(`godot --path game`, no `--headless`), 900×1200 viewport, fresh `HOME` (own `user://`).

## 0. The build carries this issue's pictures

```bash
git log --oneline e8a03ea..HEAD -- game/data/pack.json game/assets/puzzle-pictures
```

`e8a03ea..HEAD` is empty for these paths — nothing after the #595 squash touches the
delivered rows or pictures; only the verification records landed (#597, MD only).

## 1. Independent expectations

```bash
cd docs/playtest/evidence/issue-565/2026-11-05-accept/tools
python3 expectations_565.py --root "$(git rev-parse --show-toplevel)" --out ../expect.json
```

Re-implements the fill rule (alpha over white, `Y = 0.2126R + 0.7152G + 0.0722B` on
0–255 sRGB, filled when `Y < 128`, BOX 1024 → N, no gamma, no per-image threshold) at
each row's own size, checks each committed pixel against the committed pack row, and
records per-pixel-grid mirror asymmetry as K4 corroboration. `nonogram565.py` is its own
line solver and enumerator; neither imports `.github/scripts/puzzle_derive.py`. Observed
output
([`logs/expectations.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-565/2026-11-05-accept/logs/expectations.log)):
all 30 rows printed `solutions 1`, `line_logic_solves True`, `logic_matches_pixel True`,
`matches_pack_fills True`, `matches_pack_clues True`, `in_band True`, `asymmetric`
all-True, and the final line `expect.json written to … | 10x10: 10 15x15: 10 20x20: 10`.

## 2. Derive reproduces the pixel

```bash
for p in pack-000 … pack-198; do      # the 30 delivered ids, size from pack.json
  python3 .github/scripts/puzzle_derive.py derive \
    --square "game/assets/puzzle-pictures/$p-generated.png" \
    --pixel "/tmp/$p-derive.png" --size <size>
  cmp "game/assets/puzzle-pictures/$p-pixel.png" "/tmp/$p-derive.png" && echo "$p byte-identical"
  python3 .github/scripts/puzzle_derive.py judge \
    --pixel "game/assets/puzzle-pictures/$p-pixel.png" --size <size>
done
```

All 30 `cmp` calls print byte-identical and all 30 judges print `"verdict":"pass"` with
`in_band`, `unique`, `logic_solved`, and `matches_pixel` true
([`logs/derive-judge.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-565/2026-11-05-accept/logs/derive-judge.log)).

## 3. Graphical capture

```bash
RUN=docs/playtest/evidence/issue-565/2026-11-05-accept
cp "$RUN/probe/probe_capture_565.gd" game/probe_capture_565.gd
mkdir -p "$RUN/screenshots" "$RUN/logs"

HOME=/tmp/565-home godot --headless --path game --import
HOME=/tmp/565-home godot --path game -s res://probe_capture_565.gd -- \
    --debug-seams --session-id=issue-565-accept --build-id=main@78e9766 \
    --story-ids=PTD-ready-and-marks,PTD-crosses-and-fills,PTD-solve-and-pb,PTU-play-puzzle,PTU-mark-input \
    --shot-dir="$PWD/$RUN/screenshots" --run-folder="$PWD/$RUN" --expect="$PWD/$RUN/expect.json"

rm game/probe_capture_565.gd game/probe_capture_565.gd.uid   # never committed
```

Exit `0` and final line `capture: RESULT pass (…)`. The probe drives the real shell,
puzzle screen, and shipped input events over the shipped `pack.json` rows, so a wrong
clue, a wrong `solution-fills` set, or a picture that disagrees with its row shows up as
a board that will not finish. The probe's P2 computes the empty-clue auto-cross set from
`expect.json`'s independent grid, not from the shipped clues.

## 4. Repo checks

```bash
python3 .github/scripts/generate_pack.py --check     # game/data/pack.json is current
python3 .github/scripts/asset_manifest.py --check    # 0 error(s)
python3 .github/scripts/asset_catalog.py             # 0 error(s)
python3 .github/scripts/spec_lint.py                 # 0 error(s), 1 warning(s)
```

Observed output:
[`logs/acceptance-checks.log`](https://raw.githubusercontent.com/wiki/waigore/simplenono/playtest/issue-565/2026-11-05-accept/logs/acceptance-checks.log).
`pytest .github/scripts/tests` was not re-run at acceptance — CI held `Spec lint`, `Code
lint`, `Unit tests`, `Coverage`, and the integration harness green on the merged
deliverable (#595) and the evidence PRs #597 and this run's own PR.

## 5. Wiki

[Playtest-issue-565-2026-11-05-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-565-2026-11-05-accept)
holds the screenshots under `screenshots/` and the run's logs under `logs/`.
