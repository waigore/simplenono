# Game State

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../.agents/specs/rules/design/game-state.md).

Play state. Aligns with [`progression.md`](progression.md). Config: [`configuration.md`](configuration.md). Puzzle: [`entities/puzzle.md`](entities/puzzle.md). Clues: [`entities/clue.md`](entities/clue.md).

## Scopes

| Scope | Lifetime | Examples |
|-------|----------|----------|
| Moment | Gesture or get-set-ready | Marks blocked in get-set-ready |
| Stage | Open attempt | Marks, elapsed, paused, marks-allowed, line errors |
| Session | App open until quit | Open puzzle, or gallery |
| Persistent | Across sessions | Ever-completed, attempt status, marks, elapsed, personal best |

## Fields

[`game-state/fields.md`](game-state/fields.md).

## Derived values

| Value | Derived from | Used by |
|-------|--------------|---------|
| `GS.completion-rate` | Ever-completed count ÷ 200 | [`progression.md`](progression.md) |
| `GS.is-solved` | Player fills = solution fills (crosses ignored) | [`loops/solve.md`](loops/solve.md) |
| `GS.row-error[i]` / `GS.col-error[j]` | Fills contradict line [clues](entities/clue.md); crosses ignored | Line error feedback |
| `GS.clue-satisfied[i|j]` | Fills exactly match that [clue](entities/clue.md) line | Dim cue |
| `GS.gallery-thumbnail` | Pack image when ever-completed; else hidden | Gallery only |

## Global invariants

- **V1**: Ever-completed ⇒ personal best exists.
- **V2**: Attempt in progress ⇒ ≥1 fill or cross (incl. empty-clue auto-cross).
- **V3**: Attempt not started ⇒ all clear, elapsed 0 (auto-cross after ready → in progress).
- **V4**: Personal best only shrinks or stays while set.
- **V5**: Each cell is clear, fill, or cross.
- **V6**: Replay may be ever-completed and in progress together.

## Hidden and visible state

- **H1**: Solution unknown on the board; gallery thumbnail only after ever-completed.
- **H2**: Ever-completed, attempt, marks, elapsed, paused, personal best, completion rate, line errors, clue-satisfied — knowable.

## Randomness and determinism

- **Q1**: None — fixed pack; identical setups play identically.
