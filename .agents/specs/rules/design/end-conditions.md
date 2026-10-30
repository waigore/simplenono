# Authoring rules: end conditions

Read this before editing `specs/design/end-conditions.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories for this file follow [story.md](story.md).

Every way a unit of play ends. Win and loss must match the player objectives in `specs/definition/definition.md`.

## Units of play

One row per unit (game, run, match, stage, round, or sub-game). Columns: win summary, loss summary, and other endings (draw, timeout, abandon, or "None").

## Conditions

Columns: ID (for example `W1` or `L1`), unit, type (win, loss, draw, or other), the condition in game-state terms, when it is checked, and the outcome (state changes and the flow transition).

Other specs refer to a condition by qualified ID, such as `END.L1`. An ID cited elsewhere must exist.

## Precedence

**P1**: how simultaneous conditions resolve, and why. Cover every set of conditions that can be true in the same moment.

## Rewards and penalties

What each outcome grants or costs. Link `progression.md` and any economy feature.

## Experience intent

How winning and losing should feel, including what makes a loss feel fair and a win feel earned.
