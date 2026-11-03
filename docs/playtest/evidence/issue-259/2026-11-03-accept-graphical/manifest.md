# Playtest — issue #259

- **Issue:** #259 Puzzle pictures pack-106–pack-109 (15×15) (`type:task`)
- **Build / session id:** `main@8f66c6a` / `issue-259-accept` (the slice landed at PR #399's squash `95a46c4`;
  `pack-106`–`pack-109`, their eight catalog entries, and their four pack rows are byte-identical from
  `95a46c4` to `8f66c6a` — see [`reproduce.md`](reproduce.md) §0)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, on the working tree at `8f66c6a`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_259.py`](tools/expectations_259.py),
  read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop
- **Log:** [`logs/capture.log`](logs/capture.log); `DBG.2` state dump: [`logs/state-pack-109.json`](logs/state-pack-109.json)
- **Derive and judge of record:** [`logs/derive-judge.log`](logs/derive-judge.log)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-106-open-ready.png`, `04-result-106-pictures.png`, `05-gallery-106-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-107-marks.png`, `07-gallery-107-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-106-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-108-crossed.png`, `03-puzzle-106-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-106-one-fill-from-solve.png`, `09-puzzle-109-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — no reset flow changed | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected. Telemetry: 5 `open`, 5 `ready`, 310 `mark`, 310 `commit`, 3 `solved`, 1 `leave`, all keyed to
`session=issue-259-accept build=main@8f66c6a`.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-106-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-106 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-106-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-106 board with 55 of 56 fills placed |
| `screenshots/04-result-106-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-106 solved → result screen drawing its generated square (two upright blocks on a pale cool field) |
| `screenshots/05-gallery-106-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #106 Done with its own picture tile beside seeded-silhouette neighbours |
| `screenshots/06-puzzle-107-marks.png` | `PTU-mark-input` P1–P5 | pack-107: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-107-in-progress.png` | `PTU-mark-input` | pack-107 In progress after unsolved marks; #106 still Done |
| `screenshots/08-puzzle-108-crossed.png` | `PTD-crosses-and-fills` P1 | pack-108 with all 169 non-solution cells crossed |
| `screenshots/09-puzzle-109-last-fill.png` | `PTD-solve-and-pb` P1 | pack-109 solved on its last fill → result screen, two masses |

## Shared picture bar on #294 — independent checks

[`tools/expectations_259.py`](tools/expectations_259.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-106 56 1 True True True True
pack-107 79 1 True True True True
pack-108 56 1 True True True True
pack-109 78 1 True True True True
```

Columns: filled / 225, solution count, line logic solves it, logic equals pixel, pixel equals pack `solution-fills`,
pixel equals pack clues. All four filled counts sit inside the 56–101 band.

Measured on the committed pixel files: 0.00% warm pixels on all four (`mean B > mean R`); luma mean/p5/p95
168.1/98.8/206.4 (106), 152.4/68.3/210.3 (107), 171.8/90.2/208.5 (108), 159.8/54.9/224.4 (109).
Subject-versus-background luma contrast 78.8 (106), 105.4 (107), 98.6 (108), 137.2 (109).

Connected masses at 15×15 (4-connectivity): pack-106 **2** (31 + 25), pack-107 **1** (79, 8 enclosed cells),
pack-108 **1** (56), pack-109 **2** (42 + 36). Printed silhouettes are in [`notes.md`](notes.md).

Independent re-derive of the square (flatten + BOX, [`tools/recheck_259.py`](tools/recheck_259.py), not
`puzzle_derive.py`): the recorded flatten background reproduces exactly on all four (`[189,196,199]`,
`[195,201,208]`, `[202,207,212]`, `[213,218,221]`) and per-cell colour matches the committed pixel within 2.2/255
(0–1 cells flip at the `Y < 128` boundary, on cells within ~1 luma unit of it) — [`logs/recheck.log`](logs/recheck.log).
The bar's own check — the PR's stated derive command — reproduces each committed pixel byte-for-byte
([`logs/derive-judge.log`](logs/derive-judge.log), `cmp: identical` ×4; the shipped judge reports `verdict: pass`,
`solutions: 1`, `logic_solved: true`, `matches_pixel: true` ×4).

## Notes

- The probe was removed from `game/` after the run; this evidence folder is the only addition.
- The acceptance agent could not open the PNGs visually (no image input in this session). The look is therefore
  recorded by measurement and printed silhouettes (see `notes.md`); a human look at `04-result-106-pictures.png`
  stays open for the product owner and blocks no bar item.
- Every pass above is also asserted through the shell API, real input events, and `DBG.2` (35 PASS lines), so no
  pass item rests on a screenshot alone.
- Reset telemetry is out of scope here: its gap is owned by #423, as the parent's notes state.
