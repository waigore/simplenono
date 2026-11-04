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

- **iOS / Android (locked orientation)**: Board and clue margins stay readable in one framing; no pan of a world for a single puzzle. The OS status bar and the navigation / home-indicator band stay visible and are drawn outside the game viewport, which never extends under them ([`projection.md`](projection.md) A3; the captured platform values are in A4). The mobile mockups' status-bar and home-indicator reserve is that same band, kept so [`UI-gallery`](../ux/screens/gallery.md), [`UI-result`](../ux/screens/result.md), and [`UI-settings`](../ux/screens/settings.md) never place controls under it. The screen does not follow the device: a cold launch opens in portrait, and the player's portrait or landscape choice stays locked, including after a force-quit (ADR-0009). A tilt never rotates the framing. The board fills the viewport left after [`UI-puzzle`](../ux/screens/puzzle.md) chrome (R1) and tools (R3) — the frame minus that system chrome band — in both orientations and without scrolling. Smallest test viewports are 360×640 dp portrait and 640×360 dp landscape; mobile renders 1 dp = 1 control pixel, so the board lays out at 360×640 and 640×360 control pixels.
- **Windows / macOS / Linux**: Same fixed board framing; extra screen margin is unused space, not a different viewpoint. No orientation lock.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`stories.md`](stories.md), [`story-coverage.md`](story-coverage.md), [`spatial-model.md`](spatial-model.md), [`projection.md`](projection.md), [`camera-controls.md`](camera-controls.md), [`physics.md`](physics.md), [`perception.md`](perception.md), [`audio.md`](audio.md), [`haptics.md`](haptics.md). Diagrams: [`diagrams/`](diagrams/).

- **Cameras**: None — fixed board; no camera list.
