---
name: create-poc
description: |-
  Build a proof of concept under pocs/<slug>/ after scope-poc passes:
  freer exploration of a technical or functional claim. Formalized specs
  constrain it. Unfinished specs, SOLID, and coding conventions do not.
  Use when the user asks for a PoC, prototype, or proof that a design is
  achievable (rendering, scene setup, feel, tooling).

  Examples:
    - user: "Build a PoC of the core loop feel" → scope-poc, then build an engine PoC
    - user: "PoC task #21 passed review, build it" → scope check, then build
    - user: "Promote the movement PoC" → use reconcile-poc first
---

# Create PoC

Contract: [`docs/pocs.md`](../../../docs/pocs.md) and [`docs/poc-style-assets.md`](../../../docs/poc-style-assets.md). README template: [`assets/poc-readme.md`](assets/poc-readme.md).

## Steps

### Scope

Run [`scope-poc`](../scope-poc/SKILL.md). Continue only when it passes. Do not restate its gate or scope rules.

### Build

1. **Start** per [`../manage-asset/references/change-pr.md`](../manage-asset/references/change-pr.md) (before editing). Branch `task/<n>-poc-<slug>` when a task owns the PoC, otherwise `chore/poc-<slug>`. Create `pocs/<slug>/`. Copy the template to `pocs/<slug>/README.md` and fill it. Issue may be none. Record the engine when the experiment needs one, and the formalized specs and Accepted ADRs it must respect. Do not require an Engine ADR. Do not contradict a formalized spec or an Accepted ADR.
2. **Produce assets** under the PoC task for each listed asset not yet cataloged: run [`manage-asset`](../manage-asset/SKILL.md) or [`register-asset`](../register-asset/SKILL.md) as chosen in scope. Record pipeline findings; land material spec fixes as tasks (or repair in place), and game/interface bugs as defects — see [`docs/issues/requirements.md`](../../../docs/issues/requirements.md). If assets would push the PoC PR past ~30 files, land them first.
3. **Implement** only enough to answer the exploration question. Optional comments citing design/ADR IDs when drawn on. Do not touch code outside `pocs/<slug>/`.
4. **Smoke run**: launch the PoC; record how to run it and what you saw vs the desired outcome. Playtest per `specs/playtest/` only if the user asks.
5. **PR** per [`../manage-asset/references/change-pr.md`](../manage-asset/references/change-pr.md) (after editing). Apply the PoC ask. Authority may be N/A (PoC) plus any ADRs or design cited. Skip `implement-project-issue` when no task owns the PoC.

## Rules

- Spec-first does **not** require the PoC to implement unfinished specs. Do not contradict a formalized spec or an Accepted ADR. Assumptions do not authorize main code.
- Included style and assets follow [`docs/poc-style-assets.md`](../../../docs/poc-style-assets.md).
- `docs/solid.md`, `docs/coding-conventions.md`, and structure continuity do not apply inside `pocs/`.
- Main code never imports from `pocs/`. Reusing PoC learning starts with [`reconcile-poc`](../reconcile-poc/SKILL.md), then [`promote-poc`](../promote-poc/SKILL.md) for a non-empty keep list.
- Do not grow scope during the build. A new need goes back through [`scope-poc`](../scope-poc/SKILL.md).
