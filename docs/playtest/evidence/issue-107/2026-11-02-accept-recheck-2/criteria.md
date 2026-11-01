# Criteria — #107 at `main@22c88c2`

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | 15 + 15 lines, indices `0…14`; row 0 `[]`, row 6 `[1, 9]`, row 7 `[10]`; columns match the fixture | pass | Fixture re-checked independently: 59 fills, recomputed runs equal `row_clues`/`col_clues`, identical to the PoC source. Test literals `EXPECTED_ROW_CLUES` / `EXPECTED_COL_CLUES` parse to those lists (`test_named_teapot_lines_hold_their_literals`, `test_row_lines_match_…`, `test_column_lines_match_…`). |
| 2 | F3/F4 verbatim: no reorder, merge, or recompute from F5 | pass | `test_a_mutated_row_clue_reaches_only_its_own_row` (no other row or column moves), `test_solution_fills_are_never_read` (F5 emptied, lines unchanged), `test_a_mutated_clue_list_wins_over_disagreeing_solution_fills`. Mapper reads only `size`, `row_clues`, `col_clues`. |
| 3 | Empty list → zero runs, index kept, still counted | pass | `test_an_empty_clue_line_is_kept_as_zero_runs` (row 0 not null; 7 empty rows among 15), `test_a_non_empty_line_is_not_reported_empty`. |
| 4 | Orientation + index distinguish row 3 from column 3 | pass | `test_every_line_carries_its_orientation_and_index`, `test_row_three_is_not_column_three` (row 3 `[]`, column 3 `[3]`). |
| 5 | `SCH-puzzle-def` I1 at the mapping boundary; no padding or truncation | pass | Four error tests (14 rows, extra column, missing list, missing size), each asserting an error and **zero** lines. |
| 6 | Suite passes, exit 0 | pass | `logs/gut-accept.log`: 7 scripts, 113/113, 29166 asserts, exit 0. Counts checked, not just the exit code. |
| 7 | No line status / error / dim / auto-cross / generator / validator added | pass | Diff at this build adds only the three model files, the test, and the fixture. Auto-cross is #132’s code in `CMP-rules`, not here. |

## `PTD-ready-and-marks` P2 (new at this build)

Empty-clue lines come from the mapper under acceptance; #132’s ready edge writes the
crosses. Probe (`probe-ready-auto-cross.gd`, run then removed from `game/test/`):

- empty rows `[0, 1, 2, 3, 12, 13, 14]`, empty columns `[0, 1, 13, 14]`;
- after `open()` + `end_get_set_ready()`, all 225 cells checked: a cell is `CROSS` **iff**
  it sits on an empty-clue line — 137 crossed, 88 clear;
- nothing crossed during the beat; attempt `IN_PROGRESS`; elapsed 0.

Log: `logs/probe-ready-auto-cross.log` (2/2, 233 asserts, exit 0).

## Fixture integrity

`logs/fixture-check.log` — the teapot fixture is 15×15 with 59 fills, its clue lists are
byte-identical to `pocs/image-nonogram-pipeline/out/teapot/puzzle.json`, and recomputing
the runs from `solution_fills` reproduces both lists exactly (I3-clean). Expected empty
lines from that recomputation match the mapper’s output.
