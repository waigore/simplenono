---
name: author-quality-rubrics
description: |-
  Interview the product owner for quality-characteristic targets and orthogonal
  domain rubric axes, then write them through author-spec. Baseline axes stay
  fixed. Deterministic evaluators are required when a threshold or invariant
  can decide the outcome; llm-judge is only for qualitative outcomes.
  Use when defining or revising quality rubrics, or when capture-requirements
  formalizes specs/definition/quality.md.

  Examples:
    - user: "Set the quality rubrics" → baseline targets, then any domain axes
    - user: "Add a fairness rubric" → new characteristic, orthogonality, one evaluator
    - capture-requirements on quality.md → this skill owns targets and axes
---

# Author quality rubrics

Interview, then write via [`author-spec`](../author-spec/SKILL.md). Do not run evaluators, playtest, or acceptance.

**Rules and specs:** [`.agents/specs/rules/quality.md`](../../specs/rules/quality.md), [`specs/definition/quality.md`](../../../specs/definition/quality.md), [`specs/definition/quality/rubrics.md`](../../../specs/definition/quality/rubrics.md), [`specs/definition/quality/rubrics/baseline.md`](../../../specs/definition/quality/rubrics/baseline.md).

## Steps

0. **Setup**: [`docs/skills.md`](../../../docs/skills.md) `ensure-project-setup` hook. Skip when [`capture-requirements`](../capture-requirements/SKILL.md) is the caller and already passed setup.
1. **Load**. Read the quality rules, both spec files, `specs/vision.md`, and the definition's platforms and spec depth. Treat a confirmed performance target from `capture-requirements` as the proposed `frame-time` and `hitch-bound` bars.
2. **Baseline**. For each of the seven characteristics, lead with the current row as the proposed answer. Ask Applies or N/A, the target, and the platforms. Do not rename, remove, or change the evaluator of a baseline axis. An N/A reason cites the vision, the supported platforms, or, except for performance, prototype spec depth. One characteristic may mix Applies and N/A across its axes.
3. **Domain**. Ask whether the genre needs an outcome no baseline axis measures. For each candidate, record the new characteristic, the outcome, and the axis id. Ask which existing axis would already fail if this outcome failed. If the owner names one, drop the candidate. If a threshold or an invariant can decide pass or fail, the evaluator is `deterministic`. Otherwise it is `llm-judge`: record the ordinal scale, the minimum passing level, and the evidence the judge may see. A vision quality is not an axis.
4. **Confirm**. Short bullets: each baseline row (Applies or N/A, target, platforms), each domain axis (characteristic, outcome, evaluator, and judge fields when used), and any dropped candidate with the axis it overlapped. Wait for OK or corrections.
5. **Author**. Run `author-spec` on `quality.md`, `rubrics.md`, and `rubrics/baseline.md` with the confirmed answers. Leave unrelated placeholders. Do not paste these steps into the specs. Do not change a baseline outcome or evaluator.
6. **PR**. When this skill is the top-level run, open a spec PR per [Spec PRs](../../../docs/pull-requests.md#spec-prs). When `capture-requirements` is the caller, return the written paths and let that skill open the PR.

## Rules

- Baseline axis ids, characteristics, and evaluators stay as the quality rules list them.
- No combined score. Every applicable axis must pass on its own.
- Do not waive an `llm-judge` result by editing nothing. A wrong rubric is a new run of this skill. Acceptance returns for clarification while the axis stays as written.
- Do not score playtest protocols, vision qualities, or per-issue acceptance criteria as rubrics.
- Executing evaluators is [`run-quality-evaluators`](../run-quality-evaluators/SKILL.md). Do not run them here.
