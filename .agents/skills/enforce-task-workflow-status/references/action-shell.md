# Issue workflow action shell

Shared by `review-project-issue`, `refine-project-issue`, `clarify-project-issue`, `implement-project-issue`, `verify-project-issue`, and `accept-project-issue`. The calling skill names the expected status, the decision, and any extra checks. Do not copy this procedure into those skills.

**Contract:** [`docs/issues/workflow.md`](../../../../docs/issues/workflow.md)

**Gate:** [`../SKILL.md`](../SKILL.md) and [`status-transitions.md`](status-transitions.md)

## Every run

1. **Load** issue `n` (title, body, labels, and whatever the calling skill names).
2. **Assert** the expected `status:*` via the gate. Abort if the status is wrong.
3. **Decide and evidence** exactly as the calling skill says. Evidence is freeform; intent must be clear. Post it as an issue comment. Refinement also edits the body.
4. **Gate** the calling skill's from→to via `enforce-task-workflow-status`. Skip the gate only when that skill says to stay put.
5. **Report** URL, outcome, and new status, plus anything the calling skill adds.

## Rules

- Do not redefine the state machine.
- Call `enforce-task-workflow-status` for every label change.
- File a defect only when the calling skill says the failure is in-game or interface behavior. Spec, doc, map, and paperwork problems are refinement, clarification, or a task ([`requirements.md`](../../../../docs/issues/requirements.md)).
