# Project labels

Repository labels categorize issues for agent workflow orchestration. The catalog in [`.github/project-labels.yml`](../.github/project-labels.yml) is the source of truth.

## Sync behavior

The workflow [`.github/workflows/sync-labels.yml`](../.github/workflows/sync-labels.yml) runs [`.github/scripts/sync-labels.sh`](../.github/scripts/sync-labels.sh):

- **Create** a label if its name is missing on the repository.
- **Update** description and color when the name already exists.
- **Never delete** labels that are not listed in the config.

### When it runs

1. **Push to `main`** that changes `.github/project-labels.yml`, the sync script, or the workflow file (covers the first commit when a repo is created from this template, if Actions are enabled).
2. **Manual run**: Actions → **Sync labels** → **Run workflow** (`workflow_dispatch`).

### First run after inheriting this template

1. Create the repository from the template (or clone and push to a new remote).
2. Ensure **Actions** are enabled for the repository (Settings → Actions → General, if needed).
3. If the initial push ran while Actions were disabled, open **Actions → Sync labels → Run workflow** once.

Local sync (requires [`gh`](https://cli.github.com/) and [`yq`](https://github.com/mikefarah/yq)):

```bash
bash .github/scripts/sync-labels.sh
```

## Catalog

| Name | Color | Description |
|------|-------|-------------|
| `type:epic` | `6F42C1` | Broad orchestration epic |
| `type:task` | `0366D6` | Concrete unit of agent work |
| `type:defect` | `D73A4A` | In-game or interface bug (not specs, docs, or planning) |
| `status:pending-review` | `FBCA04` | Pending review |
| `status:pending-refinement` | `E4A8FF` | Reviewed; refinements needed |
| `status:pending-clarification` | `D93F0B` | Needs product-owner clarification |
| `status:pending-implementation` | `1D76DB` | Ready or in progress |
| `status:pending-verification` | `0E8A16` | Implemented; awaiting verification |
| `status:pending-acceptance` | `006B75` | Verified; awaiting acceptance testing |
| `status:accepted` | `5319E7` | Accepted; leave open until planner closes |
| `status:pending-redefinition` | `6E7781` | Comment cap hit; conversation locked pending redefine |
| `no-automerge` | `B60205` | PR: opt out of automatic squash-merge (user-requested only) |
| `priority:critical` | `B60205` | Handle before high and normal |
| `priority:high` | `D93F0B` | Handle before normal; after critical |
| `priority:normal` | `C5DEF5` | Default priority (also implied when unlabeled) |

Status transitions: [`docs/issues/workflow.md`](issues/workflow.md). Priority selection: [`docs/issues/workflow-dispatch.md`](issues/workflow-dispatch.md). Auto-merge and `no-automerge` behavior: [`.github/workflows/automerge.yml`](../.github/workflows/automerge.yml) and [`pull-requests.md`](pull-requests.md).

### Priority

Exactly **one** `priority:*` label on typed issues. Create forms and `create-project-*` skills apply `priority:normal` by default. Unlabeled issues are treated as normal. Effective priority if more than one is present: critical > high > normal; hygiene keeps only the highest. **Humans only** set or change priority; agents must not add, remove, or swap `priority:*` except that hygiene (drop lower duplicates).

## Adding a label

Prefer the **`create-project-label`** skill (`.agents/skills/create-project-label/`). It updates `.github/project-labels.yml` and this catalog, then syncs to GitHub by default.

Manual steps:

1. Add an entry to `.github/project-labels.yml` (`name`, `color` hex without `#`, `description`).
2. Update the catalog table above to match.
3. Sync via push to `main`, `workflow_dispatch`, or `bash .github/scripts/sync-labels.sh`.
