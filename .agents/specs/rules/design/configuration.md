# Authoring rules: configuration

Read this before editing `specs/design/configuration.md` or a tunable file split from it. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories for this file follow [story.md](story.md).

Everything that varies the game's rules without changing the design: modes and options chosen by the player or host, and designer tunables. This file is the single source of parameter values. Other specs reference parameters by name. Describe effects on rules, not menus or settings screens.

## Modes

Columns: mode, description, how it differs from the standard rules (or "Baseline"), and a link to the flow. Reference a mode by name, such as `CFG.permadeath`.

When [`demo.md`](demo.md) Offering is **offered**, include a demo mode (or options/tunables) whose differences cite `DEMO.L*` limitations. Do not invent demo caps only here—`demo.md` owns the product meaning.

## Game options

Rule variants and assists the player or host may choose. Difficulty levels live in `difficulty.md`, not here.

When accessibility Applies in `specs/definition/quality.md` and names a rule-changing assist or timing option, that option is a row here.

Columns: option, choices, default, effect on rules, who chooses it and when (player or host; before the run or at any time), and when it is locked (or "Never").

## Designer tunables

Balance values a designer adjusts. They are not player-selectable. Reference them by name, such as `CFG.MAX_HEALTH`. The owner spec's stories prove behavior at the default and at both ends of the range.

Columns: parameter, owner spec, default, range, unit (game units such as hits, tiles, or turns), and effect.

## Dependencies and restrictions

IDs `K1`, `K2`, … per [ids.md](ids.md). Each entry is a combination that is not allowed, an option that depends on another, or an option that affects rewards or progression.

## Splitting

If the file passes 500 words, move tunables to `configuration/<domain>.md` (for example `combat.md`, `economy.md`). Keep modes and options here, with links, and update owner specs.
