# Status transitions (reference)

Contract: [`docs/issues/workflow.md`](../../../../docs/issues/workflow.md). Do not invent statuses or transitions.

## Valid `status:*` labels

`status:pending-review`, `status:pending-refinement`, `status:pending-clarification`, `status:pending-implementation`, `status:pending-verification`, `status:pending-acceptance`, `status:accepted`, `status:pending-redefinition`

Exactly one of these on each `type:epic` / `type:task` / `type:defect` issue.

`status:pending-redefinition` is Actions-only; skills must not gate to or from it. Contract: [`docs/issues/workflow-comment-cap.md`](../../../../docs/issues/workflow-comment-cap.md).

## Allowed transitions

| From | To | Typical evidence |
|------|-----|------------------|
| pending-review | pending-implementation | Pass review comment (latest) |
| pending-review | pending-refinement | Fail review comment |
| pending-review | pending-clarification | Clarification questions comment |
| pending-refinement | pending-review | Refined body + summary comment |
| pending-clarification | pending-review | PO clarification comment |
| pending-clarification | pending-refinement | PO comment saying refine needed |
| pending-implementation | pending-verification | Implementation deliverables comment |
| pending-verification | pending-acceptance | Pass verification comment |
| pending-verification | pending-implementation | Fail verification comment |
| pending-acceptance | accepted | Accept comment with test evidence |
| pending-acceptance | pending-implementation | Fail accept (+ defect link) |
| pending-acceptance | pending-verification | Missing deterministic record: accept returns the issue so verify can produce it |
| pending-acceptance | pending-clarification | Needs PO clarification |

## Why `pending-acceptance` → `pending-verification` exists

Verification is the only stage that may run `run-quality-evaluators` in `deterministic` mode, and its Pass now requires that record for the deliverable commit ([`workflow-deterministic-record.md`](../../../../docs/issues/workflow-deterministic-record.md)). If an issue nonetheless reaches `pending-acceptance` without a record (the deliverable moved after verification, or verification Passed without one), acceptance must not run that mode and must not dead-end. The accepted return route is this transition: acceptance comments the missing record and gates back so the one legal producer runs on this issue.

It is not a general back-step for a late defect. A game or interface miss at acceptance is still Fail → `pending-implementation` (+ defect).

## Label swap (`gh`)

1. Read current labels: `gh issue view <n> --json labels --jq '.labels[].name'`
2. Collect every existing `status:*` label.
3. Remove them: `gh issue edit <n> --remove-label "status:…" …` (all current status labels).
4. Add target: `gh issue edit <n> --add-label "status:<target>"`.

Never close the issue when applying `status:accepted` (closure is planner-only).

## Gate mode inputs

Action skills pass: issue number, expected `from` status (short name without `status:` prefix or full label), desired `to` status. Abort if current status ≠ `from` (after normalizing). Apply swap only when the transition is in the table above.

## Fail-review cascade

When `review-project-issue` has authorized a cascade under [Cascade (fail review)](../../../../docs/issues/workflow-cascade.md), each authorized issue may be moved to `status:pending-refinement` from any current status except `pending-redefinition` (swap all `status:*` → `pending-refinement`). Expected `from` is that issue’s current status. The gate applies the swap; it does not re-decide authorization. This exception is only for that authorized cascade.

`project-planner-agent` may move an issue from `pending-refinement` back to the `status:*` it held before that cascade, or to `pending-review` when the prior label cannot be read, after commenting why the cascade doc does not still authorize it. The issue that failed review is not this edge. Other callers cannot use it.
