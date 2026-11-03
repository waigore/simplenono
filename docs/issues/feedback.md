# Feedback issues

`type:feedback` records user feedback until the work it starts finishes. Epic/task/defect statuses: [workflow.md](workflow.md). Body: [body-shapes.md](body-shapes.md). File and dispose with `create-project-feedback`. Track linked work with `handle-feedback-agent`.

## Record

Interactive, one run. No GitHub form. Split prose into one bullet per point; raw text in **Notes**. Dispose every point before create; fill **Analysis** and **Related issues**. Labels: `type:feedback`, `priority:normal`, plus `status:pending-resolution` (open related work) or `status:resolved` (none).

## Dispositions

| Disposition | Action |
|-------------|--------|
| Defect | New or updated defect ([requirements.md](requirements.md)). |
| Requirement change | Critical exam, lock shape, then task or epic (below). |
| Already covered | Name the owning issue. No new issue. |
| No action | Record why. No issue. |

No feedback-level clarification — filed tasks/defects own `pending-clarification`. Each **Analysis** bullet: point text, disposition, `#N` or `None`.

## Requirement change

1. Critically examine purpose (as stated), feasibility, and options that reduce effort or reach the goal another way (judgement). Wait for keep, revise, or drop.
2. `capture-requirements` locks the requirement shape and which specs must change. Do not amend those specs here.
3. File a task, or an epic when large (`create-project-task` / `create-project-epic`). Deliverables: spec updates and implementation. Cite the locked shape and specs to amend.

## Existing issues

Comment on the owning issue. Edit its body only in `pending-review`, `pending-refinement`, `pending-clarification`, or `pending-redefinition`. In `pending-implementation` or later, or when closed, file a new task or defect. Do not change its status or parent.

## Supersede

When a point contradicts an open task or defect, file the replacement at `pending-review` with the same parent and `Supersedes #OLD` in the description. Copy acceptance criteria the feedback leaves standing. Comment `Superseded by #NEW` and this feedback number, then `gh issue close OLD --reason not_planned`. **Related issues** names the new issue. Leave epics open. Replaces [`redefine-project-issue`](../../.agents/skills/redefine-project-issue/SKILL.md).

New tasks use an existing epic as parent when one owns the area; otherwise no parent. Depth: [hierarchy.md](hierarchy.md).

## Priority

Tasks and defects created, updated, or filed as replacements are `priority:high` (keep `priority:critical`). Planner restores `priority:high` if a later edit drops it. Feedback stays `priority:normal`.

## Status

Exactly one `status:*`. Gate with `enforce-task-workflow-status`.

| Label | When |
|-------|------|
| `status:pending-resolution` | Create when **Related issues** names open work |
| `status:resolved` | Create when none; or every related issue is `accepted` or closed. Leave open. |

Only transition: `pending-resolution` → `resolved`. One issue per `handle-feedback-agent` run ([workflow-dispatch.md](workflow-dispatch.md)). Comment evidence. Do not edit the repo, file work, clarify, or close the feedback issue. An open already-covered owner is a related issue.

## Planner

For open tasks/defects named by open feedback: unblock first, keep in plan, restore `priority:high` (`critical` stays), close once accepted before other accepted issues. Close every open feedback in `status:resolved` on that pass.
