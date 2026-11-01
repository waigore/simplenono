# Notes — acceptance re-check 3 (#106)

## Build

`main@0115f68`. `git diff eea5f9d 0115f68 -- game/play/mark_grid.gd game/play/cell_mark.gd
game/play/mark_cell.gd game/test/test_cell_mark.gd` is a single **additive** hunk: 8 lines
adding `MarkGrid.has_any_mark()` (added for `SCH-progress` I2 by #108). No existing behaviour
changed, so the earlier step-level judgement still stands on this build.

`#108` (`17cd68d`) added `game/play/rules.gd` (`CMP-rules` R1/R2: solve check and line
status) on top of this grid. R3 auto-cross and the ready sequence are #132, not merged.
Rules consume the grid through `MarkGrid`; they do not change it.

## Suite

`godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`
→ **Scripts 6, Tests 96, Passing 96, Asserts 28620, exit 0** (`logs/gut-recheck.log`).
Counts were read from the report, not just the exit code — see the GUT caveat below.

## Falsification (run here, not taken on trust)

| Mutation | Result | Decides |
|---|---|---|
| `apply_mark` drops the `_marks_allowed` gate | 95/96 passing, 1 failing, exit 1 | `E-cell` I4, `PTD-ready-and-marks` P1/F1 (marks must not stick during get-set-ready) |
| `CellMark.counts_as_fill` returns true for `CROSS` | 91/96 passing, 5 failing, exit 1 | `E-cell` I4, `PTD-crosses-and-fills` P2/F2 (crosses are not fills) |

Both reverted; `git status` clean afterwards.

## Judgement at the delivered layer

- `E-cell` PS1.1–PS1.5: pass. Each scenario has a named test in `game/test/test_cell_mark.gd`
  (clear/fill/cross cycle; blocked mark leaves `CLEAR`; out-of-grid mark rejected;
  same-mark re-apply rejected; `MarkCell` rejects a non-mark value).
- `PTD-ready-and-marks` P1: pass at the model layer — `apply_mark` returns `false` and leaves
  `CLEAR` while blocked, and clear → fill → clear → cross each change the cell once ready.
  S2's `DBG.2` inspection and S4's pause are not judged: no screen, no `IN.pause` (#111).
- `PTD-ready-and-marks` P2: N/A at this layer. `auto_cross` is called by the caller
  (#132 owns `CMP-rules` R3 and the ready sequence); this build never calls it. The
  protocol allows N/A when the fixture has no empty clue lines — the teapot does have them,
  so the recorded reason here is "surface not delivered", not "no empty lines".
- `PTD-ready-and-marks` P3: partially observable at the model layer only — no fail state
  exists. Pause half is #111/#132.
- `PTD-crosses-and-fills` P1/P2: pass at the model layer — `filled_positions()` uses
  `counts_as_fill`, so a board filled on the solution's cells satisfies the fill-set
  comparison with crosses elsewhere, and mutation 2 proves crosses can never be counted
  as fills. S1/S3 (`DBG.3` enter, `DBG.2` inspect, result screen) are not judged.

No clause this deliverable can decide failed.

## Why the screenshots still cannot exist

`game/presentation/shell.tscn` at `0115f68` is a `CenterContainer` holding a title label and
the stub puzzle id `pack-000` (`#136`). It draws no grid, no clue lines, and exposes no
`DBG.1`–`DBG.4` or `TEL.1`–`TEL.5`. `grep` over first-party `game/**/*.gd` finds no
`draw_*`, no `DBG.`, no `TEL.` outside the GUT addon. The board arrives with #110, mark input
with #111, and solve/auto-cross with #132.

## GUT caveat (re-confirmed, still unowned)

A test script with a parse error is logged as `Ignoring script … does not extend GutTest`
and the run still exits 0. It happened during this run: an inexact first mutation edit broke
`cell_mark.gd`'s parse, GUT reported `Scripts 4 / Tests 39 / exit 0`, which looks like a pass.
Always read the `Scripts` and `Tests` counts, not only the exit code.
