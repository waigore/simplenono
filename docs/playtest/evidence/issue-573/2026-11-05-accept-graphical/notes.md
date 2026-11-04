# Notes — issue #573 acceptance playtest (graphical tile-band runs)

## What was judged

The shipped tree `main@9a32abc` — the #573 deliverable chain is only PR #579
(`game/presentation/gallery_tile.gd` reset-holder rework, merge `38937ec`); the tile-band
behavior nested on top of it is unchanged by #580 (`git diff ee1d2fd 9a32abc -- game/` is
empty). Two graphical runs of
[`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md)
(S1–S3 / P1–P6, judged per point per viewport), one probe
(`probe/probe_accept_573_layout.gd`, adapted from the committed #540 acceptance probe with
#573's own replay stage):

1. **`PTU-gallery-layout` portrait, 360×640.** First-viewport geometry (columns 2, margin
   18.5 px, gap 10 px, tile padding 8, width 153 px, picture aspect 1.000), region fit
   (R1 header, R3, row-0 cards inside the window), label containment, thumbnail
   square/full-width/centred, fresh-tile strip routing (`pack-001`: no reset strip, C1
   spanning the card, band tap raised C1, band drag scrolled), then 229 touch drags to the
   last row (no mid-drag open) and pack-199 opened through C1. 293 PASS checks, exit 0.
2. **`PTU-gallery-layout` landscape, 640×360.** Same step list at 3 columns × 179 px beside
   the 32 px margins (the #574 fit); 163 drags, no mid-drag open; pack-199 opens through C1.
   224 PASS checks, exit 0.

### The #573 replay stage (both viewports)

The progress document is seeded for `pack-003` before boot (ever-completed, in-progress,
PB 1:01, marks, elapsed 42 s), so one tile draws the Reset row:

- `reset_visible() == true` and the row sits **inside C1's floor** (portrait:
  `reset.end.y 537.0 <= button.end.y 545.0`), the shape the approved
  `MC.gallery-mobile` mockup draws.
- A **drag** starting on the row's empty side (x `card.x + 24`, left of the button) scrolls
  R2 and opens nothing; a **tap** there raises this tile's C1 (puzzle opens, no confirm
  dialog) — the band is not a dead region, matching
  `test_gallery_reset_row_side_taps_as_c1_not_c2`'s unit pin through the real input route.
- A press **on the Reset button itself** raises EX.confirm (C2), and Cancel dismisses it
  leaving the seeded record byte-identical (the full Cancel/Confirm journey is
  `PTU-gallery-reset`'s own evidence; this stage judges the C2 reach this deliverable
  moves).

### Deterministic citation

The deliverable can move the Applies deterministic axes; the passing record that covers this
`game/` tree is [`issue-574/2026-11-05-verify`](https://github.com/waigore/simplenono/blob/defect/574-gallery-fits-landscape-frame/docs/quality/evidence/issue-574/2026-11-05-verify/manifest.md)
(all five axes pass at `ee1d2fd`; `game/` identical to this build). Acceptance does not run
`deterministic`. No `llm-judge` axis applies — [`specs/definition/quality/rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md)
lists none. Paperwork note: that record currently sits on
`origin/defect/574-gallery-fits-landscape-frame` (`ed5a14e`) and is not yet merged to `main`;
#574 keeps `status:pending-acceptance` and landing it is its own handoff. #573's own
verification record (`issue-573/2026-11-05-verify`, `38937ec`) predates the #580 merge, so
its tree no longer matches this build's `game/`.

## How the runs were made

Godot 4.7.2.stable (Homebrew), Metal Forward+, on a macOS host (Apple M5). One probe ran as
`godot --path game -s res://probe_accept_573_layout.gd -- --debug-seams ...` twice, once per
test viewport, each under its own fresh `HOME` (`user://`) — the portrait progress document
is rebuilt by the seed in each run. Input routes as the #574/#540 probes: mouse through
`Input.parse_input_event` for taps (band tap, the below-fold C1 tap, the Reset button press),
viewport-pushed `InputEventScreenTouch`/`ScreenDrag` for drags. The macOS host window's
bottom ~30 px dead band and the drag threshold are handled the same way the committed
probes handle them (strip targets scrolled above the band; drags ≥ 120 px). Probes were
copied into `game/` for the run and removed afterwards.

## Non-blocking marks

- The story-id debug overlay text overlaps the R1 title in the captures (`story: portrait` /
  `story: landscape`) — the seams overlay pilot from `set_story_ids`, not game chrome.
- Both runs' end-of-session S5 dump resolves to the same `state-attempt.json` name, so the
  surviving copy is the landscape run's; it is cited as `state-landscape.json` on the wiki
  page. In R2 the dump's fields are null — no attempt is open from a scroll, which P5
  asserts.
- The seeded `Completed 1 / 200` counter and `pack-003`'s `Done · In progress` /
  `Best 1:01` copy are the seed, not shipped-pack state.

## Blockers
