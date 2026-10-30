# Authoring rules: camera

Read this before editing `specs/view/cameras/_template.md` or `specs/view/cameras/<name>.md`. Do not copy these rules into the spec.

Also read [view.md](view.md), [ids.md](ids.md), and [diagrams.md](diagrams.md). Stories follow [story.md](story.md).

Copy the template to `cameras/<kebab-name>.md`, one file per camera mode. Do not fill the template in place.

A camera mode is one way the view is positioned and moved: follow, fixed, rail, free, first person, third person, orbit, cinematic, or other. Every camera is used by some flow phase or stage.

## Header

- **Kind**: one of the kinds above.
- **Used in**: the flow phases and stages that use it, as design IDs.
- **Projection**: a `PRJ.P` ID.
- **Diagram**: `diagrams/cameras/<kebab-name>.html`. Follow [diagrams.md](diagrams.md). When spec depth requires no diagram for this camera, write "None — spec depth \<level\>", per [depth.md](../depth.md).
- **Serves**: vision qualities, definition scope items, and design specs.
- **Glossary terms**: links into `glossary.md`.

## Sections

- **Framing**: `F1`, `F2`, …. What the camera tracks, the offset from the target in units, the target's resting position as a fraction of the frame, the dead zone, and lookahead (distance in units, and in which direction).
- **Motion**: `M1`, `M2`, …. How the camera follows: the time to settle within a stated tolerance after the target stops, maximum speed or turn rate, and what it does on vertical motion (for example, holds height until landing).
- **Limits**: `L1`, `L2`, …. Bounds the camera stays inside (stage bounds, or a cited `SPC.B`), pitch and yaw limits in degrees, zoom or distance range in units.
- **Occlusion**: `O1`, `O2`, …. When scenery blocks the target: move closer, fade the blocker, show an outline, or none. How it recovers.
- **Transitions**: `T1`, `T2`, …. To or from another camera: the trigger (a design event, a flow transition, or a camera action), cut or blend, the duration in seconds, and what carries over (facing, distance).
- **Effects**: `E1`, `E2`, …. Shake, zoom punch, tilt, or other: the trigger (a design or view event), magnitude in units or degrees, duration, and the `PER.M` comfort option that reduces or disables it.
- **Player control**: `P1`, `P2`, …. Each camera action (`CC.<name>`) this camera accepts, and its effect here (rate, range, recentering). Write "None" when the player cannot move this camera.
- **Experience intent**: what this view should make the player feel. Intent only. No ID.
