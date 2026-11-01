# Criteria — issue #107 re-check

Build `main@37ef101`. Each criterion from the issue body, judged at this build against the
mapper, its tests, and the fixture.

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | 15 + 15 lines, indices 0…14; row 0 `[]`, row 6 `[1, 9]`, row 7 `[10]`; columns match the fixture literals | Pass | Fixture re-read: 15 `row_clues`, 15 `col_clues`, `row0`/`row6`/`row7` exactly those lists. The test literals `EXPECTED_ROW_CLUES` / `EXPECTED_COL_CLUES` are copied lists, not mapper output, and `test_named_teapot_lines_hold_their_literals` pins them. |
| 2 | Runs passed through verbatim, no reorder/merge/recompute from F5 | Pass | `test_a_mutated_row_clue_reaches_only_its_own_row`, `test_run_order_is_kept_and_nothing_is_merged`, `test_solution_fills_are_never_read`, `test_a_mutated_clue_list_wins_over_disagreeing_solution_fills`; plus the falsification in [`falsification.md`](falsification.md). |
| 3 | Empty list → zero runs, same index, still counted | Pass | Row 0 is `[]` with `index == 0`; 7 of 15 rows and 4 of 15 columns are empty and all 15 of each are present (`test_an_empty_clue_line_is_kept_as_zero_runs`, `test_a_non_empty_line_is_not_reported_empty`). |
| 4 | Orientation + index distinguish row 3 from column 3 | Pass | `ClueLine` carries both; row 3 = `[]`, column 3 = `[3]` (`test_row_three_is_not_column_three`). `CMP-rules` relies on exactly this to find a line's cells. |
| 5 | `SCH-puzzle-def` I1 at the mapping boundary, never padded or truncated | Pass | `test_too_few_row_clues_is_a_mapping_error`, `test_too_many_column_clues_is_a_mapping_error`, `test_a_missing_clue_list_is_a_mapping_error`, `test_a_missing_size_is_a_mapping_error` — each asserts a failed mapping and zero lines. |
| 6 | Suite passes, exit 0 | Pass | 6 scripts, 96/96, 28620 asserts, exit 0 ([`logs/gut-recheck.log`](logs/gut-recheck.log)). |
| 7 | No line status / error / dim / auto-cross, no generator, no validation | Pass | `clue_lines.gd` reads only `size`, `row_clues`, `col_clues`; the rules checks beside it are #108's files, not this deliverable's. |

## Fixture integrity

Independent of the mapper: the fixture's `size`, `row_clues`, and `col_clues` are identical to
`pocs/image-nonogram-pipeline/out/teapot/puzzle.json`, and recomputing runs from its own
`solution_fills` reproduces both clue lists exactly. The fixture is I3-clean for #105's loader
and AC 1 is not self-certifying. See [`logs/fixture-check.log`](logs/fixture-check.log).
