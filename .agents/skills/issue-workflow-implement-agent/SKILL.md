---
name: issue-workflow-implement-agent
description: |-
  Background dispatch for status:pending-implementation: resolve or discover one
  typed issue, perform the implementation work, then run implement-project-issue
  (deliverables comment + status gate). Product behavior with no formalized spec
  stops for capture-requirements. A PoC starts only when the issue asks to
  explore. Use when automation dispatches an unattended implement agent.

  Examples:
    - dispatch with no issue → discover pending-implementation, pick one, implement
    - dispatch with #12 → implement #12, then implement-project-issue
---

# Issue workflow implement agent

Veneer for unattended `status:pending-implementation`.

Resolve one issue per [`docs/issues/workflow-dispatch.md`](../../../docs/issues/workflow-dispatch.md). Do the work, then read and run [`implement-project-issue`](../implement-project-issue/SKILL.md). That skill records evidence only. Report its outcome and stop. Verification is a later `issue-workflow-verify-agent` run.

## Work

- Branch, change code, specs, or assets as the issue scopes, and open a PR when that is appropriate.
- A PoC follows [`create-poc`](../create-poc/SKILL.md), including its pull-request ask. Respect native **blocked-by** edges, including a PoC task that must prove a claim.
- If the issue asks for product behavior with no formalized spec, stop and report that `capture-requirements` must specify it. Start a PoC only when the issue asks to explore. Do not require a PoC when that spec is already formalized.
- Before main-tree UI, confirm the formalized screen mockup(s) are `approved` in [`specs/ux/mockups/catalog.md`](../../../specs/ux/mockups/catalog.md) ([`docs/ux-mockups.md`](../../../docs/ux-mockups.md)). If not, stop and report.
