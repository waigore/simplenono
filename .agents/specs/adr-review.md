# Reviewing `specs/adr/`

Instructions for agents reviewing the architecture decisions ([`specs/adr/adr.md`](../../specs/adr/adr.md) and every file under [`specs/adr/`](../../specs/adr/)). Authoring rules for each file are in [`rules/README.md`](rules/README.md). Follow [`alignment.md`](alignment.md). The spec links that file and does not contain the rules. Read [`specs/vision.md`](../../specs/vision.md), [`specs/definition/definition.md`](../../specs/definition/definition.md), [`specs/definition/quality.md`](../../specs/definition/quality.md), [`specs/design/design.md`](../../specs/design/design.md), [`specs/view/view.md`](../../specs/view/view.md), [`specs/aesthetics/aesthetics.md`](../../specs/aesthetics/aesthetics.md), [`specs/ux/ux.md`](../../specs/ux/ux.md), [`specs/playtest/playtest.md`](../../specs/playtest/playtest.md), and [`specs/assets/assets.md`](../../specs/assets/assets.md) first. Read every spec an ADR cites under **Informed by** or **Imposes**. A review may cover the whole set or named ADRs. Cross-spec checks always consider every Proposed and Accepted ADR. Skip `_template.md` and `archive/`. Do not open archived ADRs. List `archive/` file names only to check IDs and supersession. Run every check, then report a verdict.

## Aligned

Same sections and required content as the rules file for each spec in scope. File-level requirements in [`alignment.md`](alignment.md) hold.

### Completeness

- [ ] No `<!-- fill in -->` placeholders remain in formalized sections. Unused template rows there are deleted. A section that is still only a placeholder is not formalized ([`alignment.md`](alignment.md)).
- [ ] Each Markdown file links its authoring-rules file from [`rules/README.md`](rules/README.md). Those rules are not pasted into the spec.
- [ ] Overview, Stack, and the index in `adr.md`, and the alignment and imposed-constraints tables in `traceability.md`, are filled in.
- [ ] Every Proposed and Accepted ADR is listed in the index with its status, and every indexed file exists. No archived ADR is indexed.
- [ ] Every Stack area has a choice and an Accepted ADR, or "N/A — reason" grounded in the definition or the design profile. Every Accepted ADR appears in the row matching its Category. No Proposed ADR appears in the Stack.

### Decision records

- [ ] Each ADR has Status, Date, Category, Supersedes, and Informed by, with values the rules allow. The ID matches the file name and is unique across `decisions/` and `archive/` file names.
- [ ] Context, Purpose, Decision, Reasoning, Rejected alternatives, Non-functional requirements, Imposes, and Validation are present.
- [ ] Context states facts, not the choice. Purpose is one question with its scope.
- [ ] The Decision is precise enough to tell whether code complies, with versions and boundaries where they matter.
- [ ] Reasoning lists drivers in priority order, each traced to Informed by, and states the costs accepted.
- [ ] Each rejected alternative is tied to a driver, or the section says "None — reason".
- [ ] An Engine ADR realizes the engine named in the definition's Engine section and cites it under Informed by. No Engine ADR is Accepted while that engine is TBD.

### Non-functional requirements

- [ ] Quality expectations has one row per category in `quality.md`. Effect matches the category's applicability there. Each Affects row cites the target and says how it is met or limited.
- [ ] Engineering qualities assess licensing and cost, maintainability, testability, portability, and security and privacy, or say "Not relevant — reason".
- [ ] Portability covers every supported platform in the definition.

### Imposed constraints

- [ ] Every Imposes row names a spec or element that exists and states the constraint in that spec's terms.
- [ ] For an Accepted ADR, the constrained spec states the constraint and cites the ADR ID. `traceability.md` lists every Imposes row with no Pending row for an Accepted ADR.
- [ ] An ADR whose imposition is material per [`alignment.md`](alignment.md) stays Proposed until the constrained spec is revised.

### Validation

- [ ] Each ADR has at least one check that proves the decision works, with a method and when it runs.
- [ ] Each Affects quality row has a check, or cites that row's rubric axis in `specs/definition/quality/rubrics.md`.

### Lifecycle and archive

- [ ] Each Supersedes ID names a file in `archive/`. No ADR outside `archive/` has status Superseded or Deprecated.
- [ ] No spec outside `archive/` cites an archived ADR ID, except a successor's Supersedes line.

### Alignment

- [ ] `traceability.md` maps every technical constraint, supported platform, and Applies quality category to at least one Accepted ADR, and every upstream item an ADR lists under Informed by.
- [ ] No ADR contradicts an upstream spec except through a cited imposition.
- [ ] Nothing serves only a vision non-goal or a definition out-of-scope item.

### Scope boundaries

- [ ] No game rules, view behavior, or interface behavior. Upstream facts appear only as citations.
- [ ] No implementation: no code, step-by-step setup, or tuning values.

### Format

- [ ] Each Markdown file is under 500 words ([`specs/README.md`](../../specs/README.md)). Oversized ADRs are split per the rules and linked.

## Imposed

- [ ] No two Proposed or Accepted ADRs contradict each other.
- [ ] Given the stated drivers, a reader would reach the same choice. The chosen option follows the vision's tradeoff order.

## Verdict

- **Pass**: every check passes.
- **Fail**: one or more checks fail.

Report back in this shape:

```markdown
**ADR review: Pass | Fail**

Scope: <whole set | listed ADRs>

Findings:
- <file>: aligned | imposed — <failed check> — <suggested fix>

Notes (optional): <non-blocking observations>
```

List only failed checks under Findings. Tag a check that cannot be judged without product-owner input with `needs clarification` as well. If the problem is in an upstream spec, say so. Refinement follows [`alignment.md`](alignment.md).
