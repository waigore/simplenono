# Technical diagrams

Authoring rules: [`.agents/specs/rules/technical/diagrams.md`](../../../.agents/specs/rules/technical/diagrams.md).

Prefer Mermaid (or equivalent) in the owning Markdown spec. Use this folder for larger or multi-view artifacts (HTML or linked `.md`). Every file here is cited from the owning technical spec; orphan diagrams are not allowed.

| Kind | Suggested path |
|------|----------------|
| Layer / module maps | `layers.md` or `modules-<name>.md` / `.html` |
| Component communication | `components/<kebab-name>.md` / `.html` |
| Sequences | `sequences/<kebab-name>.md` / `.html` |
| Schema lifecycle / relationships | `schemata/<kebab-name>.md` / `.html` |
| Failure / concurrency / save graphs | matching optional global name |
