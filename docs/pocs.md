# Proofs of concept (PoCs)

A **PoC** is the alternative to specifying a slice with `capture-requirements`. It lives under `pocs/<slug>/`, apart from the main tree. Start one only when the user asks to explore a named uncertainty. Formalized specs and Accepted ADRs constrain it. Placeholders and requirement notes do not. Main code never imports from `pocs/`.

Product **demo mode** is different: [`demo.md`](demo.md).

## Explore, then specify

1. **Explore**: build the slice here. The README records the question, what is in and out, how to run it, the constraints, and the engine when the experiment needs one.
2. **Iterate**: change the PoC on the local branch within those constraints. Several PoCs may exist. Nothing here authorizes main-tree code. Ask before a PR ([Pull requests](#pull-requests)).
3. **Specify**: a kept PoC returns to `capture-requirements` as proposed answers ([`poc-promotion.md`](poc-promotion.md)). Spec depth is the bar for that keep list.

## Request → track → build

1. **Request**: the user asks to explore a named uncertainty. Do not open a PoC because a spec is still empty.
2. **Log**: write purpose, scope, and desired outcome in [`requirements/poc-requests.md`](requirements/poc-requests.md).
3. **File**: when agent-orc or a wave will own the PoC, create a task (or epic) whose body carries those fields. Dependents may use native **blocked-by** that issue only. An interactive session may build from a confirmed README without a task.
4. **Scope / build**: [`scope-poc`](../.agents/skills/scope-poc/SKILL.md), then [`create-poc`](../.agents/skills/create-poc/SKILL.md).

Already-specced main-tree work does not need a new PoC. Product behavior that is not in a formalized spec is specified with `capture-requirements`.

## Pull requests

Commit on the local branch. Ask before any pull request for this PoC, including assets, style, and promotion ([`poc-promotion.md`](poc-promotion.md)). Open it only after the user agrees ([`pull-requests.md`](pull-requests.md)). A no leaves the branch unpushed, including when a task owns the work. Run `implement-project-issue` only after that PR exists.

## Types

| Type | Explores |
|------|----------|
| Engine | Rules, state, feel, camera; no UI screens. Debug overlay allowed. |
| Gameplay | Playable slice with screens and input |

Default to engine unless the question is UI/flow or the user asks otherwise.

## Before building

[`scope-poc`](../.agents/skills/scope-poc/SKILL.md) applies this. Always: [`ensure-project-setup`](../.agents/skills/ensure-project-setup/SKILL.md) passed; purpose, scope, and desired outcome confirmed (README or task). Unfinished specs do not block. Formalized specs and Accepted ADRs the experiment touches are constraints. Record the engine in the README when the experiment needs one. Specify an Engine ADR with `capture-requirements` when the user locks that decision.

Style and assets only when the PoC chooses to show them ([`poc-style-assets.md`](poc-style-assets.md)).

## What is relaxed

- [SOLID](solid.md), [coding conventions](coding-conventions.md), and structure continuity do not apply. `review-code` skips `pocs/`.
- Unit tests optional. Spec-first does **not** require implementing unfinished specs.
- Playtesting per `specs/playtest/` optional, on request.

## Traceability (lightweight)

The PoC README records the exploration question, purpose/scope/outcome, constraints, what was tried, and promotion status. Assumptions do not authorize main code.

## Verification

When a task owns the PoC, `verify-project-issue` checks it against the task’s purpose/outcome and README run instructions. Style/assets per [`poc-style-assets.md`](poc-style-assets.md#verification). No code review.
