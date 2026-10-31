# Glossary

Authoring rules: [`.agents/specs/rules/design/glossary.md`](../../.agents/specs/rules/design/glossary.md).

## Terms

| Term | Definition | Detailed in |
|------|------------|-------------|
| Completed | Puzzle status after at least one successful solve. | [`progression.md`](progression.md) |
| Completion rate | Completed puzzles divided by pack size (200). | [`progression.md`](progression.md), [`game-state.md`](game-state.md) |
| Cross | Optional mark meaning “I treat this cell as not filled”; ignored by solve check and line-error fill logic. | [`loops/solve.md`](loops/solve.md), [`game-state.md`](game-state.md) |
| Gallery | Free-order pack selection: every puzzle listed and selectable, each with status and personal best when one exists. | [`progression.md`](progression.md) |
| Get-set-ready | Short prep beat before marks are allowed on a puzzle attempt. | [`progression.md`](progression.md), [`loops/solve.md`](loops/solve.md) |
| In progress | Puzzle status with persisted marks that is not yet solved. | [`progression.md`](progression.md) |
| Line error | Per-row or per-column signal that current fills contradict that line’s clues; off when the line is incomplete but still possible. | [`game-state.md`](game-state.md) |
| Not started | Puzzle status for a board that has never been marked, or after a reset. | [`progression.md`](progression.md) |
| Personal best | Shortest successful solve time stored for a puzzle. | [`progression.md`](progression.md) |
| Reset | Gallery action that makes a puzzle new: clears fills, crosses, elapsed, and personal best; status returns to not started. | [`end-conditions.md`](end-conditions.md), [`progression.md`](progression.md) |
| Solve check | Whether the player’s fill set equals the solution fill set; crosses ignored; not evaluated per cell for correctness while marking. | [`loops/solve.md`](loops/solve.md), [`game-state.md`](game-state.md) |
