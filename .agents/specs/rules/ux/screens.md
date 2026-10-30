# Authoring rules: screen

Read this before editing `specs/ux/screens/_template.md` or `specs/ux/screens/<name>.md`. Do not copy these rules into the spec.

Also read [ux.md](ux.md), [ids.md](ids.md), and [screen-mockup.md](screen-mockup.md). Stories follow [story.md](story.md).

Copy the template to `screens/<kebab-name>.md`, one file per screen. Do not fill the template in place.

One interface surface with one job. `navigation.md` lists it. Journeys only sequence it. They do not define it.

## Header

- **Job**: the one thing this screen is for.
- **Actors**: links to `actors/`.
- **Serves**: vision qualities, definition scope, and the design specs this screen surfaces.
- **Mockup**: copy `mockups/screens/_template.html` to `mockups/screens/<kebab-name>.html`. Follow [screen-mockup.md](screen-mockup.md). Add a `draft` catalog row per [mockup-catalog.md](mockup-catalog.md). Always required.
- **Glossary terms**: links into `glossary.md`.

Two readers must be able to operate the screen the same way from this file.

## Sections

- **Shows**: game facts this screen presents. Cite design IDs. Leave the rule in the design spec. Columns: region ID, the design element (such as `GS.health`), and when it is visible (cite the design knowledge rule, or "always on this screen").
- **Regions**: `R1`, `R2`, …. List order is top to bottom, then leading edge to trailing edge. Columns: region name, purpose, and contents (copy keys, design facts, child controls). Each design fact is visible when the design says the player can know it, and absent when the player cannot.
- **Controls**: `C1`, `C2`, …. List order is the focus order (`controls.md` **F1**). Columns: visible name, UI action (`IN.confirm`, or "None"), when it is available, and the result (a screen key, an exception ID, or the design verb this activation asks the game to perform). Activating it produces that result. Activating it while unavailable changes nothing.
- **States**: `S1` is Default and says how the screen opens. Further rows apply a shared exception by ID, such as `EX.loading`, and state that exception's condition on this screen. Columns: what the actor sees, and which control IDs the actor can use. The mockup anchor is `state-default` for the default row and `ex-<name>` for `EX.<name>`. The state is shown when its condition holds, with the controls that state allows.
- **Copy**: literal actor-facing strings. Columns: key, string, and the region or control ID that uses it. When localization Applies in `specs/definition/quality.md`, these strings vary by locale. The mockup shows these strings.
- **Experience intent**: what operating this screen should feel like. Intent only. No ID.
