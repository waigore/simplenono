# Playtest run — issue #233 (graphical acceptance)

- **Issue:** #233 Puzzle pictures pack-004–pack-007 (10×10) (`type:task`)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `main@7192358`, Godot 4.7.2.stable, session `issue-233-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical under Xvfb (llvmpipe Vulkan, 900×1200)

## Scope

Deliverable: PR [#297](https://github.com/waigore/simplenono/pull/297) (squash `f082f98`, `MERGED`) — eight picture
files under `game/assets/puzzle-pictures/`, their eight catalog entries, `assets/manifest.json`, and the rewritten
`solution-fills` / `row-clues` / `col-clues` on `pack-004`–`pack-007` in `game/data/pack.json`.

`git diff f082f98 7192358 -- game/` is empty, so the build under test is the deliverable tree (only docs and export
config changed after it).

The deliverable adds static pictures and rewrites four pack rows. It changes no runtime code, but it does change
**playable pack data**: what the board fills, which cells are crossed, and which pictures the result screen morphs
between. Protocols were selected by that reach:

| Protocol / story | Why it is in scope |
|------------------|--------------------|
| `PTD-crosses-and-fills` P1–P2 | Win must land when the shipped `solution-fills` are filled, with crosses on the rest |
| `PTD-solve-and-pb` S1 / P1 | First solve on a shipped puzzle sets ever-completed and clears marks |
| `PTD-ready-and-marks` P1 | Marks blocked during get-set-ready, allowed after |
| `PTU-play-puzzle` P1–P2 | Gallery → puzzle → result → gallery, tile reads done after |
| `PTU-mark-input` P1–P5, US1.6/6b/7/8 | Fill, clear, complement, drag on the new boards (auto-cross changes which cells are clear) |
| `PTU-gallery-reset` S1 | C2 Reset offered for a completed puzzle; gallery returns to Default |

Out of scope with reason: `PTU-gallery-reset` S2–S3 need the `EX.confirm` dialog, which `shell.gd`
(`_on_gallery_reset_requested`) documents as #96 work and which is not in this build; no story row assigns it to
this task. `PTD-pack-finished`, `PTU-leave-resume`, and `PTU-settings` are not reachable from picture data.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Pack load | **pass** | 200 entries accepted, 0 rejected |
| `PTU-play-puzzle` S1 / P1 | **pass** | `pack-004` opens via `DBG.3`, ready beat ends, marks allowed |
| `PTD-crosses-and-fills` P1 | **pass** | The solving fill fires `E1` once and reaches the result screen |
| `CMP-shell` R3 (result pictures) | **pass** | Both stored pictures resolve on the result screen |
| `PTU-play-puzzle` P2 | **pass** | Back from result → gallery shows `pack-004` done |
| `PTU-mark-input` P1 / P5 | **pass** | Tap fills a clear cell; `DBG.2` agrees |
| `PTU-mark-input` P2 / P5 | **pass** | Second tap clears it; `DBG.2` agrees |
| `PTU-mark-input` P3 / P5 | **pass** | Complement on a clear cell crosses it (tool Fill); `DBG.2` agrees |
| `PTU-mark-input` P4 / P5 | **pass** | Drag across 3 clear cells crosses each once, `DBG.2` agrees |
| Unfinished marks | **pass** | Unsolved marks do not complete a puzzle |
| `PTU-gallery-reset` S1 / F2 | **pass** | C2 offered for an ever-completed puzzle; the intent alone writes no record (#96 owns confirm) |
| `PTD-crosses-and-fills` P1–P2 on `pack-006` | **pass** | Every non-solution cell crossed first, then all 30 fills: still solves once |
| `PTD-crosses-and-fills` P1–P2 on `pack-007` | **pass** | All 30 fills from the committed row solve once |
| `PTD-solve-and-pb` S1 / P1 | **pass** | `pack-006` and `pack-007` read ever-completed after the solve |

Capture log: **41 `capture: PASS`, 0 `capture: FAIL`, exit 0**. Full console, telemetry, and `DBG.2` reads:
[`logs/capture-console.log`](logs/capture-console.log).

### Falsifiable checks on the picture data

The packs are the shipped rows, so a wrong clue, a wrong `solution-fills` set, or a pixel that disagrees with the
row shows up as "the board will not finish". `pack-006` is the strongest case: it is played with **every** non-solution
cell pre-crossed (70 of 100), so the win can only land if crosses are non-fills and the fill set is exactly the
committed one. Before the run, independent code re-derived each committed pixel's fill set, clues, uniqueness, and
line-logic solvability from the committed PNGs and matched them to the committed rows
([`tools/expectations.py`](tools/expectations.py), output in [`expect.json`](expect.json)).

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`01`](screenshots/01-gallery-fresh.png) | gallery after a full reset, before any solve |
| [`02`](screenshots/02-puzzle-004-open-ready.png) | `pack-004` open, get-set-ready transition |
| [`03`](screenshots/03-puzzle-004-one-fill-from-solve.png) | `pack-004` one fill from solve (40 in the row, 39 placed) |
| [`04`](screenshots/04-result-004-pictures.png) | result screen with the generated square and pixel pictures |
| [`05`](screenshots/05-gallery-004-done.png) | gallery after Back: `pack-004` done |
| [`06`](screenshots/06-puzzle-005-marks.png) | `pack-005` after fill / clear / complement / drag |
| [`07`](screenshots/07-gallery-005-in-progress.png) | gallery: `pack-005` in progress, not completed |
| [`08`](screenshots/08-gallery-005-reset-offered.png) | Reset activated on a completed tile (no confirm dialog in this build) |
| [`09`](screenshots/09-gallery-005-after-reset.png) | gallery after the record was cleared through O7 |
| [`10`](screenshots/10-puzzle-006-near-solve.png) | `pack-006` open with every non-solution cell crossed |
| [`11`](screenshots/11-puzzle-007-last-fill.png) | `pack-007` result screen after its last shipped fill |

## Paths

| Artifact | Path |
|----------|------|
| Judgement | [`notes.md`](notes.md) |
| Reproduce | [`reproduce.md`](reproduce.md) |
| Capture probe (run artifact, not main-tree code) | [`probe/probe_capture_233.gd`](probe/probe_capture_233.gd) |
| Independent expectations + solver | [`tools/expectations.py`](tools/expectations.py), [`tools/nonogram.py`](tools/nonogram.py), [`expect.json`](expect.json) |
| Console (`TEL.*`, `DBG.2`, every `capture:` line) | [`logs/capture-console.log`](logs/capture-console.log) |
| Import log | [`logs/godot-import.log`](logs/godot-import.log) |
| `SIT.3` state dump | [`logs/state-pack-007.json`](logs/state-pack-007.json) |
| Screenshots | [`screenshots/`](screenshots/) (11) |
| Scratch user data | [`logs/userdata/`](logs/userdata/) — the run's own `user://`, not the runner's; regenerated, not committed |

## Quality evaluator

Deterministic record covering this `game/` tree: [`docs/quality/evidence/issue-233/2026-11-02-verify/manifest.md`](../../../../quality/evidence/issue-233/2026-11-02-verify/manifest.md)
— `time-to-playable` **pass** (1798.1 ms vs the 3 s bar); every other Applies axis is unreachable for a data-only
change. No `llm-judge` axis applies (no `llm-judge` row exists in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md)).
