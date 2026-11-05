# Game State

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../.agents/specs/rules/design/game-state.md).

Play state. Aligns with [`progression.md`](progression.md). Config: [`configuration.md`](configuration.md). Puzzle: [`entities/puzzle.md`](entities/puzzle.md). Clues: [`entities/clue.md`](entities/clue.md).

## Scopes

| Scope | Lifetime | Examples |
|-------|----------|----------|
| Moment | Gesture or get-set-ready | Marks blocked in get-set-ready |
| Stage | Open attempt | Marks, elapsed, paused, marks-allowed, line errors |
| Session | App open until quit | Open puzzle, or gallery |
| Persistent | Across sessions | Ever-completed, attempt status, marks, elapsed, personal best, hint-free |

## Fields

[`game-state/fields.md`](game-state/fields.md).

## Derived values

| Value | Derived from | Used by |
|-------|--------------|---------|
| `GS.completion-rate` | Ever-completed count ÷ 200 | [`progression.md`](progression.md) |
| `GS.is-solved` | Player fills = solution fills (crosses ignored) | [`loops/solve.md`](loops/solve.md) |
| `GS.row-error[i]` / `GS.col-error[j]` | Fills contradict line [clues](entities/clue.md); crosses ignored | Line error feedback |
| `GS.clue-num-matched[i|j][k]` | The line's `k`-th [fill island](glossary.md) exists and its length equals its `k`-th clue number, in order | Dim cue, per clue number |
| `GS.clue-satisfied[i|j]` | Every clue number on that [clue](entities/clue.md) line matched and no fill island left over — the fills exactly match the line; true for an all-empty line with no fills | Line-level aggregate for the [puzzle screen](../ux/screens/puzzle.md) R2 and [`PTD-ready-and-marks`](../playtest/design/ready-and-marks.md) P2 |
| `GS.gallery-thumbnail` | Stored generated picture when ever-completed; else hidden | Gallery only |

## Global invariants

- **V1**: Ever-completed ⇒ personal best exists.
- **V2**: Attempt in progress ⇒ ≥1 fill or cross.
- **V3**: Attempt not started ⇒ all clear (ready after open adds no marks).
- **V4**: Personal best only shrinks or stays while set.
- **V5**: Each cell is clear, fill, or cross.
- **V6**: Replay may be ever-completed and in progress together.
- **V7**: Hint-free true ⇒ ever-completed; void or reset may clear hint-free while ever-completed stays.

## Hidden and visible state

- **H1**: The player cannot know a puzzle's fill set while solving; the stored pixel picture becomes knowable after a successful solve, the stored generated picture (gallery thumbnail) once ever-completed.
- **H2**: Ever-completed, attempt, marks, elapsed, paused, personal best, hint-free, completion rate, line errors, clue-satisfied, clue-num-matched — knowable.

## Randomness and determinism

- **Q1**: None — fixed pack; identical setups play identically.
