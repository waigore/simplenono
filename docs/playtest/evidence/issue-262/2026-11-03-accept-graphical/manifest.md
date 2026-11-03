# Playtest — issue #262

- **Issue:** #262 Puzzle pictures pack-118–pack-121 (15×15) (`type:task`)
- **Build / session id:** `main@1161953` / `issue-262-accept` (the slice landed at PR #397's squash `fdbfa63`;
  the eight picture files and their eight catalog entries are unchanged from `fdbfa63` to `1161953`, and the four
  `pack.json` rows compare equal)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, on a clean worktree at `1161953`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_262.py`](tools/expectations_262.py),
  read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop
- **Log:** [`logs/capture.log`](logs/capture.log); `DBG.2` state dump: [`logs/state-pack-121.json`](logs/state-pack-121.json)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-118-open-ready.png`, `04-result-118-pictures.png`, `05-gallery-118-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-119-marks.png`, `07-gallery-119-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-118-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-120-crossed.png`, `03-puzzle-118-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-118-one-fill-from-solve.png`, `09-puzzle-121-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-118-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-118 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-118-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-118 board with every non-solution cell crossed and 61 of 62 fills placed |
| `screenshots/04-result-118-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-118 solved → result screen drawing its generated square (two upright blocks on a pale cool field) |
| `screenshots/05-gallery-118-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #118 Done with its own picture tile beside seeded-silhouette neighbours |
| `screenshots/06-puzzle-119-marks.png` | `PTU-mark-input` P1–P5 | pack-119: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-119-in-progress.png` | `PTU-mark-input` | pack-119 In progress after unsolved marks; #118 still Done |
| `screenshots/08-puzzle-120-crossed.png` | `PTD-crosses-and-fills` P1 | pack-120 with all 141 non-solution cells crossed |
| `screenshots/09-puzzle-121-last-fill.png` | `PTD-solve-and-pb` P1 | pack-121 solved on its last fill → result screen, two masses |

## Shared picture bar on #294 — independent checks

[`tools/expectations_262.py`](tools/expectations_262.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-118 62 1 True True True True
pack-119 79 1 True True True True
pack-120 84 1 True True True True
pack-121 73 1 True True True True
```

Columns: filled / 225, solution count, line logic solves it, logic equals pixel, pixel equals pack `solution-fills`,
pixel equals pack clues. All four filled counts sit inside the 56–101 band.

Re-running `puzzle_derive.py derive` from each committed square reproduces all four committed pixels byte for byte
(`cmp`: identical), and `puzzle_derive.py judge` reports `in_band: true`, `unique: true`, `solutions: 1`,
`logic_solved: true`, `matches_pixel: true` on each.

Measured on the committed pixel files: 0.00% warm pixels on all four and on all four squares (`mean B > mean R`);
pixel luma mean/p5/p95 157.4/49.0/205.2 (118), 159.3/76.3/209.4 (119), 157.0/82.4/203.2 (120), 160.1/54.9/214.2 (121).

Connected masses at 15×15 (4-connectivity): pack-118 **2** (36 + 26), pack-119 **2** (47 + 32), pack-120 **1** (84),
pack-121 **2** (43 + 30); no enclosed background cells on any board. That is the split the body names — `pack-120`
single-subject, the rest multi-subject and/or holed — and each catalog prompt states its class.

## Notes

- The probe was removed from `game/` after the run; this evidence folder is the only addition.
- The acceptance agent had no image input in this session, so the look (bar item 6) is recorded by measurement and
  printed silhouettes (see `notes.md`); a human look at `04-result-118-pictures.png` stays open for the product owner
  and blocks no bar item.
- Every pass above is also asserted through the shell API, real input events, and `DBG.2` (35 PASS lines), so no
  pass item rests on a screenshot alone.
