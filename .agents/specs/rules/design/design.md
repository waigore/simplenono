# Authoring rules: game design

Read this before editing `specs/design/design.md`. Do not copy these rules into the spec.

Every other file under `specs/design/` follows **Rules for every design spec** below. Those rules files name this one under **Also read**.

The design describes how the game works and how it should feel to play. It is downstream of `specs/vision.md`, `specs/definition/definition.md`, and `specs/definition/quality.md`. If the design conflicts with them, change the design, or revise the upstream document first.

## Rules for every design spec

- **Self-contained**: describe every rule, character, and behavior in full, even when the game or genre is well known. Do not rely on an external reference ("like chess", a wiki, a link). A comparison may help, but the spec must stand without it. At `prototype`, a formalized spec may adopt a named convention and state only the deltas. At `small` and `full`, the spec stands without that reference.
- **Game design, not UX**: describe what happens and why. Player actions are verbs (jump, trade), not inputs, buttons, screens, menus, or layouts. Interface structure lives under `specs/ux/`. Cameras, projection, positions in world units, and the feel of motion live under `specs/view/`, which must reproduce the outcomes stated here.
- **Conceptual, logical, experiential**: no engines, frameworks, code, data formats, or platform APIs. Platforms appear only as design implications in the profile below. A limit imposed by an architecture decision is stated in design terms and cites its ID, such as `(ADR-0003)`.
- **Shared language**: define each term once in `glossary.md`, each character in `characters/`, and each entity in `entities/`. Other specs link. They never redefine.
- **Traceable**: every spec states which vision qualities and definition scope items it serves. `traceability.md` maps all of them.
- **Identified and proven**: every behavior-defining element has a stable ID per [ids.md](ids.md) and is proven by Given/When/Then player stories per [stories.md](stories.md) and [story-coverage.md](story-coverage.md).
- **Concise**: each file stays under 500 words. Split by logical unit and link. The type's own rules file says where to move the extra part.

## Genre and platform profile

Fill this in `design.md`:

- **Genre(s)**.
- **Conventions adopted**: the convention, then how this game applies it.
- **Conventions rejected or changed**: the convention, then why, traced to the vision.
- **Platform implications**: for each platform in the definition, the conceptual effect on design. Shape: "Short sessions → a run lasts ≤5 minutes." No hardware and no input mapping.

Adopted and rejected conventions show up in the specs that implement them. Platform implications show up in pacing, flows, and progression.

## Index

Keep the global-spec list. For a unit spec, copy that folder's `_template.md` to `<kebab-name>.md`, fill the copy, and add the link under the matching heading. Leave `_template.md` unchanged.

If the game has no sub-games, write "None" and create no files under `sub-games/`.

If the index pushes `design.md` past 500 words, move the index to `specs/design/index.md` and leave a link in `design.md`.
