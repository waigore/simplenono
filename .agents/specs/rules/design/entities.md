# Authoring rules: entity

Read this before editing `specs/design/entities/_template.md` or `specs/design/entities/<name>.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Copy the template to `entities/<kebab-name>.md`, one file per entity or tight entity group. Do not fill the template in place.

This file is the single definition of a non-character thing: an item, pickup, object, hazard, terrain feature, or resource. Other specs link here. Give it a one-line glossary entry that points here.

## Header

- **Kind**: item, pickup, object, hazard, terrain, or resource.
- **Serves**: vision qualities and definition scope items.
- **Glossary terms**: links into `glossary.md`.

## Sections

- **Purpose**: why it exists, and the decision or experience it creates.
- **Properties**: `P1`, `P2`, …. Values live in `configuration.md`. Reference them by name. Columns: property, what it governs, parameter name.
- **Lifecycle and states**: `S1`, `S2`, …. Columns: when the state is entered, behavior in the state, and which states it exits to.
- **Interactions**: `I1`, `I2`, …. Columns: what it interacts with (link the character, entity, or feature), the trigger, and the precise outcome.
- **Placement and availability**: where and when it appears, how many, limits or rarity, and whether placement is fixed or random.
- **Experience intent**: how it should come across. Intent only.
