# Playtest — issue #277

- **Issue:** #277 Puzzle pictures pack-178–pack-179 (15×15) (`type:task`)
- **Build / session id:** graphical run `main@58e6637` / `issue-277-accept`; repo checks `58e6637`. The slice landed at
  PR #469 (head `8f91379`, merged as `0eb2d1d`, 2026-11-03T11:59Z). Its eight picture files, eight `.import` sidecars,
  four catalog entries, and the two `pack.json` rows are byte-identical between `0eb2d1d` and `58e6637` (checked with
  `git diff`, see [`reproduce.md`](reproduce.md)); the only shared file that moved is `assets/manifest.json`, which
  gained sibling slices' ids. So this run tests the delivered slice on a later `main`.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 1440×1920 screen, `godot --path game` — not
  `--headless`), `--debug-seams`, on `58e6637`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_277.py`](tools/expectations_277.py),
  read straight off each committed `-pixel.png`; `puzzle_derive.py` is not in that path. Line logic and uniqueness come
  from [`tools/nonogram.py`](tools/nonogram.py).
- **Log / screenshots (wiki):** [Playtest-issue-277-2026-11-03-accept](https://github.com/waigore/simplenono/wiki/Playtest-issue-277-2026-11-03-accept)
  (`logs/capture.log`, `logs/import.log`, `logs/expectations.log`, `logs/derive-judge.log`, `logs/acceptance-checks.log`,
  `logs/state-pack-179.json`, nine screenshots)

These two rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-178-open-ready.png`, `04-result-178-pictures.png`, `05-gallery-178-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-179-marks.png`, `07-gallery-179-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-178-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/03-puzzle-178-one-fill-from-solve.png`, `08-puzzle-179-crossed.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-178-one-fill-from-solve.png`, `09-puzzle-179-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 30 `capture: PASS` lines, 200 puzzles accepted and
0 rejected. Telemetry: 676 `TEL event` lines (marks, commits, solves, leaves), every one keyed to
`session=issue-277-accept build=main@58e6637 story=US1.6`, in `logs/capture.log`.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-178-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-178 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-178-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-178 board one fill from solve |
| `screenshots/04-result-178-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-178 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-178-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #178 Done with its own picture tile |
| `screenshots/06-puzzle-179-marks.png` | `PTU-mark-input` P1–P5 | pack-179: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-179-in-progress.png` | `PTU-mark-input` | pack-179 In progress after unsolved marks; #178 still Done |
| `screenshots/08-puzzle-179-crossed.png` | `PTD-crosses-and-fills` P1 | pack-179 with every non-solution cell crossed (shot after crossing, before the fills) |
| `screenshots/09-puzzle-179-last-fill.png` | `PTD-solve-and-pb` P1 | pack-179 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_277.py`](tools/expectations_277.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-178 67 1 True True True True | masses [67] holes 4 | pixel look {'warm_percent': 0.0, 'luma_mean': 158.5, ...}
pack-179 69 1 True True True True | masses [36, 33] holes 0 | pixel look {'warm_percent': 0.0, 'luma_mean': 175.6, ...}
```

Columns are: filled, solutions, line-logic solves, that solution is the pixel, equals the row's `solution-fills`, equals
the row's clues. Band 56–101 for 15×15: both inside. Cell luma under the fixed rule: 178 fills 54.1–123.4, mean 76.9,
against background 129.3–208.5, mean 193.2; 179 fills 73.1–127.7, mean 95.7, against 129.7–221.7, mean 211.0 — wide
separation at the means, no cell on the threshold. `puzzle_derive.py derive --size 15` from each committed square
reproduces the committed pixel byte-identically and judges `pass` (`logs/derive-judge.log`).

**Subject classes** (index rule on #294): pack-178 (178 mod 10 = 8) → multi-subject and/or holed — one mass of 67 with
two enclosed 2-cell holes; pack-179 (179 mod 10 = 9) → multi-subject and/or holed — masses of 36 and 33, no holes.
Slice mix 0 single / 2 multi, matching the body. Each stored prompt states the multi-subject and/or holed class.

## Notes from this run (not defects)

- #179's mark run leaves two marks in solution cells (it clears then re-fills (0,0) and crosses its complement); the
  re-open resumes them, so the win is judged on the resumed board. It solves: 126 marks present at open, last fill →
  result screen, `ever_completed` set. The probe checks the resumed mark count and dumps
  `logs/state-pack-179.json`.
