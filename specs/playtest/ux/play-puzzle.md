# Protocol: Play puzzle

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-play-puzzle`
- **Cites**: `J-play-puzzle`, `UI-gallery`, `UI-puzzle`, `UI-result`, `NAV`, `ACT-player`
- **Situational tools**: None

## Steps

| ID | Action |
|----|--------|
| S1 | Start on `UI-gallery`. Via `DBG.3`, open a not-started puzzle that is one correct fill from solve (or play any small puzzle to solve). |
| S2 | Wait through get-set-ready until marks are allowed on `UI-puzzle`. |
| S3 | Place the last needed fill(s) with `UI-puzzle.C2` / fill tool until the app leaves for `UI-result`. |
| S4 | After morph reaches Default, use `UI-result.C1` Back. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Gallery → puzzle → result → gallery completes without stuck screens. |
| P2 | After solve, gallery shows that puzzle as ever-completed (Done / thumbnail when applicable). |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | Cannot open a puzzle from the gallery, or solve does not reach `UI-result`. | yes |
| F2 | Back from result does not return to `UI-gallery`, or ever-completed does not stick. | yes |

## Evidence

Default evidence rules. Screenshot gallery after return (judged ever-completed tile).
