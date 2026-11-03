# Playtest — issue #255

- **Issue:** #255 Puzzle pictures pack-090–pack-093 (15×15) (`type:task`)
- **Build / session id:** `main@29a9295` / `issue-255-accept` (the tree under acceptance; the slice landed at
  PR #381's squash `1e56ac1`, and `pack-090`–`pack-093` are byte-identical from `1e56ac1` to `29a9295`)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical (Metal, Apple arm64, GUI session), `godot --path game -s res://probe_capture_255.gd`
  with `--debug-seams`, 900×1200, on a detached worktree at `29a9295`
- **Checkerboard of record:** `expect.json`, from `tools/expectations_255.py`, read straight off each committed
  `-pixel.png` — no `puzzle_derive.py` in the loop.

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result |
|----------|-------|--------|
| `PTU-play-puzzle` | UX | pass |
| `PTU-mark-input` | UX | pass |
| `PTD-ready-and-marks` | Design | pass |
| `PTD-crosses-and-fills` | Design | pass |
| `PTD-solve-and-pb` | Design | pass |
| `PTU-gallery-reset` | UX | N/A — no reset flow changed |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected. Full log: [`logs/capture.log`](logs/capture.log).

## Judged states (screenshots are from this graphical run)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-090-open-ready.png` | `PTU-play-puzzle` P1 | pack-090 opened via `DBG.3`, Ready screen, clues `2 2 2 / 2 2 7 9 2 2 9 8 2 2 2 / 2 5 / 13` |
| `screenshots/03-puzzle-090-one-fill-from-solve.png` | `PTD-solve-and-pb` P1, `PTD-crosses-and-fills` P2 | pack-090 board with every non-solution cell crossed, 56 of 57 fills placed |
| `screenshots/04-result-090-pictures.png` | `PTU-play-puzzle` P1, P2 | pack-090 solved → result drawing its generated square (arch on a base bar) |
| `screenshots/05-gallery-090-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #090 "Done / Best 1:00" with its picture tile; #091 "Not started" |
| `screenshots/06-puzzle-091-marks.png` | `PTU-mark-input` P1–P5 | pack-091: fill, clear, complement to cross, and cross-drag; `DBG.2` agrees (`2 5 6`-style runs, "5 6" columns) |
| `screenshots/07-gallery-091-in-progress.png` | `PTU-mark-input` | pack-091 "In progress" after unsolved marks; #090 still Done |
| `screenshots/08-puzzle-092-crossed.png` | `PTD-crosses-and-fills` P1 | pack-092: all 125 non-solution cells crossed, four blocks split by a cross channel |
| `screenshots/09-puzzle-093-last-fill.png` | `PTD-solve-and-pb` P1 | pack-093 after the last fill solves it → result square, a bold cool-toned "C" |

`05-gallery-090-done.png` and `07-gallery-091-in-progress.png` also show the slice's contrast: #090 and #091 render
their own pictures while the neighbouring rows still render seeded silhouettes.

## Shared picture bar on #294 — independent checks

`tools/expectations_255.py` re-implements the bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and `tools/nonogram.py` is its own
line solver and enumerator, so neither imports `.github/scripts/puzzle_derive.py`.

```
pack-090 57 1 True True True True
pack-091 75 1 True True True True
pack-092 100 1 True True True True
pack-093 60 1 True True True True
```

Columns: filled / 225, solution count, line logic solves it, logic equals pixel, pixel equals pack `solution-fills`,
pixel equals pack clues. All four filled counts sit inside the 56–101 band.

## Notes

- The probe was removed from `game/` after the run; this evidence folder and the images are the only additions.
- The keyboard/pointer input in `06-puzzle-091-marks.png` and the board states were additionally asserted through the
  shell API and `DBG.2` (35 PASS lines), so no pass item rests on a screenshot alone.
- No screenshot shows a warm, cute, or playful subject: all four pictures are cool slate grey on pale cool grey.
