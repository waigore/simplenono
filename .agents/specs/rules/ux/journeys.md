# Authoring rules: journey

Read this before editing `specs/ux/journeys/_template.md` or `specs/ux/journeys/<name>.md`. Do not copy these rules into the spec.

Also read [ux.md](ux.md), [ids.md](ids.md), and [journey-mockup.md](journey-mockup.md). Stories follow [story.md](story.md).

Copy the template to `journeys/<kebab-name>.md`, one file per journey. Do not fill the template in place.

An ordered path one actor takes through screens that already exist in `navigation.md`. This file sequences screens, controls, and exceptions. It does not define them.

## Header

- **Actor**: a link to `actors/`.
- **Goal**: what the actor is trying to finish.
- **Serves**: vision qualities, definition scope, and the design flow or feature.
- **Mockup**: copy `mockups/journeys/_template.html` to `mockups/journeys/<kebab-name>.html`. Follow [journey-mockup.md](journey-mockup.md). Add a `draft` catalog row per [mockup-catalog.md](mockup-catalog.md). Always required.
- **Glossary terms**: links into `glossary.md`.

## Sections

- **Entry and exit**: `N1` names the UI key the journey starts on and the condition. `N2` names the UI key it ends on when the goal is met.
- **Steps**: `S1`, `S2`, …. List order is the path taken when no branch condition holds. Each step uses a control defined on that screen. Columns: UI key, qualified control ID, and the UI key arrived at (or "stays"). Using that control arrives at the named screen.
- **Branches**: `B1`, `B2`, …. A branch leaves a step when an exception or a screen state holds. The destination already exists. Columns: the step ID, the condition (`EX.loading`, or a qualified state ID), and the destination (screen key and state). When the condition holds at that step, the destination opens.
- **Experience intent**: what this path should feel like from entry to exit. No ID.
