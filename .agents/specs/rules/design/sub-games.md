# Authoring rules: sub-game

Read this before editing `specs/design/sub-games/_template.md` or `specs/design/sub-games/<name>.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Copy the template to `sub-games/<kebab-name>.md`, one file per sub-game. Do not fill the template in place.

A sub-game is a self-contained game within the game (a minigame, side activity, or bonus round) with its own rules and end conditions.

If the game has no sub-games, write "None" in the design index, mark the traceability topic N/A with a reason, and create no files.

## Header

- **Serves**: vision qualities and definition scope items.
- **Glossary terms**: links into `glossary.md`.

## Sections

- **Purpose**: why it exists and how it relates to the main game (a reward, a break in pace, or an alternate skill).
- **Entry and exit**: `N1`, `N2`, …. Where and when the player can enter, with links to the flow and stage, and whether entry is optional. One entry per way play returns to the main game.
- **Rules**: precise and complete. IDs `R1`, `R2`, ….
- **Characters and entities**: links to those used. A character or entity that exists only in the sub-game still has its own spec under `characters/` or `entities/`.
- **State**: fields that exist only during the sub-game, fields read from the main game, and fields written back, including when.
- **End conditions and rewards**: `O1`, `O2`, …. Columns: outcome (win, loss, or other), condition, and the effect on the main game.
- **Difficulty and configuration**: how difficulty and options apply. Parameter values live in `configuration.md`.
- **Experience intent**: how it should feel, and how it contrasts with the main game.
