# Authoring rules: stage

Read this before editing `specs/design/stages/_template.md` or `specs/design/stages/<name>.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Copy the template to `stages/<kebab-name>.md`, one file per stage or scene. Do not fill the template in place.

A stage is a place or scene where play happens: a level, map, arena, room, hub, or chapter. Every stage is reachable from some flow.

## Header

- **Kind**: stage, scene, hub, or other.
- **Position in flow**: the flow and phase that contain it.
- **Serves**: vision qualities and definition scope items.

## Sections

- **Purpose and theme**: what this stage introduces, tests, or tells. Mood and setting, with a link to `world.md`.
- **Layout**: conceptual spatial structure (regions, paths, landmarks, chokepoints, scale in game terms). Not an editor spec and not a tile spec. Write "N/A" for a non-spatial scene.
- **Contents**: `C1`, `C2`, …. Columns: link to the character or entity, region, count, and conditions (or "Always"). Stories prove presence, count, and region once the condition holds, and absence while it does not.
- **Objectives**: `O1` is the primary objective and the game-state condition that completes it. `O2` is optional. Delete optional rows that do not apply.
- **Stage rules**: `R1`, `R2`, …. A rule that applies only here or overrides a feature. Link the feature and cite its rule ID. Write "None" when there is no local rule.
- **Entry and exit**: `N1` and one entry per exit. Entry conditions and starting state. The transitions themselves live in `flows/`.
- **Pacing**: `B1`, `B2`, …. Columns: beat, where, the game-state condition or event that triggers it, what happens, and intensity (low, rising, peak, or rest). Also state the expected duration. The outcome of each beat follows its trigger.
- **Difficulty variation**: how contents, rules, or objectives change by difficulty level. Link `difficulty.md`.
- **Experience intent**: what the player should feel entering, playing, and leaving.
