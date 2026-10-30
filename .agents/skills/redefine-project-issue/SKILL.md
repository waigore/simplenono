---
name: redefine-project-issue
description: |-
  Replace a task/defect in status:pending-redefinition with a new task that
  states the unresolved problem succinctly, labeled pending-clarification;
  remap parent/blocked-by, comment supersession, close the old issue as
  not_planned. Called by project-planner-agent after the comment-cap lock.
  Keep this skill thin; linking follows create-project-task.

  Examples:
    - planner finds #42 pending-redefinition → new task, close #42
    - user: "Redefine the locked defect #17" → same flow (always a new task)
---

# Redefine project issue

Replace one open `type:task` or `type:defect` in `status:pending-redefinition` with a **new task**. Do not unlock the old conversation. Do not continue work on the locked issue.

**Contract:** [`docs/issues/workflow-comment-cap.md`](../../../docs/issues/workflow-comment-cap.md). **Body shape:** [`docs/issues/body-shapes.md`](../../../docs/issues/body-shapes.md) (Task). **Linking:** [`create-project-task/references/github-issue-linking.md`](../create-project-task/references/github-issue-linking.md).

## Steps

1. **Confirm** the target is open, `type:task` or `type:defect`, and `status:pending-redefinition`. Abort otherwise.
2. **Read** title, body, labels, parent (sub-issue), native `blocked_by` and `blocking`, and priority. Distill the **unresolved problem** into a short Description — no thread replay.
3. **Create** a Task via the linking reference:
   - Labels: `type:task`, `status:pending-clarification` (not `pending-review`), same `priority:*` as the old issue (default `priority:normal` if unlabeled).
   - Body: required Task sections only; Deliverables / AC may say clarification needed. Note `Supersedes #OLD`.
   - Attach the same parent when the old issue had one (depth check still applies).
   - Copy native `blocked_by` from old → new; for each issue old was **blocking**, add `blocked_by` new (before closing old). Mirror `## Dependencies` / `## Parent` on the new body.
4. **Comment** on the old issue: `Superseded by #NEW` (write access may still comment while locked).
5. **Close** the old issue: `gh issue close OLD --reason not_planned`. Do not unlock.
6. **Report** old URL (closed), new URL (`pending-clarification`), parent, and dependency remaps.

## Rules

- Always create a **task**, even when the old issue was a defect.
- Do not unlock. Do not gate-transition `pending-redefinition` via `enforce-task-workflow-status`.
- Keep the new body succinct; clarification is the next step.
- Caller: [`project-planner-agent`](../project-planner-agent/SKILL.md).

## Related

- Comment-cap workflow: `.github/workflows/issue-comment-cap.yml`
- Create pattern: `create-project-task`
