# Game State

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../.agents/specs/rules/design/game-state.md).

Tracks play state. Aligns with [`progression.md`](progression.md). Configuration waits on [`configuration.md`](configuration.md). Puzzle: [`entities/puzzle.md`](entities/puzzle.md).

## Scopes

| Scope | Lifetime | Examples |
|-------|----------|----------|
| Moment | Gesture or get-set-ready | Marks blocked in get-set-ready |
| Stage | Open attempt | Marks, elapsed, marks-allowed, line errors |
| Session | App open until quit | Open puzzle, or gallery |
| Persistent | Across sessions | Ever-completed, attempt status, marks, elapsed, personal best |

## Fields

| Field | Scope | Meaning | Initial | Changed by | Invariants |
|-------|-------|---------|---------|------------|------------|
| `GS.selected-puzzle` | Session | Open puzzle, or none | none | Open / leave | — |
| `GS.marks-allowed` | Stage | Marks may change | false in get-set-ready | Ready → true | false ⇒ no mark changes |
| `GS.cell-marks` | Stage; Persistent if attempt in progress | clear / fill / [cross](glossary.md) | all clear or restored | Marks, solve clear, gallery reset, restore | One of three |
| `GS.ever-completed` | Persistent | ≥1 successful solve | false | First [`END.W1`](end-conditions.md); gallery reset clears | Sticky until reset |
| `GS.attempt-status` | Persistent | not started or in progress (current attempt) | not started | First mark → in progress; solve or reset → not started | Orthogonal to ever-completed |
| `GS.solve-elapsed` | Stage; Persistent if attempt in progress | Elapsed this attempt | 0; restored on reopen | Ticks after ready; clear on solve or reset | ≥ 0 |
| `GS.personal-best` | Persistent | Shortest successful time | none | Shorter solve; cleared on gallery reset | Never increases while set |
| `GS.solution` | Stage | Hidden correct fills | Loaded with puzzle | Never by player | Fixed per puzzle |

## Derived values

| Value | Derived from | Used by |
|-------|--------------|---------|
| `GS.completion-rate` | Ever-completed count ÷ 200 | [`progression.md`](progression.md) |
| `GS.is-solved` | Player fills = solution fills (crosses ignored) | [`loops/solve.md`](loops/solve.md) |
| `GS.row-error[i]` / `GS.col-error[j]` | Fills contradict line clues; off if still possible; crosses ignored | Line error feedback |
| `GS.gallery-thumbnail` | Pack image when ever-completed; else hidden | Gallery only |

## Global invariants

- **V1**: Ever-completed ⇒ personal best exists.
- **V2**: Attempt in progress ⇒ ≥1 fill or cross.
- **V3**: Attempt not started ⇒ all clear, elapsed 0.
- **V4**: Personal best only shrinks or stays while set.
- **V5**: Each cell is clear, fill, or cross.
- **V6**: Replay may be ever-completed and in progress together.

## Hidden and visible state

- **H1**: Solution unknown on the board; gallery thumbnail only after ever-completed.
- **H2**: Ever-completed, attempt status, marks, elapsed, personal best, completion rate, line errors — knowable.

## Randomness and determinism

- **Q1**: None — fixed pack; identical setups play identically.
