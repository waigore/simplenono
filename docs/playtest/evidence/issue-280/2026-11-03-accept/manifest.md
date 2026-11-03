# Playtest — issue #280

- **Issue:** #280 Puzzle pictures pack-188–pack-191 (20×20) (`type:task`)
- **Build / session id:** graphical run `main@6147776` / `issue-280-accept`; repo checks `6147776`. The slice landed at
  PR #481 (merged as `a3c50b7`, 2026-11-03T13:27Z) and its deterministic evidence at PR #484 (`d874be3`). Neither commit
  after `a3c50b7` touches `game/`, the catalog, or the asset manifest (`git diff --stat a3c50b7 6147776 -- game/
  assets/catalog assets/manifest.json` prints nothing; see [reproduce.md](reproduce.md) step 0).
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical (Godot 4.7.2 stable, 900×1200 viewport, `godot --path game` — not `--headless`),
  `--debug-seams`, on `6147776`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_280.py`](tools/expectations_280.py),
  read straight off each committed `-pixel.png`; `puzzle_derive.py` is not in that path. Line logic and uniqueness come
  from [`tools/nonogram.py`](tools/nonogram.py) (`SIZE = 20`).
- **Log / screenshots (wiki):** [Playtest-issue-280-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-280-2026-11-03-accept)
  (`logs/capture.log`, `logs/import.log`, `logs/expectations.log`, `logs/derive-judge.log`, `logs/acceptance-checks.log`,
  `logs/state-pack-190.json`, nine screenshots)

These four rows change playable behavior (each ships a different 20×20 solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-188-open-ready.png`, `04-result-188-pictures.png`, `05-gallery-188-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-189-marks.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-188-open-ready.png`, `06-puzzle-189-marks.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/03-puzzle-188-one-fill-from-solve.png`, `08-puzzle-191-crossed.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-188-one-fill-from-solve.png`, `09-puzzle-190-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected. Telemetry: 1250 `TEL event` lines (marks, commits, solves, leaves), every one keyed to
`session=issue-280-accept build=main@6147776 story=US1.6`, in `logs/capture.log`.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-188-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-188 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-188-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-188 board one fill from solve |
| `screenshots/04-result-188-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-188 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-188-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #188 Done with its own picture tile |
| `screenshots/06-puzzle-189-marks.png` | `PTU-mark-input` P1–P5, `PTD-ready-and-marks` P1 | pack-189: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-189-in-progress.png` | `PTU-mark-input` | pack-189 In progress after unsolved marks; #188 still Done |
| `screenshots/08-puzzle-191-crossed.png` | `PTD-crosses-and-fills` P1 | pack-191 with every non-solution cell crossed (shot before the fills) |
| `screenshots/09-puzzle-190-last-fill.png` | `PTD-solve-and-pb` P1 | pack-190 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_280.py`](tools/expectations_280.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→20) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-188 154 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [124, 30] holes 0
pack-189 119 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [94, 25] holes 0
pack-190 111 1 True True True True | class single-subject / single-subject | masses [111] holes 0
pack-191 138 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [138] holes 40
```

Columns are: filled, solutions, line-logic solves, that solution is the pixel, equals the row's `solution-fills`, equals
the row's clues; then the index-rule class against the catalog's `generation.settings.subject_class`. Band 100–180 for
20×20: all four inside. Cell luma under the fixed rule (filled mean / background mean): 73.2 / 184.1, 77.6 / 203.4,
84.5 / 201.6, 86.7 / 201.9 — wide separation, and the warm-pixel share is 0.00 % on every square and pixel file.
`puzzle_derive.py derive --size 20` from each committed square reproduces the committed pixel byte-identically and judges
`pass` (`logs/derive-judge.log`).

**Subject classes** (index rule on #294, index mod 10 ∈ {0, 3, 7} single): pack-188 (8) multi — two masses, 124 + 30, no
hole; pack-189 (9) multi — two masses of 94 and 25, no hole; pack-190 (0) single — one connected mass of 111; pack-191
(1) multi/holed — one mass of 138 with 40 enclosed background cells. Slice mix 1 single / 3 multi, matching the body with
no deviation.

## Notes from this run (not defects)

- The mark run is #189 and the crossed board is #191, so the crossed board starts clean (no resumed marks) and the win is
  judged on a board whose only marks are the ones the run places. #188 solves from a stored near-solve; #191 and #190 are
  filled to completion from their committed `solution-fills`.
- The gallery shows 3 completed after the slice (188, 190, 191); #189 stays In progress, which is what `PTU-mark-input`
  expects (unsolved marks do not complete a puzzle).
- S5 drag-paint ran: #189 has a clear run of three in a row, every cell ended Cross on the drawn board and in `DBG.2`.
- `tools/expectations_280.py` fixes the luma coefficients to the bar's exact `0.7152` green weight; the earlier slice
  copies carried `0.7160` in code and docstring. Across all 1600 cells the two weights differ by at most 0.179 luma (the
  brightest cell, pack-189 (1,2): 224.289 against 224.468), and no cell changes side of the 128 boundary, so no fill and
  no verdict moves.
