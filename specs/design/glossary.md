# Glossary

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../.agents/specs/rules/design/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Attempt status | Whether the current attempt is not started or in progress; independent of ever completed. | [`progression.md`](progression.md), [`game-state.md`](game-state.md) |
| Board | The open puzzle's mark grid: `size`×`size` [cells](entities/cell.md) plus its row and column [clue](entities/clue.md) lines. | [`entities/cell.md`](entities/cell.md), [`entities/clue.md`](entities/clue.md) |
| Cell | One grid square with exactly one mark: clear, fill, or cross. | [`entities/cell.md`](entities/cell.md) |
| Clue | Ordered run lengths for one row or column; empty list means an all-empty line. | [`entities/clue.md`](entities/clue.md) |
| Completion rate | Ever-completed puzzles divided by pack size (200). | [`progression.md`](progression.md), [`game-state.md`](game-state.md) |
| Cross | Optional mark meaning “I treat this cell as not filled”; ignored by solve check and line-error fill logic. | [`entities/cell.md`](entities/cell.md), [`loops/solve.md`](loops/solve.md) |
| Ever completed | Sticky after ≥1 successful solve; may coexist with in-progress on replay. | [`progression.md`](progression.md), [`entities/puzzle.md`](entities/puzzle.md) |
| Fill island | Maximal run of fills on one line, ended by clear or cross; counterpart of a clue number. | [`entities/clue.md`](entities/clue.md), [`entities/cell.md`](entities/cell.md) |
| Gallery | Free-order pack browse: attempt status, ever-completed, personal best, thumbnail when ever completed, hint-free star when true. | [`progression.md`](progression.md) |
| Generated picture | Stored full-resolution pack image (1024×1024): gallery [thumbnail](entities/puzzle.md) and final result stage. | [`entities/puzzle.md`](entities/puzzle.md) |
| Get-set-ready | Short prep beat before marks are allowed on a puzzle attempt. | [`progression.md`](progression.md), [`loops/solve.md`](loops/solve.md) |
| Hint-free | Per-puzzle clean-solve flag; voided if any hint is enabled during an active attempt (even unused); re-earned on a later clean solve; cleared on gallery reset. | [`progression.md`](progression.md), [`end-conditions.md`](end-conditions.md) |
| In progress | Attempt status with persisted marks not yet solved this attempt. | [`progression.md`](progression.md) |
| Line error | Per-row or per-column signal that fills contradict that line’s [clues](entities/clue.md); off when incomplete but still possible. | [`game-state.md`](game-state.md), [`entities/clue.md`](entities/clue.md) |
| Mark | The one state a [cell](entities/cell.md) holds: clear, fill, or cross. | [`entities/cell.md`](entities/cell.md) |
| Not started | Attempt status with no current marks (fresh, after solve clear, or after reset). | [`progression.md`](progression.md) |
| Pack | The fixed local set of 200 puzzles shipped with the game. | [`progression.md`](progression.md), [`entities/puzzle.md`](entities/puzzle.md) |
| Personal best | Shortest successful solve time stored for a puzzle. | [`progression.md`](progression.md) |
| Pixel picture | Pack image downscaled to board size; basis of the solution fill set; first result stage. | [`entities/puzzle.md`](entities/puzzle.md) |
| Puzzle | One pack entry: size, clues, solution, progress, and gallery thumbnail. | [`entities/puzzle.md`](entities/puzzle.md) |
| Reset | Gallery action that makes a puzzle new: clears marks, elapsed, personal best, ever completed, and hint-free; attempt → not started. | [`end-conditions.md`](end-conditions.md), [`progression.md`](progression.md) |
| Solve check | Player fills equal solution fills; crosses ignored; not judged per cell while marking. | [`loops/solve.md`](loops/solve.md), [`game-state.md`](game-state.md) |
| Thumbnail | Stored generated picture shown in the gallery only when the puzzle is ever completed; not shown on the board. | [`entities/puzzle.md`](entities/puzzle.md) |
