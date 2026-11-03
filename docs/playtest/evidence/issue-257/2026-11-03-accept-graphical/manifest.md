# Playtest — issue #257

- **Issue:** #257 Puzzle pictures pack-098–pack-101 (15×15) (`type:task`)
- **Build / session id:** `main@fbde7ca` / `issue-257-accept` (the slice landed at PR #386's squash `5ac4894`;
  `pack-098`–`pack-101` and their eight catalog entries are byte-identical from `5ac4894` to `fbde7ca`)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, on the working tree at `fbde7ca`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_257.py`](tools/expectations_257.py),
  read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop
- **Log:** [`logs/capture.log`](logs/capture.log); `DBG.2` state dump: [`logs/state-pack-101.json`](logs/state-pack-101.json)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-098-open-ready.png`, `04-result-098-pictures.png`, `05-gallery-098-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-099-marks.png`, `07-gallery-099-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-098-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-100-crossed.png`, `03-puzzle-098-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-098-one-fill-from-solve.png`, `09-puzzle-101-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — no reset flow changed | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-098-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-098 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-098-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-098 board with every non-solution cell crossed and 89 of 90 fills placed |
| `screenshots/04-result-098-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-098 solved → result screen drawing its generated square (two upright plates on a pale cool field) |
| `screenshots/05-gallery-098-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #098 Done with its own picture tile beside seeded-silhouette neighbours |
| `screenshots/06-puzzle-099-marks.png` | `PTU-mark-input` P1–P5 | pack-099: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-099-in-progress.png` | `PTU-mark-input` | pack-099 In progress after unsolved marks; #098 still Done |
| `screenshots/08-puzzle-100-crossed.png` | `PTD-crosses-and-fills` P1 | pack-100 (single-subject) with all 133 non-solution cells crossed |
| `screenshots/09-puzzle-101-last-fill.png` | `PTD-solve-and-pb` P1 | pack-101 solved on its last fill → result screen, two unequal blocks |

## Shared picture bar on #294 — independent checks

[`tools/expectations_257.py`](tools/expectations_257.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-098 90 1 True True True True
pack-099 67 1 True True True True
pack-100 92 1 True True True True
pack-101 57 1 True True True True
```

Columns: filled / 225, solution count, line logic solves it, logic equals pixel, pixel equals pack `solution-fills`,
pixel equals pack clues. All four filled counts sit inside the 56–101 band.

Measured on the committed pixel files: 0.00% warm pixels on all four (`mean B > mean R`); luma mean/p5/p95
154.8/66.2/214.7 (098), 166.2/57.2/214.2 (099), 157.4/74.4/206.7 (100), 173.7/48.8/214.7 (101).

## Notes

- The probe was removed from `game/` after the run; this evidence folder is the only addition.
- The acceptance agent could not open the PNGs visually (no image input in this session). The look is therefore
  recorded by measurement — 0.00% warm pixels on every asset and screenshot, cool `mean B > mean R`, the luma
  spread above, and the silhouettes printed as text (098: two equal upright bars with a one-cell pale channel;
  099: a holed left bar beside a solid slab; 100: one connected stepped mass; 101: two unequal blocks). The printed
  shapes match the classes the body names. A human look at `04-result-098-pictures.png` stays open for the product
  owner and is not a blocker on any bar item.
- Every pass above is also asserted through the shell API, real input events, and `DBG.2` (35 PASS lines), so no
  pass item rests on a screenshot alone.
