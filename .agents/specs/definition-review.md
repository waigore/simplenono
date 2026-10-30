# Reviewing `specs/definition/`

Instructions for agents reviewing the game definition ([`specs/definition/definition.md`](../../specs/definition/definition.md), [`specs/definition/quality.md`](../../specs/definition/quality.md)) and any files split out beside them. Authoring rules: [`rules/definition.md`](rules/definition.md) and [`rules/quality.md`](rules/quality.md). Follow [`alignment.md`](alignment.md). Each spec links its rules file and does not contain the rules. Read [`specs/vision.md`](../../specs/vision.md) first. Run every check, then report a verdict.

## Aligned

Same sections and required content as [`rules/definition.md`](rules/definition.md) and [`rules/quality.md`](rules/quality.md). File-level requirements in [`alignment.md`](alignment.md) hold.

### Completeness

- [ ] No `<!-- fill in -->` placeholders remain in formalized sections; unused template rows there are deleted. A section that is still only a placeholder is not formalized ([`alignment.md`](alignment.md)).
- [ ] `definition.md` links [`rules/definition.md`](rules/definition.md), and `quality.md` links [`rules/quality.md`](rules/quality.md). Those rules are not pasted into the spec. A split file uses the rules file of the spec it came from.
- [ ] Every section is present: scope, objectives, supported platforms, engine, constraints, spec depth, quality expectations.
- [ ] [`quality.md`](../../specs/definition/quality.md) is linked from the quality expectations section and listed in [`specs/README.md`](../../specs/README.md).
- [ ] Split sections are linked from `definition.md` with a one-line summary and listed in [`specs/README.md`](../../specs/README.md).

### Scope

- [ ] In-scope and out-of-scope lists are both present.
- [ ] Items are concrete enough to decide whether a given feature is in or out.
- [ ] No item is in both lists.

### Objectives

- [ ] Player objectives cover goal, win/lose conditions, and progression.
- [ ] Product objectives are concrete and their completion is verifiable.

### Supported platforms

- [ ] Each platform has a primary input and a priority (primary / secondary / stretch).
- [ ] At least one platform is primary.
- [ ] Every primary platform is one the engine can reach.

### Engine

- [ ] Engine names an engine, a framework when there is none, or "Custom", with a one-line reason grounded in the platforms, constraints, team, or vision qualities. No versions, plugins, or setup.
- [ ] Implications state in product terms what the choice fixes or limits, and do not contradict the scope, platforms, or constraints.

### Constraints

- [ ] Design, technical, and market subsections each have at least one constraint or state "None".
- [ ] Each constraint has a one-line reason.
- [ ] Constraints do not contradict each other or the scope.
- [ ] A constraint imposed by an architecture decision cites an ADR ID that exists in [`specs/adr/decisions/`](../../specs/adr/decisions/).

### Spec depth

- [ ] Depth is one of `prototype`, `small`, or `full` ([`rules/depth.md`](rules/depth.md)), with a one-line reason grounded in the scope, product objectives, or constraints.

### Quality expectations

- [ ] Performance, load time / latency, reliability, observability, save durability, accessibility, and localization are each present in [`quality.md`](../../specs/definition/quality.md).
- [ ] Each category is Applies, or N/A with a reason that cites the vision or the supported platforms. At prototype depth, a category other than performance may instead cite spec depth.
- [ ] Each Applies row has a measurable target, the platforms it covers, and exactly one axis id listed in the rubric files linked from [`quality/rubrics.md`](../../specs/definition/quality/rubrics.md). Platforms match the supported-platforms table.
- [ ] An N/A row uses "—" for target and platforms. The axis id stays, and that axis is not scored.
- [ ] [`quality/rubrics.md`](../../specs/definition/quality/rubrics.md) is linked from `quality.md` and listed in [`specs/README.md`](../../specs/README.md).
- [ ] `quality.md` has Categories and Rubrics. `rubrics.md` has Baseline axes, Domain axes, and Judge record. Baseline axes are in that file or in `rubrics/baseline.md` linked from it.
- [ ] Every baseline axis in [`rules/quality.md`](rules/quality.md) is present, on that characteristic, with evaluator `deterministic`, and "—" for scale and pass level.
- [ ] A domain axis has a new characteristic and a kebab-case id that is not a baseline id. Its outcome is not already the failure of another axis.
- [ ] Evaluator is `deterministic` or `llm-judge`. An `llm-judge` row has an ordinal scale, a minimum passing level, and evidence limited to build observations, screenshots, logs, or telemetry. The outcome is the criterion.
- [ ] Applicable axes are scored separately. The file states that every applicable axis must meet its bar. There is no combined score.
- [ ] Rows for the same category do not contradict each other, the constraints, or the vision.
- [ ] Targets are observable outcomes. No architecture, engines, data formats, or APIs.
- [ ] A target set or limited by an architecture decision cites an ADR ID that exists in [`specs/adr/decisions/`](../../specs/adr/decisions/).

### Consistency with vision

- [ ] In-scope items do not serve only a vision non-goal.
- [ ] Out-of-scope items do not remove something an essential quality depends on.
- [ ] Objectives support the elevator pitch and player fantasy.

### Format

- [ ] `definition.md` reads as roughly one page. Each file is under 500 words ([`specs/README.md`](../../specs/README.md)).
- [ ] No technical details (architecture, engine systems, data formats, APIs). Technical *constraints* and the engine choice are fine.

## Imposed

- [ ] Nothing in the definition contradicts the vision's essential qualities or tradeoffs, beyond the explicit scope, objective, and constraint checks above.

## Verdict

- **Pass**: every check passes.
- **Fail**: one or more checks fail.

Report back in this shape:

```markdown
**Definition review: Pass | Fail**

Findings:
- <section>: aligned | imposed — <failed check> — <suggested fix>

Notes (optional): <non-blocking observations>
```

List only failed checks under Findings. Tag a check that cannot be judged without product-owner input with `needs clarification` as well. If the problem is in `vision.md` rather than the definition, say so. Refinement follows [`alignment.md`](alignment.md).
