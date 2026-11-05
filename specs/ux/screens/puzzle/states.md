# Puzzle states

Authoring rules: [`.agents/specs/rules/ux/screens.md`](../../../../.agents/specs/rules/ux/screens.md).

Split from the puzzle screen ([`screens/puzzle.md`](../puzzle.md)). The mockup anchors `state-default` / `state-get-set-ready` / `state-paused` show these states.

## Shows

N/A — the shown design facts are in [`puzzle.md`](../puzzle.md).

## Regions

N/A — the regions are in [`puzzle.md`](../puzzle.md).

## Controls

N/A — the controls are in [`puzzle.md`](../puzzle.md).

## States

| ID | State | Entered when | Actor sees | Actor can |
|----|-------|--------------|------------|-----------|
| S1 | Default (Ready) | After get-set-ready; not paused | R1–R3; marks allowed | C1–C6 |
| S2 | Get-set-ready | Puzzle opens ([`L-solve.K1`](../../../design/loops/solve.md)) | Board + visible Ready beat (`copy.ready`); marks blocked | C1, C6 |
| S3 | Paused | `IN.pause` / C6 while puzzle open | Board unchanged; elapsed frozen | Settings; Back resumes S1 |

## Copy

N/A — the copy strings are in [`copy.md`](copy.md).

## Experience intent

N/A — the intent is in [`puzzle.md`](../puzzle.md).
