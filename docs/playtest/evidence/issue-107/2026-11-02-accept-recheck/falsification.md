# Falsification — issue #107 re-check

The suite is not taken on trust: one mutation was applied to the mapper at `37ef101`, run, and
reverted.

| Mutation | Result | Criterion it decides |
|---|---|---|
| `clue_lines.gd`: column lines built from `row_clues[index]` instead of `col_clues[index]` | 85/96 passing, **11 failing**, exit 1 | AC 2 (verbatim F4 pass-through) and AC 1 (columns match the fixture) |

Reverted with the pre-mutation copy; `git status --porcelain` reported nothing afterwards.
Honest log: [`logs/gut-falsification-columns.log`](logs/gut-falsification-columns.log).

`Scripts 6 / Tests 96` were read from the report in both runs, because GUT logs an
unparseable test script as skipped and still exits 0.
