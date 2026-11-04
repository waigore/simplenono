# Protocol: Gallery layout

Authoring rules: [`.agents/specs/rules/playtest/protocol.md`](../../../.agents/specs/rules/playtest/protocol.md).

- **Level**: UX
- **Spec key**: `PTU-gallery-layout`
- **Cites**: `J-play-puzzle` (N1, S1), `UI-gallery` (R2, `C1`, `C2`)
- **Situational tools**: None
- **Visual reference**: `MC.gallery-mobile`, while that row stays `approved` ([mockups/catalog.md](../../../specs/ux/mockups/catalog.md)); its frame gives the quoted shares — page margin 20 per side at 390, a 10 gap, 2 portrait columns, whole-card `C1`, no fresh-tile reset row. Other viewports compare proportionally.

## Steps

| ID | Action |
|----|--------|
| S1 | Per test viewport ([`view.md`](../../view/view.md)), 360×640 then 640×360: open the gallery on the full local pack, screenshot the first viewport, and note the column count, page margin, neighbour gap, and any clipped card or chrome. |
| S2 | Per viewport: touch-drag scrolls from a card's `C1` area until the last row of R2 is inside the viewport, then tap a below-fold tile; screenshot the final scrolled state; note mid-drag opens and the tapped tile's `C1` entry. |
| S3 | Per viewport, on visible cards: labels inside their cards and untruncated; thumbnails square, full-width, centred; no blank strip on a fresh tile. Tap inside a fresh tile's metadata strip; start a scroll drag from a second fresh tile's strip; note both outcomes. |

## Pass

| ID | Outcome |
|----|---------|
| P1 | Both viewports show the page margin; every card and chrome region (`R1`, `R3`) fits the window. |
| P2 | Columns follow the mockup's share (2 columns at 360×640; the wide rule at 640×360); neighbours sit one proportional gap apart. |
| P3 | Every label stays inside its card, untruncated. |
| P4 | Every thumbnail is a square over the card's inner width, centred. |
| P5 | A drag from `C1` scrolls R2 without opening a tile; a reached below-fold tile opens through `C1`. |
| P6 | A metadata-strip tap reaches the tile (`C1`, or `C2` when reset is allowed); a strip drag scrolls R2; a no-reset card has no blank strip. |

## Fail

| ID | Outcome |
|----|---------|
| F1 | A card or chrome clips at a window edge, or the page margin is missing. |
| F2 | Cards are cramped, overlapping, or off the mockup's column and gap shares. |
| F3 | A label lies outside its card or is truncated. |
| F4 | A thumbnail is not a full-width square or not centred. |
| F5 | Scrolling misses later tiles, a drag opens a tile, or a reached below-fold tile cannot open. |
| F6 | A metadata-strip tap or drag does neither action (a dead band), or a fresh tile reserves a strip the mockup does not draw. |

## Evidence

Default evidence rules ([`evidence.md`](../../playtest/evidence.md)); judge per point and viewport. A graphical run screenshots each viewport's first and final scrolled states (4 frames minimum). Fails block acceptance and may file defects without screenshots; a headless run may judge from logs and inspection with screenshots waiting — an evidence gap, not a game fail.
