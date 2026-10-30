# Requirement notes

Raw requirement input the user has given but no spec holds yet, typically detail for a file they have not picked yet. `capture-requirements` writes and consumes these notes.

Notes are **not specs**. They are unconfirmed and do not authorize code or design: if it is not in `specs/`, it must not be in the code.

## Files

One file per downstream layer, created when first needed: `design.md`, `view.md`, `aesthetics.md`, `ux.md`, `playtest.md`, `assets.md`, `adr.md`, `technical.md`. When a file nears 500 words, split it by topic into `<layer>-<topic>.md` (for example `design-combat.md`) and list the parts in the layer file.

**PoC requests** use a separate file: [`poc-requests.md`](poc-requests.md) (purpose, scope, desired outcome). They are not layer notes; the filed GitHub issue is the build authority.

## Entry format (layer notes)

```markdown
- <detail, in the user's words> — target: `<spec path or folder>`
```

- One detail per entry. Keep the user's wording; do not refine it into spec language.
- Target is the most specific spec path or folder known, such as `specs/design/features/` or `specs/ux/screens/`.
- Only details that agree with the high-level specs are saved. Conflicts are resolved with the user during capture, and the resolved version is saved.

## Lifecycle

1. **Save**: during capture, a downstream detail is listed in the confirmation summary and saved here in the same spec PR.
2. **Consume**: when a capture run targets a spec, it reads the notes for that target and offers them as proposed answers.
3. **Prune**: once the user confirms a note into a spec, or rejects it, the run deletes the entry in that spec PR. Delete a file once it is empty.

PoC requests: save on confirm → file task/epic → set Status/Issue → prune when the PoC issue is accepted or the request is dropped.
