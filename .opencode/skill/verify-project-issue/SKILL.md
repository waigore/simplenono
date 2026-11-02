---
name: verify-project-issue
description: |-
  Independently verify an epic/task/defect in status:pending-verification against
  its deliverables; post pass or fail and advance or return status. When linked
  PRs contain code changes, run review-code and treat a Fail as verify Fail.
  When an Applies deterministic axis can move, reuse or write the deterministic
  record; a failed or blocked axis is a verify Fail.
  Use when checking implemented work (smoke test) before acceptance.

  Examples:
    - user: "Verify #12" → independent checks, pass/fail comment, gate status
    - user: "Verification failed on #12: missing tests" → fail → pending-implementation
---

# Verify project issue (facade)

Canonical instructions: [`.agents/skills/verify-project-issue/SKILL.md`](../../../.agents/skills/verify-project-issue/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
