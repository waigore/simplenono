# Close a change with a PR

Shared by skills that open a pull request. Do not copy this procedure into those skills. Run **Before editing** first and **After editing** once the change is ready.

**Contract:** [`docs/pull-requests.md`](../../../../docs/pull-requests.md). Hooks: [`docs/skills.md`](../../../../docs/skills.md).

The calling skill names the branch pattern when there is no issue, whether the PoC ask applies, and the authority and test plan.

## Before editing

1. **Setup:** run `ensure-project-setup` unless it already passed this session. Continue only on Pass.
2. **Branch** per `docs/pull-requests.md`. With no issue, use the branch pattern the calling skill names.

## After editing

3. **PoC ask:** when the calling skill says this change is for a PoC (its build, its assets or style, or its promotion), ask first per [Pull requests](../../../../docs/pocs.md#pull-requests). On no, leave the branch local and stop. A spec-PR ask inside reconcile or promote stays in that skill.
4. **Open** the PR per `docs/pull-requests.md`, using the calling skill's authority and test plan.
5. **Issue hook:** when the work delivers a typed issue and a PR is open, run `implement-project-issue`. Skip it when the calling skill says no issue owns the change.
