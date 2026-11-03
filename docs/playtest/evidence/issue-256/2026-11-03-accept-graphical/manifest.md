# Playtest — issue #256

- **Issue:** #256 Puzzle pictures pack-094–pack-097 (15×15) (`type:task`)
- **Build / session id:** `main@1c046f6` / `issue-256-accept` (the slice landed at PR #387's squash `4e61ae8`;
  `pack-094`–`pack-097` are byte-identical from `4e61ae8` to `1c046f6`)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, on a detached worktree at `1c046f6`
- **Checkerboard of record:** [`expect.json`](expect.json), from [`tools/expectations_256.py`](tools/expectations_256.py),
  read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop
- **Log:** [`logs/capture.log`](logs/capture.log); `DBG.2` state dump: [`logs/state-pack-097.json`](logs/state-pack-097.json)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-094-open-ready.png`, `04-result-094-pictures.png`, `05-gallery-094-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-095-marks.png`, `07-gallery-095-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-094-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-096-crossed.png`, `03-puzzle-094-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-094-one-fill-from-solve.png`, `09-puzzle-097-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — no reset flow changed | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-094-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-094 opened via `DBG.3`, Ready beat, clues shown |
| `screenshots/03-puzzle-094-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-094 board with every non-solution cell crossed, one fill short of solve |
| `screenshots/04-result-094-pictures.png` | `PTU-play-puzzle` P1–P2 | pack-094 solved → result screen drawing its generated square and pixel pair |
| `screenshots/05-gallery-094-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #094 Done with its picture tile |
| `screenshots/06-puzzle-095-marks.png` | `PTU-mark-input` P1–P5 | pack-095: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-095-in-progress.png` | `PTU-mark-input` | pack-095 In progress after unsolved marks; #094 still Done |
| `screenshots/08-puzzle-096-crossed.png` | `PTD-crosses-and-fills` P1 | pack-096 with all non-solution cells crossed, four blocks split by a cross channel |
| `screenshots/09-puzzle-097-last-fill.png` | `PTD-solve-and-pb` P1 | pack-097 solved on its last fill → result screen, single-subject plus |

## Shared picture bar on #294 — independent checks

[`tools/expectations_256.py`](tools/expectations_256.py) re-implements the fill rule and [`tools/nonogram.py`](tools/nonogram.py)
is its own line solver and enumerator, so neither imports `.github/scripts/puzzle_derive.py`.

```
pack-094 64 1 True True True True
pack-095 65 1 True True True True
pack-096 57 1 True True True True
pack-097 56 1 True True True True
```

Columns: filled / 225, solution count, line logic solves it, logic equals pixel, pixel equals pack `solution-fills`,
pixel equals pack clues. All four filled counts sit inside the 56–101 band. The same four puzzles were re-checked
with a second, separately written checker (own PNG reader, own solver) during acceptance: 64 / 65 / 57 / 56 fills,
one solution each, line logic reaching the pixel set, and pack fills and clues matching cell for cell.

## Notes

- The probe was removed from `game/` after the run; this evidence folder and the images are the only additions.
- The acceptance agent could not open the PNGs visually (no image input in this session). The look is therefore
  recorded by measurement — 0.00% warm pixels on every screenshot and asset, cool `mean B > mean R`, luma spread
  107–153 on the pixel files, and the silhouettes printed as text (094: two bars with a pale channel; 095: a holed
  left bar beside a wider slab; 096: a stacked pair; 097: a single plus) — not by a human or agent eyeball. A human
  look at `04-result-094-pictures.png` remains open for the product owner.
- Every pass above is asserted through the shell API, real input events, and `DBG.2` (35 PASS lines), so no pass
  item rests on a screenshot alone.
