# Authoring rules: game state

Read this before editing `specs/design/game-state.md` or a file split from it. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories for this file follow [story.md](story.md).

The conceptual model of everything the game tracks. Logical only: no data formats and no storage. Other specs reference fields by the names defined here.

## Scopes

The skeleton lists Moment, Stage, Session / run, Persistent, and Configuration. Fill each lifetime and the examples in this game. Delete a scope that does not apply. Persistent points at `progression.md`. Configuration points at `configuration.md`.

## Fields

Columns: field, scope, meaning, initial value, which specs change it, and invariants (for example `0 ≤ value ≤ max`).

Reference a field by name, such as `GS.health`. Player stories prove each field's initial value, its reset when its scope's lifetime ends, and its invariants.

## Derived values

Values computed from fields. They are never stored independently. Columns: value, the fields and rule it is derived from, and which specs use it.

## Global invariants

Rules that must hold at all times across fields. IDs `V1`, `V2`, … per [ids.md](ids.md).

## Hidden and visible state

What the player can know, not how it is displayed. Each `H` entry names a field the player knows, can infer, or cannot know, the condition that reveals or hides it, and why. Examples of the kind of fact: opponent hands, fog of war.

## Randomness and determinism

Each `Q` entry names one random outcome, its range or distribution, and whether identical setups must produce identical outcomes.

## Splitting

If the file passes 500 words, split fields by scope or domain into `game-state/<name>.md`. Keep this file as the overview and index, and update links.
