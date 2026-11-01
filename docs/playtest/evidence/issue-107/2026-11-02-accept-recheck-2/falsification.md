# Falsification — #107 re-check 2

The clue tests are only evidence if they fail when the mapping is wrong. Re-run here on
`main@22c88c2`, not taken from a prior comment.

## Mutation: columns sourced from `row_clues`

In `game/play/clue_lines.gd`, the column loop was changed from
`_runs(col_clues[index])` to `_runs(row_clues[index])`.

| Check | Result |
|-------|--------|
| Full suite | **100/113 passing, 13 failing, exit 1** |
| Reverted | yes — `git checkout -- game/play/clue_lines.gd`; working tree clean |

Log: [`logs/gut-falsification-columns.log`](logs/gut-falsification-columns.log).

This decides criteria 2 and 4: verbatim pass-through and row/column identity are enforced
by the suite, not merely asserted in prose. Prior runs used the same mutation and also a
"pad a short clue list" mutation; that path is already covered by the four I1 error tests,
which assert zero lines rather than a padded result.

## Probe independence

`probe-ready-auto-cross.gd` is not the repo’s test: it reads the empty lines from
`ClueLines.from_definition` at the acceptance build, drives `Attempt.open()` and
`end_get_set_ready()` directly, and checks all 225 cells. It would fail if the mapper
reported a non-empty line as empty, if it lost a line, or if the ready edge crossed a cell
outside an empty-clue line.
