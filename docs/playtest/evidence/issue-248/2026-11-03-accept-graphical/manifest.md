# Playtest — issue #248

- **Issue:** #248 Puzzle pictures pack-062–pack-065 (15×15) (`type:task`)
- **Build / session id:** `main@1ea9dd2` / `issue-248-accept` (the PR #370 squash that lands the slice)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical (Metal 4.0, Apple M5), `godot --path game -s res://probe_capture_248.gd` with `--debug-seams`
- **Checkerboard of record:** `expect.json`, from `tools/expectations_248.py`, read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop.

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

## Judged states (screenshots are from this graphical run)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-fresh.png` | `PTU-play-puzzle` S1 | Gallery, 200 puzzles load, none completed |
| `screenshots/02-puzzle-062-open-ready.png` | `PTU-play-puzzle` P1 | pack-062 opened via `DBG.3`, after Ready, one fill from solve |
| `screenshots/03-result-062-pictures.png` | `PTU-play-puzzle` P1, P2 | pack-062 solved → result screen drawing the generated square |
| `screenshots/04-gallery-062-done.png` | `PTU-play-puzzle` P2 | Back → gallery, pack-062 ever-completed |
| `screenshots/05-puzzle-063-marks.png` | `PTU-mark-input` P1–P5 | pack-063 after fill, clear, complement, and cross-drag; `DBG.2` agrees (console) |
| `screenshots/06-gallery-063-in-progress.png` | `PTU-mark-input` | pack-063 unsolved marks do not complete it |
| `screenshots/07-puzzle-064-crossed.png` | `PTD-crosses-and-fills` P1 | pack-064: all 166 non-solution cells crossed |
| `screenshots/08-puzzle-065-last-fill.png` | `PTD-solve-and-pb` P1, `PTD-crosses-and-fills` P2 | pack-065 after the last fill solves it |
| `screenshots/09-result-065-pictures.png` | `PTU-play-puzzle` P1 | pack-065 result screen, L-shaped mass + block, calm cool palette |

## Logs and artifacts

| Path | Content |
|------|---------|
| `logs/capture-console.log` | Full capture session: every `capture: PASS` line, `TEL` events, the final `capture: RESULT pass (9 shots)` |
| `logs/state-pack-065.json` | `DBG.2` state dump after the run |
| `logs/derive-judge.log` | `puzzle_derive.py derive` + `cmp` + `judge` for all four puzzles |
| `logs/acceptance-checks.log` | `generate_pack.py --check`, `asset_manifest.py --check`, `asset_catalog.py`, and the 138-test unit suite |
| `quality-app-start/` | One `app-start` harness run at the same commit (`time-to-playable` 286.4 ms, pass) |
| `probe/probe_capture_248.gd` | The capture probe, kept for reproduction |
| `tools/expectations_248.py` | The independent expect.json builder |

## Screenshots

All nine are present and come from this graphical run; none is waiting on a re-run.
