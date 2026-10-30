# Authoring rules: demo

Read this before editing `specs/design/demo.md`. Do not copy these rules into the spec.

Also read [design.md](design.md), [ids.md](ids.md), and [configuration.md](configuration.md). Stories for this file follow [story.md](story.md).

Product **demo mode**: a limited form of the full game that uses the same rules and systems. Not a separate codebase and not a proof of concept (`docs/pocs.md`).

## Offering

State **offered**, **not offered**, or leave undecided as `TBD — <question>`.

When **not offered**, write "N/A — not offered" for Limitations, Entry and exit, and Parity, and create no demo configuration parameters. When still TBD, the rest may stay TBD; do not implement demo mode until Offering is decided.

## Limitations

Each cap that distinguishes demo from full game (session length, content unlocks, feature set). IDs `L1`, `L2`, … per [ids.md](ids.md). Reference the `CFG.*` mode, option, or tunable in `configuration.md` that holds the value. Describe the player-facing effect in design terms, not code flags.

## Entry and exit

`N1`: how the player enters demo vs full (store build, in-app choice, or other) and what ends or unlocks exit to full. No menus or screens—those live under `specs/ux/`.

## Parity

State that demo uses the same rules and systems as the full game except the listed limitations. Do not invent a parallel ruleset. Cite any exception that is not already a Limitation row (or write "None").

## Configuration link

Concrete mode rows and parameter values live in `configuration.md`. This file owns the product meaning of demo. A demo mode row in configuration must cite `DEMO.L*` or Offering.
