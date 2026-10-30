# Authoring rules: exception states

Read this before editing `specs/ux/exceptions.md`. Do not copy these rules into the spec.

Also read [ux.md](ux.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Shared interface states for conditions that can arise on many screens. Screens apply these by ID. Each condition has one pattern, defined here. A screen does not define a second pattern for the same condition.

The mockup anchor for `EX.<name>` is `ex-<name>`.

## Rows

Delete a row the game does not use, and mark that topic N/A in `traceability.md` when the topic exists there. Add a named row for a condition this list lacks.

The skeleton names `EX.loading`, `EX.empty`, `EX.error`, `EX.confirm`, `EX.interrupt`, `EX.save-failure`, and `EX.unsupported-input`. For each row state when it appears, what the actor sees, what the actor can do, whether it blocks the screen, and how it recovers.

- **loading**: the condition, in design or session terms, and the screen or state when it ends.
- **empty**: there is nothing to show.
- **error**: a failure the actor can recover from. The actor sees what failed and what they can do next.
- **confirm**: a destructive or hard-to-undo choice. The actor can confirm and cancel.
- **interrupt**: play is suspended or the session is backgrounded. Link the design flow interruption.
- **save-failure**: a failed commit. When save durability Applies, link progression. Recovery leaves the previous commit intact. State what the actor sees.
- **unsupported-input**: an input this platform does not accept.

## Experience intent

How these states should feel. An error names what failed and what the actor can do next.
