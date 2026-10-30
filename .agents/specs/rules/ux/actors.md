# Authoring rules: actor

Read this before editing `specs/ux/actors/_template.md` or `specs/ux/actors/<name>.md`. Do not copy these rules into the spec.

Also read [ux.md](ux.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Copy the template to `actors/<kebab-name>.md`, one file per person who operates the interface. Do not fill the template in place.

An actor is a person who uses the interface, such as the player, a local co-player, a spectator, or someone on a first run. Game characters stay in `specs/design/characters/`. Each actor is defined once.

## Header

- **Serves**: the vision audience, qualities, and definition scope items.
- **Platforms**: platforms from the definition this actor uses.
- **Glossary terms**: links into `glossary.md`.

## Sections

- **Who they are**: one paragraph. How this person differs from other actors. Link the vision audience this role comes from.
- **Goals**: what they are trying to finish through the interface, in the actor's terms. Goals carry no IDs. Review judges them.
- **Can operate**: `C1`, `C2`, …. Which screens or kinds of control this actor may use. Link the screens. Stories show the actor can activate each allowed control.
- **Cannot operate**: `K1`, `K2`, …. Which controls or screens this actor must not activate, and what the interface does instead. A forbidden control does not activate. Constraints agree with the controls those screens list.
- **Relationship to play**: link the design character this actor controls or watches, or "None". Do not restate that character's actions.
