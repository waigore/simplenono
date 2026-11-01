# Acceptance criteria — issue #107

Build `main@aff969b`; deliverable `ed9e33b` (PR #121), reformatted only by `c864c6b` (#127).
"Suite" is `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`
([`logs/gut-suite.log`](logs/gut-suite.log)); "probe" is
[`probe/probe_capture_107.gd`](probe/probe_capture_107.gd), a graphical run through the real
shell, screen, and attempt ([`logs/capture-console.log`](logs/capture-console.log)).

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | `teapot` fixture (size 15) maps to 15 row and 15 column lines, indices `0…14`; row 0 `[]`, row 6 `[1, 9]`, row 7 `[10]`; columns match the fixture's copied `col_clues` | **pass** | `test_teapot_maps_to_fifteen_rows_and_fifteen_columns`, `test_named_teapot_lines_hold_their_literals`, `test_column_lines_match_the_fixture_col_clues_in_order`; fixture re-checked independently — 59 fills, runs recomputed from F5 equal F3/F4, and the test's `EXPECTED_*` literals equal the fixture lists ([`logs/fixture-check.log`](logs/fixture-check.log)) |
| 2 | Run lengths pass through verbatim in F3/F4 order; no reorder, merge, or recomputation from F5 | **pass** | `test_a_mutated_row_clue_reaches_only_its_own_row` (F3[6] mutation appears in row 6 and nowhere else, rows or columns), `test_run_order_is_kept_and_nothing_is_merged`, `test_solution_fills_are_never_read`, `test_a_mutated_clue_list_wins_over_disagreeing_solution_fills`; falsification: columns read from `row_clues` → 13 failing, exit 1 |
| 3 | An empty-list line maps to zero runs (not null, not omitted), keeps its index, and still counts toward `size` | **pass** | `test_an_empty_clue_line_is_kept_as_zero_runs` (7 all-empty rows among 15), `test_a_non_empty_line_is_not_reported_empty`; probe reads `ClueLine.is_empty()` and index for every line, and the board renders `·` on pack-000 rows 0/9 and pack-001 columns 0/1/8/9 |
| 4 | Lines carry orientation and line index so a caller can tell row 3 from column 3 | **pass** | `test_every_line_carries_its_orientation_and_index`, `test_row_three_is_not_column_three` (row 3 `[]`, column 3 `[3]`); probe checks orientation and index per line on the shipped pack |
| 5 | `SCH-puzzle-def` I1 at the mapping boundary: a F3/F4 list count other than `size` is a mapping error, never padded or truncated | **pass** | four error tests (14 rows, extra column, missing list, missing size), each asserting zero lines; falsification: the count check removed → 3 failing, exit 1 |
| 6 | The suite passes with the `Unit tests` command, exiting 0 | **pass** | 11 scripts, 139/139, 29 204 asserts, exit 0 ([`logs/gut-suite.log`](logs/gut-suite.log)); counts read, not just the exit code, because GUT logs an unparseable script as skipped |
| 7 | No line-status, line-error, Satisfied/dim, auto-cross, generator, or `SCH-puzzle-def` validation added | **pass** | the deliverable files contain only the model/mapping; the words `satisfied`/`error` appear in comments naming `CMP-rules` R2/R3 as someone else's; `grep` over the three files finds no `LineStatus`, `auto_cross`, write, or generator; auto-cross observed in the probe comes from #132's open-ready edge |

## Deliverables

| Item | Verdict | Evidence |
|------|---------|----------|
| Clue-line view model (`ClueLine`: orientation, index, run lengths, `is_empty`) | **pass** | `game/play/clue_line.gd` |
| Mapper (`ClueLines.from_definition`) | **pass** | `game/play/clue_lines.gd`; probe calls it against the shipped pack-000/pack-001 definitions |
| Outcome type (`ClueLinesResult`, lines or one mapping error) | **pass** | `game/play/clue_lines_result.gd`; error state yields no lines |
| GUT tests | **pass** | `game/test/test_clue_lines.gd`, 17 tests, green in the full suite |
| Fixture | **pass** | `game/test/fixtures/teapot.json`, identical to `pocs/image-nonogram-pipeline/out/teapot/puzzle.json` on `size`/`row_clues`/`col_clues` |
| No new component ID | **pass** | only a clarifying sentence in `CMP-attempt` R2; no spec element added, `CMP-rules` R4 holds |

## Out-of-scope confirmations

- No line status, line error, Satisfied dim, or auto-cross in the delivered files; those are
  `CMP-rules` R2/R3 (#108) and the open-ready edge (#132). The probe's crossed cells are #132's
  output, used only to judge `PTD-ready-and-marks` P2.
- No clue generator or pack validation; `SCH-puzzle-def` I1/I3 enforcement stays with the loader
  (#105).
- No screen, input, theme, or persistence code; the board and clue bars are #110's drawing.

## Verdict

All criteria pass, and the graphical screenshots every earlier run was waiting for are in
[`screenshots/`](screenshots/). No defect.
