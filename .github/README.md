# `.github/`

GitHub configuration for this repository: labels, issue forms, and workflows.

## Contents

| Path | Covers |
|------|--------|
| [`project-labels.yml`](project-labels.yml) | Declarative repository labels (source of truth) |
| [`ISSUE_TEMPLATE/`](ISSUE_TEMPLATE/) | Epic / Task / Defect issue forms |
| [`pull_request_template.md`](pull_request_template.md) | PR body sections ([`docs/pull-requests.md`](../docs/pull-requests.md)) |
| [`workflows/sync-labels.yml`](workflows/sync-labels.yml) | Sync labels on push to `main` or `workflow_dispatch` |
| [`workflows/issue-comment-cap.yml`](workflows/issue-comment-cap.yml) | Task/defect 21st comment → `status:pending-redefinition` + permanent lock ([`docs/issues/workflow-comment-cap.md`](../docs/issues/workflow-comment-cap.md)) |
| [`workflows/automerge.yml`](workflows/automerge.yml) | Squash auto-merge for all same-repo PRs; opt out with `no-automerge` (user-requested only) |
| [`workflows/pr-hygiene.yml`](workflows/pr-hygiene.yml) | Required check: PR title/body lint ([`docs/pull-requests.md`](../docs/pull-requests.md)) |
| [`workflows/spec-lint.yml`](workflows/spec-lint.yml) | Required check: structural spec rules ([`docs/spec-lint.md`](../docs/spec-lint.md)) |
| [`workflows/code-lint.yml`](workflows/code-lint.yml) | Required check: project-owned lint/format steps per [`docs/coding-conventions.md`](../docs/coding-conventions.md); passes with a notice when there are none |
| [`workflows/unit-tests.yml`](workflows/unit-tests.yml) | Required checks: `Unit tests` then `Coverage` per [`docs/coding-conventions.md`](../docs/coding-conventions.md); each passes with a notice when not configured |
| [`scripts/sync-labels.sh`](scripts/sync-labels.sh) | Local / CI label sync script |
| [`scripts/asset_catalog.py`](scripts/asset_catalog.py) | CI integrity check of asset catalog entry files per `specs/assets/catalog.md`; roots from ADR-0003 (`assets/catalog/`, `game/assets/`) |
| [`scripts/new_asset_id.py`](scripts/new_asset_id.py) | Generate asset IDs (UUID version 7) per `specs/assets/catalog.md`: the only way to mint one — never type or copy a UUID; `is_asset_id` validates one |
| [`scripts/pr_hygiene.py`](scripts/pr_hygiene.py) | Local / CI PR hygiene lint (one function per rule); tests in [`scripts/tests/`](scripts/tests/) |
| [`scripts/spec_lint.py`](scripts/spec_lint.py) | Local / CI spec lint; tests in [`scripts/tests/`](scripts/tests/) |

Label catalog and sync docs: [`docs/labels.md`](../docs/labels.md). Issue contract: [`docs/issues/`](../docs/issues/). First-time remote workflow: [`docs/github-repo-setup.md`](../docs/github-repo-setup.md).
