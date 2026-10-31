# Aesthetics

Authoring rules: [`.agents/specs/rules/aesthetics/aesthetics.md`](../../.agents/specs/rules/aesthetics/aesthetics.md).

## Medium

- **Medium**: Flat clinical UI / vector presentation — 2D board and chrome. Not pixel art, not 3D, not hand-painted illustration as the primary medium.
- **Resolution and scale**: Reference is the full open board in one frame. Art scales with the cell grid ([`SPC.U`](../view/spatial-model.md) = 1 cell). Not a locked art-pixel grid ([`PRJ.X`](../view/projection.md) N/A).
- **Platform implications**: Phone → marks and clues stay crisp at small cell sizes. Desktop → same clinical style; unused margin stays empty, not decorative fill.

## Style pillars

| ID | Pillar | Description | Conforms if… | Serves |
|----|--------|-------------|--------------|--------|
| P1 | Cool clinical | Restrained, high-contrast, cool presentation | Asset is high-contrast, cool-toned, and not cute, warm, or playful | Cool clinical look |
| P2 | Grid clarity | Board stays readable and uncluttered | Fills, crosses, clear, and clues stay distinct | Calm tactile grid |
| P3 | Snappy restraint | Style never slows or muddies the mark loop | No ornament that would muddy or delay marking | Snappy solve; vision tradeoff |

When pillars conflict, the higher ID wins (P1 over P2 over P3).

## Content limits

- No cute mascots, warm “cozy” chrome, or narrative character art in UI.
- No gore or horror.
- Puzzle solution images may show calm subjects but must not break P1–P2 on the board or gallery.
- None from market mandates — definition has no store-feature or rating mandates.

## Variation

None — one style throughout (gallery, board, chrome). Puzzle pictures change content, not the product style system.

## Traceability

[`traceability.md`](traceability.md).

## Index

Global specs: [`glossary.md`](glossary.md), [`ids.md`](ids.md), [`traceability.md`](traceability.md), [`palette.md`](palette.md), [`form.md`](form.md), [`surface.md`](surface.md), [`motion.md`](motion.md), [`ui-style.md`](ui-style.md), [`sound.md`](sound.md), [`references.md`](references.md).

- **Sheets**: [`sheets/palette.html`](sheets/palette.html) and [`sheets/lineup.html`](sheets/lineup.html) filled.
