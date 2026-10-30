# Issue hierarchy and dependencies

Parent/child and blocker rules for Epics, Tasks, and Defects. Index: [README.md](README.md). Exact `gh` / API steps: [`.agents/skills/create-project-task/references/github-issue-linking.md`](../../.agents/skills/create-project-task/references/github-issue-linking.md).

## Hierarchy (sub-issues)

Use GitHub **sub-issues** for parent/child:

- An **epic** is the usual parent of tasks that deliver its outcome.
- A **task** may be a sub-issue of an epic **or** of another task.
- **Maximum depth: 3 levels from epic to leaf** (epic → task → task). Do not create a fourth level.
- Defects are not required to sit under an epic; link related work in the body and optionally attach as a sub-issue when it clearly belongs to that parent.

Skills reject creates that would exceed the depth limit.

## Dependencies

For blockers and ordering:

1. Set GitHub native **blocked-by** relationships (REST or GraphQL).
2. Mirror them in the issue body under `## Dependencies`:

```markdown
## Dependencies
- Blocked by: #8, #11
- Blocking: none
```

Use `none` when there are no blockers or no issues this one blocks. Merely related work belongs in `## Related tasks or defects` (defects) or prose — not as fake blocked-by edges.

Closing a blocker resolves its native dependency. Acceptance (`status:accepted`) is a human product-owner gate and does **not** gate dependency clearance; accepted issues may stay open until [`project-planner-agent`](../../.agents/skills/project-planner-agent/SKILL.md) closes them ([workflow.md](workflow.md)). While the blocker is open, [`unblock-project-issues`](../../.agents/skills/unblock-project-issues/SKILL.md) deletes an edge when **either** holds:

1. **Satisfied in repo** — the default branch meets every done-condition in the blocker body. A task uses deliverables and acceptance criteria; an epic uses its goal; a defect uses expected behavior. Count code, specs, pocs, and playtest evidence on that branch only (not other branches or open PRs).
2. **Edge not warranted** — from both issue bodies and default-branch evidence, the blocked issue no longer depends on that blocker (or never did)—including scopes that diverged, a mistaken link, or equivalent work already on the default branch under other ownership.

Keep the edge when done-conditions are still missing **and** the dependency still reads as real, or when a condition cannot be checked. The skill adds no blocked-by edges. A create flow may still remove a mistaken link while both issues are open (linking doc above). After a deletion, set the blocked issue's `Blocked by` line and the blocker's `Blocking` line from the native links that remain (`none` when empty). Do not close the blocker to force resolution.
