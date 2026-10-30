# Reviewing `specs/design/`

Instructions for agents reviewing the game design ([`specs/design/design.md`](../../specs/design/design.md) and every file under [`specs/design/`](../../specs/design/)). Authoring rules for each file are in [`rules/README.md`](rules/README.md). Follow [`alignment.md`](alignment.md). The spec links that file and does not contain the rules. Read [`specs/vision.md`](../../specs/vision.md), [`specs/definition/definition.md`](../../specs/definition/definition.md), and [`specs/definition/quality.md`](../../specs/definition/quality.md) first. A review may cover the whole design or named files; cross-spec checks always consider the whole design. Skip `_template.md` files. Run every check, then report a verdict.

## Aligned

Same sections and required content as the rules file for each spec in scope. File-level requirements in [`alignment.md`](alignment.md) hold.

### Completeness

- [ ] No `<!-- fill in -->` placeholders remain in formalized sections; unused template rows and sections there are deleted. A section that is still only a placeholder is not formalized ([`alignment.md`](alignment.md)).
- [ ] Each file links its authoring-rules file from [`rules/README.md`](rules/README.md). Those rules are not pasted into the spec. The authoring-rules link is not game content.
- [ ] The genre and platform profile and index in `design.md`, and the alignment and topic coverage tables in `traceability.md`, are filled in.
- [ ] Every topic in the coverage table is covered, or marked N/A with a reason grounded in the genre profile or definition.
- [ ] Every unit spec is listed in the `design.md` index, and every indexed file exists.

### Self-contained detail

- [ ] Every rule, character, entity, and behavior is described in full, even for well-known games or genres.
- [ ] No spec depends on an external reference (named game, wiki, link) to be understood. The authoring-rules link does not count.
- [ ] Feature rules, sub-game rules, and player stories are precise enough that two readers reach the same outcome. A feature states the outcome of each edge case and simultaneous event.
- [ ] Every walkthrough in `scenarios/` can be resolved step by step from the other specs.
- [ ] Scenarios meet the minimum for the definition's spec depth in [`depth.md`](rules/depth.md).

### Shared language

- [ ] Each game term is defined once in `glossary.md` and used consistently; no synonyms.
- [ ] Each character and entity is defined once in its own file; other specs link instead of redefining.
- [ ] Parameter values appear only in `configuration.md`; other specs reference them by name.
- [ ] Game-state fields referenced anywhere exist in `game-state.md`.

### Internal consistency

- [ ] Every flow phase is reachable and has an exit, unless it ends the flow; every stage is reachable from some flow.
- [ ] Transitions state what carries over and what resets.
- [ ] End-condition IDs referenced elsewhere exist; precedence covers simultaneous conditions.
- [ ] Difficulty adjustments reference existing parameters and specs.
- [ ] Progression persistence agrees with flows, end conditions, and game-state scopes.

### Element IDs

- [ ] Every section listed in [`ids.md`](rules/design/ids.md) gives each element an ID in the prescribed form, unique within its spec.
- [ ] Qualified IDs cited anywhere (e.g. `F-movement.R3`) exist.

### Player stories

Rules: [`stories.md`](rules/design/stories.md) and [`story.md`](rules/design/story.md).

- [ ] Every design spec with element IDs is a row in the `stories.md` index with core and coverage. The specs marked core include at least those [`depth.md`](rules/depth.md) names, and each coverage level meets the minimum for the definition's spec depth.
- [ ] Every spec whose coverage is not None has a story file at the mirrored path under `stories/`; no story file lacks a design spec.
- [ ] In each story file, every element ID and name-referenced item (fields, modes, options, tunables) is proven by at least one scenario, and the coverage table agrees with its scenarios' **Proves** lines.
- [ ] For each spec at Full coverage, every requirement in [`story-coverage.md`](rules/design/story-coverage.md) is met for each element kind.
- [ ] Knowledge scenarios state what the player can or cannot know, never how it is shown.
- [ ] Each scenario has a complete Given, one When (a player verb or design-defined game event; chained only in walkthrough stories), and a Then with concrete values that match `configuration.md` or the Given.
- [ ] Each scenario is falsifiable: an implementation that breaks the element it proves would fail it. No subjective wording.
- [ ] No scenario asserts behavior absent from the design, or mentions screens, inputs, or presentation.

### Alignment with vision and definition

- [ ] Every essential quality, in-scope item, and player objective is served by at least one spec, and `traceability.md` reflects this.
- [ ] Nothing serves only a vision non-goal or definition out-of-scope item.
- [ ] Win/lose conditions and progression match the definition's player objectives.
- [ ] Where qualities conflict in the design, the vision's tradeoff order is followed.
- [ ] Every spec states what it serves.
- [ ] When accessibility Applies in [`quality.md`](../../specs/definition/quality.md), `experience.md` states channels, timing and assists, and scale. A rule-changing assist or timing option named there is an option in `configuration.md`.
- [ ] When localization Applies, `experience.md` lists the player-facing content that varies by locale.
- [ ] When save durability Applies, `progression.md` persistence and **M1** state what is committed, when it becomes permanent, and where play resumes.
- [ ] Performance, load time, reliability, and observability targets appear only in [`quality.md`](../../specs/definition/quality.md).

### Genre and platform fit

- [ ] Adopted and rejected genre conventions are reflected in the relevant specs.
- [ ] Platform implications (e.g. session length) are reflected in pacing, flows, and progression.
- [ ] Platforms appear only as design implications, never as hardware, input mapping, or APIs.

### Scope boundaries

- [ ] No UX design: no screens, menus, layouts, widgets, or input bindings. Player actions are verbs. Interface structure belongs in [`specs/ux/`](../../specs/ux/ux.md).
- [ ] No technical design: no engines, frameworks, code, data formats, or storage. A limit imposed by an architecture decision is stated in design terms and cites an ADR ID that exists in [`specs/adr/decisions/`](../../specs/adr/decisions/).
- [ ] Presentation appears only as experience intent.

### Format

- [ ] Each file is under 500 words ([`specs/README.md`](../../specs/README.md)); oversized files are split by logical unit and linked.

## Imposed

- [ ] No two specs contradict each other.
- [ ] A rule outside feature rules, sub-game rules, and player stories is precise enough that two readers would resolve the same situation identically.

## Verdict

- **Pass**: every check passes.
- **Fail**: one or more checks fail.

Report back in this shape:

```markdown
**Design review: Pass | Fail**

Scope: <whole design | listed files>

Findings:
- <file>: aligned | imposed — <failed check> — <suggested fix>

Notes (optional): <non-blocking observations>
```

List only failed checks under Findings. Tag a check that cannot be judged without product-owner input with `needs clarification` as well. If the problem is in `vision.md` or the definition rather than the design, say so. Refinement follows [`alignment.md`](alignment.md).
