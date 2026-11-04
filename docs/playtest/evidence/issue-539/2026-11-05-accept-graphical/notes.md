# Notes — issue #539 acceptance playtest (graphical mobile gallery scroll runs)

## What was judged

The deliverable tree `main@dd0b141` — `game/` identical to the verified deliverable
`8c941af` (`git diff 8c941af dd0b141 -- game/` is empty; the only later `main` commits are the
#574/#589 evidence records). This is the same `game/` tree the 2026-11-05-verify-3
deterministic record was written for, so the issue's count of covered trees holds at this run.
One probe (`probe/probe_accept_539_layout.gd`, adapted from the committed #574 acceptance probe —
same checks, renamed identity/progress files):

1. **`PTU-gallery-layout` portrait, 360×640.** First-viewport geometry (columns 2, margin,
   gap, tile padding, width 153 px, picture aspect 1.000), region fit (R1 header, R3, row-0
   cards inside the window), label containment, thumbnail square/full-width/centred,
   fresh-tile strip routing (`pack-001`: no reset strip, C1 spanning the card, band tap
   raised C1, band drag scrolled), then **229 touch-drag swipes starting on each tile's
   tappable C1 area** to the last row — 0 mid-drag opens, the scroll settles at 24151 against
   a scrollbar max of 24664, and `pack-199` (20×20 · #199) sits in frame at P (181, 386) size
   153×236 and opens through C1. 293 PASS checks, exit 0.
2. **`PTU-gallery-layout` landscape, 640×360.** Same step list at 3 columns × 179 px beside
   the margins: **163 drags**, no mid-drag opens, scroll 17193 / max 17546, `pack-199` in
   frame at P (227, 85) and opens through C1. 224 PASS checks, exit 0.

Both P5 legs against the fix's own cause: every swipe started inside the card's tappable C1
area (the surface that swallowed touches before `scroll_drag_release.gd`), so the probe
exercises the exact routed input path, not the scrollbar.

### The replay stage (both viewports)

The progress document is seeded for `pack-003` before boot (ever-completed, in-progress,
PB 1:01, marks, elapsed 42 s), so one tile draws the Reset row:

- `reset_visible() == true` and the row sits inside C1's floor.
- A drag starting on the row's empty side scrolls R2 and opens nothing; a tap there raises
  this tile's C1 (puzzle opens, no confirm dialog) — the band is not a dead region.
- A press on the Reset button itself raises EX.confirm (C2), and Cancel dismisses it
  leaving the seeded record byte-identical (the full Cancel/Confirm journey is
  `PTU-gallery-reset`'s own evidence).

### Deterministic citation

The deliverable can move the Applies deterministic axes; the passing record that covers this
`game/` tree is
[`docs/quality/evidence/issue-539/2026-11-05-verify-3/manifest.md`](../../../../quality/evidence/issue-539/2026-11-05-verify-3/manifest.md)
(deliverable `8c941af`, PR #588 merged as `85c21e5`; all five selected axes pass). Acceptance
does not run `deterministic`. No `llm-judge` axis applies —
[`specs/definition/quality/rubrics/baseline.md`](../../../../../specs/definition/quality/rubrics/baseline.md)
lists none.

## How the runs were made

Godot 4.7.2.stable (Homebrew), macOS arm64. One probe ran as
`godot --path game -s res://probe_accept_539_layout.gd -- --debug-seams ...` twice, once per
test viewport, each under its own fresh `HOME` (`user://`) — the runs re-seed the progress
document each boot on their own `user://progress-accept-539-layout.cfg`. Input routes as the
#573/#540/#574 probes: mouse through `Input.parse_input_event` for taps (strip tap, the
below-fold C1 tap, the Reset button press), viewport-pushed `InputEventScreenTouch` /
`ScreenDrag` for drags. The macOS host window's bottom ~30 px dead band and the drag
threshold are handled the same way the committed probes handle them (strip targets scrolled
above the band; drags ≥ 120 px). The fresh worktree used the `game/.godot` import cache
copied from the main checkout before the global script classes resolved. The probe was
copied into `game/` for the runs and removed afterwards (kept in this folder's `probe/`).

## Non-blocking marks

- The story-id debug overlay text overlaps the R1 title in the captures (`story: portrait`
  / `story: landscape`) — the seams overlay pilots from `set_story_ids`, not game chrome.
- Both runs' end-of-session S5 dump resolves to the same `state-attempt.json` name, so each
  run's copy is renamed (`state-portrait.json` / `state-landscape.json`); both are on the
  wiki page. In R2 the dumps' attempt fields are null — no attempt is open from a scroll,
  which P5 asserts.
- The seeded `Completed 1 / 200` counter and `pack-003`'s `Done · In progress` / `Best 1:01`
  copy are the seed, not shipped-pack state.

## Blockers

None.
