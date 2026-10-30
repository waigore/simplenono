# Reviewing `specs/view/`

Instructions for agents reviewing the view specs ([`specs/view/view.md`](../../specs/view/view.md) and every file under [`specs/view/`](../../specs/view/)). Authoring rules for each file are in [`rules/README.md`](rules/README.md). Follow [`alignment.md`](alignment.md). The spec links that file and does not contain the rules. Read [`specs/vision.md`](../../specs/vision.md), [`specs/definition/definition.md`](../../specs/definition/definition.md), [`specs/definition/quality.md`](../../specs/definition/quality.md), [`specs/design/design.md`](../../specs/design/design.md), and [`specs/design/experience.md`](../../specs/design/experience.md) first. When a view file cites a design element, read that design spec. A review may cover the whole view or named files. Cross-spec checks always consider the whole view. Skip `_template.md` and `_template.html`. Run every check, then report a verdict.

## Aligned

Same sections and required content as the rules file for each spec in scope. File-level requirements in [`alignment.md`](alignment.md) hold.

### Completeness

- [ ] No `<!-- fill in -->` placeholders remain in formalized Markdown or in formalized diagrams. Unused template rows there are deleted. A section that is still only a placeholder is not formalized ([`alignment.md`](alignment.md)).
- [ ] Each Markdown file links its authoring-rules file from [`rules/README.md`](rules/README.md). Those rules are not pasted into the spec. Diagrams do not carry a rules link; their rules are [diagrams.md](rules/view/diagrams.md).
- [ ] Dimensionality, embodiment, platform implications, and the index in `view.md`, and the alignment and topic coverage tables in `traceability.md`, are filled in.
- [ ] Every topic in the coverage table is covered, or marked N/A with a reason grounded in the design profile, the definition, or the quality spec. A section that does not apply says "N/A — reason" instead of being deleted.
- [ ] Every camera file is listed in the `view.md` index, and every indexed file exists. The projection and each camera have a diagram when the definition's spec depth requires one ([`depth.md`](rules/depth.md)). Otherwise the **Diagram** field reads "None — spec depth \<level\>".

### Concrete detail

- [ ] Positions, extents, distances, angles, durations, and frame fractions are stated with units. Two readers would build the same view from the specs.
- [ ] Gameplay space and rendered space are both stated, and any mismatch says what it means for the player.
- [ ] Every character and entity with a body in space has an extent and, when it collides, a collision shape.
- [ ] Each camera states framing, motion, limits, occlusion, transitions, effects, and player control, or "None" where the rules allow it.

### Shared language

- [ ] Each view term is defined once in `glossary.md` and used as defined. Game terms stay in the design glossary, and UI terms in the UX glossary.
- [ ] Characters and entities are linked, not redefined.
- [ ] Camera actions are defined once in `camera-controls.md`. Cameras refer to them by ID.
- [ ] A design parameter is cited by name from `configuration.md`, never restated.
- [ ] Cited design and view element IDs exist.

### Internal consistency

- [ ] Every camera is used by at least one flow phase or stage, and every flow phase or stage with play in space is covered by some camera's **Used in**.
- [ ] Every camera transition names a camera that exists, and the trigger is a design event, flow transition, or camera action that exists.
- [ ] Every camera's projection is a `PRJ.P` that exists. Camera limits stay inside the stage bounds in `SPC.B`.
- [ ] Every camera action is accepted by at least one camera and has a binding in `specs/ux/controls.md` on every primary platform.
- [ ] Every camera effect that moves the view names the comfort option that reduces or disables it, when motion comfort Applies.
- [ ] Readability guarantees hold in every camera they name, given that camera's framing, limits, effects, and the projection's visible area.
- [ ] Contact feel, positional cues, and haptic cues that link each other agree on the triggering event.

### Design fidelity

- [ ] No view element changes whether a design outcome occurs. Physics motion reproduces every design outcome it cites.
- [ ] Visibility limits, occlusion, and audio agree with the design's hidden and visible state: they reveal nothing hidden and conceal nothing the player can know.
- [ ] Each clarity rule and feedback principle in `experience.md` is realized by a view element or by the UX.

### Element IDs

- [ ] Every section listed in [`ids.md`](rules/view/ids.md) gives each element an ID in the prescribed form, unique within its spec.
- [ ] Qualified IDs cited anywhere exist. Each diagram labels its drawn elements with their IDs.

### View stories

Rules: [`stories.md`](rules/view/stories.md) and [`story.md`](rules/view/story.md).

- [ ] Every view spec with element IDs is a row in the `stories.md` index with core and coverage. The specs marked core include at least those [`depth.md`](rules/depth.md) names, and each coverage level meets the minimum for the definition's spec depth.
- [ ] Every spec whose coverage is not None has a story file at the mirrored path under `stories/`. No story file lacks a view spec.
- [ ] In each story file, every element ID and named item is proven by at least one scenario, and the coverage table agrees with its scenarios' **Proves** lines.
- [ ] For each spec at Full coverage, every requirement in [`story-coverage.md`](rules/view/story-coverage.md) is met for each element kind.
- [ ] Each scenario has a complete Given (camera, platform and aspect, positions, settings), one When (chained only in transition stories), and a Then with concrete values and tolerances.
- [ ] Each scenario is falsifiable. An implementation that breaks the element it proves would fail it. No subjective wording.
- [ ] No scenario asserts a game-rule outcome or interface behavior.

### Alignment

- [ ] `traceability.md` maps every essential quality the view affects and every design spec whose play is seen, heard, or felt.
- [ ] Nothing serves only a vision non-goal or a definition out-of-scope item. Every spec states what it serves.
- [ ] Platform implications in `view.md` are reflected in projection, visible area, and cameras for each platform.
- [ ] When accessibility Applies, comfort options name the target each meets, and every positional cue that carries game information has a non-audio equivalent.

### Diagrams

- [ ] Each diagram is self-contained, drawn to scale with a scale bar and labelled axes, and shows what [diagrams.md](rules/view/diagrams.md) requires for its kind.
- [ ] Each diagram's values match its spec. It adds no element or value the spec does not state.

### Scope boundaries

- [ ] No game rules. Design outcomes appear only as citations.
- [ ] No interface: no screens, menus, HUD layout, or input bindings.
- [ ] No technical design: no engines, frameworks, editors, APIs, or file formats. A limit imposed by an architecture decision is stated in view terms and cites an ADR ID that exists in [`specs/adr/decisions/`](../../specs/adr/decisions/).

### Format

- [ ] Each Markdown file is under 500 words ([`specs/README.md`](../../specs/README.md)). HTML under `specs/view/diagrams/` is exempt. Oversized Markdown is split by logical unit and linked.

## Imposed

- [ ] No two view specs contradict each other, or contradict the design fact they cite.
- [ ] The viewpoint and embodiment support the vision's player fantasy.

## Verdict

- **Pass**: every check passes.
- **Fail**: one or more checks fail.

Report back in this shape:

```markdown
**View review: Pass | Fail**

Scope: <whole view | listed files>

Findings:
- <file>: aligned | imposed — <failed check> — <suggested fix>

Notes (optional): <non-blocking observations>
```

List only failed checks under Findings. Tag a check that cannot be judged without product-owner input with `needs clarification` as well. If the problem is in the vision, the definition, or the design, say so. Refinement follows [`alignment.md`](alignment.md).
