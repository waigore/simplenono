# Notes — issue #107 re-check

Build `main@37ef101`, headless, `full` coverage. Prior judgement:
[`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md).

## What changed since the last check

| Commit | Effect on #107 |
|---|---|
| #108 `17cd68d` — `game/play/rules.gd`, `line_status.gd`, `line_status_check.gd`, `attempt_state.gd` | `CMP-rules` R1–R2 loads the definition, calls `ClueLines.from_definition`, and indexes the result by `ClueLine.orientation` + `.index`. The mapper now has a live consumer, so its contract (orientation, index, verbatim runs, empty line = zero runs) is exercised end to end, not only by its own test file. |
| #136 `007140d` — `game/presentation/shell.tscn` / `shell.gd` | The run entry is now a text stub: a title and one hardcoded puzzle id (`pack-000`). It sets a `Label`, nothing else. Still no board, clue bar, debug overlay, or telemetry. |
| Everything else on `main` since `ed9e33b` | Evidence/docs only (mockup approvals #129/#130/#135, acceptance holds, #101 quality evidence). No playable change. |

The deliverable's own files are byte-identical to the build judged last time
(`git diff ed9e33b 37ef101 -- game/play/clue_line.gd game/play/clue_lines.gd
game/play/clue_lines_result.gd game/test/test_clue_lines.gd
game/test/fixtures/teapot.json` is empty), so criteria 1–5 were re-confirmed by reading the
mapper against the fixture and by re-running its tests rather than re-derived from scratch.

## Acceptance criteria at this build

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | 15 + 15 lines, indices 0…14; row 0 `[]`, row 6 `[1, 9]`, row 7 `[10]`; columns match the fixture literals | Pass | Fixture re-read at this build: 15 `row_clues`, 15 `col_clues`, `row0`/`row6`/`row7` exactly those lists; the test literals `EXPECTED_ROW_CLUES` / `EXPECTED_COL_CLUES` are copied lists, not mapper output |
| 2 | Runs passed through verbatim, no reorder/merge/recompute from F5 | Pass | Falsification below: sourcing columns from `row_clues` reddens 11 tests |
| 3 | Empty list → zero runs, same index, still counted | Pass | Row 0 is `[]` with `index == 0`; 7 of 15 rows and 4 of 15 columns are empty and all 15 of each are present |
| 4 | Orientation + index distinguish row 3 from column 3 | Pass | `ClueLine` carries both; row 3 = `[]`, column 3 = `[3]`; `CMP-rules` relies on exactly this to find line cells |
| 5 | `SCH-puzzle-def` I1 at the mapping boundary, never padded or truncated | Pass | Four error tests (14 rows, extra column, missing list, missing size) each assert a failed mapping and zero lines |
| 6 | Suite passes, exit 0 | Pass | 6 scripts, 96/96, 28620 asserts, exit 0 at `37ef101` |
| 7 | No line status / error / dim / auto-cross, no generator, no validation | Pass | `clue_lines.gd` reads only `size`, `row_clues`, `col_clues`; the rules checks that now sit beside it are #108's files, not this deliverable's |

## Fixture integrity

Independent of the mapper: the fixture's `size`, `row_clues`, and `col_clues` are identical
to `pocs/image-nonogram-pipeline/out/teapot/puzzle.json`, and recomputing runs from its own
`solution_fills` reproduces both clue lists exactly. So AC 1 is not self-certifying and the
fixture stays I3-clean for #105's loader. See [`logs/fixture-check.log`](logs/fixture-check.log).

## Falsification (run here, then reverted)

Columns sourced from `row_clues` instead of `col_clues` in `clue_lines.gd`: **85/96 passing,
11 failing, exit 1**. Reverted; `git status` clean afterwards. See
[`logs/gut-falsification-columns.log`](logs/gut-falsification-columns.log).

## Judgement carried forward

- **`E-clue`** — pass at the delivered layer (criteria 1–5 above).
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
[`../../../accept-dispatch-deadlock.md`](../../accept-dispatch-deadlock.md); each unblocking
option there is a spec or workflow change this agent must not make.

## Non-blocking

- A fresh worktree needs `godot --headless --path game --import` before GUT runs at all; the
  `Unit tests` row of `docs/coding-conventions.md` lists only the suite command.
- The GUT skip trap (unparseable test script → logged and skipped, still exit 0) is still
  unowned. Re-hit during this run's mutation step, so the `Scripts` and `Tests` counts were
  read from the report rather than trusting the exit code.
