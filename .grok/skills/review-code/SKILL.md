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

# Review code (facade)

Canonical instructions: [`.agents/skills/review-code/SKILL.md`](../../../.agents/skills/review-code/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
