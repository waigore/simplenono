# Authoring rules: motion style

Read this before editing `specs/aesthetics/motion.md`. Do not copy these rules into the spec.

Also read [aesthetics.md](aesthetics.md) and [ids.md](ids.md).

How things animate as a style: the principles and timing of character, entity, and effect animation. How bodies move through space (acceleration, jump arcs) is physics feel in `specs/view/physics.md`. How long an action takes in play is a design fact. Cite both; do not restate them. An animation must fit inside the design's action timing and must not change when an outcome occurs. Camera effects stay in the view.

Write "N/A — reason" in each section when nothing in the game animates.

## Header

- **Serves**: vision qualities, style pillars, and design or view specs.

## Sections

- **Animation principles**: `A1`, `A2`, …. Columns: ID, principle (squash and stretch, anticipation, follow-through, smear frames, holds, easing), how strongly it is used (such as up to 20% squash), and who it applies to.
- **Timing**: `T1`, `T2`, …. Columns: ID, action class (idle, move, attack, hit, death, interface-free ambient), the animation frame rate (such as 12 frames per second), and the frame count or duration range. Cite the design action whose timing it must fit.
- **Effect motion**: `E1`, `E2`, …. Columns: ID, effect class (cite `SRF.E`), lifetime in seconds, and motion rule (easing, spread, fade).

## Splitting

If the file passes 500 words, move timing to `motion/timing.md`. Leave a summary and a link, and update `aesthetics.md`.
