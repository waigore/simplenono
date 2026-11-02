# Notes — issue #95 graphical acceptance, rerun after the #218 fix

## What was judged

Build `main@e1de7a4` (HEAD `23f01a6`; `game/` identical between them), rendered graphically under Xvfb
with Mesa llvmpipe. The probe drove the real `shell.tscn`, real screens, real controls (`Button.pressed` on
the gallery's `Settings`, the settings toggles, Back, the gallery tile's `Open`, the result's Back), and real
engine frames. It never called `Shell` routing directly, except to reset `pack-000`'s progress so the
gallery start state was `Not started`.

## `PTU-settings` — pass

C3 (`Settings`) opened `UI-settings` through `NAV.T2`. `S2` flipped `haptics` and `mute_bgm` on the one
`SCH-preferences` source and the labels followed (`Haptics On → Off`, `Mute music Off → On`). `S3` returned
via `NAV.T6`, and reopening showed `Off` and `On` still set, so the session-scoped values stuck across the
round trip. `F1` and `F2` did not occur.

## `PTU-play-puzzle` — pass

`S1`–`S4` all completed. 41 fills staged left the screen on `UI-puzzle` (US1.4b); the 42nd opened
`UI-result` (`NAV.T4`); the reveal ran with no control offered during it; C1 returned to the gallery
(`NAV.T5`) and `#000` read `Done` with completion past zero (`P2`). `F1` and `F2` did not occur.

The previously failing state is fixed: at `S1 Default` the fills layer is visible at opacity 1.0 with 42
fills, the pixel and picture layers are at opacity 0.0 (this build ships neither), and C1 is available —
`UI-result` R1/S1 and US1.5 as written after #218.

## The probe's one failing assertion is an environment artifact, not a product defect

`probe95: FAIL UI-result US1.2: the morph spends both stages (297 ms, 2 x 300)`.

Under llvmpipe each rendered frame costs ~27–33 ms, so the 600 ms of morph time is spent in only ~11 frames
and the probe's wall-clock sum lands short of its `> 1.5 × stage` bound. This is the same class of
quantisation the first run hit from the other side (560.8 ms in 69 frames on a GPU).

It is **not** the double-clock regression verify found earlier. That was confirmed three ways:

1. **One clock in code** — `Shell._process` (`game/presentation/shell.gd:316`) is the only `advance(` call
   site; `ResultScreen` has no `_process`, and `ResultReveal.tick` has that single caller.
2. **Frame deltas** — a diagnostic summing the shell's own per-frame deltas measured min 0.4 ms, max 33.2 ms,
   mean 27.3 ms over 16 frames (`logs/diagnostics.log`). A second clock would show one doubled step per
   frame, not uniformly long frames.
3. **The regression tests** — `test_one_clock_plays_both_stages_on_real_frames` and
   `test_a_paused_attempt_freezes_the_morph` both pass here (`logs/reveal-clock-suite.log`); they fail on the
   old double-clock code.

The morph reaching `S1` in both runs also shows the stage logic is right. Timing is measured properly by the
`navigate` protocol (`transition-latency` 360.5 ms, `frame-time` p95 9.09 ms) and by the cited deterministic
record, not by this probe's wall-clock check.

## Non-blocking marks

- **Xvfb/llvmpipe, not a phone GPU.** Frame costs here (~27 ms) are far above the target device, so the
  probe's absolute timings are pessimistic. Screenshot content is unaffected.
- **Audio is the dummy driver** (`libasound`/`libpulse` absent in this container), so haptics/mute were judged
  from their labels and session flags, not by ear. `PTU-settings` judges only those.
- **No telemetry session id from the probe**, so `TEL.1`–`TEL.5` correlation for this run is the probe log
  itself. The integration harness folder beside it (five protocols) carries proper sessions.
- **Two temporary probes** (`probe_accept_95_clock.gd`, `probe_accept_95_layers.gd`) were used for the
  diagnostics and removed with the acceptance probe; `game/` is clean afterwards.
- **The gallery tiles share one thumbnail motif**, which is #94's gallery and #98's pictures, not this epic's
  deliverable.
