# Playtest run — issue #245 (graphical acceptance)

- **Issue:** #245 Puzzle pictures pack-050–pack-053 (15×15) (`type:task`)
- **Run id:** `2026-11-03-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-03
- **Build / session id:** `main@88f10ef`, Godot 4.7.2.stable, session `issue-245-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical on macOS arm64 (Metal 4.0 Forward+), 900×1200

## Scope

Deliverable: PR [#363](https://github.com/waigore/simplenono/pull/363) (squash `88f10ef`, `MERGED`) — eight picture
files under `game/assets/puzzle-pictures/`, their eight catalog entries, `assets/manifest.json`, and the rewritten
`solution-fills` / `row-clues` / `col-clues` on `pack-050`–`pack-053` in `game/data/pack.json`.

The tree under test is a clean worktree checked out at `88f10ef`; `git diff 88f10ef <that tree> -- game/` is empty.
`main` has since advanced through later picture slices, so the slice was played on its own squash rather than on
today's `main`.

The deliverable adds four playable boards and the pictures they resolve to. It changes no runtime code, but it does
change **playable pack data**: what each board fills, the clues it shows, and the pictures the result screen
morphs between. Protocols were selected by that reach:

| Protocol / story | Why it is in scope |
|------------------|--------------------|
| `PTD-ready-and-marks` P1 | Marks must be blocked during get-set-ready and allowed after it on a new board |
| `PTD-solve-and-pb` S1 / P1 | First solve on a shipped puzzle sets ever-completed and PB and clears marks/elapsed |
| `PTD-crosses-and-fills` P1–P2 | Win lands from the shipped fills; crosses on the other cells are non-fills |
| `PTU-play-puzzle` P1–P2 | Gallery → puzzle → result → gallery, tile reads done after |
| `PTU-mark-input` P1–P5, US1.6/6b/7/8 | Fill, clear, complement, drag on a new board (auto-cross changes which cells are clear) |
| `CMP-shell` R3 (result pictures) | Both stored pictures resolve and draw on the result screen |

Out of scope, with reason:

- `PTU-gallery-reset` S1–S3 — the slice changes picture files and pack rows, not the reset flow; the
  `EX.confirm` UI is owned by #311/#335 and untouched by PR #363. The flow was exercised incidentally while the
  completed `pack-050` was on the gallery; its intents work, but the dialog renders blank (pre-existing layout
  defect, filed as **#380**, screenshot `08`). It is not this slice's protocol row.
- `PTD-pack-finished` — needs a 199-completed fixture; the slice cannot reach it, and pack-wide completion stays
  on #294.
- `PTU-leave-resume`, `PTU-settings` — not reachable from picture data.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Pack load | **pass** | 200 entries accepted, 0 rejected |
| `PTD-ready-and-marks` P1 | **pass** | A tap during get-set-ready did not stick; marks allowed after Ready; fill → clear → cross transitions checked on `pack-051` |
| `PTU-play-puzzle` S1–S4 / P1–P2 | **pass** | `pack-050` opens via `DBG.3`, ready beat ends, last fill sends the app to `UI-result`, Back returns to the gallery with the tile Done |
| `PTD-solve-and-pb` S1 / P1 | **pass** | `pack-050`, `pack-052`, `pack-053`: ever-completed set, attempt not started, PB set, stored marks cleared |
| `CMP-shell` R3 | **pass** | Generated square and pixel picture both resolve on the result screen |
| `PTU-mark-input` P1 / P5 | **pass** | Tap fills the clear cell; `DBG.2` agrees |
| `PTU-mark-input` P2 / P5 | **pass** | Second tap clears it; `DBG.2` agrees |
| `PTU-mark-input` P3 / P5 | **pass** | Complement on a clear cell crosses it (tool Fill); `DBG.2` agrees |
| `PTU-mark-input` P4 / P5 | **pass** | Drag across 3 clear cells crosses each once; `DBG.2` agrees |
| Unfinished marks | **pass** | Unsolved marks do not complete `pack-051` |
| `PTD-crosses-and-fills` P1–P2 on `pack-052` | **pass** | Every non-solution cell crossed first (156 cells), then the last committed fill: solves once |
| `PTD-crosses-and-fills` P1–P2 on `pack-053` | **pass** | Every committed fill placed from an empty board: solves once |
| `PTU-gallery-reset` (out of slice scope) | **not judged** | Intents pass (Reset → Cancel keeps the record, Confirm clears it); the `EX.confirm` card draws blank on first open — defect **#380** |

Capture log: **62 `capture: PASS`, 0 `capture: FAIL`, exit 0**. Full console, telemetry, and `DBG.2` reads:
[`logs/capture-console.log`](logs/capture-console.log).

### Falsifiable checks on the picture data

The packs are the shipped rows, so a wrong clue, a wrong `solution-fills` set, or a pixel that disagrees with the
row shows up as "the board will not finish". `pack-052` is the strongest case: it is played with **every**
non-solution cell pre-crossed, so the win can only land if crosses are non-fills and the fill set is exactly the
committed one. `tools/expectations.py` re-derives fills, clues, uniqueness, line-logic reachability, the 56–101
band, the 1024² stored square, the border, and the warm-pixel ratio for all four puzzles from the committed
pixels with its own code, and compares them with the committed pack rows (see [`reproduce.md`](reproduce.md)).

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`01`](screenshots/01-gallery-fresh.png) | gallery after every record was cleared |
| [`02`](screenshots/02-puzzle-050-open-ready.png) | `pack-050` open, get-set-ready beat (15×15 board and clues) |
| [`03`](screenshots/03-puzzle-050-one-fill-from-solve.png) | `pack-050` one fill from solve (93 of 94 placed) |
| [`04`](screenshots/04-result-050-pictures.png) | result screen, generated square for `pack-050` |
| [`05`](screenshots/05-gallery-050-done.png) | gallery scrolled to `pack-050`: Done, best 1:00, its picture thumbnail |
| [`06a`](screenshots/06a-puzzle-051-fill.png) | `pack-051` after the Fill tap (judged cell filled) |
| [`06b`](screenshots/06b-puzzle-051-cleared.png) | `pack-051` after the second tap (judged cell cleared) |
| [`06c`](screenshots/06c-puzzle-051-complement.png) | `pack-051` after complement (judged cell crossed) |
| [`06d`](screenshots/06d-puzzle-051-drag.png) | `pack-051` after the 3-cell cross drag |
| [`07`](screenshots/07-gallery-051-in-progress.png) | gallery scrolled to `pack-051`: in progress, not completed |
| [`08`](screenshots/08-gallery-050-reset-confirm.png) | `EX.confirm` on first open — blank card, defect #380 |
| [`09`](screenshots/09-gallery-050-reset-cancelled.png) | gallery after Cancel (record unchanged) |
| [`10`](screenshots/10-gallery-050-after-confirm.png) | gallery scrolled to `pack-050` after Confirm: Not started |
| [`11`](screenshots/11-puzzle-052-crossed-near-solve.png) | `pack-052` with every non-solution cell crossed, one fill from solve |
| [`12`](screenshots/12-result-052-solved.png) | result screen after `pack-052`'s last fill |
| [`13`](screenshots/13-result-053-solved.png) | result screen after `pack-053` solved from its committed fills |
| [`14`](screenshots/14-gallery-final.png) | gallery scrolled to `pack-053`: Done; 2 completed after `pack-050` was reset |

## Paths

| Artifact | Path |
|----------|------|
| Judgement | [`notes.md`](notes.md) |
| Reproduce | [`reproduce.md`](reproduce.md) |
| Capture probe (run artifact, not main-tree code) | [`probe/probe_capture_245.gd`](probe/probe_capture_245.gd) |
| Independent expectations + solver | [`tools/expectations.py`](tools/expectations.py), [`tools/nonogram.py`](tools/nonogram.py), [`expect.json`](expect.json) |
| Console (`TEL.*`, `DBG.2`, every `capture:` line) | [`logs/capture-console.log`](logs/capture-console.log) |
| Import log | [`logs/godot-import.log`](logs/godot-import.log) |
| `SIT.3` state dump | [`logs/state-pack-053.json`](logs/state-pack-053.json) |
| Screenshots | [`screenshots/`](screenshots/) (17) |
| Scratch user data | [`logs/userdata/`](logs/userdata/) — the run's own `user://` home, regenerated, not committed ([README](logs/userdata/README.md)) |

## Quality evaluator

Deterministic record covering this deliverable tree:
[`docs/quality/evidence/issue-245/2026-11-03-verify/manifest.md`](../../../../quality/evidence/issue-245/2026-11-03-verify/manifest.md)
— `time-to-playable` **pass** (283.8 ms vs the 3 s bar) at `88f10ef`; every other Applies axis is unreachable for
a data-only change. No `llm-judge` axis exists in
[`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md), so no judge row applies.

## Defect observation

`EX.confirm` renders as a blank, full-height card on first open at 900×1200 and 1152×648 (defect **#380**). It is
pre-existing, reproducible without this slice, and outside the slice's deliverable; the box's Cancel/Confirm
intents were still judged at the record level. It does not change the slice protocols above.
