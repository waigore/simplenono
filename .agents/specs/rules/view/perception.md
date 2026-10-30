# Authoring rules: perception and comfort

Read this before editing `specs/view/perception.md`. Do not copy these rules into the spec.

Also read [view.md](view.md), [ids.md](ids.md), and [../design/experience.md](../design/experience.md). Stories follow [story.md](story.md).

What the player must be able to perceive in space, how depth and scale are conveyed, and how the view stays comfortable. This file realizes the clarity rules and feedback principles in `specs/design/experience.md`.

## Sections

- **Readability**: `R1`, `R2`, …. Guarantees on what stays perceivable. Columns: subject (link a character or entity, or a design condition such as "a threat within 5 units"), the guarantee (inside the frame or the safe area, not more than a stated fraction hidden, at least a stated fraction of frame height), and the cameras it holds in (or "all", including transitions and effects).
- **Depth cues**: `D1`, `D2`, …. Columns: the cue (ground shadow, outline when hidden, fade with distance, size change, parallax), when it applies, and what it tells the player.
- **Sense of scale**: how big the world and its objects should feel, with reference comparisons in units. No ID.
- **Comfort options**: `M1`, `M2`, …. Columns: option (such as reduce camera shake, field of view, head bob off, motion blur off), what it changes (cite the camera, projection, or physics element), choices or range, default, and platforms. When accessibility Applies in `specs/definition/quality.md`, name the target each option meets. An option that changes a game rule belongs in `specs/design/configuration.md`.
- **Experience intent**: how present the player should feel in the world. Intent only. No ID.

When accessibility is N/A, write "N/A" under comfort options with the same reason as the quality spec.
