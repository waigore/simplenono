---
name: implement-project-issue
description: |-
  After implementing an epic/task/defect in status:pending-implementation, post a
  deliverables summary (PRs/commits) and move to pending-verification.
  Use when implementation work for an issue is done and ready for verification.

  Examples:
    - user: "Mark #12 implemented; PR #40" → summary comment + gate status
    - user: "Implementation done for the HUD task" → same for that issue
---

# Implement project issue

Veneer over the [action shell](../enforce-task-workflow-status/references/action-shell.md) for `status:pending-implementation`.

This skill records evidence and status. It does not replace doing the implementation work.

Load requirements, deliverables, and acceptance criteria. Confirm deliverables exist (PRs, commits, paths). Ask if they are missing. Comment summarizing what was created or modified, with PR and commit links. Gate: `pending-implementation` → `pending-verification`.

**Main-tree UI** ([`docs/ux-mockups.md`](../../../docs/ux-mockups.md)): if deliverables include main-tree UI for a screen, that screen's row in [`specs/ux/mockups/catalog.md`](../../../specs/ux/mockups/catalog.md) must be `approved`. If not, stop. Do not gate to verification. Comment the missing approval, and set the row back to `draft` if a material upstream change landed after review. PoCs under `pocs/` are exempt. Journey catalog approval is not required to implement a screen. The screen row is the gate.
