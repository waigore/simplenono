# Projection

Authoring rules: [`.agents/specs/rules/view/projection.md`](../../.agents/specs/rules/view/projection.md).

- **Serves**: Calm tactile grid, Cool clinical look — fixed flat framing of the open board ([`view.md`](view.md), [`perception.md`](perception.md)).
- **Diagram**: [`diagrams/projection.html`](diagrams/projection.html)

## Projections

| ID | Type | Parameters | Used in |
|----|------|------------|---------|
| P1 | Orthographic (flat UI) | Visible height = full open board (clue margins + `size`×`size` grid) in one framing | all (no cameras) |

## Visible area

| ID | Platform | Minimum (units) | Maximum (units) | Reference distance |
|----|----------|-----------------|-----------------|--------------------|
| V1 | all supported | Full `size`×`size` play grid always in frame | Same; clue margins stay readable in the same framing | N/A — orthographic UI |

## Aspect and safe area

| ID | Rule | Statement |
|----|------|-----------|
| A1 | Aspect range | About 9:16 through 16:9; outside that, letterbox or pillarbox |
| A2 | Safe area | Inner ~90% of the game viewport, which is the frame minus the A3 system chrome band; clues + grid stay inside ([`PER.R6`](perception.md)) and never extend under the status bar or the navigation / home-indicator band. |
| A3 | System chrome band | The OS status bar and the navigation / home-indicator band stay visible, are drawn by the OS outside the game viewport, and are never covered by game content ([`view.md`](view.md) Platform implications). Its reserve in the mobile mockups is this band, not decoration. |
| A4 | Android chrome keys | Both Android presets capture `screen/immersive_mode=false` and `screen/edge_to_edge=false` — `[preset.0]` (Android debug) and `[preset.4]` (Android Release) in `game/export_presets.cfg` — so the OS keeps drawing the A3 band. A live read of these keys by game code is `specs/technical/` work, not view work. |

## Pixel scale

N/A — not a locked pixel-art scale; clinical UI scaling follows aesthetics later.

## Visibility limits

N/A — no draw distance, fade, or fog. The open board is either framed or not; nothing hides by distance.
