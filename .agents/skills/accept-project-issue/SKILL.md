---
name: accept-project-issue
description: |-
  Accept, fail, or escalate clarification for an epic/task/defect in
  status:pending-acceptance using test evidence against acceptance criteria.
  Cite the deterministic rubric record. When an Applies llm-judge axis can
  move, run run-quality-evaluators.
  Use when running acceptance testing after verification.

  Examples:
    - user: "Accept #12 with evidence in docs/playtest/evidence/..." → accept comment, status:accepted, leave open (planner may close later)
    - user: "Acceptance failed; file defect" → create defect (game/interface only), link, → pending-implementation
    - user: "Need PO input to finish acceptance on #12" → pending-clarification
    - user: "Headless accept on #12; screenshots still waiting" → stay pending-acceptance, no defect
---

# Accept project issue

Veneer over the [action shell](../enforce-task-workflow-status/references/action-shell.md) for `status:pending-acceptance`.

**Type routing:** [`docs/issues/requirements.md`](../../../docs/issues/requirements.md) (When to file what).

**Playtesting:** [`specs/playtest/playtest.md`](../../../specs/playtest/playtest.md) — required only when deliverables change playable behavior.

**Quality evaluators:** [`run-quality-evaluators`](../run-quality-evaluators/SKILL.md) — `llm-judge` when an Applies qualitative axis can move. Cite the verify-time `deterministic` record; do not run that mode here. Layout: [`docs/quality/evidence/README.md`](../../../docs/quality/evidence/README.md).

Load acceptance criteria, the verification comment, and related PRs. Test against each acceptance criterion. Evidence must be locatable in the repo (logs, screenshots, paths). Summarize where to find it.

When the issue's deliverables change playable behavior (game or code), also run AI-agent playtesting per [`specs/playtest/playtest.md`](../../../specs/playtest/playtest.md) and cite evidence under [`docs/playtest/evidence/`](../../../docs/playtest/evidence/) (story IDs, pass or fail, notes, logs, and screenshots when required). Spec-only, docs-only, or other non-playable deliverables do not require playtesting.

A headless playtest run may judge and record pass or fail, notes, and logs. Acceptance still needs screenshots from a graphical re-run of that same build for every protocol that requires them. A protocol that says none may be accepted from the headless run alone.

When the deliverable can move an Applies deterministic axis, cite the latest `deterministic` evidence record for this issue and deliverable commit. Do not run `run-quality-evaluators` in `deterministic` mode. A record with a **fail** or **blocked** row is an acceptance Fail. No record for that commit: stay on `pending-acceptance` (see Outcome).

When the deliverable can move an Applies `llm-judge` axis, run [`run-quality-evaluators`](../run-quality-evaluators/SKILL.md) in `llm-judge` mode. Include its report and the evidence path. A **fail** row is an acceptance Fail. **blocked** / `missing-evidence` stays on `pending-acceptance`. **blocked** / `missing-judge-record` is Clarify. **N/A** from that skill adds no rubric evidence.

## Outcome

- **Accept** — comment summarizing evidence per criterion and related PRs, including the graphical-run screenshot paths when playtesting required them, the deterministic evidence path when a deterministic axis applies, and the llm-judge evidence path when a qualitative axis applies. Gate: `pending-acceptance` → `accepted`. Leave the issue open. Only [`project-planner-agent`](../project-planner-agent/SKILL.md) closes accepted work.
- **Waiting on screenshots** — headless judgement is recorded and required screenshots are not in the repo yet. Comment with the evidence path and that acceptance waits on a graphical re-run of the same build. Stay on `pending-acceptance`. Do not file a defect. Do not call the status gate.
- **Waiting on deterministic record** — an Applies deterministic axis can move and no `deterministic` record exists for this deliverable commit. Comment that acceptance waits on that record. A `run-quality-evaluators` deterministic run for this commit supplies it. Stay on `pending-acceptance`. Do not run those checks in this skill. Do not file a defect. Do not call the status gate.
- **Waiting on judge evidence** — an `llm-judge` row is **blocked** / `missing-evidence`. Comment with the axis id and the evidence the judge record allows. Stay on `pending-acceptance`. Do not file a defect. Do not call the status gate.
- **Fail** — a protocol failed for a **game or interface** reason, a deterministic record row is **fail** or **blocked**, or an `llm-judge` row is **fail**. Create a Defect via `create-project-defect` when the miss is game or interface behavior, and link it in the comment. Gate: `pending-acceptance` → `pending-implementation`. Missing screenshots, a missing deterministic record, or missing judge evidence alone are not this outcome. Never file a defect for a spec, doc, or map problem.
- **Clarify** — tests cannot proceed without product-owner input, a wrong or ambiguous **spec** blocks judging the acceptance criteria, or an `llm-judge` row is **blocked** / `missing-judge-record`. Summarize questions. The axis stays as written. Gate: `pending-acceptance` → `pending-clarification`. No defect.
