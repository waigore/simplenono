# GitHub issue linking (sub-issues)

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

## Blocked-by (banned)

Do **not** create native blocked-by / blocking edges or body `Blocked by` / `Blocking` / `## Dependencies` blocker lists. See [`hierarchy.md`](../../../../docs/issues/hierarchy.md). Leftover edges: [`unblock-project-issues`](../../unblock-project-issues/SKILL.md).

## Related links (defects)

For related tasks/defects, put `#N` references in `## Related tasks or defects`. Do not invent blocked-by edges for relatedness or preferred sequence.
