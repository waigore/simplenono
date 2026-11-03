# Playtest — issue #274

- **Issue:** #274 Puzzle pictures pack-166–pack-169 (15×15) (`type:task`)
- **Build / session id:** graphical run `main@ec135ed` / `issue-274-accept`; repo checks `ec135ed`. The slice landed at
  PR #448 (head `ac52f1a`). Its eight picture files, eight `.import` sidecars, eight catalog entries, and the four
  `pack.json` rows are byte-identical between `ac52f1a` and `ec135ed` (checked with `git diff`, see
  [`reproduce.md`](reproduce.md)), so this run tests the delivered slice on a later `main`. A sibling slice (#469,
  pack-178–179) landed during the run and changed `pack.json` for its own rows only; those rows and catalog entries are
  not this slice's.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 1440×1920 screen, `godot --path game` — not
  `--headless`), `--debug-seams`, on `ec135ed`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_274.py`](tools/expectations_274.py),
  read straight off each committed `-pixel.png`; `puzzle_derive.py` is not in that path
- **Log / screenshots (wiki):** [Playtest-issue-274-2026-11-03-accept-graphical](https://github.com/waigore/simplenono/wiki/Playtest-issue-274-2026-11-03-accept-graphical)
  (`logs/capture.log`, `logs/derive-judge.log`, `logs/expectations.log`, `logs/acceptance-checks.log`,
  `logs/state-pack-169.json`, nine screenshots)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-166-open-ready.png`, `04-result-166-pictures.png`, `05-gallery-166-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-167-marks.png`, `07-gallery-167-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-166-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-168-crossed.png`, `03-puzzle-166-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-166-one-fill-from-solve.png`, `09-puzzle-169-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-166-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-166 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-166-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-166 board one fill from solve |
| `screenshots/04-result-166-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-166 solved → result screen; both picture ids resolve |
| `screenshots/05-gallery-166-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #166 Done with its own picture tile |
| `screenshots/06-puzzle-167-marks.png` | `PTU-mark-input` P1–P5 | pack-167: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-167-in-progress.png` | `PTU-mark-input` | pack-167 In progress after unsolved marks; #166 still Done |
| `screenshots/08-puzzle-168-crossed.png` | `PTD-crosses-and-fills` P1 | pack-168 with every non-solution cell crossed (shot after crossing, before the fills) |
| `screenshots/09-puzzle-169-last-fill.png` | `PTD-solve-and-pb` P1 | pack-169 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_274.py`](tools/expectations_274.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-166 71 1 True True True True | masses [36, 35] holes 0
pack-167 57 1 True True True True | masses [57] holes 0
pack-168 90 1 True True True True | masses [54, 36] holes 0
pack-169 61 1 True True True True | masses [40, 21] holes 0
```

Columns: filled, solutions, line-logic solves, logic matches pixel, matches pack fills, matches pack clues.

Classes against the slice assignment (index mod 10 ∈ {0, 3, 7} single-subject): pack-167 (index 7) is single-subject;
pack-166, pack-168, pack-169 are multi-subject and/or holed. Measured structure agrees: pack-167 is one solid 57-cell
mass; pack-166 two masses (36 + 35); pack-168 two masses (54 + 36); pack-169 two masses (40 + 21). No enclosed regions
in any of the four. Warm pixels 0.00 % on every pixel and square; pixel luma mean 153.7 / 171.2 / 141.5 / 164.4.

The repo's derive and judge were also re-run from the committed squares (`logs/derive-judge.log` on the wiki page):
each derived pixel is byte-identical to its committed pixel, and each judge reports `solutions: 1`,
`logic_solved: true`, `matches_pixel: true`, filled inside the 56–101 band.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, scope, blockers | [`notes.md`](notes.md) |
| Screenshots and logs | [wiki page](https://github.com/waigore/simplenono/wiki/Playtest-issue-274-2026-11-03-accept-graphical) |
