---
name: audit-spec-applicability
description: |-
  Audit Applies/N/A consistency for a quality category, design topic, or the
  whole spec set: ground each claim upstream and check required carry-outs
  downstream. Use when quality depends on features, after scope/design changes,
  or before a whole-spec review. Read-only; report mismatches for author-spec.

  Examples:
    - user: "Does save durability apply?" → upstream scope/progression + downstream
    - user: "Audit observability applicability" → quality ↔ ADRs ↔ technical
    - user: "Applicability audit for the whole spec" → all coverage/quality tables
---

# Audit spec applicability

Read-only audit of **Applies** / **N/A** claims across the spec stack. Fixes go through [`author-spec`](../author-spec/SKILL.md). Full checklist review is [`review-spec`](../review-spec/SKILL.md), which runs this audit on whole-spec review.

**Edge list:** [`references/applicability-graph.md`](references/applicability-graph.md). Sourced from [`.agents/specs/rules/`](../../specs/rules/); do not invent edges.

## Steps

1. **Resolve the seed**:
   - **Quality category** (e.g. save durability, observability).
   - **Hub topic** (a row in a `traceability.md` coverage table).
   - **Whole set**: every quality category, then every hub coverage table (design → view → aesthetics → UX → assets → ADR → technical).
2. **Load the graph**: read [`references/applicability-graph.md`](references/applicability-graph.md) for the seed's upstream grounds and downstream carry-outs. Open only the specs those edges name.
3. **Upstream**: for each Applies claim, confirm a grounding fact still holds (vision, definition scope/platforms, design presence, Accepted ADR, or an upstream Applies). For each N/A, confirm the reason still matches those facts and is not contradicted by in-scope content.
4. **Downstream**: for each Applies, confirm required carry-outs exist and are not themselves N/A without the same reason. For each N/A, confirm downstream did not author content that assumes Applies (filled targets, Affects rows that need a target, or topic files that should be N/A).
5. **Report** using the shape below, then close per [`references/report-back.md`](references/report-back.md). If the requester wants fixes, point them at `author-spec`.

## Finding tags

| Tag | Meaning |
|-----|---------|
| `orphan Applies` | Applies, but no upstream ground |
| `stale N/A` | N/A reason no longer true, or contradicted by scope/design |
| `missing carry-out` | Applies upstream, required downstream missing or wrongly N/A |
| `leaking N/A` | N/A upstream, but downstream still assumes Applies |
| `reason mismatch` | Linked N/A reasons disagree |
| `ADR mismatch` | ADR Quality row vs `quality.md` Applicability disagree |

## Report shape

```markdown
**Applicability audit: Pass | Fail**

Seed: <category | topic | whole set>

Findings:
- <tag> — <where> — <evidence> — <suggested fix for author-spec>

Notes (optional): <non-blocking observations>
```

Do not tag an unfilled section `orphan Applies` or `stale N/A`.

## Rules

- Close per [`references/report-back.md`](references/report-back.md).
- Use only edges in the reference graph (or the rules files they cite). Do not invent carry-outs.
