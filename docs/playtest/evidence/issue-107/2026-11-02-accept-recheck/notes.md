# Notes — issue #107 re-check

Build `main@37ef101`, headless, `full` coverage. Prior judgement:
[`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md).

## What changed since the last check

| Commit | Effect on #107 |
|---|---|
| #108 `17cd68d` — `rules.gd`, `line_status.gd`, `line_status_check.gd`, `attempt_state.gd` | `CMP-rules` R1–R2 calls `ClueLines.from_definition` and indexes the result by `ClueLine.orientation` + `.index`. The mapper now has a live consumer, so its contract is exercised end to end, not only by its own test file. |
| #136 `007140d` — `shell.tscn` / `shell.gd` | The run entry is a text stub: a title and one hardcoded puzzle id (`pack-000`). It sets a `Label`, nothing else. No board, clue bar, debug overlay, or telemetry. |
| Everything else since `ed9e33b` | Evidence/docs only (mockup approvals, acceptance holds, #101 quality evidence). No playable change. |

The deliverable's own files are byte-identical to the build judged last time
(`git diff ed9e33b 37ef101 -- game/play/clue_line.gd game/play/clue_lines.gd
game/play/clue_lines_result.gd game/test/test_clue_lines.gd
game/test/fixtures/teapot.json` is empty), and `git diff ed9e33b 37ef101 -- specs/playtest`
is empty, so the protocols did not move either.

## Criteria and fixture

Each acceptance criterion with its verdict is in [`criteria.md`](criteria.md); the fixture
integrity check is there too, so AC 1 is not self-certifying.

## Falsification

Columns sourced from `row_clues` instead of `col_clues` → **85/96 passing, 11 failing, exit
1**; reverted, `git status` clean. Detail: [`falsification.md`](falsification.md).

## Judgement carried forward

- **`E-clue`** — pass at the delivered layer (criteria 1–5 in [`criteria.md`](criteria.md)).
- **`PTD-ready-and-marks` P2** — N/A at this layer: `auto_cross` is `CMP-rules` R3 and the
  ready sequence is #132, not merged. The fixture does have empty lines (7 rows, 4 columns),
  so the recorded reason is "surface not delivered", not "no premise".
- **Clauses needing solve state, the puzzle screen, pause, or `DBG`/`TEL`** — out of scope:
  #108 rules landed but no screen exists (#110, #112), and #132 owns ready/auto-cross.
- No clause this build can decide was observed to fail; neither protocol's F1/F2 failed.

## Blocker

The required screenshots need a scene that draws a board and clue lines, plus the debug
surface the protocols name. `shell.gd` writes one `Label`; `grep` over `game/**/*.gd` and
`*.tscn` (excluding `addons/`) finds no `draw_*`, no `DBG.`, no `TEL.`. A graphical run of
`37ef101` renders a title and a puzzle id and has nothing of the judged states to capture.

This is the same structural hold recorded in
[`../../accept-dispatch-deadlock.md`](../../accept-dispatch-deadlock.md); each unblocking
option there is a spec or workflow change this agent must not make.

## Non-blocking

- A fresh worktree needs `godot --headless --path game --import` before GUT runs at all; the
  `Unit tests` row of `docs/coding-conventions.md` lists only the suite command.
- The GUT skip trap (unparseable test script → logged and skipped, still exit 0) is still
  unowned. The `Scripts` and `Tests` counts were read from the report rather than trusting
  the exit code.
