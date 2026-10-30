# Authoring rules: progression

Read this before editing `specs/design/progression.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories for this file follow [story.md](story.md).

How the player advances, and how progress is kept, lost, or reset. This must match the progression objective in `specs/definition/definition.md`. Persistence agrees with flows, end conditions, and game-state scopes.

## Progression axes

IDs `A1`, `A2`, … per [ids.md](ids.md). Columns: axis, kind (skill, character power, content unlock, story, collection, or rank), what advances it, and the cap (or "None").

## Unlocks

IDs `U1`, `U2`, …. Columns: unlock, requirement, and effect, with a link to the spec it enables.

## Persistence

When save durability Applies in `specs/definition/quality.md`, this table and **M1** are its design side. The target itself stays in the quality spec.

Columns: what (a game-state field), which boundaries it persists across (stage, session, run, or playthrough), and when it is lost or reset. IDs `P1`, `P2`, ….

## Committing progress

Conceptual only. Not save-file design.

**M1**: when progress becomes permanent (checkpoints, stage end, or at any moment) and where play resumes after an interruption. When save durability Applies, state what is committed, when it becomes permanent, and where play resumes.

## Failure consequences

**F1**: what is lost, kept, or converted on a failure, and why that cost suits the vision.

## Completion

- **Z1**: the game-state condition that counts as finishing the game.
- **Z2**: what happens after completion (replay, a harder cycle, endless mode, or "Ends").
- **Z3**: full completion (for example all collectibles), or "Same as finishing".

## Experience intent

How growth should feel over minutes, over a session, and over the whole game.
