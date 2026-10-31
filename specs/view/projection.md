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
| A2 | Safe area | Inner ~90% of the frame; clues + grid stay inside ([`PER.R6`](perception.md)) |

## Pixel scale

N/A — not a locked pixel-art scale; clinical UI scaling follows aesthetics later.

## Visibility limits

N/A — no draw distance, fade, or fog. The open board is either framed or not; nothing hides by distance.
