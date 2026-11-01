# Notes — issue #95 graphical acceptance

## What was judged

Build `a0e6e3a` (`main` HEAD), run through the real `shell.tscn` with its real screens, real
controls, and real engine frames. The probe drove player-facing controls (`Button.pressed` on the
gallery's `Settings`, the settings toggles, Back, and the gallery tile's `Open`) and `DBG.3`
(`finish_ready_beat`, the pack definition's solution) where the protocol allows a jump. It never
called `Shell` routing directly, except to reset `pack-000` before the play so the gallery start
state was `Not started`.

## `PTU-settings` — pass

All three steps behaved:

- `S1` the gallery's C3 (`Settings`) opened `UI-settings` through `NAV.T2`.
- `S2` C1 flipped `haptics` and C2 flipped `mute_bgm` on the one `SCH-preferences` source, and the
  labels followed (`Haptics On → Off`, `Mute music Off → On`).
- `S3` C3 returned to `UI-gallery` (`NAV.T6`); reopening showed `Off` and `On` still set, so the
  session-scoped values stuck across the round trip.

`P1` and `P2` both hold; `F1` and `F2` did not occur. The layout matches the approved
`MC.settings-mobile` / `MC.settings-desktop` rows: title, two options with their hint lines, the on
state inverted to ink, Back below.

## `PTU-play-puzzle` — P1 pass, P2 judged state fails

`P1` holds: gallery → puzzle → result → gallery completes, and the morph now spends both stages
(560.8 ms measured across 69 real frames against `2 × CFG.MORPH_STAGE_MS` = 600 ms, within frame
quantisation). The ever-completed part of `P2` also holds — `#000` reads `Done`, `Best 0:00`,
`Completed 1 / 200`.

The judged **result** state does not. At `S1 Default` the screen is empty paper with only the
`Back to gallery` button:

- `UI-result` R1 is *"Visible when: Always on this screen"*, and it shows nothing at `S1`.
- `UI-result` S1 says the actor sees the generated picture; they see a blank.
- The approved mockup's `default` state draws a picture.
- `PER.R5`, `MOT.E1`, `MOT.E2` name this as the win reveal; the build ends the win on an empty screen.

## Why it happens (and why it is not "assets pending")

`Shell._picture_for()` resolves the definition's two picture ids through the manifest and gets `null`
for both, because the ids are simply not in `assets/manifest.json`. `ResultMorphSlot.show_picture(null)`
paints nothing, and `ResultReveal._apply_frames()` at `S1` sets the picture layer to `1.0` while the
fills and pixel layers go to `0.0`. Every visible layer is therefore empty at the end of the morph.

A build with no assets still has a correct fallback available — finish on the picture that *is* in the
build (the pixel picture, or the solved fills) — and the mockup shows the screen is never meant to be
blank. So the defect is in the `S1` fallback, not in #98's asset delivery. It is filed against #95's
deliverable, which is the result screen and its morph.

## Non-blocking marks

- **Three screenshot pairs are byte-identical** (`p0`/`p1`, `p2`/`p4`, `p3`/`p5`). Each pair is a
  deliberate before/after of a state that is the same on both sides (settings defaults before the
  toggle; the toggled values after reopen; the gallery before play and after the settings round trip),
  so identical images are the correct result, not a stale capture. `p0` and `p1` were checked by eye:
  both show `Haptics On` / `Mute music Off`.
- **`p7`/`p8` are byte-identical** for the same reason: `marks_allowed()` is the only thing changing
  between them and it is not drawn, so the two frames are the same mid-solve grid.
- **The gallery tiles all share one thumbnail motif.** This is #94's gallery and #98's pictures, not
  this epic's deliverable.
- No instrumentation ever reached telemetry: the probe took no session id, so `TEL.1`–`TEL.5`
  correlation for this run is the probe log itself. The deterministic record's `navigate`/`ui-ack`
  logs cover the same screens with telemetry.
