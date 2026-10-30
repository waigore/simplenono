# Game Design

Authoring rules: [`.agents/specs/rules/design/design.md`](../../.agents/specs/rules/design/design.md).

## Genre and platform profile

- **Serves**: Calm tactile grid, Snappy solve, and Cool clinical look. Local puzzle pack, free-order selection, and persisted completion and personal-best times.
- **Genre(s)**: Nonogram. Each row and each column lists the lengths of consecutive filled groups, in order. A filled group is a run of filled cells with no empty cell inside it. Groups on the same line are separated by at least one empty cell. The player marks cells from those clues until every cell matches the hidden picture.

- **Conventions adopted**:
  - Clue runs. Each line's clues are the lengths of its filled groups, in order. Those clues are the only information that decides which cells are filled.
  - Three mark actions. The player fills a cell, marks a cell empty, or clears a mark. A wrong mark stays until the player changes it.
  - Solution match. The puzzle is solved when every cell matches the hidden picture. That is the only way a puzzle ends. The time taken for that successful solve is stored as the puzzle's personal best. The score is that time. A later solve replaces the personal best only when its time is shorter, and that shorter time is the better score. A longer replay leaves the stored best unchanged. A finished puzzle can be solved again.

- **Conventions rejected or changed**:
  - Punishing a mistake with lives, a lock, or a failed attempt. Rejected because the vision has no lose state; the player corrects marks until the grid matches the picture.
  - A campaign that locks later puzzles behind earlier ones. Rejected because the vision rejects a narrative that forces puzzle order.
  - Shared online packs and player-authored puzzles. Rejected because both are vision non-goals.

- **Platform implications**:
  - Windows, macOS, Linux, iOS, and Android share one local pack, the same 10×10 and 15×15 boards, free-order selection, and the same personal-best rule.
  - Short sessions on Windows, macOS, Linux, iOS, and Android → a session is one puzzle or a few.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`stories.md`](stories.md), [`story-coverage.md`](story-coverage.md), [`game-state.md`](game-state.md), [`configuration.md`](configuration.md), [`demo.md`](demo.md), [`difficulty.md`](difficulty.md), [`progression.md`](progression.md), [`end-conditions.md`](end-conditions.md), [`world.md`](world.md), [`experience.md`](experience.md).

- **Characters**: <!-- fill in -->
- **Entities**: <!-- fill in -->
- **Loops**: <!-- fill in -->
- **Features**: <!-- fill in -->
- **Flows**: <!-- fill in -->
- **Stages**: <!-- fill in -->
- **Scenarios**: <!-- fill in -->
- **Sub-games**: None
