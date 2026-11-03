# Playtest — issue #266

- **Issue:** #266 Puzzle pictures pack-134–pack-137 (15×15) (`type:task`)
- **Build / session id:** `main@dafc87c` / `issue-266-accept` (the slice landed at PR #411's squash `d10d86d`;
  the eight picture files, their eight `.import` sidecars, the eight catalog entries, the eight
  `assets/manifest.json` entries, and the four `pack.json` rows of `pack-134`–`pack-137` are identical from
  `d10d86d` to `dafc87c`, so this tree plays exactly the delivered rows even though later slices landed after it)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run:** 2026-11-03, graphical through `xvfb-run` (Godot 4.7.2 stable, 900×1200, `godot --path game` — not
  `--headless`), `--debug-seams`, on a worktree at `dafc87c`
- **Checkerboard of record:** [`expect.json`](expect.json), from
  [`tools/expectations_266.py`](tools/expectations_266.py), read straight off each committed `-pixel.png` — no
  `puzzle_derive.py` in the loop
- **Log:** [`logs/capture.log`](logs/capture.log); `DBG.2` state dump: [`logs/state-pack-137.json`](logs/state-pack-137.json)

These four rows change playable behavior (each ships a different solution grid and clues, and each gallery tile now
resolves a picture pair), so playtesting is required. The scope is the protocols these rows can reach; no other flow
changed in the slice.

## Results

| Protocol | Level | Result | Screenshot |
|----------|-------|--------|------------|
| `PTU-play-puzzle` | UX | pass | `screenshots/01-gallery-fresh.png`, `02-puzzle-134-open-ready.png`, `04-result-134-pictures.png`, `05-gallery-134-done.png` |
| `PTU-mark-input` | UX | pass | `screenshots/06-puzzle-135-marks.png`, `07-gallery-135-in-progress.png` |
| `PTD-ready-and-marks` | Design | pass | `screenshots/02-puzzle-134-open-ready.png` |
| `PTD-crosses-and-fills` | Design | pass | `screenshots/08-puzzle-136-crossed.png`, `03-puzzle-134-one-fill-from-solve.png` |
| `PTD-solve-and-pb` | Design | pass | `screenshots/03-puzzle-134-one-fill-from-solve.png`, `09-puzzle-137-last-fill.png` |
| `PTU-gallery-reset` | UX | N/A — a picture slice changes no reset flow | — |
| `PTD-pack-finished`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a picture slice | — |

Final line: `capture: RESULT pass (9 shots, 0 checks failed)`, 35 `capture: PASS` lines, 200 puzzles accepted and
0 rejected.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-134-open-ready.png` | `PTU-play-puzzle` P1, `PTD-ready-and-marks` | pack-134 opened via `DBG.3`, Ready beat, clues drawn |
| `screenshots/03-puzzle-134-one-fill-from-solve.png` | `PTD-crosses-and-fills` P2, `PTD-solve-and-pb` P1 | pack-134 board with 61 of its 62 fills placed |
| `screenshots/04-result-134-pictures.png` | `PTU-play-puzzle` P1–P2, `CMP-shell` R3 | pack-134 solved → result screen drawing its generated square |
| `screenshots/05-gallery-134-done.png` | `PTU-play-puzzle` P2 | Back → gallery, #134 Done with its own picture tile |
| `screenshots/06-puzzle-135-marks.png` | `PTU-mark-input` P1–P5 | pack-135: fill, clear, complement to cross, cross-drag; `DBG.2` agrees after each |
| `screenshots/07-gallery-135-in-progress.png` | `PTU-mark-input` | pack-135 In progress after unsolved marks; #134 still Done |
| `screenshots/08-puzzle-136-crossed.png` | `PTD-crosses-and-fills` P1 | pack-136 with all 153 non-solution cells crossed |
| `screenshots/09-puzzle-137-last-fill.png` | `PTD-solve-and-pb` P1 | pack-137 solved on its last fill → result screen |

## Shared picture bar on #294 — independent checks

[`tools/expectations_266.py`](tools/expectations_266.py) re-implements the fill rule (alpha over white,
`Y = 0.2126R + 0.7152G + 0.0722B` on 0–255 sRGB, filled when `Y < 128`, BOX 1024→15) and
[`tools/nonogram.py`](tools/nonogram.py) is its own line solver and enumerator, so neither imports
`.github/scripts/puzzle_derive.py`.

```
pack-134 62 1 True True True True | masses [62] holes 0
pack-135 75 1 True True True True | masses [55, 20] holes 0
pack-136 72 1 True True True True | masses [72] holes 0
pack-137 57 1 True True True True | masses [57] holes 0
```

The repo's derive and judge were also re-run from the committed squares
([`logs/derive-judge.log`](logs/derive-judge.log)): each derived pixel is byte-identical to its committed pixel, and
each judge reports `solutions: 1`, `logic_solved: true`, `matches_pixel: true`, filled inside the 56–101 band.
Subject classes: pack-137 single-subject; pack-134, pack-135, pack-136 multi-subject and/or holed — as the slice
states.

Judgement text: [`notes.md`](notes.md). Reproduce steps: [`reproduce.md`](reproduce.md).
