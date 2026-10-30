# Authoring rules: journey mockup

Read this before editing `specs/ux/mockups/journeys/_template.html` or `specs/ux/mockups/journeys/<name>.html`. Do not copy these rules into the HTML.

Also read [presentation.md](presentation.md) and [journeys.md](journeys.md).

Copy the template to `mockups/journeys/<kebab-name>.html`, one per journey. Do not fill the template in place. Delete the template comment from the copy.

## What the file contains

Link only the screens, controls, and exception anchors the journey spec names. Each step loads that screen in the stage. A step link uses the screen file's `#state-default` anchor. A branch link uses the exception anchor, such as `#ex-loading`.

Each screen file keeps its own Open Design treatment. This file does not restyle the screen.

Replace every `<!-- fill in -->`. The step list matches the journey's steps and branches, including exception anchors.

After writing the HTML, add or update the journey's row in `mockups/catalog.md` (`draft` until approved) per [mockup-catalog.md](mockup-catalog.md).
