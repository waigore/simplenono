# UX Traceability

Authoring rules: [`.agents/specs/rules/ux/traceability.md`](../../.agents/specs/rules/ux/traceability.md).

## Alignment

| Upstream item | Source | Served by |
|---------------|--------|-----------|
| Casual puzzle players; short sessions | [`specs/vision.md`](../vision.md) | [`actors/player.md`](actors/player.md) |
| Calm tactile grid; Snappy solve; Cool clinical look | [`specs/vision.md`](../vision.md) | [`actors/player.md`](actors/player.md); [`screens/gallery.md`](screens/gallery.md) |
| Local free-order pack; desktop and mobile | [`specs/definition/definition.md`](../definition/definition.md) | [`actors/player.md`](actors/player.md); [`screens/gallery.md`](screens/gallery.md) |
| Gallery completion rate; statuses; PB; thumbnails; reset | [`progression.md`](../design/progression.md), [`game-state.md`](../design/game-state.md) | [`screens/gallery.md`](screens/gallery.md) |
| Solve loop; get-set-ready; marks; leave/solve | [`loops/solve.md`](../design/loops/solve.md), [`game-state.md`](../design/game-state.md) | [`screens/puzzle.md`](screens/puzzle.md) |

## Topic coverage

| Topic | Covered in | Applicability |
|-------|------------|---------------|
| Actors | [`actors/`](actors/), [`ux.md`](ux.md) | Applies (`actors/player.md`) |
| Screens | [`screens/`](screens/), [`navigation.md`](navigation.md), [`ux.md`](ux.md) | Applies — `gallery.md`, `puzzle.md`; result, settings indexed pending |
| Journeys | [`journeys/`](journeys/), [`ux.md`](ux.md) | Applies — play, leave-resume, gallery-reset, settings indexed; bodies pending |
| Navigation | [`navigation.md`](navigation.md) | Applies — `UI-gallery`, `UI-puzzle`; T2/T4 destinations pending |
| Exception states | [`exceptions.md`](exceptions.md) | Applies — `EX.confirm` for gallery reset; others omitted until needed |
| Controls and bindings | [`controls.md`](controls.md) | <!-- fill in --> |
| Mockups | [`mockups/`](mockups/), [`mockups/catalog.md`](mockups/catalog.md), [`presentation.md`](presentation.md) | Applies — Open Design `minimal`; mobile-app / web-prototype / play template; aesthetics remap ([`presentation.md`](presentation.md)); catalog rows when screens land |
| Accessibility presentation | [`screens/`](screens/), [`presentation.md`](presentation.md) | <!-- fill in --> |
| Localization copy | screen copy tables | <!-- fill in --> |
| Save-failure feedback | `EX.save-failure` | <!-- fill in --> |
