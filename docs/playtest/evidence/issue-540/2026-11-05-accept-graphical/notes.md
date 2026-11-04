# Notes — issue #540 acceptance playtest (graphical layout re-run)

## What was judged

The shipped tree `main@9a32abc` — the whole R2 tile-layout deliverable chain: PR #547
(frame-derived columns/margin/gap, clipped labels, square centered picture), #561 (tile body
padding), #579 (the strip below the metadata returns to C1 taps and drags), and #580 (the
640×360 landscape frame fit). Three graphical runs, one probe per concern:

1. **`PTU-gallery-layout` portrait, 360×640** (`probe/probe_accept_540_layout.gd`, adapted from
   the #574 verification probe on the same tree). Steps S1/S3/S2 in order: first-viewport
   geometry (columns 2, margin 18.5 px, gap 10 px, tile padding 8 px, width 153 px, picture
   aspect 1.000), region fit (R1 header, R3, row-0 cards inside the window), label containment
   (0 of 612 outside or truncated at the settled scroll), thumbnail square/full-width/centered,
   fresh-tile strip routing (tap opens through C1, drag scrolls, no blank reset strip,
   `reset_visible() == false`), then 229 touch drags to the last row (no mid-drag open) and
   pack-199 opened through C1. 289 PASS checks, exit 0.
2. **`PTU-gallery-layout` landscape, 640×360.** Same step list; `_columns_for_width` steps the
   wide rule down to 3 columns × 179 px so the row fits inside the window (32 px gutter,
   16.41 px gap, tile padding 12 px) — the #574 fix. 161 drags with no mid-drag open;
   206 PASS checks, exit 0.
3. **`PTU-play-puzzle` S1 / P3 + `PTU-gallery-reset` S1–S3 / P1–P2 at the mobile mockup frame
   390×844** (`probe/probe_accept_540_reset.gd`, adapted from the committed #540 acceptance
   probe). Portrait and landscape chrome at the mockups' own values (2 columns, 10 px gap,
   20 px gutter at 390; every column fits 844×390), per-tile label containment and picture
   squareness/centring on all 200 entries, then the seeded `pack-003` (ever-completed +
   in-progress + PB 1:01 + marks + elapsed 42 s): C2 → `EX.confirm` → Cancel leaves the record
   byte-identical; Confirm clears every field and the tile reads Not started with C2 gone.
   6640 PASS checks, 6 shots, exit 0.

## Why the deterministic record is cited, not re-run

The deliverable can move the Applies deterministic axes and the reuse rule is met by
[`issue-539/2026-11-05-verify-2/manifest.md`](../../../../quality/evidence/issue-539/2026-11-05-verify-2/manifest.md):
all five axes pass at `9a32abc`, the same `main` this run played. Acceptance
does not run `deterministic`. No `llm-judge` axis applies (the rubrics list none for the axes
this deliverable moves).

## How the runs were made

Godot 4.7.2.stable (Homebrew), Metal Forward+, on a macOS host (Apple M5). Each probe ran as
`godot --path game -s res://<probe>.gd -- --debug-seams ...` with its fresh `HOME` (`user://`)
and the stage frames set through `root.size`. Input routes as the #574 probe: mouse through
`Input.parse_input_event` for taps, viewport-pushed `InputEventScreenTouch`/`ScreenDrag` for
drags. The macOS host window's bottom ~30 px dead band and the drag threshold are handled the
same way the #574 verification handled them (strip targets scrolled above the band; drags
≥ 66 px). Probes were copied into `game/` for the run and removed afterwards.

## Non-blocking marks

- The story-id debug overlay text overlaps the R1 title in the captures (`story: portrait`) —
  the seams overlay pilot from `set_story_ids`, not game chrome.
- `capture-reset.log`'s `port state` (progress JSON) shows the seeded record; nothing in the
  reset journey is environment-specific.

## Blockers

None.
