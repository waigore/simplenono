# Project issues

Issue templates and agent skills for Epics, Tasks, and Defects. This set of docs is the **source of truth** for issue shape, section requirements, hierarchy, and dependency documentation. Skills and forms must follow it — they must not redefine or diverge from these shapes.

Agents use the matching `create-project-*` skill so labels, sub-issues, and blockers stay consistent. Do not invent ad-hoc issue bodies.

| Doc | Covers |
|-----|--------|
| [requirements.md](requirements.md) | Required sections per type; when to file defect vs task vs clarify |
| [body-shapes.md](body-shapes.md) | Canonical body templates (Epic / Task / Defect) |
| [hierarchy.md](hierarchy.md) | Sub-issues, depth limit, blocked-by ban |
| [workflow.md](workflow.md) | Status labels, transitions, evidence |
| [workflow-comment-cap.md](workflow-comment-cap.md) | Task/defect comment cap; `pending-redefinition` |
| [workflow-cascade.md](workflow-cascade.md) | When a failed review moves another issue |
| [workflow-dispatch.md](workflow-dispatch.md) | Background dispatch agents (one issue per run) |
| [waves.md](waves.md) | Milestones as waves; description = expected deliverable; foundation; vertical epics; optional PoCs; wave audit |

## Types and labels

| Type | Label | Form | Skill |
|------|-------|------|-------|
| Epic | `type:epic` | [`.github/ISSUE_TEMPLATE/epic.yml`](../../.github/ISSUE_TEMPLATE/epic.yml) | `create-project-epic` |
| Task | `type:task` | [`.github/ISSUE_TEMPLATE/task.yml`](../../.github/ISSUE_TEMPLATE/task.yml) | `create-project-task` |
| Defect | `type:defect` | [`.github/ISSUE_TEMPLATE/defect.yml`](../../.github/ISSUE_TEMPLATE/defect.yml) | `create-project-defect` |

Labels: [`.github/project-labels.yml`](../../.github/project-labels.yml). Chooser: [`.github/ISSUE_TEMPLATE/config.yml`](../../.github/ISSUE_TEMPLATE/config.yml) (`blank_issues_enabled: false`).

## Creating issues

| Audience | How |
|----------|-----|
| Humans (GitHub UI) | New issue → Epic / Task / Defect form |
| Agents | `create-project-epic`, `create-project-task`, or `create-project-defect`; wave maps via `plan-project-waves`; filed-wave coherence via `audit-project-wave`; leftover blocked-by cleanup via `unblock-project-issues` ([hierarchy.md](hierarchy.md)) |

Agent defaults: create on GitHub with `status:pending-review` and `priority:normal`. Pass `--no-create` (or “draft only”) for title + body without filing. Optional inputs shared by skills: `title`, parent issue number (where applicable), and a human-requested priority (`critical` / `high` / `normal`). Do not collect or wire blocked-by. Collect content for every required section of the type; ask when missing — do not invent goal, scope, deliverables, or defect expected/actual. Agents must not change priority after create.

## Workflow status

After create, issues move through review → refinement/clarification (as needed) → implementation → verification → acceptance. Contract: [workflow.md](workflow.md). Use `enforce-task-workflow-status` and the `*-project-issue` action skills. Comment cap: [workflow-comment-cap.md](workflow-comment-cap.md).
