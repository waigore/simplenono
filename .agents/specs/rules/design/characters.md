# Authoring rules: character

Read this before editing `specs/design/characters/_template.md` or `specs/design/characters/<name>.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Copy the template to `characters/<kebab-name>.md`, one file per character or archetype. Do not fill the template in place.

This file is the single definition of the character. Other specs link here. They do not restate it. Give the character a one-line glossary entry that points here.

## Header

- **Kind**: player character, ally, opponent, or neutral.
- **Serves**: vision qualities and definition scope items.
- **Glossary terms**: links into `glossary.md`.

## Sections

- **Role and fantasy**: the role in the game, and what the character should make the player feel.
- **Attributes**: `P1`, `P2`, …. Values live in `configuration.md`. Reference them by name. Columns: attribute, what it governs, parameter name.
- **Actions and abilities**: `A1`, `A2`, …. The action is a verb. Columns: when it is available, the precise effect, and the cost or limit.
- **States**: `S1`, `S2`, …. Columns: when the state is entered, behavior in the state, and which states it exits to.
- **Behavior**: for a player character, write "N/A — player-controlled" and delete the list. For any other character, state goals, what it perceives, and what is random versus fixed, then decision rules in priority order. Each rule is `B1`, `B2`, …: when a perceived situation holds, what it does.
- **Interactions**: `I1`, `I2`, …. How it affects or is affected by another character, an entity, or the world. Link those specs.
- **Appearances and variation**: stages and scenarios where it appears, and how it changes with difficulty or progression.
- **Experience intent**: how it should come across. Intent only, not asset specs.
