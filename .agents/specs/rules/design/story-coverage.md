# Authoring rules: design story coverage

Read this before writing player stories. Do not copy this table into `specs/design/story-coverage.md` or into a story file. That file only links here.

Also read [stories.md](stories.md) and [ids.md](ids.md).

Every element is proven, not only mentioned.

This file is the Full coverage level. A spec at Baseline or None follows [depth.md](../depth.md) instead. The `stories.md` index records each spec's level.

## Every element

Every element ID and every name-referenced item (fields, modes, options, tunables) is proven by at least one scenario in the story file of the spec that defines it. Designer tunables are proven in their owner spec's story file. Requirements below are cumulative: an element that is both conditional and numeric needs both sets of scenarios.

## Requirements by kind

| Element kind | Scenarios required |
|--------------|--------------------|
| Conditional element: a rule, action, transition, or adjustment that applies only when something holds | One where the condition holds and one where it does not |
| Numeric threshold | At the boundary and on each side of it |
| Edge case | One per edge case |
| Invariant (`GS.V`, field invariants) | One where play would break it, showing it still holds |
| Difficulty level or game option that changes an element | One under each level or choice that changes it |
| Designer tunable (`CFG.<name>`) | In its owner spec's story file: behavior at the default and at both ends of its range |
| Mode (`CFG.<name>`) | One for each rule the mode changes |
| Character attribute, entity property (`P`) | Its initial value from its parameter, and the effect it governs |
| Game-state field (`GS.<name>`) | Its initial value, its reset when its scope's lifetime ends, and its invariants |
| Hidden and visible state (`GS.H`) | What the player can know and cannot know, before and after the condition that reveals or hides it |
| Stage contents (`C`) | Presence, count, and region once its condition holds; absence while it does not |
| Flow phase (`P`) | Each listed verb is available; each verb named as unavailable has no effect on game state |
| Loop step or exit, pacing beat, walkthrough step | The stated outcome follows its trigger |
| Completion (`PRG.Z`) | The condition that counts as completion, and what happens after |

## Phrasing knowledge

Hidden and visible state describes what the player can know, never how it is shown. Write "Then the player can know `<field>`" or "Then the player cannot know `<field>`". Never mention screens, indicators, or display.

## Not covered

Sections without IDs (purpose, motivation, layout, expected duration, experience intent, and similar) are not proven by stories. Review and acceptance judge them.
