# GitHub issue linking (sub-issues and blocked-by)

Shared procedure for `create-project-epic`, `create-project-task`, and `create-project-defect`. Policy: [`docs/issues/`](../../../../docs/issues/) and [`docs/issues/hierarchy.md`](../../../../docs/issues/hierarchy.md).

Resolve `OWNER` / `REPO` once:

```bash
gh repo view --json nameWithOwner --jq .nameWithOwner
# → OWNER/REPO
```

## Create issue

```bash
gh issue create \
  --title "TITLE" \
  --label "type:task" \
  --label "status:pending-review" \
  --label "priority:normal" \
  --body "$(cat <<'EOF'
## Description
...
EOF
)"
```

Prefer `--body-file` for large bodies. Capture the issue URL/number from the command output.

GitHub MCP alternative: `issue_write` with `method: create`, `labels`, `body`, and optional `parent_issue_number` (attaches as sub-issue at create time).

## Attach parent (sub-issue)

If the issue was created without a parent:

1. Get the child issue **node id** (not the number):

   ```bash
   gh api graphql -f query='
   query($owner:String!,$repo:String!,$n:Int!) {
     repository(owner:$owner, name:$repo) {
       issue(number:$n) { id number }
     }
   }' -f owner=OWNER -f repo=REPO -F n=CHILD_NUMBER \
     --jq .data.repository.issue.id
   ```

2. Add as sub-issue of the parent:

   ```bash
   gh api graphql -f query='
   mutation($parent:ID!,$child:ID!) {
     addSubIssue(input: { issueId: $parent, subIssueId: $child }) {
       issue { number }
       subIssue { number }
     }
   }' -f parent=PARENT_NODE_ID -f child=CHILD_NODE_ID
   ```

   Or use MCP `sub_issue_write` with `method: add`, parent `issue_number`, and `sub_issue_id` (numeric database id from REST `gh api repos/OWNER/REPO/issues/CHILD_NUMBER --jq .id`).

Prefer create-with-parent when available (`gh` / MCP `parent_issue_number`) to avoid a second call.

## Depth check (tasks)

Before attaching a task under a parent, ensure the new issue would be at most **level 3** from the nearest ancestor epic:

| Level | Role |
|-------|------|
| 1 | Epic |
| 2 | Task under epic (or task with no epic ancestor — treat parent chain length carefully) |
| 3 | Task under a level-2 task (leaf) |

Walk parents via GraphQL `parent` / sub-issue metadata until no parent or an epic (`type:epic` label) is found. Count steps from that epic to the proposed parent; if the new child would be depth **> 3**, **abort** and tell the user to flatten the hierarchy.

Practical rule: if the parent is already a task whose parent is also a task under an epic, do not nest further.

```bash
# Inspect parent labels and title
gh issue view PARENT_NUMBER --json number,title,labels,body
```

If GraphQL parent fields are unavailable, infer from the parent's `## Parent` section and labels; ask the user when ambiguous.

## Blocked-by (native dependencies)

For each issue number that **blocks** the new issue:

1. Resolve the blocking issue's numeric REST `id`:

   ```bash
   BLOCKER_ID=$(gh api "repos/OWNER/REPO/issues/BLOCKER_NUMBER" --jq .id)
   ```

2. Add blocked-by on the new issue:

   ```bash
   gh api \
     --method POST \
     "repos/OWNER/REPO/issues/NEW_NUMBER/dependencies/blocked_by" \
     -f issue_id="$BLOCKER_ID"
   ```

GraphQL alternative:

```bash
# Resolve node ids for blocked issue and blocker, then:
gh api graphql -f query='
mutation($issueId:ID!,$blockingIssueId:ID!) {
  addBlockedBy(input: { issueId: $issueId, blockingIssueId: $blockingIssueId }) {
    issue { number }
    blockingIssue { number }
  }
}' -f issueId=BLOCKED_NODE_ID -f blockingIssueId=BLOCKER_NODE_ID
```

Always mirror in the body:

```markdown
## Dependencies
- Blocked by: #8, #11
- Blocking: none
```

Do not remove native dependencies from a create flow except a mistaken link while both issues are still open. GitHub resolves a dependency when its blocker closes. A satisfied blocker that stays open is cleared only by [`unblock-project-issues`](../../unblock-project-issues/SKILL.md).

## Related links (defects)

For related tasks/defects that are not blockers, put `#N` references in `## Related tasks or defects` (and optionally `## Dependencies` as non-blocking notes). Do not invent fake blocked-by edges for mere relatedness.
