---
name: create-project-feedback
description: |-
  File a type:feedback issue: dispose every point, critically examine
  requirement changes, lock shape via capture-requirements, then file
  follow-up tasks/epics/defects. No GitHub form.
  Use when the user supplies feedback to record.

  Examples:
    - user: "File this feedback: the jump feels late" → dispose, file follow-ups, pending-resolution or resolved
    - user: "Draft the feedback issue only" → --no-create
---

# Create project feedback

Veneer for `type:feedback`. Contract: [`docs/issues/feedback.md`](../../../docs/issues/feedback.md).

**Create:** [`typed-issue-create.md`](../create-project-task/references/typed-issue-create.md).

## Deltas

- No parent and no blocked-by. Priority `priority:normal` on the feedback issue.
- Required **Points**. Split prose into points; put the raw text in **Notes**.
- In the same interactive run, dispose every point per the contract before create:
  - **Requirement change:** critical exam (purpose, feasibility, cheaper/other means — judgement) → wait for keep/revise/drop → [`capture-requirements`](../capture-requirements/SKILL.md) to lock shape and which specs must change (do not amend specs here) → file a task or epic via `create-project-task` / `create-project-epic`.
  - **Defect:** file via `create-project-defect`.
  - **Already covered** / **No action:** record only; no new issue.
- Follow-ups use `priority:high` and any `Supersedes #N` per the contract. Prefer an existing epic as parent when one owns the area.
- Fill **Analysis** and **Related issues** before create. Initial status `pending-resolution` when Related issues names open work; otherwise `resolved`.
- Do not leave disposition or filing for `handle-feedback-agent`. That skill only tracks related issues to `resolved`. Clarification lives on filed tasks/defects, not on the feedback issue.

## Related

- Contract: `docs/issues/feedback.md`
- Body: `docs/issues/body-shapes.md`
