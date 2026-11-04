# Notes — issue #574 acceptance playtest (graphical landscape fit runs)

## What was judged

The deliverable tree `main@9a32abc` — PR #580
(`game/presentation/gallery.gd` `_columns_for_width` step-down + the landscape frame-fit
test in `game/test/test_gallery.gd`), where `git diff ee1d2fd 9a32abc -- game/` is empty.
Two graphical runs of
[`PTU-gallery-layout`](../../../../specs/playtest/ux/gallery-layout.md)
(S1–S3 / P1–P6, judged per point per viewport), one probe
(`probe/probe_accept_574_layout.gd`, adapted from the committed #573 acceptance probe —
same checks, renamed identity/progress files):

1. **`PTU-gallery-layout` portrait, 360×640.** First-viewport geometry (columns 2, margin
   18.5 px, gap 10 px, tile padding 8, width 153 px, picture aspect 1.000, breakpoint
   546.0), region fit (R1 header, R3, row-0 cards inside the window), label containment,
   thumbnail square/full-width/centred, fresh-tile strip routing (`pack-001`: no reset
   strip, C1 spanning the card, band tap raised C1, band drag scrolled), then 229 touch
   drags to the last row (no mid-drag open) and pack-199 opened through C1. 293 PASS
   checks, exit 0.
2. **`PTU-gallery-layout` landscape, 640×360 — the shipped defect's viewport.** Same step
   list at 3 columns × 179 px beside the 32 px margins (the `_columns_for_width` fit:
   breakpoint 307.1, gap 16.41, tile padding 12); the recorded overshoot does not
   reproduce — first-column cards sit at x 32.0 / 227.0 / 422.0, the `Margin` container
   starts at 32.0 on both sides, and the R1 header (`Greeting`, `Title`) and the
   `Settings` button are inside the window (the filed `cal pack`/`allery` clipping is
   gone); the wide four-floor minimum (~712 px) still provably exceeds the six-wide frame
   and the count steps to the three that fit. 0 containment misses across the scroll, 163
   drags, no mid-drag open; pack-199 in frame at y 85 opens through C1. 224 PASS checks,
   exit 0.

### The replay stage (both viewports)

The progress document is seeded for `pack-003` before boot (ever-completed, in-progress,
PB 1:01, marks, elapsed 42 s), so one tile draws the Reset row:

- `reset_visible() == true` and the row sits inside C1's floor — the shape the approved
  `MC.gallery-mobile` mockup draws.
- A drag starting on the row's empty side scrolls R2 and opens nothing; a tap there raises
  this tile's C1 (puzzle opens, no confirm dialog) — the band is not a dead region.
- A press on the Reset button itself raises EX.confirm (C2), and Cancel dismisses it
  leaving the seeded record byte-identical (the full Cancel/Confirm journey is
  `PTU-gallery-reset`'s own evidence; P6 here judges the C2 reach this deliverable moves).

### Deterministic citation

The deliverable can move the Applies deterministic axes; the passing record that covers
this `game/` tree is [`docs/quality/evidence/issue-574/2026-11-05-verify/manifest.md`](../../../../quality/evidence/issue-574/2026-11-05-verify/manifest.md)
(all five axes pass at `ee1d2fd`; `game/` identical to this build's deliverable merge).
Acceptance does not run `deterministic`. No `llm-judge` axis applies —
[`specs/definition/quality/rubrics/baseline.md`](../../../../../../specs/definition/quality/rubrics/baseline.md)
lists none. Paperwork note verified this run: origin/main after the #580 merge adds only
#583/#584/#582/#583 + #540/#585 evidence (docs), #555's harness/test files
(`game/test/integration/solve_oracle.gd`, `test_solve_oracle.gd`, `test_lane_recording.gd`,
supervisor + README) and #587's protocol spec — no game runtime code — so the record's
deliverable coordinates remain the judged tree. That record and the verification playtest
record ([`docs/playtest/evidence/issue-574/2026-11-05-verify`](../2026-11-05-verify/manifest.md))
sit on `origin/defect/574-gallery-fits-landscape-frame` (`ed5a14e`) and are not yet merged
to `main`; landing them is #574's handoff PR this run opens with this folder.

## How the runs were made

Godot 4.7.2.stable (Homebrew), Metal Forward+, on a macOS host (Apple M5). One probe ran as
`godot --path game -s res://probe_accept_574_layout.gd -- --debug-seams ...` twice, once per
test viewport, each under its own fresh `HOME` (`user://`) — the portrait and landscape
runs re-seed the progress document each boot. Input routes as the #573/#540 probes: mouse
through `Input.parse_input_event` for taps (strip tap, the below-fold C1 tap, the Reset
button press), viewport-pushed `InputEventScreenTouch`/`ScreenDrag` for drags. The macOS
host window's bottom ~30 px dead band and the drag threshold are handled the same way the
committed probes handle them (strip targets scrolled above the band; drags ≥ 120 px). The
fresh worktree needed Godot's import cache (`game/.godot`) copied from the main checkout
before the global script classes resolved. Probes were copied into `game/` for the runs and
removed afterwards.

## Non-blocking marks

- The story-id debug overlay text overlaps the R1 title in the captures (`story: portrait`
  / `story: landscape`) — the seams overlay pilot from `set_story_ids`, not game chrome.
- Both runs' end-of-session S5 dump resolves to the same `state-attempt.json` name, so each
  run's copy is renamed (`state-portrait.json` / `state-landscape.json`); both are on the
  wiki page. In R2 the dumps' attempt fields are null — no attempt is open from a scroll,
  which P5 asserts.
- The seeded `Completed 1 / 200` counter and `pack-003`'s `Done · In progress` / `Best 1:01`
  copy are the seed, not shipped-pack state.
- Fresh `pack-002` at 640×360 draws one neighbour gap 16.41 px and no reserve strip; its
  thumbs keep the mockup shape (only `.meta` takes the 12 px padding).

## Blockers

None.
