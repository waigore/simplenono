# Playtest — issue #249

- **Issue:** #249 Puzzle pictures pack-066–pack-069 (15×15) (`type:task`)
- **Build / session id:** `main@212c7e0` / `issue-249-accept`
- **Coverage mode:** `full`
- **Run:** 2026-11-03, graphical (Metal, Apple Silicon), `godot --path game -s res://probe_capture_249.gd` with `--debug-seams`
- **Checkerboard of record:** `expect.json`, from `tools/expectations_249.py`, read straight off each committed `-pixel.png` — no `puzzle_derive.py` in the loop.

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
| `screenshots/02-puzzle-066-open-ready.png` | `PTU-play-puzzle` P1 | pack-066 opened via `DBG.3`, after Ready, one fill from solve |
| `screenshots/03-result-066-pictures.png` | `PTU-play-puzzle` P1, P2 | pack-066 solved → result screen drawing the generated square |
| `screenshots/04-gallery-066-done.png` | `PTU-play-puzzle` P2 | Back → gallery, pack-066 ever-completed |
| `screenshots/05-puzzle-067-marks.png` | `PTU-mark-input` P1–P5 | pack-067 after fill, clear, complement, and cross-drag; `DBG.2` agrees (console) |
| `screenshots/06-gallery-067-in-progress.png` | `PTU-mark-input` | pack-067 unsolved marks do not complete it |
| `screenshots/07-puzzle-068-crossed.png` | `PTD-crosses-and-fills` P1 | pack-068: all 163 non-solution cells crossed |
| `screenshots/08-puzzle-069-last-fill.png` | `PTD-solve-and-pb` P1, `PTD-crosses-and-fills` P2 | pack-069 after the last fill solves it |
| `screenshots/09-result-069-pictures.png` | `PTU-play-puzzle` P1 | pack-069 result screen, bar + block masses, calm cool palette |

## Logs and artifacts

| Path | Content |
|------|---------|
| `logs/capture-console.log` | Full capture session: every `capture: PASS` line, `TEL` events, the final `capture: RESULT pass (9 shots)` |
| `logs/state-pack-069.json` | `DBG.2` state dump after the run |
| `logs/derive-judge.log` | `puzzle_derive.py derive` + `cmp` + `judge` for all four puzzles |
| `logs/expectations.log` | Independent pixel read: fills, masses, holes, class, pack agreement |
| `logs/acceptance-checks.log` | Catalog shape, `generate_pack.py --check`, `asset_manifest.py --check`, `asset_catalog.py`, `spec_lint.py`, and the 138-test unit suite |
| `probe/probe_capture_249.gd` | The capture probe, kept for reproduction |
| `tools/expectations_249.py` | The independent `expect.json` builder |

## Shared picture bar (#294)

| Item | Evidence at `main@212c7e0` |
|------|---------------------------|
| 1. Two pictures, one source | Derive reproduces each committed pixel byte-identically (`cmp` clean). Squares 1024², pixels 15×15. No touch-up. |
| 2. Border | Flatten recorded in each pixel entry's `generation.settings` / `steps`; `background_rgb` 066 `[193,197,203]`, 067 `[196,204,206]`, 068 `[202,206,210]`, 069 `[202,210,213]`. |
| 3. Fill criterion and band | 97 / 56 / 62 / 63 of 225, all inside 56–101; fills equal the pixel's `Y < 128` cells. |
| 4. Clues match | Both clue axes recomputed from the pixel; `generate_pack.py --check` current; ids unchanged and distinct. |
| 5. One line-logic solution | `solutions: 1`, `logic_solved: true`, `matches_pixel: true`, `verdict: "pass"` on all four. |
| 6. Calm clinical look | Cool pale ground, dark geometric masses; screenshot 03 and 09. `review.verdict: Pass` on all eight entries. |
| 7. Catalog record | Shape checked per entry: kind, coverage, recipe, state, review, `serves`, `tool_role`, settings, `base_assets`, license, no `series`. |
| 8. Manifest | `asset_manifest.py --check` → 0 errors. |
| 9. Slice PR note | PR #369; the diff this tree carries is the same 26-file set. |

`K5` (pack-wide subject mix) is #294's, not this slice's.

## Screenshots

All nine are present and come from this graphical run; none is waiting on a re-run.
