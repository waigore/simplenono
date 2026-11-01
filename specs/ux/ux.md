# UX Design

Authoring rules: [`.agents/specs/rules/ux/ux.md`](../../.agents/specs/rules/ux/ux.md).

Serves Calm tactile grid, Snappy solve, and Cool clinical look; free-order local pack play on all supported platforms ([`specs/design/design.md`](../design/design.md), [`specs/definition/definition.md`](../definition/definition.md)).

## Index

Global specs: [`glossary.md`](glossary.md), [`traceability.md`](traceability.md), [`ids.md`](ids.md), [`navigation.md`](navigation.md), [`exceptions.md`](exceptions.md), [`controls.md`](controls.md) ([`controls/bindings.md`](controls/bindings.md)), [`stories.md`](stories.md), [`story-coverage.md`](story-coverage.md), [`presentation.md`](presentation.md), [`mockups/catalog.md`](mockups/catalog.md).

- **Actors**: [`player.md`](actors/player.md) — casual puzzle player; sole operator
- **Screens**:
  - [`gallery.md`](screens/gallery.md) — browse pack; status / personal best / thumbnails; prominent completion rate; gallery reset; open puzzle or settings
  - [`puzzle.md`](screens/puzzle.md) — get-set-ready and mark loop; Fill / Cross / Clear tools; pause into settings; no win morph on this screen
  - [`result.md`](screens/result.md) — after solve: fills, then the stored pixel picture, then the stored generated picture; control returns to gallery
  - [`settings.md`](screens/settings.md) — slim: haptics on/off; mute BGM only (SFX stay on); Back to gallery or resume paused puzzle
- **Journeys**:
  - [`play-puzzle.md`](journeys/play-puzzle.md) — gallery → puzzle → result → gallery
  - [`leave-resume.md`](journeys/leave-resume.md) — leave puzzle → gallery → reopen in progress
  - [`gallery-reset.md`](journeys/gallery-reset.md) — gallery reset → puzzle treated as new
  - [`settings.md`](journeys/settings.md) — open slim settings → change haptics or mute → back
- **Stories**: [`stories.md`](stories.md) — Full coverage for formalized actors, nav, controls, exceptions, screens, journeys


## Traceability

[`traceability.md`](traceability.md).
