# Deterministic record (verify ↔ acceptance)

Which stage may produce a `deterministic` quality record, and what acceptance does with it. Status transitions: [workflow.md](workflow.md). Axes: [`specs/definition/quality.md`](../../specs/definition/quality.md).

## One legal producer

| Mode | Who may write a record | Who may cite it |
|------|------------------------|-----------------|
| `deterministic` | [`verify-project-issue`](../../.agents/skills/verify-project-issue/SKILL.md) running [`run-quality-evaluators`](../../.agents/skills/run-quality-evaluators/SKILL.md), or a user-directed run | Verification, and acceptance |
| `llm-judge` | [`accept-project-issue`](../../.agents/skills/accept-project-issue/SKILL.md), or a user-directed run | Acceptance |

A `manifest.md` names its issue, mode, and deliverable commit. Whoever writes it changes neither the rubric nor the target. Layout: [`docs/quality/evidence/README.md`](../quality/evidence/README.md).

## At verification

When the deliverable can move an Applies deterministic axis, verification **cannot Pass** without a `docs/quality/evidence/issue-<n>/<run-id>/manifest.md` record for that deliverable commit.

- A **fail** or **blocked** row, a deferral of the run to acceptance, or a harness that prevents the run is a verification **Fail** — never a Pass with a note. Fail returns the issue to `pending-implementation` with a named blocker.
- **N/A** from `run-quality-evaluators` is not a Fail and writes nothing.

## At acceptance

- Acceptance **cites** the record for the same deliverable commit. It does not edit it, run that mode, or change the target. A **fail** or **blocked** row is an acceptance Fail.
- No record for the deliverable commit (for example, the deliverable moved after verification): acceptance comments the axes and commit, then gates `pending-acceptance` → `pending-verification` so the producer can run. It does not file a defect and does not sit on `pending-acceptance` waiting.
- That return route exists only for this gap. A game or interface miss at acceptance is still Fail → `pending-implementation` with a defect.

Each stage therefore names exactly one actor for the record, and no state leaves an issue with a missing record and no actor able to produce it. Fail-review cascades are not this route: [workflow-cascade.md](workflow-cascade.md).
