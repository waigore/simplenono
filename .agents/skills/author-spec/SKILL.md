---
name: author-spec
description: |-
  Write or edit a spec under specs/ by reading its authoring rules in
  .agents/specs/rules/ first. Do not copy those rules into the spec.
  Use when creating, filling, or revising a vision, definition, design, view,
  aesthetics, UX, playtest, asset pipeline, architecture decision (ADR), or
  technical design spec, including a file copied from a _template.

  Examples:
    - user: "Write the vision" → read vision rules, fill specs/vision.md
    - user: "Add a movement feature spec" → copy the feature template, read feature rules
    - user: "Fill in the screen specs" → read screen rules for each screen
    - user: "Add a technical component for input" → copy components/_template, read component rules
---

# Author spec

Write or edit specs. The writing rules stay in [`.agents/specs/rules/`](../../specs/rules/README.md).

## Steps

1. **Resolve the target** path under `specs/`. A new unit spec does not exist yet: its path is the copy destination named in that folder's `_template` comment.
2. **Read the rules** before writing. Open [`.agents/specs/rules/README.md`](../../specs/rules/README.md) and take the most specific matching row. Read that file, then every file named in its **Also read** line, and the files those name, until none remain.
3. **Copy, then fill**, when the target is a new unit, story, or mockup. Copy the folder's `_template` to the new path. Leave the template unchanged.
4. **Edit the spec**. Keep its section skeleton and its authoring-rules line. Replace `<!-- fill in -->` placeholders only in sections this run is formalizing. Leave other placeholders; they mean not formalized. Write an undecided aspect as `TBD — <open question>` per [Undecided aspects](../../specs/rules/README.md#undecided-aspects-tbd); never invent the decision. Delete a row or section only when the rules file says to. On a mockup copy, delete the template comment.
5. **Stay inside the rules**. Split an oversized Markdown file the way its rules file says. Each Markdown file under `specs/` stays under 500 words.
6. **Mockup catalog**: when creating a screen or journey mockup, add a `draft` catalog row. When a material edit to aesthetics, UX Markdown, or a mockup would leave an `approved` row stale, set it to `draft` with a short reason ([`docs/ux-mockups.md`](../../../docs/ux-mockups.md)).
7. **Apply a failed review** only when asked to refine the spec. Follow [alignment.md](../../specs/alignment.md) under Refinement. Use the finding's `aligned` or `imposed` tag. Do not apply a `needs clarification` finding by choosing an outcome.

## Rules

- Do not paste authoring rules into `specs/` or into a template.
- Do not edit `.agents/specs/rules/` unless the user asked to change the rules.
- Do not fill a `_template` file in place.
- The spec states the game. The rules file states how to write it.
