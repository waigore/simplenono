---
name: verify-project-issue
description: |-
  Independently verify an epic/task/defect in status:pending-verification against
  its deliverables; post pass or fail and advance or return status. When linked
  PRs contain code changes, run review-code and treat a Fail as verify Fail.
  When an Applies deterministic axis can move, run run-quality-evaluators and
  treat a failed or blocked axis as verify Fail; a missing record is never
  deferred to acceptance.
  Use when checking implemented work (smoke test) before acceptance.

  Examples:
    - user: "Verify #12" → independent checks, pass/fail comment, gate status
    - user: "Verification failed on #12: missing tests" → fail → pending-implementation
---

# Verify project issue

Veneer over the [action shell](../enforce-task-workflow-status/references/action-shell.md) for `status:pending-verification`.

**Delegates when applicable:** [`review-code`](../review-code/SKILL.md) · [`review-asset`](../review-asset/SKILL.md) · [`run-quality-evaluators`](../run-quality-evaluators/SKILL.md) (`deterministic`) · [Verification in `docs/pocs.md`](../../../docs/pocs.md#verification) · [`docs/poc-style-assets.md`](../../../docs/poc-style-assets.md#verification)

**Type routing:** [`docs/issues/requirements.md`](../../../docs/issues/requirements.md) (When to file what).

Load the implementation comment and linked PRs, commits, and paths. Check the deliverables themselves. Do not treat the implementation comment as the verdict.

## Check

Smoke-level, and independent of the implementor's claim:

- Deliverables align with what the issue demands.
- Coding, architecture, spec, and doc standards are followed where they apply.
- No major gaps, ambiguities, or underspecification that require revision.
- If coding: unit-test coverage is adequate, and tests cover the program logic.
- **If any linked PR contains code changes:** run [`review-code`](../review-code/SKILL.md) on those diffs. Include its report. A Fail from that skill fails verification. Do not skip it when linked PRs include implementation files.
- **If any linked PR adds or changes cataloged assets:** run [`review-asset`](../review-asset/SKILL.md) on those entries. Include its report. A Fail from that skill fails verification.
- **If the deliverable can move an Applies deterministic axis** in [`specs/definition/quality.md`](../../../specs/definition/quality.md): run [`run-quality-evaluators`](../run-quality-evaluators/SKILL.md) in `deterministic` mode. This run is the **only** legal producer of a deterministic record and this skill is the only stage that may run it. A **fail** or **blocked** row fails verification. A missing invariant is this failure and is not a defect. **N/A** from that skill is not a Fail.
- **Pass precondition — the record exists.** When an Applies deterministic axis can move, verification cannot Pass unless a `docs/quality/evidence/issue-<n>/<run-id>/manifest.md` record for this deliverable commit exists and its rows are not **fail** or **blocked**. Verification may not defer that run to acceptance: "the acceptance run will produce or request it" is a verification **Fail**, not a Pass with a note. Environment or harness unavailable so the run cannot happen: also **Fail** with that reason, so the issue returns to implementation with a named blocker. Layout and writer rules: [`docs/quality/evidence/README.md`](../../../docs/quality/evidence/README.md).
- **If the deliverable is a PoC** (`pocs/<slug>/`): check per [Verification in `docs/pocs.md`](../../../docs/pocs.md#verification) and [`docs/poc-style-assets.md`](../../../docs/poc-style-assets.md#verification) instead of code review and unit-test coverage. A Fail there fails verification.
- **If the deliverable is product demo mode** (main tree): verify against [`specs/design/demo.md`](../../../specs/design/demo.md) and normal code review and tests ([`docs/demo.md`](../../../docs/demo.md)).
- **If main-tree UI changed:** compare to the **approved** screen mockup(s) per [`docs/ux-mockups.md`](../../../docs/ux-mockups.md). Material drift in layout, palette, or functional behavior → **Fail**, and file an interface defect via `create-project-defect` when appropriate. Not pixel-perfect. If the catalog row is no longer `approved`, Fail and return to implementation.

**Hygiene / non-material gaps** (stale issue IDs in maps or [`story-rows.md`](../../../specs/playtest/story-rows.md), soft acceptance-criteria wording, paperwork with no effect on implementation or functional outcome): repair them in the deliverable or a focused follow-up commit or PR on this work. Do not Fail solely for that, and do not file a defect. A story-row `none` with a durable reason (no live defect link) is valid. If repair cannot land here and the gap is **material** with no open owner, create a **task** via `create-project-task`, note it, and still Pass when the game and implementation checks hold.

## Outcome

- **Pass** — comment summarizing what was checked against each deliverable (include a delegated review Pass when one ran, and the deterministic evidence path — required, with its deliverable commit, when an Applies deterministic axis can move; note any hygiene repair or material follow-up task). Gate: `pending-verification` → `pending-acceptance`.
- **Fail** — detail **material** implementation, behavior, or standards gaps (include delegated review findings when that review failed, and the evaluator report when a row failed or was blocked). Gate: `pending-verification` → `pending-implementation`. No defect for spec, doc, or map problems. Repair, clarify on this issue, or file a task per routing.
