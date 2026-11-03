# Playtest — issue #278

- **Issue:** #278 Puzzle pictures pack-180–pack-183 (20×20) (`type:task`)
- **Build / session id:** graphical run `main@893e60f` / `issue-278-accept`; repo checks `893e60f`. The slice landed at
  PR #474 (head `10447ee`, merged as `e0d8ff2`, 2026-11-03T12:50Z). The only later commits touching `game/`, the catalog,
  or the asset manifest are the sibling slices #279 (PR #478, merged `58e6637`) and #280 (PR #481, merged `a3c50b7`), which
  add their own pictures and pack rows. This slice's eight picture files, its four `pack.json` rows, and its eight catalog
  entries are byte-identical between `e0d8ff2` and `893e60f` (`git rev-parse` and a row diff; `reproduce.md` step 0), so
  this run tests the delivered slice on `main`.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 1440×1920 screen, 900×1200 viewport,
  `godot --path game` — not `--headless`), `--debug-seams`, on `893e60f`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_278.py`](tools/expectations_278.py),
  read straight off each committed `-pixel.png`; `puzzle_derive.py` is not in that path. Line logic and uniqueness come
  from [`tools/nonogram.py`](tools/nonogram.py) (`SIZE = 20`).
- **Log / screenshots (wiki):** [Playtest-issue-278-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-278-2026-11-03-accept)
  (`logs/capture.log`, `logs/import.log`, `logs/expectations.log`, `logs/derive-judge.log`, `logs/acceptance-checks.log`,
  `logs/state-pack-183.json`, nine screenshots)
- **Notes:** [`notes.md`](notes.md) · **Reproduce:** [`reproduce.md`](reproduce.md)

These four rows change playable behavior (each ships a different 20×20 solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-180-open-ready.png`, `04-result-180-pictures.png`, `05-gallery-180-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-181-marks.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-180-open-ready.png`, `06-puzzle-181-marks.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/03-puzzle-180-one-fill-from-solve.png`, `08-puzzle-182-crossed.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-180-one-fill-from-solve.png`, `09-puzzle-183-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected. Telemetry: 1238 `TEL event` lines (marks, commits, solves, leaves), every one keyed to
`session=issue-278-accept build=main@893e60f story=US1.6`, in `logs/capture.log`.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-180-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-180 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-180-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-180 board one fill from solve |
| `screenshots/04-result-180-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-180 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-180-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #180 Done with its own picture tile |
| `screenshots/06-puzzle-181-marks.png` | `PTU-mark-input` P1–P5, `PTD-ready-and-marks` P1 | pack-181: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-181-in-progress.png` | `PTU-mark-input` | pack-181 In progress after unsolved marks; #180 still Done |
| `screenshots/08-puzzle-182-crossed.png` | `PTD-crosses-and-fills` P1 | pack-182 with every non-solution cell crossed (shot before the fills) |
| `screenshots/09-puzzle-183-last-fill.png` | `PTD-solve-and-pb` P1 | pack-183 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_278.py`](tools/expectations_278.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→20) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-180 130 1 True True True True | class single-subject / single-subject | masses [130] holes 0
pack-181 137 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [137] holes 21
pack-182 139 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [119, 20] holes 0
pack-183 105 1 True True True True | class single-subject / single-subject | masses [105] holes 0
```

Columns are: filled, solutions, line-logic solves, that solution is the pixel, equals the row's `solution-fills`, equals
the row's clues; then the index-rule class against the catalog's `generation.settings.subject_class`. Band 100–180 for
20×20: all four inside. Cell luma under the fixed rule (filled mean / background mean): 93.0 / 188.9, 83.3 / 199.0,
87.8 / 186.2, 105.4 / 189.3 — wide separation, and the warm-pixel share is 0.00 % on every square and pixel file.
`puzzle_derive.py derive --size 20` from each committed square reproduces the committed pixel byte-identically and judges
`pass` (`logs/derive-judge.log`).

**Subject classes** (index rule on #294, index mod 10 ∈ {0, 3, 7} single): pack-180 (0) single — one connected mass of
130; pack-181 (1) multi/holed — one mass of 137 with 21 enclosed background cells; pack-182 (2) multi — two masses of 119
and 20; pack-183 (3) single — one connected mass of 105. Slice mix 2 single / 2 multi, matching the body with no
deviation.

## Notes from this run (not defects)

- The mark run is #181 and the crossed board is #182, so the crossed board starts clean (no resumed marks) and the win is
  judged on a board whose only marks are the ones the run places. #180 solves from a stored near-solve; #182 and #183 are
  filled to completion from their committed `solution-fills`.
- The gallery shows 3 completed after the slice (180, 182, 183); #181 stays In progress, which is what `PTU-mark-input`
  expects (unsolved marks do not complete a puzzle).
- S5 drag-paint ran: #181 has a clear run of three in a row, every cell ended Cross on the drawn board and in `DBG.2`.
