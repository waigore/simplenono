# Authoring rules: spatial model

Read this before editing `specs/view/spatial-model.md` or a section split from it. Do not copy these rules into the spec.

Also read [view.md](view.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

How space is measured and how every object is positioned in it. Stage layouts in `specs/design/stages/` describe regions in game terms. This file states the frame those regions are measured in.

Write "N/A — reason" in each section when the game has no world space.

## Sections

- **Coordinate frame**: `A1`, `A2`, …. The axes play uses and what each points toward (for example, x to the player's right, y up, z toward the viewer), the up direction, handedness for 3D, and where the origin lies (per stage, or per world). Angles: which direction is 0° and which way is positive.
- **Units and scale**: `U1`, `U2`, …. What one world unit means in game terms (for example, "1 unit = 1 tile" or "1 unit = 1 meter; the avatar is 1.8 units tall"), and any reference sizes the player uses to judge distance. Time unit for rates (per second).
- **Placement**: `P1`, `P2`, …. How a position is stated and resolved: continuous or snapped to a grid (cell size), ground alignment, how facing is set, and what may share a position. A placement that changes play (for example, two objects may not overlap) cites the design rule.
- **Object extents**: `E1`, `E2`, …. One row per character or entity with a body in space. Columns: link, extent (width × height, or × depth in 3D) in units, anchor point (for example, feet center), and facing rule. Collision shapes live in `physics.md`.
- **Layers and depth**: `L1`, `L2`, …. In list order from farthest to nearest. Columns: layer, what it holds, how depth is ordered within it (fixed, by y, by distance), and a parallax factor relative to camera motion (1 for the play layer). For pure 3D, state only overlays and sorting exceptions.
- **Bounds**: `B1`, `B2`, …. The extent of each stage's space in units, or a rule for computing it, and what the edge is. When the edge changes play (wall, wrap, fall-out), cite the design rule.

## Splitting

If the file passes 500 words, move object extents to `spatial-model/extents.md`. Leave a summary and a link, and update `view.md`.
