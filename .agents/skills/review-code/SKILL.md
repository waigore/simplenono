---
name: review-code
description: |-
  Review code against docs/solid.md (SOLID + structure continuity, owned by the
  template) and docs/coding-conventions.md (project-owned conventions and the
  Code lint / Unit tests / Coverage checks): Pass/Fail with findings tagged by
  principle or rule and severity. Read-only.
  Use on demand for working-tree or PR diffs, or when verify-project-issue finds
  code changes in linked PRs.

  Examples:
    - user: "Review my uncommitted changes" → working-tree diff
    - user: "review-code on PR #40" → PR code diff + Code lint / Unit tests / Coverage
    - verify-project-issue: linked PR has code → run this review; Fail blocks verify
---

# Review code

Read-only review of a diff. Sources and precedence: [`references/sources.md`](references/sources.md). Do not restate them.

## Resolve the target

Use the first match:

1. **Named PR** — user or caller gives a PR number/URL → that PR’s code diff.
2. **Verify caller** — linked deliverable PRs that contain **code changes** → those PR diffs.
3. **Default** — uncommitted / working-tree changes (`git status`, staged + unstaged diff).

**Code changes:** touched implementation files, as [`sources.md`](references/sources.md) defines them. Skip this skill when the diff is only non-implementation paths.

If there is nothing to review, report **N/A** (not a Pass) and stop.

## Review

For the resolved diff (and nearby existing structure needed for continuity):

1. **Sources**: apply [`sources.md`](references/sources.md), including the conventions-file cases. A contradicting convention is a `CONV` `must-fix` naming the rule and the principle.
2. **SOLID**: check **SRP**, **OCP**, **LSP**, **ISP**, **DIP**.
3. **Conventions**: check each applicable rule. A broken `must` rule is a `must-fix`; a broken `should` rule is a `suggestion`.
4. **CI checks**: for a PR target, read `Code lint`, `Unit tests`, and `Coverage` (`gh pr checks <n>`). A failing check is a `LINT` / `TEST` / `COV` `must-fix` citing the failing step; still running, wait and re-read. A conventions table row with no matching step in [`code-lint.yml`](../../../.github/workflows/code-lint.yml) or [`unit-tests.yml`](../../../.github/workflows/unit-tests.yml) is a must-fix against the workflow; a `None` row needs no step. For a working-tree target, note that the checks run on the PR.
5. **Continuity** (`CONT`): new code matches existing layout, naming, layering, and patterns unless SOLID or a convention requires otherwise.
6. Tag each finding: `SRP` | `OCP` | `LSP` | `ISP` | `DIP` | `CONV <CC-n>` | `LINT` | `TEST` | `COV` | `CONT`, and severity `must-fail` | `suggestion`.
7. Cite path (and line range when clear). Keep findings concrete; no speculative rewrites.

## Verdict

- **Fail** — any `must-fix` finding.
- **Pass** — no `must-fix` findings (suggestions allowed).

## Report shape

```markdown
## Code review: Pass | Fail | N/A

**Target:** working tree | PR #<n> | …

### Findings
- `[TAG]` `must-fix` | `suggestion` — path: summary

### Notes
(optional: continuity context, SOLID only or conventions not filled in, skipped non-code paths)
```

When called from chat, reply with the report. When called from `verify-project-issue`, return the report to the caller for inclusion in the verify comment.

## Rules

- Read-only: do not edit code, conventions, or workflows while reviewing.
- Follow [`sources.md`](references/sources.md) for precedence and for which `CONV` or `CONT` findings are allowed.
- A Fail from this skill fails verification when invoked by `verify-project-issue`.
- A structure or technical-debt pass over the tree or a named portion is [`suggest-code-refactors`](../suggest-code-refactors/SKILL.md). Do not stretch this skill into that audit.
