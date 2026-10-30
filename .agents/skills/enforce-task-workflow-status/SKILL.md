---
name: enforce-task-workflow-status
description: |-
  Gate or audit epic/task/defect status:* labels per docs/issues/workflow.md,
  and repair duplicate priority:* labels (keep highest).
  Use when transitioning workflow status after review/refine/clarify/implement/verify/accept,
  or when auditing issues for missing or duplicate status/priority labels.
  Use proactively before applying a status change so only one valid status:* remains.

  Examples:
    - user: "Move #12 to pending-verification" → gate: assert from, swap label
    - user: "Audit open issues for status labels" → standalone repair/report
    - called by review-project-issue after a pass comment → gate pending-review → pending-implementation
---

# Enforce task workflow status

Ensure typed issues (Epic / Task / Defect) have exactly one valid `status:*` label and that transitions follow the contract. Also keep at most one `priority:*` label (hygiene).

**Contract:** [`docs/issues/workflow.md`](../../../docs/issues/workflow.md)

**Transitions / `gh` commands:** [`references/status-transitions.md`](references/status-transitions.md)

**Priority catalog:** [`docs/labels.md`](../../../docs/labels.md)

## Modes

### Gate (default when an action skill or user names from→to)

Inputs: issue number `n`, expected `from` status, desired `to` status.

1. Confirm the issue has a `type:epic`, `type:task`, or `type:defect` label; abort otherwise.
2. Read current `status:*` and `priority:*` labels.
3. If more than one status label: remove extras so only one remains, then continue.
4. If none: report and ask whether to set `status:pending-review` or abort — do not guess a mid-pipeline status.
5. **Priority hygiene:** if more than one `priority:*` label, remove the lower ones and keep only the highest (`critical` > `high` > `normal`). Do not add `priority:normal` to unlabeled issues. Do not otherwise change priority (humans only set or change it).
6. Assert current status equals `from`; abort with current vs expected if not.
7. Assert `from`→`to` is allowed per the transitions reference; abort if not.
8. Swap status labels (remove all `status:*`, add `to`). Leave `priority:*` unchanged except for step 5 hygiene.
9. Report issue URL, previous status, new status, and any priority hygiene applied.

### Standalone audit

Inputs: one or more issue numbers, or “all open typed issues”.

1. List targets: given numbers, or `gh issue list --state open --label type:epic,type:task,type:defect` (run per type if needed) and union.
2. For each issue:
   - Zero status labels → set `status:pending-review` **only if** the user confirmed bulk repair or the issue was just created; otherwise report and ask.
   - Multiple status labels → keep none until swap: apply a single status only when the user names the correct one, or when evidence clearly matches one transition endpoint; otherwise report duplicates and ask.
   - One valid status → OK.
   - Unknown/non-catalog status-like label → report; do not delete non-`status:*` labels.
   - Multiple `priority:*` → keep highest; remove lower (hygiene). Report what was removed.
   - Zero or one `priority:*` → OK (zero means effective normal; do not add a label unless a human asks).
3. Summarize: fixed / needs attention / OK.

## Rules

- Never close an issue when setting `status:accepted` (closure is planner-only; see [`project-planner-agent`](../project-planner-agent/SKILL.md)).
- Do not invent statuses outside the catalog.
- Prefer report + ask over guessing mid-pipeline state.
- Type labels (`type:*`) are never removed by this skill.
- Do not elevate, lower, or invent priority except duplicate hygiene (keep highest).

## Related

- Action skills share [`references/action-shell.md`](references/action-shell.md): `review-project-issue`, `refine-project-issue`, `clarify-project-issue`, `implement-project-issue`, `verify-project-issue`, `accept-project-issue`
- `pending-redefinition`: Actions comment-cap only; replace via `redefine-project-issue` (not a gate transition)
- Create skills apply `status:pending-review` and `priority:normal` on create
