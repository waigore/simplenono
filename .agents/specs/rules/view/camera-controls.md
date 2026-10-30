# Authoring rules: camera controls

Read this before editing `specs/view/camera-controls.md`. Do not copy these rules into the spec.

Also read [view.md](view.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

The commands the player uses to move the camera, and the player's camera settings. Inputs are bound to these actions in `specs/ux/controls.md`. Each camera states which actions it accepts and their effect there.

## Camera actions

The skeleton defines `CC.orbit`, `CC.look`, `CC.zoom`, and `CC.recenter`. Delete an action this game does not use. Add a row for an action it needs. When the player never controls the camera, delete every row and write "None — reason".

Columns: ID, action name, and meaning (what changes, in which direction, independent of input device).

Every action is accepted by at least one camera. Every action has a binding in `specs/ux/controls.md` on each primary platform.

## Settings

`S1`, `S2`, …. Player-adjustable camera settings, such as invert vertical, sensitivity, or auto-recenter delay. Columns: setting, what it changes (cite the action or camera element), choices or range with units, and default. Write "None" when there are none. Comfort settings live in `perception.md`.
