# Playtest — issue #252

- **Issue:** #252 Puzzle pictures pack-078–pack-081 (15×15) (`type:task`)
- **Build / session id:** `main@c41c104` / `issue-252-accept` (the tree on `origin/main`; `git diff ee57b38 c41c104 -- game/assets/puzzle-pictures game/data/pack.json` shows no change to these four puzzles)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical (Metal, Apple arm64), `godot --path game -s res://probe_capture_252.gd` with `--debug-seams`, 900×1200
- **Checkerboard of record:** `expect.json`, from `tools/expectations_252.py`, read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop.

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
| `screenshots/02-puzzle-078-open-ready.png` | `PTU-play-puzzle` P1 | pack-078 opened via `DBG.3`, after Ready, one fill from solve |
| `screenshots/03-puzzle-078-one-fill-from-solve.png` | `PTD-solve-and-pb` P1 | pack-078 board, 83 of 84 fills placed |
| `screenshots/04-result-078-pictures.png` | `PTU-play-puzzle` P1, P2 | pack-078 solved → result drawing its generated square |
| `screenshots/05-gallery-078-done.png` | `PTU-play-puzzle` P2 | Back → gallery, pack-078 ever-completed |
| `screenshots/06-puzzle-079-marks.png` | `PTU-mark-input` P1–P5 | pack-079 after fill, clear, complement, and cross-drag; `DBG.2` agrees (console) |
| `screenshots/07-gallery-079-in-progress.png` | `PTU-mark-input` | pack-079 unsolved marks do not complete it |
| `screenshots/08-puzzle-080-crossed.png` | `PTD-crosses-and-fills` P1 | pack-080: all 153 non-solution cells crossed |
| `screenshots/09-puzzle-081-last-fill.png` | `PTD-solve-and-pb` P1, `PTD-crosses-and-fills` P2 | pack-081 after the last fill solves it; result square, cool palette |

## Logs and artifacts

| Path | Content |
|------|---------|
| `logs/capture-console.log` | Full capture session: every `capture: PASS` line, `TEL` events, the final `capture: RESULT pass (9 shots, 0 checks failed)` |
| `logs/state-pack-081.json` | `DBG.2` state dump after the run |
| `logs/derive-judge.log` | `puzzle_derive.py derive` + `cmp` + `judge` for all four puzzles |
| `logs/acceptance-checks.log` | `generate_pack.py --check`, `asset_manifest.py --check`, `asset_catalog.py`, and the unit suite (142 passed) |
| `logs/app-start.log` | The `app-start` harness run for `time-to-playable` (307.5 ms, pass) |
| `quality-app-start/` | That harness run's own folder (`integration/logs`, `results`, `samples`) |
| `probe/probe_capture_252.gd` | The capture probe, kept for reproduction |
| `tools/expectations_252.py`, `tools/nonogram.py` | The independent `expect.json` builder and its line solver |
| `reproduce.md` | Exact commands, including the build check |

## Screenshots

All nine are present and come from this graphical run; none is waiting on a re-run.
