# Comment cap (tasks and defects)

Open `type:task` and `type:defect` issues may have at most **20** comments. When the **21st** lands, [`.github/workflows/issue-comment-cap.yml`](../../.github/workflows/issue-comment-cap.yml) swaps `status:*` → `status:pending-redefinition` and **locks the conversation permanently** (do not unlock). Epics are exempt. All comments count.

## `status:pending-redefinition`

Applied only by that workflow — not by action skills. Conversation is locked. Background dispatch does not pick these up. [`project-planner-agent`](../../.agents/skills/project-planner-agent/SKILL.md) replaces each one via [`redefine-project-issue`](../../.agents/skills/redefine-project-issue/SKILL.md): new task at `pending-clarification`, remap parent/blocked-by, supersede comment, close old as `not_planned`. Never cascade onto or off this status ([workflow-cascade.md](workflow-cascade.md)).

Status catalog and other transitions: [workflow.md](workflow.md).
