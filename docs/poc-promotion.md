# PoC promotion

Formalize is how a kept PoC enters specs and main code. [`reconcile-poc`](../.agents/skills/reconcile-poc/SKILL.md) applies the act. Does **not** block unrelated main-tree work: fixes, content, and tech tasks whose spec is already formalized.

## When

Run when the user asks to promote or reconcile a PoC, or a task explicitly requires it. Skip if no PoC should enter the game. Product behavior that is not in a formalized spec is specified with `capture-requirements`.

## What formalize writes

Scope is the keep/adapt list only. Sections that are still `<!-- fill in -->` stay until a later slice needs them.

Before main-tree code for that slice, lock blocking high-level fields that are still placeholders: elevator pitch, essential qualities, scope, player objectives, platforms, engine, spec depth, and a performance target. At `prototype`, other quality categories may stay N/A until a kept slice needs them. Accept the Engine ADR here, for the stack the main tree will use.

Fill the slice to the project's spec depth ([`depth.md`](../.agents/specs/rules/depth.md)):

- **prototype**: a kept rule may adopt a named convention and state only the deltas. One scenario is the proof. No glossary, element IDs, traceability, or story matrix for that slice.
- **small** and **full**: story, ID, and traceability rules apply to formalized elements only.

Technical shape covers the keep list only. Aesthetics, asset kinds, and playtest protocols are written only when the keep list needs them.

## Act

- Walk each claim or demonstrated behavior in the PoC README. Default **keep**. Choices: **keep** (land in specs + main), **drop**, or **adapt** (keep intent, change shape to fit design).
- A kept/adapted claim that disagrees with another PoC or the current spec stops for the user. The winner is written into `specs/` through `capture-requirements`, using the winning claim as the proposed answer. A losing claim is not promoted. PoC behavior stays as it was.
- The act is complete only after any agreed spec PR from those choices has merged. Ask first ([Pull requests](pocs.md#pull-requests)). A no leaves the edits on the local branch and the act incomplete.
- Record keep/drop/adapt and conflict choices in the PoC README. Do not walk a completed act again unless a new conflict appears.

## Reimplementation

A non-empty keep/adapt list is reimplemented by [`promote-poc`](../.agents/skills/promote-poc/SKILL.md), one PoC per task. An empty list completes the act and does not start that skill.

That work writes the keep list into `specs/` through `capture-requirements` (user-confirmed), at the depth in **What formalize writes**. It adds only the technical design that code needs, approves draft assets it uses, and passes `review-code` and the normal test bar. Main code never imports from `pocs/`. The PoC folder stays as historical reference. Do not assume glossaries, the technical hub, or the mockup catalog already exist.

When the keep/adapt list includes UI, author or update mockups to match what is promoted and get catalog **approved** before main-tree UI merges ([`ux-mockups.md`](ux-mockups.md)). Order may vary; unapproved mockups must not ship with main UI.
