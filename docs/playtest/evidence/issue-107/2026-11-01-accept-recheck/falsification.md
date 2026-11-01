# Falsification — issue #107 re-check

Evidence that the suite can fail. Detail for the run in [`notes.md`](notes.md).

Re-run against the real mapper, not just the test literals. Pointing column
lines at `row_clues` instead of `col_clues` in `game/play/clue_lines.gd`
produced **7 failing tests (26/33 passing), exit 1**; reverted, `git status`
clean afterwards. Transcript:
[`logs/gut-falsification-mutation.log`](logs/gut-falsification-mutation.log).

## Caveat for future runs

Naively replacing the string `col_clues` repo-wide breaks the constant names
too, and the suite then reports **Scripts 2 / Tests 16 / exit 0** — the GUT
skip trap again (see [`findings.md`](findings.md)). The valid mutation only
changes the argument passed at the `ClueLine.Orientation.COLUMN` construction
site.

## Fixture integrity

Re-checked on this build. `game/test/fixtures/teapot.json` `size` /
`row_clues` / `col_clues` are identical to
`pocs/image-nonogram-pipeline/out/teapot/puzzle.json`; recomputing the runs of
the PoC's `grid` reproduces the fixture's `row_clues` and `col_clues` exactly
(I3-clean). `row 0 = []`, `row 6 = [1, 9]`, `row 7 = [10]`. The test's
`EXPECTED_ROW_CLUES` / `EXPECTED_COL_CLUES` literals match the fixture lists,
so AC 1 is not self-certifying.
