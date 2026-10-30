# Authoring rules: loop

Read this before editing `specs/design/loops/_template.md` or `specs/design/loops/<name>.md`. Do not copy these rules into the spec.

Also read [design.md](design.md) and [ids.md](ids.md). Stories follow [story.md](story.md).

Copy the template to `loops/<kebab-name>.md`, one file per loop. Do not fill the template in place.

A loop is a repeating cycle of player activity: the core loop (seconds to minutes), a session loop, or a meta loop across sessions.

## Header

- **Level**: core, session, or meta.
- **Timescale**: how long one iteration typically lasts.
- **Serves**: vision qualities and definition scope items.
- **Parent / child loops**: links, or "None".

## Sections

- **Steps**: in order. IDs `K1`, `K2`, …. Columns: what the player does (a verb), how the game responds, and what the player gains or learns. The stated outcome of each step follows its trigger.
- **Motivation**: why the player wants to repeat the loop, tied to the player fantasy.
- **Inputs and outputs**: what each iteration consumes and produces (resources, state, progress). Link features and game-state fields.
- **Variation**: what keeps iterations from feeling identical (new content, randomness, escalation, or player choice).
- **Exits**: `E1`, `E2`, …. One way the player leaves the loop (win, loss, choice, or transition), its condition, and links to the flow and end conditions.
- **Experience intent**: pacing and tension across one iteration and across many.
