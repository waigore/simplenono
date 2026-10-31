# Game State

Authoring rules: [`.agents/specs/rules/design/game-state.md`](../../.agents/specs/rules/design/game-state.md).

What the game tracks. Persistent fields align with [`progression.md`](progression.md). Configuration scope waits on [`configuration.md`](configuration.md).

## Scopes

| Scope | Lifetime | Examples in this game |
|-------|----------|-----------------------|
| Moment | Mark gesture or get-set-ready | Marks blocked during get-set-ready |
| Stage | Open puzzle attempt | Marks, elapsed, marks-allowed, line errors |
| Session / run | App open until quit | Open puzzle, or gallery with none |
| Persistent | Across sessions | Status, in-progress marks and elapsed, personal best |

## Fields

| Field | Scope | Meaning | Initial value | Changed by | Invariants |
|-------|-------|---------|---------------|------------|------------|
| `GS.selected-puzzle` | Session | Puzzle open now, or none in the gallery | none | Open / leave ([`loops/solve.md`](loops/solve.md)) | — |
| `GS.marks-allowed` | Stage | Whether marks may change | false in get-set-ready | Ready → true | false ⇒ no mark changes |
| `GS.cell-marks` | Stage; Persistent while in progress | Per cell: clear, fill, or [cross](glossary.md) | all clear, or restored | Mark actions, gallery reset, restore | Exactly one of the three |
| `GS.puzzle-status` | Persistent | not started, in progress, or completed | not started | First mark, solve, gallery reset | See V2–V3 |
| `GS.solve-elapsed` | Stage; Persistent while in progress | Elapsed this attempt | 0 at start; restored on reopen | Ticks after ready; stops on solve; cleared on gallery reset | ≥ 0 |
| `GS.personal-best` | Persistent | Shortest successful time for that puzzle | none | Shorter successful solve; cleared on gallery reset | Never increases while set |
| `GS.solution` | Stage | Hidden correct fill set | Loaded with the puzzle | Never by the player | Fixed for that puzzle |

## Derived values

| Value | Derived from | Used by |
|-------|--------------|---------|
| `GS.completion-rate` | Completed count ÷ 200 | [`progression.md`](progression.md) |
| `GS.is-solved` | Player fills equal `GS.solution` fills (crosses ignored) | [`loops/solve.md`](loops/solve.md) |
| `GS.row-error[i]` / `GS.col-error[j]` | Fills contradict that line’s clues; false if incomplete but still possible; crosses ignored | Line error feedback |

## Global invariants

- **V1**: Completed ⇒ `GS.personal-best` exists for that puzzle.
- **V2**: In progress ⇒ at least one fill or cross.
- **V3**: Not started ⇒ every cell clear.
- **V4**: `GS.personal-best` only shrinks or stays.
- **V5**: Each cell is exactly one of clear, fill, or cross.

## Hidden and visible state

- **H1**: `GS.solution` — unknown; only clues and own marks.
- **H2**: Status, marks, elapsed, personal best, completion rate, line errors — knowable.

## Randomness and determinism

- **Q1**: None — pack and solutions are fixed; identical setups play identically.
