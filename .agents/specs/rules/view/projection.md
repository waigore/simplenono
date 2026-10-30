# Authoring rules: projection

Read this before editing `specs/view/projection.md` or a section split from it. Do not copy these rules into the spec.

Also read [view.md](view.md), [ids.md](ids.md), and [diagrams.md](diagrams.md). Stories follow [story.md](story.md).

How world space becomes the image on the player's display, and how much of the world the player sees. Cameras choose a projection from this file by ID.

## Header

- **Diagram**: `diagrams/projection.html`. Follow [diagrams.md](diagrams.md). When spec depth requires no diagram, write "None — spec depth \<level\>", per [depth.md](../depth.md).

## Sections

- **Projections**: `P1`, `P2`, …. One row per projection used. Columns: type (perspective, orthographic, isometric, dimetric, oblique, or other), parameters (vertical field of view in degrees for perspective; visible height in units for orthographic; axis angles for isometric, dimetric, or oblique), and where it is used (cameras, or "all").
- **Visible area**: `V1`, `V2`, …. The minimum and maximum world extent visible in units, per platform when they differ. For perspective, state it at a named reference distance from the camera.
- **Aspect and safe area**: `A1`, `A2`, …. The supported aspect-ratio range, what happens outside it (extend the view, crop, or bars), and the safe area as a fraction of the frame where nothing essential is placed.
- **Pixel scale**: `X1`, `X2`, …. For pixel art: pixels per unit, whether scaling is whole-number only, and what happens at resolutions that do not divide evenly. Otherwise "N/A — reason".
- **Visibility limits**: `D1`, `D2`, …. Draw distance, fade or fog distances in units, and what is never hidden by them. A limit agrees with the design's hidden and visible state.

## Splitting

If the file passes 500 words, move visibility limits to `projection/visibility.md`. Leave a summary and a link, and update `view.md`.
