# Spec audit report-back

Shared by `audit-spec-applicability`, `audit-spec-terminology`, and `audit-spec-tbd`. Do not copy this close-out into those skills.

- For applicability and terminology, **Pass** only when there are no findings. Sections or glossary rows that are still only `<!-- fill in -->` are not formalized. Skip them. Do not tag them as failures. `audit-spec-tbd` keeps its own report shape. An open TBD is not a Fail.
- Read-only during the audit: do not edit `specs/` or `.agents/specs/rules/`. `audit-spec-tbd` may write only after the user confirms, and only through [`author-spec`](../../author-spec/SKILL.md).
- Do not run a full [`review-spec`](../../review-spec/SKILL.md) checklist. When that skill invoked this audit, return the report to it. Do not call `review-spec` back.
- When run alone, report to the request source (chat, issue or PR comment, or calling agent), the same way `review-spec` does.
