---
name: audit-code-structure
description: |-
  Audit implementation code for structure and technical debt against
  docs/solid.md, docs/coding-conventions.md, structure continuity, and four
  smells (duplication, dead code, awkward seams, parallel structure). Each
  finding includes a proposed target or a decision the target needs. Read-only.
  Use for the whole implementation tree or a named portion, when the user wants
  findings without filing issues, or when suggest-code-refactors asks for the audit.

  Examples:
    - user: "Audit structure, don't file issues" → whole tree except pocs/
    - user: "Audit src/combat" → that portion
    - suggest-code-refactors: pass the request scope, return this report
---

# Audit code structure

Read-only audit of **implementation code**. Findings go to the requester. Filing issues is [`suggest-code-refactors`](../suggest-code-refactors/SKILL.md). Diff Pass/Fail for verification stays [`review-code`](../review-code/SKILL.md); do not call it and do not emit a Pass/Fail.

## Scope

Use the first match:

1. **Named portion** — the user or caller names paths or a module.
2. **Default** — the whole implementation tree.

**Implementation code** is defined in [`sources.md`](../review-code/references/sources.md). If a named path is not implementation code, skip it and say so. If nothing remains, report no findings and stop.

When the scope is a portion, read surrounding callers and siblings far enough to judge continuity and seams.

## Sources

Apply [`sources.md`](../review-code/references/sources.md). Do not restate precedence or the conventions-file cases. A contradicting convention is one `CONV` finding against `docs/coding-conventions.md`.

## Smells

Use a smell tag only when no SOLID, convention, or continuity tag fits.

| Tag | Finding |
|-----|---------|
| `DUP` | The same responsibility is implemented in more than one place. |
| `DEAD` | Unused or unreachable in the implementation tree. Not an extension point a spec requires. |
| `SEAM` | Callers reach across layers, or one change forces unrelated edits. |
| `PAR` | Two ways exist to do the same thing, and one existing seam should have been extended. |

Prefer `CONT` over `PAR` when one pattern is clearly the established one and the other diverges. Prefer `SRP` over `DUP` when one unit has several reasons to change. Prefer `DIP` over `SEAM` when the fix is to depend on a port instead of a concretion.

## Review

For the resolved scope:

1. Check **SRP**, **OCP**, **LSP**, **ISP**, **DIP**, each applicable convention, continuity, then the smells.
2. One problem, one finding, best-fitting tag. Cite paths and a line range when clear.
3. **Proposed target:** name the structure change (extract, merge, delete, invert a dependency, extend an existing seam) and the paths it touches. Describe the target; do not paste a replacement implementation. The target must obey [`sources.md`](../review-code/references/sources.md).
4. If a sound target would invent an architecture or product decision that is not already specified, do not invent it. Mark the finding `needs decision` and state the question.
5. Note finding ids that share a seam so the caller can group them.

## Report shape

```markdown
## Code structure audit

**Scope:** whole implementation tree | <paths>
**Excluded:** pocs/ | <skipped paths>

### Findings
- `F1` `[TAG]` — paths — evidence — proposed target
- `F2` `[TAG]` — paths — evidence — needs decision: <question>

### Notes
(optional: conventions status, shared seams, non-implementation paths skipped)
```

No findings is an empty Findings list, not a failure.

## Rules

- Read-only: do not edit the repo and do not file issues.
- Do not call `review-code` or `suggest-code-refactors`.
- When called by `suggest-code-refactors`, return this report to the caller.
- When run alone, reply with the report.
