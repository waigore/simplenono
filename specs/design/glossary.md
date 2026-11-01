# Glossary

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../.agents/specs/rules/design/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Attempt status | Whether the current attempt is not started or in progress; independent of ever completed. | [`progression.md`](progression.md), [`game-state.md`](game-state.md) |
| Auto-cross | The automatic crosses placed on every still-clear cell of an empty-clue line when get-set-ready ends; counts as marking, so it sets the attempt in progress. | [`loops/solve.md`](loops/solve.md), [`game-state.md`](game-state.md) |
| Board | The open puzzle's mark grid: `size`×`size` [cells](entities/cell.md) plus its row and column [clue](entities/clue.md) lines. | [`entities/cell.md`](entities/cell.md), [`entities/clue.md`](entities/clue.md) |
| Cell | One grid square with exactly one mark: clear, fill, or cross. | [`entities/cell.md`](entities/cell.md) |
| Clue | Ordered run lengths for one row or column; empty list means an all-empty line. | [`entities/clue.md`](entities/clue.md) |
| Completion rate | Ever-completed puzzles divided by pack size (200). | [`progression.md`](progression.md), [`game-state.md`](game-state.md) |
| Cross | Optional mark meaning “I treat this cell as not filled”; ignored by solve check and line-error fill logic. | [`entities/cell.md`](entities/cell.md), [`loops/solve.md`](loops/solve.md) |
| Ever completed | Sticky flag after at least one successful solve; may coexist with an in-progress attempt on replay. | [`progression.md`](progression.md), [`entities/puzzle.md`](entities/puzzle.md) |
| Gallery | Free-order pack selection: every puzzle listed and selectable, with attempt status, ever-completed, personal best, and thumbnail when ever completed. | [`progression.md`](progression.md) |
| Generated picture | The puzzle's stored full-resolution pack image (1024×1024): the gallery [thumbnail](entities/puzzle.md) and the final result stage. | [`entities/puzzle.md`](entities/puzzle.md) |
| Get-set-ready | Short prep beat before marks are allowed on a puzzle attempt. | [`progression.md`](progression.md), [`loops/solve.md`](loops/solve.md) |
| In progress | Attempt status with persisted marks not yet solved this attempt. | [`progression.md`](progression.md) |
| Line error | Per-row or per-column signal that current fills contradict that line’s [clues](entities/clue.md); off when the line is incomplete but still possible. | [`game-state.md`](game-state.md), [`entities/clue.md`](entities/clue.md) |
| Mark | The one state a [cell](entities/cell.md) holds: clear, fill, or cross. | [`entities/cell.md`](entities/cell.md) |
| Not started | Attempt status with no current marks (fresh, after solve clear, or after reset). | [`progression.md`](progression.md) |
| Pack | The fixed local set of 200 puzzles shipped with the game. | [`progression.md`](progression.md), [`entities/puzzle.md`](entities/puzzle.md) |
| Personal best | Shortest successful solve time stored for a puzzle. | [`progression.md`](progression.md) |
| Pixel picture | The pack image downscaled to the puzzle's board size; the basis the solution fill set was derived from; the first result stage. | [`entities/puzzle.md`](entities/puzzle.md) |
| Puzzle | One pack entry: size, clues, solution, progress, and gallery thumbnail. | [`entities/puzzle.md`](entities/puzzle.md) |
| Reset | Gallery action that makes a puzzle new: clears marks, elapsed, personal best, and ever completed; attempt → not started. | [`end-conditions.md`](end-conditions.md), [`progression.md`](progression.md) |
| Solve check | Whether the player’s fill set equals the solution fill set; crosses ignored; not evaluated per cell for correctness while marking. | [`loops/solve.md`](loops/solve.md), [`game-state.md`](game-state.md) |
| Thumbnail | Stored generated picture shown in the gallery only when the puzzle is ever completed; not shown on the board. | [`entities/puzzle.md`](entities/puzzle.md) |
