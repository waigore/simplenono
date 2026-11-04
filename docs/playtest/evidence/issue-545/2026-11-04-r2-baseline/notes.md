# Notes — issue #545 R2 layout baseline run

## What was judged

The R2 layout on the shipped shell at the two mobile test viewports, first viewport and after
a swipe scroll attempt, explicitly and separately:

1. **Card spacing** (`#540a`): the grid's columns, page gutter, tile gap, first-row
   neighbour spacing and the second row's alignment.
2. **Per-tile label containment** (`#540b`): every drawn tile's labels stay inside their own
   card and none is truncated — checked across all 200 tiles on the worst-case copy too
   (seeded `pack-003` `Done · In progress` + `Best 9:01`).
3. **Thumbnail centring** (`#540c`): every drawn picture square, spanning its card's inner
   width, centred across the card.
4. **Scroll reachability** (`#539`): R2 is a clipped scroll region, the first tiles start
   inside it, later tiles sit below the fold — then real touch-drag swipes from each visible
   tile's tappable C1 area until more swipes move nothing, at both viewports, plus the reach
   proof: C1 opens a last-row tile.

## How it was driven

`probe_gallery_r2_baseline.gd` boots the shipped `shell.tscn` on a fresh `$HOME`, sizes the
window to each judged frame (`root.size` + `DisplayServer.window_set_size`; the desktop floor
refuses 360 px through `DisplayServer` alone), and captures the displayed frame. Swipes are
`InputEventScreenTouch` press + 8 `ScreenDrag` steps + release pushed through the viewport,
then the async open is allowed to settle before an attempt's outcome (scroll vs open) is
recorded, so one swallowed or late-opening drag cannot end a judgement early. Result:
**42 checks passed, 0 failed**, 4 frames, exit 0.

## The run's checked results, per point

- `#540a` **pass at 360×640** — 2 columns, gutter 18.5 px, gap 10 px, neighbours apart. The
  values are the mockup's own shares under the tree's frame rule (`10/390` gap, `20/390`
  margin), so they were graded pass at this viewport.
- `#540a` **fail at 640×360, filed as #574** — the in-grid values are a consistent 16.4 px
  gap with 4 columns, but the layout does not fit the window: R2 at x=−8 and 656 px wide, the
  first card clipped off the left edge, the 32 px margin never drawn, and R1's header clips
  the same way ("cal pack"/"allery", Settings flush right). The grid's content minimum
  (4 × 150 px min-width cards + gaps + margins ≈ 712 px) exceeds the 640 px frame, so
  containers overflow their rect. **The scroll and containment points still pass on their own
  terms; only the frame fit fails.**
- `#540b` / `#540c` **pass at both viewports** — no label outside its card, no truncation,
  every picture square / inner-width / centred (0 of 600 off at either viewport).
- `#539` **pass at both viewports** — portrait: 231 swipes, 0 opens, offset 27715 of 28190,
  `#199` opens through C1 after the scroll; landscape: 115 swipes, 0 opens, offset 13750 of
  13934, last row reachable and openable. The blank strip finding below meant the swipes
  start on each tile's tappable area (the C1 button's band), which is where a player's finger
  really starts a scroll — the tool first tried strip-band starts and recorded why they
  cannot (see below).

## Observations worth the trail

**Dead strip below the metadata — filed as #573.** Every card reserves an empty band
(~50 px at 360×640: the mockup's body padding plus the 36 px reset-row holder) below its
labels. On a fresh tile the approved mockup draws no reset row at all and stretches C1 over
the whole card. Measured at 360×640: tap in that band does nothing, and a 120 px drag from it
moves R2 by nothing (`observe:` line in the capture log). At 640×360 the strip sits below the
fold at the first viewport, so that viewport was recorded as not probed for it. The #540
metadata-padding rework (#557) touches the same band, so #573's fix should be coordinated.

**The reserved strip is a per-card visual divergence too.** The scrolled portrait shot shows
each card's blank band under the labels where the mockup ends the card at the metadata. It is
recorded on the wiki page; no approval change was made and none is requested here.

**Tool-driving notes, not product findings.** The probe's first pass aborted its landscape
climb after one swallowed swipe and could not finish a fair reachability judgement; the
shipped probe retargets the top tile with ≥16 px of C1 under R2's view, starts each press
inside the tappable band, and recovers a late open (#539's rule says a drag must not open the
tile — none of the 346 successful attempts in this run did). The window's frame always
matched the requested test dimensions (`frame … got 360x640` / `got 640x360`, both logged
PASS).

## Blockers

None.

## Non-blocking marks

- The manifest's `#540a` pass at 360×640 grades the values against the tree's frame-scaled
  rule; the mockup's 20/10 nominal values belong to its 390 frame, so the grade spells the
  scaled values out rather than claiming a literal 20.
- The 640×360 first-viewport shot's R1/R3 clipping is part of the #574 frame-overshoot
  record; judging R3 chrome is not this task's scope.
