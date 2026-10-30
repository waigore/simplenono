# Reviewing `specs/vision.md`

Instructions for agents reviewing the game vision document ([`specs/vision.md`](../../specs/vision.md)). Authoring rules: [`rules/vision.md`](rules/vision.md). Follow [`alignment.md`](alignment.md). The spec links that rules file and does not contain the rules. Run every check, then report a verdict.

## Aligned

Same sections and required content as [`rules/vision.md`](rules/vision.md). File-level requirements in [`alignment.md`](alignment.md) hold.

### Completeness

- [ ] No `<!-- fill in -->` placeholders remain in formalized sections; unused template rows there are deleted. A section that is still only a placeholder is not formalized ([`alignment.md`](alignment.md)).
- [ ] The file links [`rules/vision.md`](rules/vision.md). Those rules are not pasted into the spec.
- [ ] Every section is present: elevator pitch, high-level description, target audience and player fantasy, essential qualities, tradeoffs, non-goals.

### Elevator pitch

- [ ] 1–2 sentences.
- [ ] States the core player action and why it is compelling.
- [ ] Understandable without reading the rest of the document.

### High-level description

- [ ] ≤150 words, one paragraph.
- [ ] Covers core loop, setting, and tone.
- [ ] Describes the experience, not a feature list.
- [ ] Consistent with the elevator pitch.

### Target audience and player fantasy

- [ ] Audience is specific (not "everyone") and names experience level, play habits, and session length.
- [ ] Player fantasy is a feeling or role, not a mechanic.

### Essential qualities

- [ ] At most **5** qualities. Three rows are present. Rows 4 and 5 appear only when needed. Unused rows are deleted.
- [ ] Each has a name, a one-line description, and a "supports it if…" test.
- [ ] Each test is observable: two reviewers would reach the same judgment on a given feature.
- [ ] Qualities are distinct.
- [ ] Qualities follow from the pitch and description.

### Tradeoffs

- [ ] When qualities conflict, the higher-priority one wins. Pairs are listed in priority order, with why.
- [ ] Every likely conflict between qualities has a stated winner.
- [ ] Ordering does not cycle.

### Non-goals

- [ ] At least one non-goal.
- [ ] Features that only serve a non-goal are rejected.
- [ ] Non-goals do not contradict the pitch, description, or qualities.

### Format

- [ ] File is under 500 words ([`specs/README.md`](../../specs/README.md)).

## Imposed

No imposed conditions for this document. Do not invent one.

## Verdict

- **Pass**: every check passes.
- **Fail**: one or more checks fail.

Report back in this shape:

```markdown
**Vision review: Pass | Fail**

Findings:
- <section>: aligned | imposed — <failed check> — <suggested fix>

Notes (optional): <non-blocking observations>
```

List only failed checks under Findings. Tag a check that cannot be judged without product-owner input with `needs clarification` as well. Refinement follows [`alignment.md`](alignment.md).
