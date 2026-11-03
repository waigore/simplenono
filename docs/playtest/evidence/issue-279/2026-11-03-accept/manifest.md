# Playtest — issue #279

- **Issue:** #279 Puzzle pictures pack-184–pack-187 (20×20) (`type:task`)
- **Build / session id:** graphical run `main@05ef321` / `issue-279-accept`; repo checks `05ef321`. The slice landed at
  PR #478 (head `b42830d`, merged as `58e6637`, 2026-11-03T13:12Z); #277's evidence (`05ef321`) is the only later commit
  and touches no `game/` file, so this run tests the delivered slice on `main`.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 1440×1920 screen, 900×1200 viewport,
  `godot --path game` — not `--headless`), `--debug-seams`, on `05ef321`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_279.py`](tools/expectations_279.py),
  read straight off each committed `-pixel.png`; `puzzle_derive.py` is not in that path. Line logic and uniqueness come
  from [`tools/nonogram.py`](tools/nonogram.py) (`SIZE = 20`).
- **Log / screenshots (wiki):** [Playtest-issue-279-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-279-2026-11-03-accept)
  (`logs/capture.log`, `logs/import.log`, `logs/expectations.log`, `logs/derive-judge.log`, `logs/acceptance-checks.log`,
  `logs/state-pack-187.json`, nine screenshots)

These four rows change playable behavior (each ships a different 20×20 solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-184-open-ready.png`, `04-result-184-pictures.png`, `05-gallery-184-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-185-marks.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-184-open-ready.png`, `06-puzzle-185-marks.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/03-puzzle-184-one-fill-from-solve.png`, `08-puzzle-186-crossed.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-184-one-fill-from-solve.png`, `09-puzzle-187-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected. Telemetry: 1286 `TEL event` lines (marks, commits, solves, leaves), every one keyed to
`session=issue-279-accept build=main@05ef321 story=US1.6`, in `logs/capture.log`.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-184-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-184 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-184-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-184 board one fill from solve |
| `screenshots/04-result-184-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-184 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-184-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #184 Done with its own picture tile |
| `screenshots/06-puzzle-185-marks.png` | `PTU-mark-input` P1–P5, `PTD-ready-and-marks` P1 | pack-185: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-185-in-progress.png` | `PTU-mark-input` | pack-185 In progress after unsolved marks; #184 still Done |
| `screenshots/08-puzzle-186-crossed.png` | `PTD-crosses-and-fills` P1 | pack-186 with every non-solution cell crossed (shot before the fills) |
| `screenshots/09-puzzle-187-last-fill.png` | `PTD-solve-and-pb` P1 | pack-187 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_279.py`](tools/expectations_279.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→20) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-184 101 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [67, 34] holes 0
pack-185 144 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [144] holes 30
pack-186 175 1 True True True True | class multi-subject and/or holed / multi-subject and/or holed | masses [96, 79] holes 0
pack-187 129 1 True True True True | class single-subject / single-subject | masses [129] holes 0
```

Columns are: filled, solutions, line-logic solves, that solution is the pixel, equals the row's `solution-fills`, equals
the row's clues; then the index-rule class against the catalog's `generation.settings.subject_class`. Band 100–180 for
20×20: all four inside. Cell luma under the fixed rule (filled mean / background mean): 72.6 / 200.9, 75.0 / 202.8,
107.7 / 191.4, 74.4 / 199.4 — wide separation, and the warm-pixel share is 0.00 % on every square and pixel file.
`puzzle_derive.py derive --size 20` from each committed square reproduces the committed pixel byte-identically and judges
`pass` (`logs/derive-judge.log`).

**Subject classes** (index rule on #294, index mod 10 ∈ {0, 3, 7} single): pack-184 (4) multi — two masses, 67 + 34, no
hole; pack-185 (5) multi/holed — one mass of 144 with 30 enclosed background cells; pack-186 (6) multi — two masses of
96 and 79; pack-187 (7) single — one connected mass of 129. Slice mix 1 single / 3 multi, matching the body with no
deviation.

## Notes from this run (not defects)

- The mark run is #185 and the crossed board is #186, so the crossed board starts clean (no resumed marks) and the win is
  judged on a board whose only marks are the ones the run places. #184 solves from a stored near-solve; #186 and #187 are
  filled to completion from their committed `solution-fills`.
- The gallery shows 3 completed after the slice (184, 186, 187); #185 stays In progress, which is what `PTU-mark-input`
  expects (unsolved marks do not complete a puzzle).
- S5 drag-paint ran: #185 has a clear run of three in a row, every cell ended Cross on the drawn board and in `DBG.2`.
