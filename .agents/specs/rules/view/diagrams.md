# Authoring rules: view diagrams

Read this before editing `specs/view/diagrams/projection.html`, `specs/view/diagrams/cameras/_template.html`, or `specs/view/diagrams/cameras/<name>.html`. Do not copy these rules into the HTML.

Also read [view.md](view.md), [projection.md](projection.md), and [cameras.md](cameras.md).

Diagrams let a reader see the frame, the projection, and the camera geometry the specs state. They are views of the spec, not art direction. When a diagram and its spec disagree, the spec wins and the diagram changes. HTML under `specs/view/diagrams/` is exempt from the 500-word limit.

## Files

Which diagrams exist follows spec depth, per [depth.md](../depth.md).

- **Projection**: fill `diagrams/projection.html` in place. It is a global diagram, like `projection.md`.
- **Camera**: copy `diagrams/cameras/_template.html` to `diagrams/cameras/<kebab-name>.html`, one per camera spec. Do not fill the template in place. Delete the template comment from the copy.

## What a diagram contains

- One self-contained HTML file with inline SVG. No scripts, no external assets, no external fonts.
- Drawn to scale. A scale bar states how many world units it spans, and the axes from `SPC.A` are labelled.
- A projection diagram shows each `PRJ.P` with its field of view or visible height, the visible area at the reference distance, the supported aspect range, and the safe area.
- A camera diagram shows the frame, the target and its resting position, the offset, the dead zone, lookahead, and limits. For a 3D camera, draw a side view and a top view.
- Each drawn element carries `data-element` with its ID (such as `F1` or `PRJ.V1`) and a visible label with the same ID.
- The diagram adds no element and no value the spec does not state.
