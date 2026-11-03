# Playtest — issue #253

- **Issue:** #253 Puzzle pictures pack-082–pack-085 (15×15) (`type:task`)
- **Build / session id:** `main@49dc0c6` / `issue-253-accept` (the tree under acceptance)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical (Metal, Apple arm64, GUI session), `godot --path game -s res://probe_capture_253.gd` with `--debug-seams`, 900×1200
- **Checkerboard of record:** `expect.json`, from `tools/expectations_253.py`, read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop.

These four rows change playable behavior (each ships a different solution grid and
clues, and each gallery tile now resolves a picture pair), so playtesting is required.
The scope is the protocols these rows can reach; no other flow changed in the slice.

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

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines,
200 puzzles accepted and 0 rejected.

## Judged states (screenshots are from this graphical run)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-082-open-ready.png` | `PTU-play-puzzle` P1 | pack-082 opened via `DBG.3`, after Ready, one fill from solve |
| `screenshots/03-puzzle-082-one-fill-from-solve.png` | `PTD-solve-and-pb` P1 | pack-082 board, 55 of 56 fills placed |
| `screenshots/04-result-082-pictures.png` | `PTU-play-puzzle` P1, P2 | pack-082 solved → result drawing its generated square |
| `screenshots/05-gallery-082-done.png` | `PTU-play-puzzle` P2 | Back → gallery, pack-082 ever-completed ("Done", Best 1:00) |
| `screenshots/06-puzzle-083-marks.png` | `PTU-mark-input` P1–P5 | pack-083 after fill, clear, complement, and cross-drag; `DBG.2` agrees (console) |
| `screenshots/07-gallery-083-in-progress.png` | `PTU-mark-input` | pack-083 unsolved marks do not complete it |
| `screenshots/08-puzzle-084-crossed.png` | `PTD-crosses-and-fills` P1 | pack-084: all 157 non-solution cells crossed |
| `screenshots/09-puzzle-085-last-fill.png` | `PTD-solve-and-pb` P1, `PTD-crosses-and-fills` P2 | pack-085 after the last fill solves it; result square, cool palette |

`05-gallery-082-done.png` also shows the contrast the slice is for: #082 renders its new
picture while the un-sliced neighbours #076–#081 and #083 still render seeded silhouettes.

## Shared picture bar on #294 — independent checks

`tools/expectations_253.py` re-implements the bar's fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
`nonogram.py` is its own solver/enumerator, so neither imports `puzzle_derive.py`.

```
pack-082 56 1 True True True True
pack-083 56 1 True True True True
pack-084 68 1 True True True True
pack-085 74 1 True True True True
```

Columns: filled / 225, solution count, line logic solves it, logic equals pixel, pixel equals
pack `solution-fills`, pixel equals pack clues. All filled counts sit inside the 56–101 band.

## Notes

- Screenshot images saved by Godot's privacy filter were transcribed at the level shown;
  gallery and board states were additionally asserted through the shell API and `DBG.2`
  (35 PASS lines), so no pass item rests on an unreadable image alone.
- The probe was removed from `game/` after the run; only this evidence folder is added.
