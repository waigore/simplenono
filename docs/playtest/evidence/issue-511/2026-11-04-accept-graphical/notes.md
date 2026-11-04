# Notes — issue #511 acceptance playtest

## What was judged

`PTU-settings` in full against the built mobile Settings screen carrying `UI-settings.C4`:

1. **S1 / P1** — gallery → settings, the `R1` row set (`C1`, `C2`, `C4`, then `C3` Back), Back returns.
2. **S2 / S3 / P2** — C1 toggles and the choice sticks when settings re-opens.
3. **S4 / P3** — C4 shows Portrait, activating it asks for and applies Landscape at once, no relaunch, screen stays on Settings.
4. **S5 / P4** — force-quit, relaunch, the stored Landscape is restored and locked; tilt both ways does not rotate it or lose it.

## How it was driven

`probe/probe_accept_511.gd` boots the shipped `shell.tscn` at 900×1200 under Xvfb, on a fresh
`$HOME` so `user://orientation.cfg` starts absent. It drives the real screen methods
(`open_settings`, `activate_haptics`, `activate_orientation`, `back_from_input`) and reads the
screen's own copy and control order.

On a desktop host `OS.get_name()` is not a mobile platform, so the C4 branch would be off. The
probe sets `OrientationLock.mobile = true` and records `DisplayServer.screen_set_orientation`
through `OrientationLock.platform_orientation` — the same two seams `game/test/test_settings*.gd`
use — so it observes the exact value the iOS/Android build asks for.

Result: **40 checks passed, 0 failed**, 5 shots, exit 0.

**Full suite on the same tree:** GUT `game/test` 356 tests, 356 passing.

## Tilt

The app never reads a device tilt: no presentation code or project line asks for
`SCREEN_SENSOR*`. The probe turns the root viewport by −90° and then +90°, four frames each, then
upright. The display frame is byte-identical to the pre-tilt frame and the stored/held values are
unchanged, so a tilt neither rotates nor loses the choice.

## Device caveat

A phone re-run of S5 would confirm the platform orientation call end to end. This graphical run
proves the app asks for the right fixed orientation on every path and never for a sensor one.

## Reproduce

```sh
cp docs/playtest/evidence/issue-511/probe/probe_accept_511.gd game/
HOME=<fresh-home> xvfb-run -a -s "-screen 0 1000x1300x24" \
    godot --path game -s res://probe_accept_511.gd -- --debug-seams \
    --session-id=issue-511-accept --build-id=main@51dfe86 \
    --shot-dir=<run>/screenshots --run-folder=<run>
```
