# Notes — issue #654, `2026-11-06-accept-graphical`

## What was judged

The shipped screens, driven through real pointer events under Xvfb at the mobile
mockup frame, 900×1200, fresh `user://`:

- `PTD-solve-and-pb` S4 / P4 / F3 — earnings, void-on-enable (including an enable that
  was never used), re-earn, and reset-clear.
- `PTU-gallery-reset` S1–S3 / P1–P2 — Cancel keeps, Confirm clears hint-free with the
  rest, the tile returns to Default.
- The star itself: `PER.R7` / `UIS.I1` / `US1.8` placement and look.

The 39-fill clean solves were done with real left clicks on `PuzzleCell` rects, not by
calling `Attempt.mark`. The hint enable went through `Shell.set_hint_single_line`, the
same entry point the `UI-settings` `C5`–`C7` chrome calls (that chrome is sibling #651).

## Star sampling

The probe reads the drawn frame and counts pixels matching `PresentationPalette.INK`
inside a 20×20 block anchored at the thumb square's upper-left plus the held
`(inset, size)` metrics:

| State | Ink px in block | Reading |
|-------|-----------------|---------|
| Clean solve, star earned | 18 / 400 | star drawn, `UIS.I1` size 14, inset 6 at 900 px |
| After enable-void | 0 / 400 | no star |
| After unused-enable solve | 0 (tile `shows_star()` false) | no star |
| After reset | 0 / 400 | no star, tile `Not started` |

`PresentationPalette.INK` is dark and the thumb is Paper, so a non-star text glyph
inside that 20×20 block would also count; the block sits on the picture region's
upper-left corner, which holds no copy.

## Harness caveats (probe-side, not product)

- **Scroll into view.** pack-004 is tile index 4, below the fold at 900×1200. Sampling
  needs the thumb inside the frame, so the probe scrolls with
  `ScrollContainer.ensure_control_visible` before each pixel read. The gallery's held
  star metrics are unaffected by scrolling.
- **Gallery settle.** After the shell returns to the gallery it re-reads O1 and rebuilds
  the tiles. The probe settles 3 frames before reading `entries()` / sampling. Two
  earlier probe builds read one frame too early and saw the pre-solve entry; that was a
  probe race. The settled reads were correct on every re-run.
- **Result C1.** `UI-result.C1` is inert while the morph runs (`US1.3`). The probe calls
  `ResultScreen.finish_morph()`, confirms `can_go_back()`, then presses through
  `Shell.back_from_input()` — the `IN.back` route the screen exposes.

## Non-blocking observations

None. Every check that judged a protocol outcome passed on the final run; the only
failures seen during the session were the probe caveats above, fixed before the run
recorded in `manifest.md`.

## Hygiene

- The probe was copied to `game/probe_accept_654.gd` for the run and removed after; the
  `game/` tree was verified unchanged (`git status` clean under `game/`) before the
  evidence branch.
- Local user data written by the run (`user://progress.cfg`) and by the GUT suite lives
  outside the repo.
