# Protocol: Gallery layout

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-gallery-layout`
- **Cites**: `J-play-puzzle` (N1, S1), `UI-gallery` (R2, `C1`, `C2`)
- **Situational tools**: None
- **Visual reference**: `MC.gallery-mobile`, while that row stays `approved` ([mockups/catalog.md](../../../specs/ux/mockups/catalog.md)); its frame gives the shares — page margin 20 per side at 390, a 10 gap, 2 portrait columns, whole-card `C1`, no fresh-tile reset row. Shares hold as drawn at 360×640, scaled elsewhere. No mockup depicts 640×360: its count is an `S1` observation, judged via `P1` and `P2`.

## Steps

| ID | Action |
|----|--------|
| S1 | Per test viewport ([`view.md`](../../view/view.md)), 360×640 then 640×360: open the gallery on the full pack, screenshot the first viewport; note count, page margin, neighbour gap, clipped card or chrome. |
| S2 | Per viewport: touch-drag from a card's `C1` area until R2's last row is inside, then tap a below-fold tile; screenshot the final scrolled state; note mid-drag opens and the tapped tile's `C1` entry. |
| S3 | Per viewport: labels sit inside cards, untruncated; thumbnails square, full-width, centred; fresh tiles show no blank strip. Tap a fresh tile's metadata strip; scroll-drag from another fresh tile's strip; note both outcomes. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Both viewports show the page margin; every card and chrome region (`R1`, `R3`) fits. |
| P2 | 360×640 lays the mockup's 2 columns, margin, and gap shares, scaled; 640×360 keeps cards clear: one neighbour gap, no overlap, no crowding. |
| P3 | Every label stays inside its card, untruncated. |
| P4 | Every thumbnail is a square over the card's inner width, centred. |
| P5 | A drag from `C1` scrolls R2 without opening a tile; a reached below-fold tile opens through `C1`. |
| P6 | A metadata-strip tap reaches the tile (`C1`, else `C2` when reset is allowed); a strip drag scrolls R2; no-reset cards keep no blank strip. |

## Fail

| ID | Outcome | Blocks acceptance |
|----|---------|-------------------|
| F1 | A card or chrome clips at a window edge, or the page margin is missing. | yes |
| F2 | 360×640: count, margin, or gap drifts from the mockup share; 640×360: cards overlap, crowd, or two different neighbour gaps. | yes |
| F3 | A label lies outside its card or is truncated. | yes |
| F4 | A thumbnail is not a full-width square or not centred. | yes |
| F5 | Scrolling misses later tiles, a drag opens a tile, or a reached below-fold tile cannot open. | yes |
| F6 | A metadata-strip tap or drag does neither (dead band), or a fresh tile reserves an undrawn strip. | yes |

## Evidence

Default evidence rules ([`evidence.md`](../../playtest/evidence.md)), per point per viewport: a graphical run screenshots each viewport's first and final scrolled states (4 frames minimum); a headless run judges from logs and inspection, screenshots waiting — an evidence gap, not a game fail.
