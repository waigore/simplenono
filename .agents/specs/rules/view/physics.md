# Authoring rules: physics feel

Read this before editing `specs/view/physics.md` or a section split from it. Do not copy these rules into the spec.

Also read [view.md](view.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

How motion, collision, and contact feel to the player. The design states outcomes in game terms, such as how high a jump reaches or what a hit does. This file states the motion that produces them: curves over time, collision shapes, and the response to contact.

Physics feel must reproduce every design outcome it touches. A design parameter (such as `JUMP_HEIGHT`) is cited by name from `configuration.md`, never restated. When a feel value would change whether an outcome occurs, add the rule to the design first. The design wins on conflict.

Write "N/A — reason" in each section when the game has no simulated motion.

## Sections

- **Motion**: `M1`, `M2`, …. One row per kind of motion the design defines (walk, run, jump, fall, swim, drive). Columns: the design verb or rule it realizes (cite the ID), the motion profile in units and seconds (time to top speed, time to stop, rise and fall times, gravity, air control as a fraction of ground control), and the design outcome it must reproduce.
- **Collision**: `K1`, `K2`, …. Columns: what collides (link characters and entities), the collision shape and its size in units relative to the anchor in `spatial-model.md`, the response (stop, slide along, bounce with a stated fraction of speed kept, push), and what passes through.
- **Contact feel**: `I1`, `I2`, …. Columns: the event (cite the design ID, such as a landing or a hit), and the feedback in motion: freeze time in seconds, knockback distance in units, squash or recoil. Link any camera effect, positional cue, or haptic cue it triggers.
- **Experience intent**: how weight, speed, and impact should come across. Intent only. No ID.

## Splitting

If the file passes 500 words, move collision to `physics/collision.md`. Leave a summary and a link, and update `view.md`.
