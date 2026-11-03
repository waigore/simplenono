# Playtest — issue #251

- **Issue:** #251 Puzzle pictures pack-074–pack-077 (15×15) (`type:task`)
- **Build / session id:** `main@9053c8c` / `issue-251-accept` (`origin/main` at acceptance time; the slice landed earlier in PR #374)
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical (Metal, macOS arm64), `godot --path game -s res://probe_capture_251.gd` with `--debug-seams`
- **Checkerboard of record:** `expect.json`, from `tools/expectations_251.py`, read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop.

These four rows change playable behaviour (each ships a different solution grid and clues,
and each gallery tile now resolves a picture pair), so playtesting is required. The scope is
the protocols these rows can reach; no other flow changed in the slice.

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
| `screenshots/02-puzzle-074-open-ready.png` | `PTU-play-puzzle` P1 | pack-074 opened via `DBG.3`, after Ready, one fill from solve |
| `screenshots/03-result-074-pictures.png` | `PTU-play-puzzle` P1, P2 | pack-074 solved → result screen drawing the generated square |
| `screenshots/04-gallery-074-done.png` | `PTU-play-puzzle` P2 | Back → gallery, pack-074 ever-completed |
| `screenshots/05-puzzle-075-marks.png` | `PTU-mark-input` P1–P5 | pack-075 after fill, clear, complement, and cross-drag; `DBG.2` agrees (console) |
| `screenshots/06-gallery-075-in-progress.png` | `PTU-mark-input` | pack-075 unsolved marks do not complete it |
| `screenshots/07-puzzle-076-crossed.png` | `PTD-crosses-and-fills` P1 | pack-076: all 164 non-solution cells crossed |
| `screenshots/08-puzzle-077-last-fill.png` | `PTD-solve-and-pb` P1, `PTD-crosses-and-fills` P2 | pack-077 after the last fill solves it |
| `screenshots/09-result-077-pictures.png` | `PTU-play-puzzle` P1 | pack-077 result screen, holed ring on a plinth, calm cool palette |

## Logs and artifacts

| Path | Content |
|------|---------|
| `logs/capture-console.log` | Full capture session: every `capture: PASS` line, `TEL` events, the final `capture: RESULT pass (9 shots)` |
| `logs/state-pack-077.json` | `DBG.2` state dump after the run |
| `logs/derive-judge.log` | `puzzle_derive.py derive` + `cmp` + `judge` for all four puzzles |
| `logs/acceptance-checks.log` | `generate_pack.py --check`, `asset_manifest.py --check`, `asset_catalog.py`, and the 138-test unit suite |
| `probe/probe_capture_251.gd` | The capture probe, kept for reproduction |
| `tools/expectations_251.py` | The independent expect.json builder |

## Notes

See [`notes.md`](notes.md) for the judged detail and non-blocking marks.
