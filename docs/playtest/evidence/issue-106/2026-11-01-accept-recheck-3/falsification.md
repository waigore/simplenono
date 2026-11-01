# Falsification — acceptance re-check 3 (#106)

Run in the same clean detached worktree at `main@0115f68`, after the green suite in
[`manifest.md`](manifest.md). Each mutation was applied, the suite re-run, then reverted and
`git status` confirmed clean before the next one.

| Mutation | File | Result | Criterion it decides |
|---|---|---|---|
| 1. `apply_mark` drops the `_marks_allowed` gate | `game/play/mark_grid.gd` | **95/96 passing, 1 failing, exit 1** (`logs/gut-mutation-marks-allowed.log`) | `E-cell` I4; `PTD-ready-and-marks` P1/F1 — marks must not stick during get-set-ready |
| 2. `CellMark.counts_as_fill` returns true for `CROSS` | `game/play/cell_mark.gd` | **91/96 passing, 5 failing, exit 1** (`logs/gut-mutation-cross-as-fill.log`) | `E-cell` I4; `PTD-crosses-and-fills` P2/F2 — crosses are not fills |

## Commands

```bash
# baseline
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit   # 96/96, exit 0

# mutation 1: delete "not _marks_allowed or " from apply_mark's guard
# mutation 2: counts_as_fill -> `return mark == Mark.FILL or mark == Mark.CROSS`
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
git checkout -- game/play/mark_grid.gd game/play/cell_mark.gd
```

## GUT caveat (re-confirmed, still unowned)

A test script with a parse error is logged as `Ignoring script … does not extend GutTest` and
the run still exits 0. It happened during this run: an inexact first edit of mutation 2 broke
`cell_mark.gd`'s parse and GUT reported `Scripts 4 / Tests 39 / exit 0` — a pass-shaped
result for a run that skipped 57 tests. Mutation 2 was then re-applied exactly. Always read
the `Scripts` and `Tests` counts, not only the exit code.
