# Protocol: Play puzzle with hint assists

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-play-hints`
- **Cites**: `UI-puzzle` (R2, `C2`), `UI-settings` (`C5`–`C7`)
- **Situational tools**: None

Base flow (gallery → puzzle → result → gallery, mobile framing): [`play-puzzle`](play-puzzle.md).

## Steps

| ID | Action |
|----|--------|
| S1 | Cold start on `UI-menu`; activate `UI-menu.C1` to reach `UI-gallery`. Open the 10×10 sample board via `DBG.3` and wait through get-set-ready. |
| S2 | In `UI-settings` turn `copy.hint-single` on and return: note which cells R2 now ghosts (`US1.8`), and that no cell gained a mark. |
| S3 | Turn `copy.hint-multi` on too and note the additional ghosts; turn both off and note that no ghost remains (`US1.9`). |
| S4 | With `copy.hint-fillable` on and Fill selected, tap a cell: note the lighter shade on the max legal run containing it, and that the tap wrote no mark (`US1.10`). |
| S5 | Turn `copy.hint-fillable` off in `UI-settings` and return: note the shade is gone with the marks unchanged (`US1.11`). |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Hint assists apply at once on toggle: each assist ghosts its cells (or shades the tapped run) without writing a mark, the overlay and shade colours read as distinct, and turning an assist off removes it. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A hint assist writes a board mark, does not show on enable, does not clear on disable, or its colour is indistinguishable from the shade or from the cell marks. | yes |

## Evidence

Default evidence rules. One screenshot of the 10×10 sample with the single- and multi-line overlays on, and one with the fillable shade showing.
