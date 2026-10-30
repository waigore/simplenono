# Reviewing `specs/technical/`

Instructions for agents reviewing the technical design ([`specs/technical/technical.md`](../../specs/technical/technical.md) and every file under [`specs/technical/`](../../specs/technical/)). Authoring rules for each file are in [`rules/README.md`](rules/README.md). Follow [`alignment.md`](alignment.md). The spec links that file and does not contain the rules. Read [`specs/vision.md`](../../specs/vision.md), [`specs/definition/definition.md`](../../specs/definition/definition.md), [`specs/definition/quality.md`](../../specs/definition/quality.md), [`specs/design/design.md`](../../specs/design/design.md), [`specs/view/view.md`](../../specs/view/view.md), [`specs/ux/ux.md`](../../specs/ux/ux.md), [`specs/playtest/playtest.md`](../../specs/playtest/playtest.md), [`specs/assets/assets.md`](../../specs/assets/assets.md), and [`specs/adr/adr.md`](../../specs/adr/adr.md) first. Read every Accepted ADR and every upstream spec a technical file cites. A review may cover the whole set or named files. Cross-spec checks always consider the whole technical set. Skip `_template.md`, files under `_templates/`, and unfilled diagram templates. Run every check, then report a verdict.

## Aligned

Same sections and required content as the rules file for each spec in scope. File-level requirements in [`alignment.md`](alignment.md) hold.

### Completeness

- [ ] No `<!-- fill in -->` placeholders remain in formalized Markdown or in formalized diagrams. Unused template rows and optional sections the rules say to delete are deleted there. A section that is still only a placeholder is not formalized ([`alignment.md`](alignment.md)).
- [ ] Each Markdown file links its authoring-rules file from [`rules/README.md`](rules/README.md). Those rules are not pasted into the spec. HTML diagrams do not carry a rules link; their rules are [diagrams.md](rules/technical/diagrams.md). `diagrams/README.md` links its rules.
- [ ] Overview and the index in `technical.md`, and the alignment and topic coverage tables in `traceability.md`, are filled in.
- [ ] Every topic in the coverage table is Applies with a covering file, or N/A with a reason grounded in the definition, design profile, quality, or Accepted ADRs.
- [ ] Every unit file under `components/`, `contracts/`, `schemata/`, and `sequences/` is listed in the hub index, and every indexed file exists.
- [ ] An optional global (`failures`, `concurrency`, `persistence`, `configuration`, `verification`) exists if and only if the hub indexes it with a link (not "None yet") and its topic is Applies. No empty stub for an unused optional.
- [ ] `asset-access.md` is filled whenever `specs/assets/access.md` is (Fail if one is filled and the other is not). Each value is set or `TBD — <question>` naming the ADR or technical element it waits on. `R1`–`R3` realize `ACC.A1`–`ACC.A3`; every `ACC.G` group has a load-group row; engine resources and build outputs live outside the asset root.

### Structure and contracts

- [ ] `layers.md` and `modules.md` state decomposition precise enough that two readers would place the same responsibility in the same layer or module.
- [ ] Each component states responsibilities, communication peers, and owns/mutates; each communication row cites a contract that exists when Via contract is used.
- [ ] Each contract states provider, consumers, operations, guarantees, and errors; events are filled or "None".
- [ ] Each schema states fields, invariants, and lifecycle (create, update, destroy at minimum); relationships are filled or "None".
- [ ] Each sequence states trigger, participants, contracts used, ordered steps, branches (or "None"), and postconditions.

### Shared language and IDs

- [ ] Each technical term is defined once in `glossary.md` and used as defined. Design, view, and UX terms stay in their glossaries.
- [ ] Every section listed in [`ids.md`](rules/technical/ids.md) gives each element an ID in the prescribed form, unique within its spec.
- [ ] Qualified IDs cited anywhere exist. Diagrams label drawn elements with IDs when those elements have IDs.
- [ ] Cited design, view, UX, and ADR IDs exist (Accepted ADRs for authorizing stack choices).

### Diagrams

- [ ] Diagram requirements in [diagrams.md](rules/technical/diagrams.md) are met for each filled spec kind in scope.
- [ ] Prefer in-file Mermaid unless a `diagrams/` artifact is linked from the owning spec. No orphan files under `diagrams/` except `README.md`.
- [ ] Each diagram shows only what its owning spec states. Values and participants match the spec.

### Alignment

- [ ] `traceability.md` maps upstream items the technical design serves, including Accepted ADRs that shape code or data.
- [ ] Nothing serves only a vision non-goal or a definition out-of-scope item. Every unit states Serves / Informed by / ADRs as required.
- [ ] Named engines, frameworks, libraries, storage, protocols, and formats appear only with an Accepted ADR citation.

### Scope boundaries

- [ ] No new game rules, view behaviors, or interface behaviors. Upstream facts appear only as citations.
- [ ] Does not re-litigate ADR choices; stack boundaries match Accepted ADRs.
- [ ] No Given/When/Then player, view, or user stories in this folder.
- [ ] No deep performance budgets that belong only in `quality.md` or ADRs; no full UML dump as a substitute for the typed specs.
- [ ] When `verification.md` is in scope, each automatable deterministic axis listed from [`quality/rubrics.md`](../../specs/definition/quality/rubrics.md) is cited by one invariant.

### Format

- [ ] Each Markdown file is under 500 words ([`specs/README.md`](../../specs/README.md)). HTML under `specs/technical/diagrams/` is exempt. Oversized Markdown is split by logical unit and linked.

## Imposed

- [ ] No two technical specs contradict each other, or contradict the upstream fact or Accepted ADR they cite.
- [ ] Layer and module dependency rules leave no unexplained cycle among indexed components.

## Verdict

- **Pass**: every check passes.
- **Fail**: one or more checks fail.

Report back in this shape:

```markdown
**Technical review: Pass | Fail**

Scope: <whole set | listed files>

Findings:
- <file>: aligned | imposed — <failed check> — <suggested fix>

Notes (optional): <non-blocking observations>
```

List only failed checks under Findings. Tag a check that cannot be judged without product-owner input with `needs clarification` as well. If the problem is in an upstream spec, say so. Refinement follows [`alignment.md`](alignment.md).
