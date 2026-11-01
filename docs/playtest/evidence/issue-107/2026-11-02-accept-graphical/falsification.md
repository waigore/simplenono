# Falsification — issue #107

Both mutations were applied to the acceptance worktree at `aff969b`, run against the full suite,
and reverted (`git checkout -- game/play/clue_lines.gd`). They prove the suite decides the
criteria instead of certifying itself.

## 1. Column lines read from `row_clues`

`game/play/clue_lines.gd`, column loop: `_runs(col_clues[index])` → `_runs(row_clues[index])`.

- **Result:** 126/139 passing, **13 failing**, exit 1
  ([`logs/falsify-columns-from-rows.log`](logs/falsify-columns-from-rows.log)).
- **Decides:** AC 1 (columns match the fixture), AC 2 (verbatim per-orientation order), AC 4
  (orientation is not interchangeable).

## 2. Short F3/F4 list padded instead of rejected

`_describe_line_set_failure`: the `line_set.size() != size` check was removed, so the builder
would index past a short list or silently build fewer lines.

- **Result:** 136/139 passing, **3 failing**, exit 1
  ([`logs/falsify-padded-lists.log`](logs/falsify-padded-lists.log)).
- **Decides:** AC 5 (`SCH-puzzle-def` I1 at the mapping boundary, no padding or truncation).

## Fixture independence

Not a mutation to the deliverable: the fixture's expected lists were checked against its own
`solution_fills` and the PoC source
([`logs/fixture-check.log`](logs/fixture-check.log)).

- 59 fills; runs recomputed row-wise and column-wise equal `row_clues` and `col_clues`.
- `size` / `row_clues` / `col_clues` are identical to
  `pocs/image-nonogram-pipeline/out/teapot/puzzle.json`.
- The test's `EXPECTED_ROW_CLUES` / `EXPECTED_COL_CLUES` parse to exactly the fixture lists, so
  AC 1 is asserted against copied data, not mapper output.
