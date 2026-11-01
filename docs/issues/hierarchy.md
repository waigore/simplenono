# Issue hierarchy and dependencies

Parent/child rules for Epics, Tasks, and Defects. Index: [README.md](README.md). Exact `gh` / API steps: [`.agents/skills/create-project-task/references/github-issue-linking.md`](../../.agents/skills/create-project-task/references/github-issue-linking.md).

## Hierarchy (sub-issues)

Use GitHub **sub-issues** for parent/child:

- An **epic** is the usual parent of tasks that deliver its outcome.
- A **task** may be a sub-issue of an epic **or** of another task.
- **Maximum depth: 3 levels from epic to leaf** (epic → task → task). Do not create a fourth level.
- Defects are not required to sit under an epic; link related work in the body and optionally attach as a sub-issue when it clearly belongs to that parent.

Skills reject creates that would exceed the depth limit.

## Blocked-by (banned)

**Do not create or remirror** GitHub native **blocked-by** / **blocking** edges, and do not put `Blocked by` / `Blocking` lines (or a `## Dependencies` blocker list) on issue bodies. Related work belongs in `## Related tasks or defects` (defects) or Notes — never as a dependency graph or preferred sequence.

Leftover native edges: [`unblock-project-issues`](../../.agents/skills/unblock-project-issues/SKILL.md) critically examines each and deletes it when not justified under this ban (preferred sequence, soft order, relatedness, and any new use of blocked-by are never justified). Acceptance does not gate clearance.
