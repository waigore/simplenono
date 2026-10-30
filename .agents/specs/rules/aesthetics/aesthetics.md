# Authoring rules: aesthetics

Read this before editing `specs/aesthetics/aesthetics.md`. Do not copy these rules into the spec.

Every other file under `specs/aesthetics/` follows **Rules for every aesthetics spec** below. Those rules files name this one under **Also read**.

The aesthetics state the game's style: how it looks and sounds. They cover the medium, style pillars, palette, form, surface and light, animation style, interface style, and sound style. Every asset is judged against them. They are downstream of `specs/vision.md`, `specs/definition/definition.md`, `specs/definition/quality.md`, `specs/design/design.md` (especially `experience.md`), and `specs/view/view.md`. `specs/ux/` and `specs/assets/` are downstream of them. If the aesthetics conflict with an upstream document, change the aesthetics, or revise the upstream document first.

## Rules for every aesthetics spec

- **Realizes intent, does not change it**: `specs/design/experience.md` states mood, sensory intent, feedback principles, and clarity rules. The view states readability guarantees, depth cues, and sense of scale. The aesthetics give them a concrete style. A style element must not break a clarity rule, a feedback principle, or a readability guarantee (`PER.R`), and must not reveal or conceal state against the design's hidden and visible state (`GS.H`). When they disagree, the upstream spec wins.
- **Derived**: every element states what it serves: a vision quality, a definition item (platform, constraint, engine implication), a quality category, or a design or view spec. Taste alone is not a ground. A pillar is the ground for a taste choice.
- **Checkable**: state style as values and tests a reviewer can apply to a single asset: hex colors, ratios, counts, sizes in art pixels or world units, frame rates, loudness ranges, and "conforms if…" tests. An adjective needs a test beside it.
- **Style, not production**: no asset lists, file names, budgets, tools, prompts, or file formats. Those live in `specs/assets/`. No engine, renderer, shader, or product names. A limit imposed by an architecture decision is stated in style terms and cites its ID, such as `(ADR-0003)`.
- **Not interface layout**: screens, regions, controls, and copy live in `specs/ux/`. This folder states how the interface looks, not what it holds or how it is operated.
- **Shared language**: define each style term once in `glossary.md`. Game terms stay in `specs/design/glossary.md`, view terms in `specs/view/glossary.md`, and UI terms in `specs/ux/glossary.md`. Link characters, entities, and stages. Do not redefine them.
- **Traceable**: every spec states what it serves. `traceability.md` maps all of them.
- **Identified**: every style element has a stable ID per [ids.md](ids.md), so asset specs, reviews, and catalog records can cite it.
- **Shown**: reference sheets under `sheets/` per [sheets.md](sheets.md), as spec depth requires.
- **Topics that do not apply**: when a section does not apply (no sound, nothing animates), write "N/A — reason" grounded in the definition, design, or view. Do not delete the section.
- **Concise**: each Markdown file stays under 500 words. Sheets and reference images are exempt. Split by logical unit and link. The type's own rules file says where to move the extra part.

## Medium

- **Medium**: the visual medium, such as pixel art, hand-drawn 2D, vector, low-poly 3D, stylized 3D, or realistic 3D. Ground it in the view's rendered space and the definition's engine implications.
- **Resolution and scale**: for pixel art, the size of one art pixel in world units and in screen pixels, citing `SPC.U` and `PRJ.X`. For other 2D, the art's reference resolution relative to the frame. For 3D, the detail scale (such as texture detail per world unit) in style terms.
- **Platform implications**: for each supported platform in the definition, the effect on style. Shape: "Phone → silhouettes read at 1/12 of frame height." No hardware model names.

## Style pillars

`P1`, `P2`, …: at most five, in priority order. When pillars conflict, the higher one wins. Each row has a name, a one-line description, a "conforms if…" test a reviewer can apply to one asset, and what it serves. Each pillar traces to a vision quality or to the sensory intent in `experience.md`.

## Content limits

What the art and sound must not show or imply, grounded in the definition's market constraints (age rating, store policy, regions) and the vision's non-goals. Write "None — reason" when there are none.

## Variation

How the style varies across stages, factions, progression, or time: one row per axis. Columns: axis, what varies, what stays fixed, and the palette sets, form, surface, or sound elements that realize it. Write "None — one style throughout" when it does not vary.

## Index

Keep the global-spec list. List each sheet under **Sheets**. When spec depth requires no sheet, write "None — spec depth \<level\>", per [depth.md](../depth.md).

If the index pushes `aesthetics.md` past 500 words, move it to `specs/aesthetics/index.md` and leave a link.
