# Playtest — issue #273

- **Issue:** #273 Puzzle pictures pack-162–pack-165 (15×15) (`type:task`)
- **Build / session id:** graphical run `main@e945c88` / `issue-273-accept`. The slice landed at PR #445 squash
  `df95619`. Its eight picture files, eight `.import` sidecars, eight catalog entries and its four `pack.json` rows are
  unchanged between `df95619` and `e945c88` (`git diff --name-only df95619 e945c88` on those paths is empty, and
  `0` changed `pack-16{2..5}` lines in `game/data/pack.json`; see [`reproduce.md`](reproduce.md)). This run therefore
  tests the delivered slice on the accepted `main` tree.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 1440×1920 screen, `godot --path game`, not
  `--headless`), `--debug-seams`, on `e945c88`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_273.py`](tools/expectations_273.py),
  read straight off each committed `-pixel.png`; `puzzle_derive.py` is not in that path
- **Log / screenshots (wiki):** [Playtest-issue-273-2026-11-03-accept-graphical](https://github.com/waigore/simplenono/wiki/Playtest-issue-273-2026-11-03-accept-graphical)
  (`logs/capture.log`, `logs/derive-judge.log`, `logs/expectations.log`, `logs/acceptance-checks.log`,
  `logs/state-pack-165.json`, nine screenshots)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `01-gallery-fresh.png`, `02-puzzle-162-open-ready.png`, `04-result-162-pictures.png`, `05-gallery-162-done.png` |
| `PTU-mark-input` | UX | pass | `06-puzzle-163-marks.png`, `07-gallery-163-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `02-puzzle-162-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `08-puzzle-164-crossed.png`, `03-puzzle-162-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `03-puzzle-162-one-fill-from-solve.png`, `09-puzzle-165-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|----------------------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-162-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-162 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-162-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-162 board one fill from solve |
| `screenshots/04-result-162-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-162 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-162-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #162 Done with its own picture tile |
| `screenshots/06-puzzle-163-marks.png` | `PTU-mark-input` P1–P5 | pack-163: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-163-in-progress.png` | `PTU-mark-input` | pack-163 In progress after unsolved marks; #162 still Done |
| `screenshots/08-puzzle-164-crossed.png` | `PTD-crosses-and-fills` P1 | pack-164 with every non-solution cell crossed (shot after crossing, before the fills) |
| `screenshots/09-puzzle-165-last-fill.png` | `PTD-solve-and-pb` P1 | pack-165 solved on its last fill → result screen |

## Picture bar and repo checks

The bar-on-#294 re-measurement (independent fill rule per puzzle, subject classes, committed pixels), the picture
judge, and the repo checks are in the acceptance comment on #273; their logs are `logs/expectations.log`,
`logs/derive-judge.log`, and `logs/acceptance-checks.log` on the wiki page. `expect.json` holds the same numbers.

## Blockers

None.
