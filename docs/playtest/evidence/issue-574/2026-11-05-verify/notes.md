# Notes — issue #574 layout verification capture

## How the run was made

`probe/probe_layout_574.gd` (a `SceneTree` script, committed here for the record and removed from `game/` after the
run) drives the whole `PTU-gallery-layout` step list at one viewport per run:

1. `S1` — open the gallery on the shipped pack, screenshot the first viewport, and log the measured geometry the
   manifest cites (`columns=`, `page_margin=`, `grid_gap=`, `tile_padding`, `widest=`, `aspect=`, `breakpoint=`,
   row-0 card rects, region rects).
2. `S3` — scroll so a row's strip band is fully visible and clear of the host window's bottom dead band, then tap a
   fresh tile's metadata strip (C1 open), leave the puzzle, and drag from the same tile's strip band (R2 scrolls;
   no open). Also checks C1 covering a whole fresh card (no blank reserved strip) and `reset_visible() == false`.
3. `S3`/`P3`/`P4` — judge labels inside their cards and the thumbnail geometry on the fully visible cards at the
   settled scroll.
4. `S2` — repeated touch drags (press on a live card's C1 surface, 8 drag steps, release, re-pick the pressed card)
   until the last row of the 200-tile grid is fully inside the viewport; screenshot the scrolled state; tap
   pack-199 through C1 and confirm the puzzle opens; leave.

All input goes through the real routes: `Input.parse_input_event` mouse for taps (the desktop host is not a product
platform; the touch path is the product's) and viewport-pushed `InputEventScreenTouch`/`ScreenDrag` for drags, the
same synthetic route [`scroll_drag_release.gd`](../../../../../../game/presentation/scroll_drag_release.gd) serves.

## Judgement anchors and tolerances

- Column shares: portrait 2 × 153 px cards beside 18.5 px margins with a 10 px gap; landscape 3 × ~179 px beside
  32 px margins with a 16.41 px gap. The wide minimum (4 × 150 px floors + 3 gaps + 2 margins ≈ 713 px) exceeds the
  640 px frame, which is the recorded defect; the fix steps the count down to the three columns that fit
  (`_columns_for_width`, `game/presentation/gallery.gd`), and the row rects print beside the page margin.
- P4 treats the thumbnail as the mockup's full-bleed square (`MC.gallery-mobile` CSS: `.open { width:100%;
  padding:0 }`, `.thumb { aspect-ratio:1 }`; only `.meta` takes the 8/12 px padding), so the check is
  thumb control = card width, drawn square centred.
- The scroll hand-off `DRAG_THRESHOLD` is 6 px, so every reach-loop press is held at least 76 px under R2's top edge
  and 100 px above its card's bottom edge, giving a ≥ 66 px drag that can never be judged a tap. Mid-drag checks
  assert the shell stays on the gallery between drag steps.

## Host-environment notes (capture-only, not game behaviour)

- The macOS host window absorbs clicks in its bottom ~30 px (a native resize/decoration zone): verified dead at
  `y ≥ 328` in a 360 px-tall window with both input routes while the same card surface at `y ≤ 326` answers. The
  probe therefore scrolls each strip target so its band sits above that zone before tapping, and clamps taps 24 px
  inside the right edge. Prototype judgement is unaffected: those checks judge the card's C1/C2 routing, and the
  per-point taps happen on live card surfaces.
- Drags: press and the first drag step are separated by one frame (same-frame press+drag does not hand off); each
  drag step is one frame apart so the scroll hand-off accumulates the full motion (~120–150 px per gesture).

## Evidence

- Logs pushed to the wiki: `playtest/issue-574/2026-11-05-verify/logs/` — `capture-landscape.log`,
  `capture-portrait.log` (the full probe console with one `capture: PASS/FAIL` line per judged point and the
  geometry info lines), and the S4 state dumps.
- In-repo `logs/state-attempt.json` is the portrait run's dump — the runs share the dump filename, so the
  landscape run's copy was overwritten; both capture logs carry each run's `capture: state dump` line.
- Screenshots live on the wiki page (`screenshots/`); per the wiki-evidence contract nothing media is committed
  under `docs/` here.
