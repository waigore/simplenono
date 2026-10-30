---
name: review-spec
description: |-
  Review a spec document (or the formalized spec set) under specs/ against its
  review instructions in .agents/specs/, then report the verdict back to the
  requester (chat, GitHub issue, PR, or calling agent). Whole-spec review also
  runs the applicability, terminology, and TBD audits on formalized sections;
  any Fail fails the overall verdict. Placeholder-only files are not formalized
  and are not a Fail.
  Use when the user asks to review, check, or validate a spec such as the vision,
  definition, design, view, aesthetics, UX, playtest, asset pipeline, ADR, or
  technical design docs.

  Examples:
    - user: "Review specs/vision.md" → run vision review, reply in chat
    - user: "Review the whole spec" → checklists upstream first, then audits
    - issue #14: "Review the design spec" → run design review, comment on #14
    - user: "Review specs/technical/" → run technical review, reply in chat
---

# Review spec (facade)

Canonical instructions: [`.agents/skills/review-spec/SKILL.md`](../../../.agents/skills/review-spec/SKILL.md).

Read that file and its `references/` as needed, then run the workflow there. Do not invent a parallel process.
