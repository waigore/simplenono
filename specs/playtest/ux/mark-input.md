# Protocol: Mark input

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-mark-input`
- **Cites**: `IN`, `UI-puzzle`
- **Situational tools**: None

Runs on the puzzle screen alone. Do not solve the puzzle: a completing fill leaves for `UI-result`, which this protocol does not need or expect.

## Steps

| ID | Action |
|----|--------|
| S1 | Via `DBG.3`, open a puzzle with room for the S2–S4 cells and a run in S5, none of whose fills completes it. Wait through get-set-ready to Ready (`UI-puzzle.S1`). |
| S2 | Select Fill (`UI-puzzle.C3`). Tap a clear cell (US1.6). Read `DBG.2` grid. Screenshot. |
| S3 | Tap that same cell again (US1.6b). Read `DBG.2`. Screenshot. |
| S4 | With Fill still selected, use `IN.mark-complement` (secondary click, `B2`/`B12`/`B22`) on a clear cell (US1.7). Read `DBG.2`. Screenshot. |
| S5 | Select Cross (`UI-puzzle.C4`). Hold and drag `IN.drag-paint` (`B3`/`B13`/`B23`) across a run of three or more clear cells in one row or column, in drag order (US1.8). Read `DBG.2` after each cell crossing the pointer. Screenshot. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | US1.6: the tapped clear cell becomes fill; `CTR-attempt` O2 returns the consistent grid. |
| P2 | US1.6b: tapping the filled cell with Fill selected returns it to clear; other cells unchanged. |
| P3 | US1.7: with Fill selected, complement on a clear cell makes it cross. |
| P4 | US1.8: every cell under the drag is cross — each one once, none toggled back to clear, origin included. |
| P5 | Every judged change reconciles with one `CTR-attempt` O2 effect per gesture on `DBG.2`; drawn cell state and reported grid agree. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A tap with Fill selected does not fill, or fills a different cell (US1.6). | yes |
| F2 | A second tap on the filled cell does not clear it, or clears other cells too (US1.6b). | yes |
| F3 | Complement on a clear cell does not produce a cross, or leaves the cell fill (US1.7). | yes |
| F4 | Drag leaves a cell under it unmarked, or toggles an already-crossed cell back to clear mid-run (US1.8). | yes |
| F5 | A gesture judged by `DBG.2` disagrees with the drawn cell state. | yes |

## Evidence

Default evidence rules. One screenshot of the judged cells for each of P1–P4, from a graphical run on the build under acceptance. If no chosen puzzle offers a run free of empty-clue auto-cross, record S5 as not applicable, name the puzzle id in `notes.md`, and do not fail S5 for it.
