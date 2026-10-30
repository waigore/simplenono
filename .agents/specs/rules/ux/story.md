# Authoring rules: user-story file

Read this before editing a file under `specs/ux/stories/`, including `stories/_template.md` when changing the form. Do not copy these rules into the story file.

Also read [stories.md](stories.md), [story-coverage.md](story-coverage.md), and [ids.md](ids.md).

Copy `specs/ux/stories/_template.md` to the mirrored path of the UX spec. One file per UX spec. Do not fill the template in place.

## Header

- **UX spec**: link to the spec this file proves.
- **Spec key**: the key from [ids.md](ids.md), such as `UI-main-menu`.
- **Glossary terms**: links into `glossary.md`.

## Coverage table

One row per element ID and named item the UX spec defines. Columns are element (such as `C1` or `EX.loading`), a short summary, and the scenario IDs that prove it (such as `US1.1`, `US1.2`). The table matches each scenario's **Proves** line. At Full coverage, meet every requirement in [story-coverage.md](story-coverage.md) for that element's kind. At Baseline, each row needs at least one scenario. The spec's coverage level is in the `stories.md` index.

## Stories

Number stories `US1`, `US2`, … and scenarios `US1.1`, `US1.2`, …. Each story uses the narrative line from [stories.md](stories.md).

Each scenario has a **Proves** line (qualify other specs' IDs) and one Given / When / Then block that follows [stories.md](stories.md). Add stories and scenarios until every coverage row is proven.

A scenario does not assert a game-rule outcome. A visibility scenario states what a region shows and cites the design for whether the player can know it.
