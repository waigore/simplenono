# Protocol: Play puzzle

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-play-puzzle`
- **Cites**: `J-play-puzzle`, `UI-gallery`, `UI-puzzle`, `UI-result`, `NAV`, `ACT-player`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Mobile (iOS / Android), do this first: open `UI-puzzle` in portrait on a 10×10, then a 15×15, then a 20×20 puzzle. Judge R2 visually: one framing, no scrollbar, no pan or pinch-zoom affordance, every row and column clue legible without zooming. Repeat with the device turned to landscape (or on the 640×360 landscape frame). Judge by eye only; the cell-size figure is not this protocol's to check. |
| S2 | Start on `UI-gallery`. Via `DBG.3`, open a not-started puzzle that is one correct fill from solve (or play any small puzzle to solve). |
| S3 | Wait through get-set-ready until marks are allowed on `UI-puzzle`. |
| S4 | Place the last needed fill(s) with `UI-puzzle.C2` / fill tool until the app leaves for `UI-result`. |
| S5 | After morph reaches Default, use `UI-result.C1` Back. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Gallery → puzzle → result → gallery completes without stuck screens. |
| P2 | After solve, gallery shows that puzzle as ever-completed (Done / thumbnail when applicable). |
| P3 | On mobile, R2 shows each of 10×10, 15×15, and 20×20 in one framing in portrait and landscape, with no scroll, pan, or pinch-zoom affordance, and every clue legible. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Cannot open a puzzle from the gallery, or solve does not reach `UI-result`. | yes |
| F2 | Back from result does not return to `UI-gallery`, or ever-completed does not stick. | yes |
| F3 | On mobile, R2 scrolls, pans, or zooms, leaves part of the clue-led board out of frame, or a clue is not legible in portrait or landscape. | yes |

## Evidence

Default evidence rules. Screenshot gallery after return (judged ever-completed tile). For P3/F3, one screenshot per orientation at the largest tested size (20×20), portrait and landscape.
