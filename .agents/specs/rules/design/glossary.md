# Authoring rules: design glossary

Read this before editing `specs/design/glossary.md` or a domain file split from it. Do not copy these rules into the spec.

Also read [design.md](design.md).

Shared language for every design spec. Each term is defined once here. Other specs use the term exactly as written and link here. They do not redefine it.

## Conventions

- One term per concept. No synonyms. Pick one word and use it everywhere.
- One meaning per term. When a common genre term means something specific here, define this game's meaning.
- Characters and entities get a one-line entry that points at their spec in `characters/` or `entities/`.
- Keep rows alphabetical.

## Rows

Columns: term, a one-sentence definition of what it means in this game, and where it is detailed (a spec link, or "here").

## Splitting

If the file passes 500 words, split by domain into `glossary/<domain>.md` (for example `combat.md`, `world.md`). Keep `glossary.md` as the index of those files, and update links.
