# Notes — issue #95 graphical acceptance

## What was judged

Build `a0e6e3a` (`main` HEAD), run through the real `shell.tscn` with its real screens, real
controls, and real engine frames. The probe drove player-facing controls (`Button.pressed` on the
gallery's `Settings`, the settings toggles, Back, and the gallery tile's `Open`) and `DBG.3`
(`finish_ready_beat`, the pack definition's solution) where the protocol allows a jump. It never
called `Shell` routing directly, except to reset `pack-000` before the play so the gallery start
state was `Not started`.

## `PTU-settings` — pass

C3 (`Settings`) opened `UI-settings` through `NAV.T2`. `S2` flipped `haptics` and `mute_bgm` on the
one `SCH-preferences` source and the labels followed
(`Haptics On → Off`, `Mute music Off → On`); `S3` returned via `NAV.T6` and reopening showed `Off` and
`On` still set, so the session-scoped values stuck across the round trip. `F1` and `F2` did not occur.
The layout matches `MC.settings-mobile` / `MC.settings-desktop`: title, two options with their hint
lines, the on state inverted to ink, Back below.

## `PTU-play-puzzle` — P1 pass, P2 judged state fails

`P1` holds and the morph spends both stages (560.8 ms over 69 real frames against
`2 × CFG.MORPH_STAGE_MS` = 600 ms, within frame quantisation). `P2`'s ever-completed half also holds —
`#000` reads `Done`, `Best 0:00`, `Completed 1 / 200`. Its judged **result** state does not: at
`S1 Default` the screen is empty paper with only `Back to gallery`, contradicting `UI-result` R1 and
S1, the approved mockup, and the `PER.R5` / `MOT.E1` / `MOT.E2` win reveal. The claim-by-claim
comparison and the root cause are in [`failure.md`](failure.md).

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
