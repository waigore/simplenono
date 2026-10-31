# View

Authoring rules: [`.agents/specs/rules/view/view.md`](../../.agents/specs/rules/view/view.md).

Serves Calm tactile grid, Snappy solve, and Cool clinical look; local 2D pack play on all supported platforms ([`specs/design/design.md`](../design/design.md), [`specs/definition/definition.md`](../definition/definition.md)).

## Dimensionality

- **Gameplay space**: 2D — positions resolve on the puzzle grid; axes are row and column (orthogonal).
- **Rendered space**: 2D — flat board and chrome; no 3D play plane. Matches gameplay space.

## Embodiment

- **Viewpoint**: Fixed board — the open puzzle (clues + grid) is one stable face while solving; no free look or world camera.
- **Player presence**: None — no avatar. Attention is anchored on cells and clues. Pointer and finger are input ([`specs/ux/`](../ux/)), not a body in the world.

## Platform implications

- **iOS / Android (portrait or landscape)**: Board and clue margins stay readable in one framing; no pan of a world for a single puzzle.
- **Windows / macOS / Linux**: Same fixed board framing; extra screen margin is unused space, not a different viewpoint.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`stories.md`](stories.md), [`story-coverage.md`](story-coverage.md), [`spatial-model.md`](spatial-model.md), [`projection.md`](projection.md), [`camera-controls.md`](camera-controls.md), [`physics.md`](physics.md), [`perception.md`](perception.md), [`audio.md`](audio.md), [`haptics.md`](haptics.md). Diagrams: [`diagrams/`](diagrams/).

- **Cameras**: None — fixed board; no camera list.
