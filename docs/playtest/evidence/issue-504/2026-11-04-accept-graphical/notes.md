# Notes — issue #504 acceptance playtest

## What was judged

#504 adds the mobile orientation lock and the durable F3 value. The running app carries no Settings
control (`UI-settings.C4` is #511), so the judged protocols are the mobile lock alone:

1. **`PTU-settings` S4** — a mobile build's framing. `C4` is absent from this build by design.
2. **`PTU-settings` S5** — force-quit, relaunch, and tilt the device both ways.
3. **`PTU-settings` P4 / F3** — the stored choice survives the relaunch and a tilt does not rotate it.

`PTU-settings` P3 judges `C4` and is out of scope; everything else in
[`specs/playtest/coverage.md`](../../../../../specs/playtest/coverage.md) is out of reach of the lock.

## How it was driven

`probe/probe_accept_504.gd` boots the shipped `shell.tscn` at 900×1200 under Xvfb. Each relaunch is
a new `Shell` from that scene — the state a device cold start reaches before its first screen —
with its own `orientation_path` and `progress_path` under an isolated `HOME`. The stored choice is
written directly, as a build without the control leaves it.

On a desktop host `OS.get_name()` is not a mobile platform, so the app's launch call returns before
`DisplayServer.screen_set_orientation`. The probe reads `OrientationLock` back from the shell and
applies the same instance once more with `platform_orientation` recording instead of calling, which
records the exact value the shell computed. The build's own exported lock is read from
`ProjectSettings` (`display/window/handheld/orientation=1`, Portrait), which the Android and iOS
exporters map to `android:screenOrientation` and `UISupportedInterfaceOrientations`.

Result: **29 checks passed, 0 failed**, 6 shots, exit 0.

## Tilt

The app never reads a device tilt: no presentation code or project line asks for `SCREEN_SENSOR`,
`SCREEN_SENSOR_LANDSCAPE`, or `SCREEN_SENSOR_PORTRAIT` (the probe scans `project.godot` and
`game/presentation/*.gd` code lines, leaving comments aside). The probe turns the root
viewport by −90° and then +90° for four frames each, then upright:

- no lock call is made by either tilt;
- the held F3 value stays `landscape`;
- the stored value stays `landscape`;
- the display frame is byte-identical to the pre-tilt frame.

## Observations (non-blocking)

- **Rotated shots.** The `04-tilt-left` and `05-tilt-right` captures show the turned viewport
  (a rotated rendering), not the display frame. They are in the log as evidence of the turn and are
  not kept as judged states on the wiki.- **Project file rewrite.** Running `godot --import` once in `game/` made the editor rewrite
  `game/project.godot` (formatting, comment removal). It was restored with `git checkout`; the run
  makes no `game/` change.
- **Phone confirmation.** A device re-run of S5 would confirm the platform call end to end. This run
  proves the requested orientation on every launch path.

## Reproduce

```sh
cp docs/playtest/evidence/issue-504/probe/probe_accept_504.gd game/
HOME=<fresh-home> xvfb-run -a -s "-screen 0 1000x1300x24" \
    godot --path game -s res://probe_accept_504.gd -- --debug-seams \
    --session-id=issue-504-accept --build-id=main@9c322b5 \
    --shot-dir=<run>/screenshots --run-folder=<run>
rm game/probe_accept_504.gd game/probe_accept_504.gd.uid
```
