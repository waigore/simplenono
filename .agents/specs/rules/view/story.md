# Authoring rules: view-story file

Read this before editing a file under `specs/view/stories/`, including `stories/_template.md` when changing the form. Do not copy these rules into the story file.

Also read [stories.md](stories.md), [story-coverage.md](story-coverage.md), and [ids.md](ids.md).

Copy `specs/view/stories/_template.md` to the mirrored path of the view spec. One file per view spec. Do not fill the template in place.

## Header

- **View spec**: link to the spec this file proves.
- **Spec key**: the key from [ids.md](ids.md), such as `CAM-follow`.
- **Glossary terms**: links into `glossary.md`.

## Coverage table

One row per element ID and named item the view spec defines. Columns are element (such as `F1` or `CC.orbit`), a short summary, and the scenario IDs that prove it (such as `VS1.1`, `VS1.2`). The table matches each scenario's **Proves** line. At Full coverage, meet every requirement in [story-coverage.md](story-coverage.md) for that element's kind. At Baseline, each row needs at least one scenario. The spec's coverage level is in the `stories.md` index.

## Stories

Number stories `VS1`, `VS2`, … and scenarios `VS1.1`, `VS1.2`, …. Each story uses the narrative line from [stories.md](stories.md).

Each scenario has a **Proves** line (qualify other specs' IDs) and one Given / When / Then block that follows [stories.md](stories.md). Add stories and scenarios until every coverage row is proven.

A scenario does not assert a game-rule outcome or interface behavior. It cites the design or UX ID instead.
