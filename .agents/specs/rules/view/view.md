# Authoring rules: view

Read this before editing `specs/view/view.md`. Do not copy these rules into the spec.

Every other file under `specs/view/` follows **Rules for every view spec** below. Those rules files name this one under **Also read**.

The view states how the player is placed in the game world and how that world is seen, heard, and felt: dimensionality, space and positioning, projection, cameras and their controls, physical feel of motion, perception and comfort, spatial audio, and haptics. It is downstream of `specs/vision.md`, `specs/definition/definition.md`, `specs/definition/quality.md`, and `specs/design/design.md`. `specs/ux/` is downstream of it. If the view conflicts with an upstream document, change the view, or revise the upstream document first.

## Rules for every view spec

- **Realizes the design, does not change it**: the design states what happens in play. The view states how it is seen, heard, and felt, and how motion feels. A view element must not change whether a design outcome occurs. When a needed behavior changes an outcome (such as extra time to jump after leaving a ledge), add the rule to the design first, then realize it here. When the design and the view disagree, the design wins.
- **Knowledge preserved**: what the player can see, hear, or feel agrees with the design's hidden and visible state (`GS.H`). Visibility limits, occlusion, and audio never reveal hidden state, and never conceal state the design says the player can know.
- **Concrete**: state values in world units, degrees, seconds, and fractions of the frame. A design parameter is cited by name from `configuration.md`, never restated. View values that are not design parameters are written in the view spec that owns them.
- **No technology**: no engine, framework, editor, API, or file-format names, and no node or component settings. Axis conventions and units are allowed. A limit imposed by an architecture decision is stated in view terms and cites its ID, such as `(ADR-0003)`.
- **Not interface**: menus, HUD, screens, and input bindings live under `specs/ux/`. Camera actions are defined here and bound in `specs/ux/controls.md`. A comfort or camera setting is defined here, and the screen that changes it lives in the UX.
- **Shared language**: define each view term once in `glossary.md`. Game terms stay in `specs/design/glossary.md`. UI terms stay in `specs/ux/glossary.md`. Link characters and entities. Do not redefine them.
- **Traceable**: every spec states which vision qualities, definition scope items, and design specs it serves. `traceability.md` maps all of them.
- **Identified and proven**: every behavior-defining element has a stable ID per [ids.md](ids.md) and is proven by Given/When/Then view stories per [stories.md](stories.md) and [story-coverage.md](story-coverage.md).
- **Shown**: every camera and the projection have an HTML diagram under `diagrams/`, per [diagrams.md](diagrams.md).
- **Non-spatial games**: when a section does not apply (for example, a game with no world space), write "N/A — reason" grounded in the design profile or the definition. Do not delete the section.
- **Concise**: each Markdown file stays under 500 words. Diagrams are exempt. Split by logical unit and link. The type's own rules file says where to move the extra part.

## Dimensionality

- **Gameplay space**: the dimensions in which positions and movement are resolved: none, 2D, 2.5D (2D play with limited depth, such as lanes), or 3D. Name the axes play uses.
- **Rendered space**: how the world is drawn: 2D, 3D, or mixed (such as 3D models on a 2D play plane). State any mismatch with gameplay space and what it means for the player.

## Embodiment

- **Viewpoint**: first person, third person, top-down, side-on, isometric, fixed board, or other. When it changes by flow or stage, list each and link the camera.
- **Player presence**: what represents the player in the world (an avatar, a cursor, a vehicle, or nothing), and where the player's attention is anchored.

## Platform implications

For each platform in the definition, the effect on the view. Shape: "Phone in portrait → visible area is at least 9 units wide." No hardware model names.

## Index

Keep the global-spec list. For a camera, copy `cameras/_template.md` to `cameras/<kebab-name>.md`, fill the copy, and add the link under Cameras. Leave `_template.md` unchanged. When there is no camera, write "None — reason".

If the index pushes `view.md` past 500 words, move it to `specs/view/index.md` and leave a link.
