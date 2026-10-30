# GitHub setup: example commands

Non-binding examples for the outcomes in [`github-repo-setup.md`](github-repo-setup.md). GitHub's APIs and `gh` change; when an example fails, adapt it or use another tool. Check results against the contract, not these commands.

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api "repos/$REPO" --jq .permissions.admin   # expect true
```

## Remotes

Skip when this repo is the template (`gh repo view --json isTemplate -q .isTemplate` is `true`).

```bash
git remote get-url origin
gh repo set-default --view          # expect same repo as origin
gh api "repos/$REPO" --jq '.template_repository.full_name // empty'
# If upstream missing (child only):
# git remote add upstream https://github.com/<template_full_name>.git
# gh repo set-default origin        # restore default after adding upstream
```

## Actions

```bash
gh api "repos/$REPO/actions/permissions"              # expect enabled: true
gh api -X PUT "repos/$REPO/actions/permissions" -F enabled=true
gh workflow run spec-lint.yml --ref main && gh run list --workflow spec-lint.yml --limit 1
```

## Ruleset for `main`

List with `gh api "repos/$REPO/rulesets"`. Create with `POST`; update an existing one with `PUT "repos/$REPO/rulesets/<id>"`.

```bash
gh api -X POST "repos/$REPO/rulesets" --input - <<'EOF'
{
  "name": "Protect main",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": {"ref_name": {"include": ["refs/heads/main"], "exclude": []}},
  "rules": [
    {"type": "deletion"},
    {"type": "non_fast_forward"},
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 0,
      "dismiss_stale_reviews_on_push": false,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": false}},
    {"type": "required_status_checks", "parameters": {
      "strict_required_status_checks_policy": true,
      "required_status_checks": [
        {"context": "Spec lint"}, {"context": "PR hygiene"}, {"context": "Code lint"},
        {"context": "Unit tests"}, {"context": "Coverage"}]}}
  ]
}
EOF
```

Verify the rules in effect on `main` (rulesets and classic protection together):

```bash
gh api "repos/$REPO/rules/branches/main" --jq '[.[] | {type, parameters}]'
gh api "repos/$REPO/rulesets/<id>" --jq '{enforcement, bypass_actors}'
```

## Merge settings

```bash
gh api -X PATCH "repos/$REPO" \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -F allow_update_branch=true -F allow_auto_merge=true -F delete_branch_on_merge=true \
  -f squash_merge_commit_title=PR_TITLE -f squash_merge_commit_message=PR_BODY

gh api "repos/$REPO" --jq '{allow_squash_merge, allow_merge_commit, allow_rebase_merge,
  allow_update_branch, allow_auto_merge, delete_branch_on_merge,
  squash_merge_commit_title, squash_merge_commit_message}'
```

## Issue and pull request creation

UI: Settings → General → Features → Issues / Pull requests → Creation allowed by: **Collaborators only**. Collaborator = anyone invited (personal repo) or triage/write/maintain/admin (org). Commenting on existing issues is unaffected.

GraphQL: read and set `issueCreationPolicy` / `pullRequestCreationPolicy` (`ALL` or `COLLABORATORS_ONLY`). Expect both `COLLABORATORS_ONLY`.

```bash
OWNER=$(gh repo view --json owner -q .owner.login)
NAME=$(gh repo view --json name -q .name)
gh api graphql -f query="
query {
  repository(owner: \"$OWNER\", name: \"$NAME\") {
    id issueCreationPolicy pullRequestCreationPolicy
  }
}"

# Apply (replace RID with repository id from the query above):
# RID=...
# gh api graphql -f query='
# mutation($id: ID!) {
#   updateRepository(input: {
#     repositoryId: $id
#     issueCreationPolicy: COLLABORATORS_ONLY
#     pullRequestCreationPolicy: COLLABORATORS_ONLY
#   }) {
#     repository { issueCreationPolicy pullRequestCreationPolicy }
#   }
# }' -f id="$RID"
```

## Labels

Prints configured labels missing on GitHub; expect no output:

```bash
comm -23 <(sed -n 's/^- name: //p' .github/project-labels.yml | sort) \
  <(gh label list --repo "$REPO" --limit 1000 --json name -q '.[].name' | sort)
```
