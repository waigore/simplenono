---
name: scope-poc
description: |-
  Clarify a proof-of-concept exploration from a logged request or issue:
  purpose, scope, desired outcome, type, and tool/env blockers only.
  Contract: docs/pocs.md Before building. Unfinished specs do not bind it.
  Formalized specs and Accepted ADRs constrain it.
  Use when scoping a PoC, or when create-poc starts its scope phase.

  Examples:
    - user: "PoC the water rendering approach" → load or write request; confirm purpose/scope/outcome
    - create-poc: Scope → run this; do not restate the gate
    - issue #12 pending-implementation with purpose in body → classify and return pass or misses
---

# Scope PoC

Contract: [Before building](../../../docs/pocs.md#before-building) and [Types](../../../docs/pocs.md#types). Apply them. Do not restate them.

## Steps

1. **Setup**: [`docs/skills.md`](../../../docs/skills.md) `ensure-project-setup` hook.
2. **Always-on**: apply [Before building](../../../docs/pocs.md#before-building). On a miss, stop. Do not add a high-level lock or an Engine ADR.
3. **Load request**: prefer the given task body (purpose, scope, desired outcome). Else read [`docs/requirements/poc-requests.md`](../../../docs/requirements/poc-requests.md). If neither has a confirmed request, draft one with the user and log it per that file before continuing.
4. **Already scoped**: when the task is `status:pending-implementation` and its body has confirmed purpose/scope/outcome, classify and return pass or the misses. Do not confirm again.
5. **Draft**: one exploration question; type (engine|gameplay); purpose; scope in/out; desired outcome; formalized specs and Accepted ADRs the experiment must respect; exclusions. Prefer the smallest experiment that can prove or disprove the claim.
6. **Blockers**: only tools, env, or Engine ADR gaps this PoC needs. Unfinished product specs do **not** block. A clash with a formalized spec or Accepted ADR stops for the user: change the spec, change the experiment, or drop the claim. When style/assets are in scope, classify gaps per [poc-style-assets Before building](../../../docs/poc-style-assets.md#before-building).
7. **Confirm** question, type, purpose, scope, outcome, citations, blockers. Wait.
8. **Resolve** tool/env blockers only. Update the log Status/Issue when filing. An interactive session may build once the README fields are confirmed, with no task. When agent-orc or a wave will own the PoC, use the given task or [`create-project-task`](../create-project-task/SKILL.md) / epic whose body carries the confirmed fields, and wait until `status:pending-implementation`. Return pass only when [Before building](../../../docs/pocs.md#before-building) is met.

## Rules

- Requirement notes and the PoC log are not authority for main code.
- Do not build the PoC. When [`create-poc`](../create-poc/SKILL.md) called this skill, return pass to it.
