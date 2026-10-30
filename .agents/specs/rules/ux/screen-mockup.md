# Authoring rules: screen mockup

Read this before editing `specs/ux/mockups/screens/_template.html` or `specs/ux/mockups/screens/<name>.html`. Do not copy these rules into the HTML.

Also read [presentation.md](presentation.md) and [screens.md](screens.md).

Copy the template to `mockups/screens/<kebab-name>.html`, one per screen. Do not fill the template in place. Delete the template comment from the copy.

## What the file contains

The filled page shows only the screen, regions, controls, copy, and states named in the screen spec. It adds no screen, control, or state.

Keep `data-screen`, `data-region`, `data-control`, and `data-state`, and keep every `id`. Anchors: `state-default` for the default state, and `ex-<name>` for `EX.<name>`. One state link per exception this screen uses. Delete the rest.

Meta screens may adopt the `mobile-app` or `web-prototype` seed named in `presentation.md`. Play screens keep this skeleton and take the bound design system's color, type, and components.

Replace every `<!-- fill in -->`. The visible strings match the screen spec's copy table.

After writing the HTML, add or update the screen's row in `mockups/catalog.md` (`draft` until approved) per [mockup-catalog.md](mockup-catalog.md).
