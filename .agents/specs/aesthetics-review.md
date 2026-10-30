# Reviewing `specs/aesthetics/`

Instructions for agents reviewing the aesthetics specs ([`specs/aesthetics/aesthetics.md`](../../specs/aesthetics/aesthetics.md) and every file under [`specs/aesthetics/`](../../specs/aesthetics/)). Authoring rules for each file are in [`rules/README.md`](rules/README.md). Follow [`alignment.md`](alignment.md). The spec links that file and does not contain the rules. Read [`specs/vision.md`](../../specs/vision.md), [`specs/definition/definition.md`](../../specs/definition/definition.md), [`specs/definition/quality.md`](../../specs/definition/quality.md), [`specs/design/design.md`](../../specs/design/design.md), [`specs/design/experience.md`](../../specs/design/experience.md), [`specs/view/view.md`](../../specs/view/view.md), and [`specs/view/perception.md`](../../specs/view/perception.md) first. When an aesthetics file cites a design or view element, read that spec. A review may cover the whole set or named files. Cross-spec checks always consider the whole set. Run every check, then report a verdict.

## Aligned

Same sections and required content as the rules file for each spec in scope. File-level requirements in [`alignment.md`](alignment.md) hold.

### Completeness

- [ ] No `<!-- fill in -->` placeholders remain in formalized Markdown or in formalized sheets. Unused template rows there are deleted. A section that is still only a placeholder is not formalized ([`alignment.md`](alignment.md)).
- [ ] Each Markdown file links its authoring-rules file from [`rules/README.md`](rules/README.md). Those rules are not pasted into the spec. Sheets do not carry a rules link; their rules are [sheets.md](rules/aesthetics/sheets.md).
- [ ] Medium, style pillars, content limits, variation, and the index in `aesthetics.md`, and the alignment and topic coverage tables in `traceability.md`, are filled in.
- [ ] Every topic in the coverage table is covered, or marked N/A with a reason grounded in the definition, the design, or the view, and follows the upstream rules in [traceability.md](rules/aesthetics/traceability.md). A section that does not apply says "N/A — reason" instead of being deleted.
- [ ] The sheets spec depth requires exist and are linked from the index, `palette.md`, and `form.md` ([`depth.md`](rules/depth.md)). Otherwise those fields read "None — spec depth \<level\>".

### Derivation

- [ ] The medium is grounded in the view's rendered space and the definition's engine implications. Resolution and scale cite `SPC.U` and `PRJ.X` for pixel art.
- [ ] Platform implications cover every supported platform in the definition.
- [ ] There are at most five pillars, in priority order. Each traces to a vision quality or the sensory intent in `experience.md`, and has a "conforms if…" test.
- [ ] Every spec and element states what it serves. Content limits are grounded in market constraints or non-goals.
- [ ] `traceability.md` maps every item [traceability.md](rules/aesthetics/traceability.md) requires.

### Checkable detail

- [ ] Colors are hex values; sizes, ratios, counts, durations, frame rates, and loudness are stated with units. Two reviewers would judge the same asset the same way.
- [ ] Each section holds the columns its rules file names: palette, form, surface, motion, interface style, sound, and references.
- [ ] Every color pair the design or view must keep distinguishable has a color rule with a test.
- [ ] Each silhouette rule names the smallest on-screen size and a test.

### Upstream fidelity

- [ ] No element breaks a clarity rule, a feedback principle, or a readability guarantee (`PER.R`), or weakens a depth cue (`PER.D`).
- [ ] Nothing reveals or conceals state against the design's hidden and visible state.
- [ ] Motion fits the design's action timing and does not restate physics feel. Sound style does not restate positional rules or when music changes.
- [ ] When accessibility Applies, color rules cover the deficiencies the target names, no information is carried by color alone, and typography states the smallest size. When localization Applies, typography states the scripts.

### Shared language and IDs

- [ ] Each style term is defined once in `glossary.md` and used as defined. Design, view, UX, and asset terms stay in their glossaries.
- [ ] Every section listed in [`ids.md`](rules/aesthetics/ids.md) gives each element an ID in the prescribed form, unique within its spec. Cited IDs exist.
- [ ] Interface color roles use swatches that exist in `palette.md`.

### Sheets and references

- [ ] Each sheet is self-contained, labels each drawn element with its ID, and shows what [sheets.md](rules/aesthetics/sheets.md) requires. Its values match the spec; it adds nothing.
- [ ] Each reference image states what it shows, what not to take, provenance, and rights. No stored file lacks the rights to be stored.

### Scope boundaries

- [ ] No asset lists, budgets, tools, prompts, or file formats. No engine, renderer, shader, or product names. An ADR limit cites an ADR ID that exists.
- [ ] No interface layout, screen content, or input behavior.

### Format

- [ ] Each Markdown file is under 500 words. Oversized Markdown is split per the rules and linked.

## Imposed

- [ ] No two aesthetics specs contradict each other.
- [ ] The pillars together support the vision's player fantasy.
- [ ] Each pillar's test is specific enough to fail a plausible off-style asset.

## Verdict

Report back in this shape:

```markdown
**Aesthetics review: Pass | Fail**

Scope: <whole set | listed files>

Findings:
- <file>: aligned | imposed — <failed check> — <suggested fix>

Notes (optional): <non-blocking observations>
```

List only failed checks under Findings. Tag a check that cannot be judged without product-owner input with `needs clarification` as well. If the problem is in an upstream spec, say so. Refinement follows [`alignment.md`](alignment.md).
