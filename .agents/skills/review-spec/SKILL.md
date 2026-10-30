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

# Review spec

Review one spec document or the formalized spec set and report the result to whoever asked.

**Spec index and review instructions:** [`specs/README.md`](../../../specs/README.md), whose "Review instructions" column links each spec to its checklist in [`.agents/specs/`](../../specs/).

## Steps

1. **Resolve the target**:
   - **Specific doc**: find its row in the spec index. A file inside a spec's folder (e.g. `specs/design/flows/run.md`) uses that spec's review instructions, scoped to the file.
   - **Whole spec**: every formalized spec in the index, reviewed upstream first (in index order). A file with no formalized section is not formalized: list it, and do not Fail the review for it. Skip checks for sections that are still only placeholders ([`alignment.md`](../../specs/alignment.md)).
   - If a target has no review instructions, do not invent criteria; report it as not reviewable.
2. **Review**: read [`.agents/specs/alignment.md`](../../specs/alignment.md), then follow the linked review instructions exactly, including their upstream reading and report shape. Run the aligned checks and the imposed conditions. Tag each finding `aligned` or `imposed`. Do not invent an imposed condition, a section, or a required field.
3. **Whole-spec audits** (only when the target is the whole spec; skip for a specific doc or folder): run in this order, each at **whole set** scope, following that skill's steps and report shape. Placeholder-only files are not formalized and are not audit failures:
   1. [`audit-spec-applicability`](../audit-spec-applicability/SKILL.md)
   2. [`audit-spec-terminology`](../audit-spec-terminology/SKILL.md)
   3. [`audit-spec-tbd`](../audit-spec-tbd/SKILL.md)
4. **Summarize**: for a whole-spec review, open with an overall verdict (**Fail** if any checklist Fail or any audit Fail), then each checklist report, then each audit report. Note when a downstream finding may stem from an upstream failure. For a single-doc review, the checklist verdict alone is the overall verdict.
5. **Report back to the source of the request**:
   - **Chat**: reply with the report.
   - **GitHub issue or PR**: post the report as a comment on it (`gh issue comment` / `gh pr comment`); if the request also came through chat, reply there with the outcome and comment link.
   - **Another skill or agent**: return the report to the caller.

## Rules

- Read-only for checklist review: do not edit specs while reviewing checklists. Fixes happen in a separate step. The TBD audit may edit only as that skill defines (confirmed answers via `author-spec`).
- Writing rules live in [`.agents/specs/rules/`](../../specs/rules/README.md), not in the spec. Do not treat a missing rules section inside the spec as a defect. Fail a spec that pastes those rules back in, or that drops its authoring-rules link. [alignment.md](../../specs/alignment.md) is the contract between those rules and the checklist.
- Do not change issue labels or status; callers that run the issue workflow gate status themselves via [`enforce-task-workflow-status`](../enforce-task-workflow-status/SKILL.md).
- Use the report shape defined by the review instructions; do not restate their checklists here or in the report.
- Do not run the three audits on a single-doc or folder review unless the user separately asks for an audit.
- When invoking an audit skill, do not let it call back into this skill.
