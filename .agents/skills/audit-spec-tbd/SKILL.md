---
name: audit-spec-tbd
description: |-
  Find every TBD (undecided aspect) in specs/, order them upstream first, and
  propose grounded answers for the user to confirm. Confirmed answers go to
  author-spec; unconfirmed ones stay TBD. Use after capture sessions, before a
  spec review, or when the user asks what is still undecided.

  Examples:
    - user: "What's still TBD?" → whole set, suggestions, ask to confirm
    - user: "Resolve the TBDs in the definition" → specs/definition/ only
    - user: "TBD audit for design" → specs/design/, blocking TBDs first
---

# Audit spec TBDs

Surfaces undecided aspects marked per [Undecided aspects](../../specs/rules/README.md#undecided-aspects-tbd) and proposes answers. The audit itself is read-only; confirmed answers are written through [`author-spec`](../author-spec/SKILL.md).

## Steps

1. **Resolve the scope**: one spec file, one folder, or the whole set (default). Skip `_template` files, `specs/technical/_templates/`, and `specs/adr/archive/`.
2. **Find TBDs**: `rg -n '\bTBD\b' specs/` within scope. Also note files still holding `<!-- fill in -->`; they are not captured yet, not TBD.
3. **Order upstream first**, in [`specs/README.md`](../../../specs/README.md) index order. Mark a TBD **blocking** when a downstream TBD links it, or when it sits in a high-level field listed under [High-level stage](../capture-requirements/SKILL.md#high-level-stage).
4. **Suggest**: for each TBD, read its rules file (per the path table) and the upstream specs that ground it. Propose one to three answers that satisfy the rules, each citing the upstream fact it rests on (a vision quality, scope item, constraint, platform, Accepted ADR). Mark one as recommended only when the upstream points to it. If nothing upstream grounds an answer, say so and pass the question on as written.
5. **Report** in the shape below, then **ask the user to confirm**, upstream and blocking first, a few at a time. Use a structured multiple-choice question when available, always allowing a custom answer or "keep TBD".
6. **Hand off**: for each confirmed answer, run `author-spec` on that file to replace the TBD. When `reconcile-poc` or `promote-poc` is the caller, return the written paths and do not open a PR. Otherwise open a spec PR per [Spec PRs](../../../docs/pull-requests.md#spec-prs). A downstream TBD that cited a resolved one is re-asked, not resolved automatically.

## Report shape

```markdown
**TBD audit: <n> open (<b> blocking)**

Scope: <file | folder | whole set>

Open:
- <file>:<line> — <open question> — blocking: <what it gates | no>
  - (recommended) <answer> — grounded in <cite>
  - <answer> — grounded in <cite>

Not captured: <files still holding `<!-- fill in -->`, or none>
```

## Rules

- Close per [`../audit-spec-applicability/references/report-back.md`](../audit-spec-applicability/references/report-back.md). When `review-spec` invoked this audit, still confirm with the user and write through `author-spec` before returning the report, including remaining open TBDs.
- Never resolve a TBD without the user's confirmation, and never present a suggestion as decided.
- Suggestions stay inside the rules and the upstream specs. A suggestion that would change scope, an objective, a platform, a constraint, or a quality target says so.
