---
name: unblock-project-issues
description: |-
  Critically examine leftover native blocked-by edges and delete those not
  justified under the hierarchy ban (preferred sequence, soft order, and
  relatedness are never justified). Does not add dependencies or close issues.
  Use when unblocking issues or at the start of a project-planner-agent pass.

  Examples:
    - user: "Unblock issues whose blockers are done" → examine every open edge
    - user: "Can #40 proceed?" → examine #40's blockers only
    - called by project-planner-agent at the start of a pass
---

# Unblock project issues

Clear leftover native **blocked-by** edges. Creating or remirroring edges is banned ([`docs/issues/hierarchy.md`](../../../docs/issues/hierarchy.md)). Read that ban and apply it. Do not add blocked-by links or close issues.

## Scope

- Default: every open `type:epic`, `type:task`, and `type:defect` issue.
- If the user names issue numbers, judge only those issues' blocked-by links.
- Delete each edge that fails critical examination without asking for confirmation.
- When ordering work across many issues, prefer higher **priority** first (`priority:critical` → `priority:high` → `priority:normal` / unlabeled), then judgement within a tier — same rule as [workflow-dispatch.md](../../../docs/issues/workflow-dispatch.md). Do not change `priority:*` labels.

## Steps

1. Resolve `OWNER/REPO`:

   ```bash
   gh repo view --json nameWithOwner --jq .nameWithOwner
   ```

2. List the target issues (`gh issue list --state open --limit 200` once per type label; raise the limit if a page comes back full). Order the work by priority tier then judgement (see Scope). For each issue, list native blockers with `gh api --paginate`. Each object includes numeric REST `id` and issue `number`:

   ```bash
   gh api --paginate "repos/OWNER/REPO/issues/NUMBER/dependencies/blocked_by"
   ```

   Skip an issue whose list is empty.
3. For each blocker, read both issues' titles and bodies (`gh issue view … --json title,body,state,labels`). Critically examine whether the edge is justified under the ban:

   - **Not justified** (delete): preferred sequence, soft order, mere relatedness, mistaken link, scopes diverged, equivalent work already owned elsewhere, or any use of blocked-by after the ban.
   - **Also delete** when the default branch already meets the blocker's done-conditions (task deliverables/AC, epic goal, defect expected behavior) — optional check via `git fetch` + `git grep` / `git ls-tree` on `origin/<default-branch>` only.

   Under the ban, keep an edge only if the user explicitly ordered that specific edge retained in this run.
4. On a deletion, `ISSUE_ID` is the blocker's REST `id` from step 2:

   ```bash
   gh api --method DELETE \
     "repos/OWNER/REPO/issues/NUMBER/dependencies/blocked_by/ISSUE_ID"
   ```

5. After deletions on an issue, if the body still has `## Dependencies` or `Blocked by` / `Blocking` lines, remove that section or those lines only. Change no other body section.
6. Do not change `status:*` labels or edit the repository.

## Report

For every edge: blocked issue, blocker, removed or kept, and the reason.

- **Removed (ban / obsolete):** state why the edge is not justified under the ban.
- **Removed (satisfied):** name the done-conditions and default-branch paths when that check was used.
- **Kept:** only when the user explicitly ordered retention; quote that order.

## Related

- Called at the start of [`project-planner-agent`](../project-planner-agent/SKILL.md)
- Linking: [`github-issue-linking.md`](../create-project-task/references/github-issue-linking.md)
- Status labels: [`docs/issues/workflow.md`](../../../docs/issues/workflow.md)
