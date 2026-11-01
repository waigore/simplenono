# Acceptance criteria — issue #107

Build `main@aff969b`; deliverable `ed9e33b` (PR #121), reformatted only by `c864c6b` (#127).
"Suite" is `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`
([`logs/gut-suite.log`](logs/gut-suite.log)); "probe" is
[`probe/probe_capture_107.gd`](probe/probe_capture_107.gd), a graphical run through the real
shell, screen, and attempt ([`logs/capture-console.log`](logs/capture-console.log)).

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | 15 row + 15 column lines, indices `0…14`; row 0 `[]`, row 6 `[1, 9]`, row 7 `[10]`; columns match the fixture | **pass** | `test_teapot_maps_to_fifteen_rows_and_fifteen_columns`, `test_named_teapot_lines_hold_their_literals`, `test_column_lines_match_the_fixture_col_clues_in_order`; independently re-checked: 59 fills, runs recomputed from F5 equal F3/F4, test literals equal the fixture ([`logs/fixture-check.log`](logs/fixture-check.log)) |
| 2 | Verbatim F3/F4 order; no reorder, merge, or recompute from F5 | **pass** | `test_a_mutated_row_clue_reaches_only_its_own_row`, `test_run_order_is_kept_and_nothing_is_merged`, `test_solution_fills_are_never_read`, `test_a_mutated_clue_list_wins_over_disagreeing_solution_fills`; falsification: columns read from `row_clues` → 13 failing |
| 3 | Empty list → zero runs, keeps its index, still counts toward `size` | **pass** | `test_an_empty_clue_line_is_kept_as_zero_runs` (7 empty rows), `test_a_non_empty_line_is_not_reported_empty`; probe reads `is_empty()`/index for every line; board draws `·` on pack-000 rows 0/9 and pack-001 columns 0/1/8/9 |
| 4 | Orientation and index tell row 3 from column 3 | **pass** | `test_every_line_carries_its_orientation_and_index`, `test_row_three_is_not_column_three`; probe checks both per line on the shipped pack |
| 5 | `SCH-puzzle-def` I1 at the mapping boundary — a count other than `size` is an error, never padded or truncated | **pass** | four error tests (14 rows, extra column, missing list, missing size), each asserting zero lines; falsification: count check removed → 3 failing |
| 6 | Suite passes with the `Unit tests` command, exit 0 | **pass** | 11 scripts, 139/139, 29 204 asserts, exit 0; counts read, not just the exit code (GUT logs an unparseable script as skipped) |
| 7 | No line status/error/dim/auto-cross, generator, or loader validation added | **pass** | the three delivered files hold only model and mapping; `grep` finds no `LineStatus`, `auto_cross`, write, or generator; the crossed cells in the probe are #132's open-ready edge |

## Deliverables

| Item | Verdict | Evidence |
|------|---------|----------|
| `ClueLine` (orientation, index, run lengths, `is_empty`) | **pass** | `game/play/clue_line.gd` |
| `ClueLines.from_definition` | **pass** | `game/play/clue_lines.gd`; probe maps the shipped pack-000/001 definitions |
| `ClueLinesResult` (lines or one mapping error) | **pass** | `game/play/clue_lines_result.gd`; an error yields no lines |
| GUT tests | **pass** | `game/test/test_clue_lines.gd`, 17 tests, green in the suite |
| Fixture | **pass** | `game/test/fixtures/teapot.json`, identical to the PoC source on `size`/`row_clues`/`col_clues` |
| No new component ID | **pass** | one clarifying sentence in `CMP-attempt` R2; no spec element added, `CMP-rules` R4 holds |

## Out-of-scope confirmations

- No line status, line error, Satisfied dim, or auto-cross in the delivered files — `CMP-rules`
  R2/R3 (#108) and the open-ready edge (#132).
- No clue generator or pack validation; `SCH-puzzle-def` I1/I3 enforcement stays with the loader
  (#105).
- No screen, input, theme, or persistence code; the board is #110's drawing.

## Verdict

All criteria pass, and the graphical screenshots every earlier run waited for are in
[`screenshots/`](screenshots/). No defect.
