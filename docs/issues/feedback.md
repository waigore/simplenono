# Feedback issues

`type:feedback` records user feedback until the work it starts is finished. Epic, task, and defect statuses stay in [workflow.md](workflow.md). Body: [body-shapes.md](body-shapes.md). File with `create-project-feedback`. Lifecycle: `handle-feedback-agent`.

## Record

Agents file these issues. There is no GitHub form. Split pasted prose into one bullet per point. Keep the raw text in **Notes**. **Analysis** and **Related issues** start as `None`. Labels: `type:feedback`, `status:pending-analysis`, `priority:normal`.

## Dispositions

| Disposition | Action |
|-------------|--------|
| Defect | New or updated defect. In-game or interface only ([requirements.md](requirements.md)). |
| Requirement change | New or updated task whose deliverables are the spec update and the implementation. |
| Already covered | Name the owning issue. No new issue. |
| No action | Record why. No issue. |
| Needs clarification | Do not file that point. |

File every clear point even when another point needs a decision. A later pass must not file a point that already has an issue link. Each **Analysis** bullet is the point text, the disposition name, and `#N` or `None`.

## Existing issues

Comment on the owning issue. Edit its body only in `pending-review`, `pending-refinement`, `pending-clarification`, or `pending-redefinition`. In `pending-implementation` or later, or when closed, file a new task or defect. Do not change its status or parent.

## Supersede

When a point contradicts an open task or defect, file the replacement at `pending-review` with the same parent and `Supersedes #OLD` in the description. Copy acceptance criteria the feedback leaves standing. Comment `Superseded by #NEW` and this feedback number, then `gh issue close OLD --reason not_planned`. **Related issues** names the new issue. Leave epics open. This close replaces [`redefine-project-issue`](../../.agents/skills/redefine-project-issue/SKILL.md).

New tasks use an existing epic as parent when one owns the area; otherwise no parent. Depth: [hierarchy.md](hierarchy.md).

## Priority

Tasks and defects created, updated, or filed as replacements are `priority:high`. Set that when filing or adopting the issue. Leave an existing `priority:critical` label. The planner restores `priority:high` if a later edit drops it. The feedback issue stays `priority:normal`.

## Status

Exactly one `status:*`. Gate with `enforce-task-workflow-status`.

| Label | When |
|-------|------|
| `status:pending-analysis` | Create default, and the return from clarification. |
| `status:pending-clarification` | Any point still needs a product-owner decision. |
| `status:pending-resolution` | Analysis is done and a related issue is still open and not accepted. |
| `status:resolved` | Every related issue is `status:accepted` or closed, including closed without acceptance. Points with no follow-up do not block. Leave the issue open. |

Transitions: [`status-transitions.md`](../../.agents/skills/enforce-task-workflow-status/references/status-transitions.md). One issue per run (`pending-analysis`, else `pending-resolution`; [workflow-dispatch.md](workflow-dispatch.md)). **Related issues** lists open or newly filed work. Comment the evidence. Do not edit the repo or close the feedback issue.

An open owner for an already-covered point is a related issue.

## Planner

For open tasks and defects named by an open feedback issue: unblock them first, keep them in the plan, restore `priority:high` (`priority:critical` stays), and close them once accepted before other accepted issues. Close every open feedback issue in `status:resolved` on that pass.
