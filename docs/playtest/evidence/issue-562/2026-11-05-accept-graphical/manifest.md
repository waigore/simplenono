# Playtest run — issue #562 (graphical acceptance, empty-line auto-cross removed)

- **Issue:** #562 Remove empty-line auto-cross after ready (`type:task`, `priority:high`; requirement origin: feedback #566)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** `main@6ec4077` (origin/main when the run started), sessions
  `issue-562-accept-main` / `-resume` / `-pause`, Godot 4.7.2.stable, Vulkan Forward+
  (llvmpipe under Xvfb, 900×1200 viewport), one fresh `user://` shared by the three
  processes. `git diff 3288a38 6ec4077 -- game/play game/records
  game/presentation/debug_seams.gd game/presentation/state_snapshot.gd` is empty, so the
  ready edge this issue changed (its merge is `3288a38`) is exactly the judged tree; the
  later presentation commits in that range (`38937ec`, `9a32abc`, `6ec4077`) touch the
  gallery only.
- **Coverage mode:** `full` · graphical, three processes (relaunch included)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-562-2026-11-05-accept-graphical>

## Scope

The deliverable (PR #572, merge `3288a38`) deletes `Rules.auto_cross_cells`, the
`MarkGrid.auto_cross` write entry point, `AttemptState.auto_cross`, and the
`end_get_set_ready` auto-cross path. Ready now takes line status, commits only on a
change, and emits E3, so the board stays exactly as the loaded progress left it — a fresh
board is all clear, empty clue lines included — and the attempt stays not started until
the player's first fill or cross. The protocols that surface can reach:

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTD-ready-and-marks`](../../../../../specs/playtest/design/ready-and-marks.md) S1–S4 / P1–P3 (`pack-015`) | Its P2 is the changed rule: empty-clue lines keep the loaded marks (all clear when fresh) and ready alone does not start the attempt. `pack-015` ships six empty clue rows and three empty clue columns, so 117 of its 225 cells are on empty-clue lines |
| [`PTU-mark-input`](../../../../../specs/playtest/ux/mark-input.md) S2–S5 / P1–P5 (`pack-018`) | The mark gestures now run on a board ready never wrote to; fill, clear, complement, and drag-paint are judged over that starting board with `DBG.2` read-back |
| `PTD-ready-and-marks` P2, cross-first (`pack-016`) | The other half of AC 3: a player's **first cross** starts the attempt, where the deleted auto-cross used to be the only cross before any player mark |
| [`PTD-crosses-and-fills`](../../../../../specs/playtest/design/crosses-and-fills.md) S1–S3 / P1–P2 (`pack-183`) | Twenty empty clue lines on a 20×20 board: all 295 non-solution cells are crossed by the player (232 of them on empty-clue lines) and the win still comes from fills alone |
| [`PTU-leave-resume`](../../../../../specs/playtest/ux/leave-resume.md) S1–S5 / P1–P3 (`pack-019`) | AC 4: in-progress marks restore on reopen with no new auto-cross, and a pause-then-quit restore keeps marks and elapsed |

Out of scope: `PTD-solve-and-pb`, `PTD-pack-finished`, `PTU-play-puzzle`, `PTU-settings`,
`PTU-gallery-reset`, `PTU-gallery-layout` — the deliverable changes the ready edge and the
attempt's status derivation only; pictures, PB, the pack-finished path, and gallery
layout/Reset are untouched and stay with their own acceptance evidence.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTD-ready-and-marks` S1–S4 / P1–P3 (`pack-015`) | **pass** | mark during the beat does not stick; after ready 0 crosses and 0 fills, all 117 empty-clue cells clear, attempt `not_started`; first fill → `in_progress`; clear, complement, wrong fill playable; pause froze elapsed at 2 and blocked marks |
| `PTU-mark-input` S2–S5 / P1–P5 (`pack-018`) | **pass** | fill / clear / complement / 3-cell drag-paint, `DBG.2` agreed with every judged cell; the board opened with 0 crosses |
| Cross-first start (`pack-016`) | **pass** | ready left the attempt `not_started`; the first cross (Cross tool) marked the cell and set `in_progress` |
| `PTD-crosses-and-fills` S1–S3 / P1–P2 (`pack-183`) | **pass** | 295 non-solution cells crossed (232 on empty-clue lines); the crossed board did not solve; the solution fills solved it once → result screen, `ever_completed` set |
| `PTU-leave-resume` S1–S5 / P1–P3 (`pack-019`) | **pass** | leave → tile `In progress`, stored elapsed 7, 0 crosses stored; relaunch → reopen restored the same 3 marks, `in_progress`, elapsed 7 ticking to 11, no auto-cross; pause + quit → reopen restored marks and elapsed 11, ticking to 15 |

Capture: `capture: RESULT pass` for all three phases (9 + 3 + 2 shots), **89 `capture: PASS`
checks, 0 failures**, exit 0 each; 200 puzzles accepted and 0 rejected; 1046 `TEL` lines
(`session=issue-562-accept-main|-resume|-pause build=main@6ec4077`).

## Judged states (wiki media, graphical run of this build)

| Screenshot | Judged state |
|------------|--------------|
| `01-gallery-fresh` | the fresh gallery after `DBG.reset_puzzle` over all 200 ids |
| `02-ready-015-during-beat` | `pack-015` during get-set-ready: the attempted mark left the tried cell clear |
| `03-ready-015-after-ready-empty-lines-clear` | after ready: no cross anywhere, the six empty clue rows and three empty clue columns all clear |
| `04-ready-015-marks-and-pause` | fill + complement cross + wrong fill, paused: elapsed frozen, marks blocked |
| `05-mark-018-input` | `pack-018` after fill, clear, complement, and the drag run |
| `06-cross-first-016-in-progress` | `pack-016`: the first cross, attempt `in_progress` |
| `07-crossed-183-empty-lines` | `pack-183` with all 295 non-solution cells crossed, empty clue lines included, not solved |
| `08-result-183` | `pack-183` solved from fills while every cross is still held |
| `09-gallery-019-in-progress` | `pack-019` tile reading In progress after Leave |
| `10-gallery-019-after-relaunch` | the tile still In progress after the process exited |
| `11-puzzle-019-resumed` | the reopened `pack-019` after ready: 3 restored fills, empty clue lines clear, no auto-cross |
| `12-settings-paused-019` | `UI-settings` while the attempt is paused (S4) |
| `13-gallery-019-after-pause-quit` | the tile after the pause-then-quit relaunch |
| `14-puzzle-019-after-pause-quit` | the reopened board after the pause-quit: marks and elapsed restored, empty clue lines clear |

## Paths

- Notes: [`notes.md`](notes.md)
- Reproduce: [`reproduce.md`](reproduce.md); the probe is [`probe/probe_accept_562.gd`](probe/probe_accept_562.gd)
- Screenshots and logs (wiki page above):
  `playtest/issue-562/2026-11-05-accept-graphical/screenshots/` and `.../logs/`
