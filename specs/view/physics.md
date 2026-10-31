# Physics Feel

Authoring rules: [`.agents/specs/rules/view/physics.md`](../../.agents/specs/rules/view/physics.md).

- **Serves**: Calm tactile grid, Snappy solve — marks are discrete UI state, not simulated bodies.

## Motion

N/A — no simulated motion. Cell marks change instantly; there is no walk, jump, fall, or continuous travel.

## Collision

N/A — no simulated motion. Cells do not collide; one mark state occupies each cell by design.

## Contact feel

N/A — no simulated motion. Place feedback is visual, soft SFX, and light haptic ([`haptics.md`](haptics.md)), not physics contact.

## Experience intent

N/A — no weight or impact from physics. Snappy place feel comes from UI response, not a dynamics model.
