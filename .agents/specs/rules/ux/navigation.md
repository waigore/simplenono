# Authoring rules: navigation

Read this before editing `specs/ux/navigation.md` or a file split from it. Do not copy these rules into the spec.

Also read [ux.md](ux.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

The inventory of screens and the transitions between them. Each screen is defined in `screens/`. Journeys walk this map and add no screens.

## Screens

Columns: UI key, job, actors, spec link, and mockup link. Every screen in the table has a spec and a mockup. Every spec under `screens/` is a row here. Catalog approval: [`docs/ux-mockups.md`](../../../../docs/ux-mockups.md).

## Transitions

IDs `T1`, `T2`, … per [ids.md](ids.md). A transition is one control or one system UI event.

Columns: from (UI key), via (a qualified control ID, or a system UI event), to (UI key), conditions, and actors.

Every screen is reachable from **N1** and has at least one exit, unless it ends the session. Each transition matches the result of the control or system event it names.

## Entry and resume

- **N1**: the screen a new session opens on, and which actor.
- **N2**: the screen an interrupted session resumes on. Link the design flow interruption this follows.

A new session opens on the named screen. The resume condition arrives at the named screen.

## Splitting

If the file passes 500 words, move the screen table to `navigation/screens.md` and the transition table to `navigation/transitions.md`. Leave a one-line summary and links here.
