# Authoring rules: difficulty

Read this before editing `specs/design/difficulty.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories for this file follow [story.md](story.md).

How challenge is set, scaled over time, and changed.

## Approach

State the approach: fixed, selectable levels, dynamic adjustment, or a combination. Say why, traced to vision qualities, audience, and tradeoffs.

## Difficulty levels

Delete this section when difficulty is fixed. Otherwise each level names the intended player and the experience goal.

## Parameter adjustments

How each level changes parameters from `configuration.md`. Cells give the value or the change from the default. One column per level. Adjustments reference parameters and specs that exist.

## Rule adjustments

IDs `R1`, `R2`, … per [ids.md](ids.md). A change beyond parameter values, such as an extra opponent behavior, a removed aid, or a different end condition. Name the level and cite the affected element IDs.

## Dynamic adjustment

`Y1`: the signal observed (for example repeated failures), what changes, the limits, and whether the player knows. Or "None".

## Challenge curve

How challenge rises across stages and progression, where the spikes and rests are, and what new skill each step demands.

## Changing difficulty

`C1`: when the player may change difficulty, and the consequences for rewards, progress, and records.

## Fairness

What the player must always be able to anticipate or recover from, and which failures must never feel random.
