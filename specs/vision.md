# Game Vision

Authoring rules: [`.agents/specs/rules/vision.md`](../.agents/specs/rules/vision.md).

## Elevator pitch

A nonogram puzzle game where you mark cells from row and column clues to reveal a picture, with a calm tactile grid and a cool clinical look.

## High-level description

The player opens a local pack of nonogram puzzles and picks any board, finished or not. Clues along each row and column say which cells belong in the picture. Marking filled cells and crosses feels snappy and deliberate; the board stays clear and clinical rather than playful. Completing a puzzle records that it is done and stores the time taken as that puzzle's personal best. A later solve in a shorter time replaces that best and is the better score. There is no fail state—mistakes are corrected until the grid matches the solution, which is the only way a puzzle ends. Sessions are short: one puzzle or a few, then put the game down.

## Target audience and player fantasy

- **Audience**: Casual puzzle players who know or will learn nonograms; short sessions on phone or desktop.
- **Player fantasy**: Quiet focused deduction—the clean “I solved it” click when the picture appears.

## Essential qualities

| # | Quality | Description | Supports it if… |
|---|---------|-------------|-----------------|
| 1 | Calm tactile grid | Marking cells feels deliberate and physical | Paint, cross, and erase stay clear and uncluttered |
| 2 | Snappy solve | The mark loop feels instant | Grid actions never feel laggy during play |
| 3 | Cool clinical look | Restrained, high-contrast presentation | UI stays clinical rather than cute or playful |

## Tradeoffs

1. Snappy clarity over decorative flourish — when decoration would slow or muddy the grid, drop it.
2. Clinical look over warm/cute styling — tone stays cool even if friendlier art would feel inviting.

## Non-goals

- Online accounts, multiplayer, or networked content
- An in-game puzzle editor or user-generated pack sharing
- Narrative campaign that forces puzzle order
