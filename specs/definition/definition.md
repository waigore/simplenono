# Game Definition

Authoring rules: [`.agents/specs/rules/definition.md`](../../.agents/specs/rules/definition.md).

## Scope

### In scope

- Local puzzle pack of nonograms (10×10 and 15×15)
- Free-order puzzle selection; completion status persisted
- Desktop and mobile play with mouse/keyboard or touch

### Out of scope

- Accounts, multiplayer, or online content delivery
- In-game puzzle editor or player-authored packs
- Lives, fail states, or forced unlock order

## Objectives

### Player objectives

- **Goal**: Correctly fill each puzzle from its row and column clues.
- **Win / lose conditions**: Win when the grid matches the solution. No lose state; the player may correct marks until solved.
- **Progression**: Choose any puzzle in any order; completed status is recorded (gallery-style).

### Product objectives

- Ship a local pack playable offline on the supported platforms.
- Persist which puzzles the player has completed across sessions.

## Supported platforms

| Platform | Primary input | Priority |
|----------|---------------|----------|
| Windows | Mouse / keyboard | primary |
| macOS | Mouse / keyboard | primary |
| Linux | Mouse / keyboard | primary |
| iOS | Touch | primary |
| Android | Touch | primary |

## Engine

- **Engine**: Godot — one project exports to the listed desktop and mobile targets with strong 2D/UI support for a grid puzzle.
- **Implications**: The game is 2D and UI-led; platform reach is desktop plus mobile from a shared codebase. Native look-and-feel details stay platform-specific exports, not separate engines.

## Constraints

### Design

- Free-order selection only — no campaign gate that locks puzzles behind others.
- No fail/out state — errors are corrected, not punished.

### Technical

- Fully playable offline after install — no required network for core play or completion saves.

### Market

- None — personal/simple product; no store-feature mandates at definition time.

## Spec depth

- **Depth**: small — a focused local puzzle product; enough formalization for design/UX without full-ceremony coverage.

## Quality expectations

[`quality.md`](quality.md).
