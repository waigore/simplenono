# Game Design

Authoring rules: [`.agents/specs/rules/design/design.md`](../../.agents/specs/rules/design/design.md).

## Genre and platform profile

- **Serves**: Calm tactile grid, Snappy solve, and Cool clinical look. Local puzzle pack, free-order selection, and persisted completion and personal-best times.
- **Genre(s)**: Nonogram. Each row and each column lists the lengths of consecutive filled groups, in order. A filled group is a run of filled cells with no empty cell inside it. Groups on the same line are separated by at least one empty cell. The player marks fills from those clues until the fill set matches the hidden picture. Crosses are optional memory aids and are not required to solve.

- **Conventions adopted**:
  - Clue runs. Each line's [clues](entities/clue.md) are filled-group lengths in order (empty list = all-empty; auto-cross after ready; dim when satisfied). Clues alone decide fills.
  - Three mark actions. The player fills a cell, places a cross, or clears a mark. A wrong mark stays until the player changes it. Crosses do not count toward the solution.
  - Solution match. Solved when the player's fill set equals the solution fill set. Crosses are ignored. Whole-puzzle fills only, not per-cell correctness while marking. That successful time is the personal best (the score); a later solve replaces it only when shorter. Ever-completed is sticky and independent of the current attempt, so replay can be both ever-completed and in progress.
  - Line error. Each row and column can signal when fills contradict that line's clues; off while incomplete but still possible.
  - Gallery thumbnail. When ever-completed, the gallery may show that puzzle's solution picture; the board does not.
  - Reset. From the gallery, reset makes a puzzle new: clears fills, crosses, elapsed, personal best, and ever-completed; attempt → not started.

- **Conventions rejected or changed**:
  - Punishing a mistake with lives, a lock, or a failed attempt. Rejected because the vision has no lose state; the player corrects marks until the fills match the picture.
  - Requiring crosses to solve. Rejected so only fills decide the win.
  - Live per-cell correctness while marking. Rejected so solve is fill-set match only; line error is contradiction feedback, not a fail state.
  - A campaign that locks later puzzles behind earlier ones. Rejected because the vision rejects a narrative that forces puzzle order.
  - Shared online packs and player-authored puzzles. Rejected because both are vision non-goals.

- **Platform implications**:
  - Windows, macOS, Linux, iOS, and Android share one local pack, the same 10×10, 15×15, and 20×20 boards, free-order selection, and the same personal-best rule.
  - Short sessions on Windows, macOS, Linux, iOS, and Android → a session is one puzzle or a few.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`stories.md`](stories.md), [`story-coverage.md`](story-coverage.md), [`game-state.md`](game-state.md) ([`game-state/fields.md`](game-state/fields.md)), [`configuration.md`](configuration.md), [`demo.md`](demo.md), [`difficulty.md`](difficulty.md), [`progression.md`](progression.md), [`end-conditions.md`](end-conditions.md), [`world.md`](world.md), [`experience.md`](experience.md).

- **Characters**: <!-- fill in -->
- **Entities**: [`puzzle.md`](entities/puzzle.md), [`cell.md`](entities/cell.md), [`clue.md`](entities/clue.md)
- **Loops**: [`solve.md`](loops/solve.md)
- **Features**: <!-- fill in -->
- **Flows**: <!-- fill in -->
- **Stages**: <!-- fill in -->
- **Scenarios**: <!-- fill in -->
- **Sub-games**: None
