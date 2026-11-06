# Notes — issue #692, `2026-11-06-accept-graphical`

## What was judged

The shipped gallery, driven through the real shell under Xvfb, fresh `user://`:

- `PTU-gallery-layout` P1 / P2 / P4 — the tile fits the frame, the column count
  follows the frame, and the thumb stays a square.
- The star itself: `PER.R7` / `UIS.I1` / `US1.8` — Gold, sized from the thumb, flat
  five-point, at the thumb's upper-left.
- `PTU-gallery-reset` P2 — Confirm clears hint-free, so the star goes with it.

Two frames: 900×1200 (narrow, two columns) and 1080×900 (wide, four columns).

## Star sampling

The probe reads the drawn frame and counts pixels matching `PresentationPalette.GOLD`
inside a block anchored at the thumb square's upper-left plus the held inset:

| Frame | Thumb side | Star side | Inset | Gold px in block | Reading |
|-------|-----------|-----------|-------|------------------|---------|
| 900×1200 narrow | 404 | 51.0 (1/8) | 10.2 (1/40) | 687 / 3721 | Gold star drawn, larger than the old 12 px |
| 1080×900 wide | 237 | 14.9 (1/16) | 6.0 | 62 / 400 | Gold star drawn, near today's 14 px |
| after reset | 237 | — | — | 0 / 400 | no star; tile `Not started` |

The block's pixel map is a flat five-point star: a wide horizontal bar with two upper
points and two lower legs, no glow or sparkle. The star is drawn over the stored
picture, so the block also holds picture pixels; only the Gold match is counted.

## Harness caveats (probe-side, not product)

- **Seeded state.** The probe seeds a completed, hint-free puzzle through `CTR-pack`
  O6 (`record_solve`) instead of a 39-fill clean solve. The deliverable is the star's
  look and size; earning hint-free is #654's accepted scope.
- **Scroll into view.** pack-004 is below the fold at both frames. The probe scrolls
  with `ScrollContainer.ensure_control_visible` before sampling; that is a scroll, not
  a layout change, and the held star metrics come from the gallery either way.
- **Ratio rounding.** The gallery sizes the star from the tile width (408 px at
  900×1200), while the thumb's drawn square is 404 px after the tile border. The
  0.5 px difference is within the spec's "about 20 px / 16 px" and the issue AC.
- **P1 scope.** P1 bars clipping at a window edge. The grid scrolls, so a card below
  the fold is expected; the probe checks horizontal fit, not that every card is
  on-screen.

## Non-blocking observations

- The star ratio follows the column count (`columns() >= WIDE_COLUMNS`), so a wide
  frame that drops to three columns (e.g. 640×360) uses the narrow 1/8 ratio. This
  matches the spec's "narrow frames" intent (fewer columns = narrower tile) but is not
  covered by a test; a future test could pin it. Verification noted the same.

## Hygiene

- The probe was copied to `game/probe_accept_692.gd` for the run and removed after;
  the `game/` tree was verified unchanged (`git status` clean under `game/`) before the
  evidence branch.
- Local user data written by the run (`user://progress.cfg`) lives outside the repo.
