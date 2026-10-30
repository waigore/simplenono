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

# Author quality rubrics (facade)

Canonical instructions: [`.agents/skills/author-quality-rubrics/SKILL.md`](../../../.agents/skills/author-quality-rubrics/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
