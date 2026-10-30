# Authoring rules: playtest story rows

Read this before editing `specs/playtest/story-rows.md`. Do not copy these rules into the spec.

Also read [playtest.md](playtest.md), [coverage.md](coverage.md), and [`docs/issues/requirements.md`](../../../../docs/issues/requirements.md) (When to file what).

Maps each in-scope design story and UX journey/story to delivery ownership. It is a planning aid for waves and tasks — not a playtest results table (that is evidence). View stories are never listed.

## Purpose

State that the file is the story↔work map: which open epic/task owns delivery of each design/UX story ID, or that the row is explicitly not delivered yet.

## Rows

One row per design story ID and each UX journey or story ID that can be playtested under the hub coverage mode. Columns:

- **ID** — design or UX story/journey ID
- **Owner** — open `type:epic` or `type:task` `#n` that delivers it, or `none`
- **Note** — short reason when Owner is `none`, or `—` when owned

## Owner values (routing)

Align with defect vs task vs clarification — never invent a parallel rule:

- **Owned** — link an open epic or task. Do not put `type:defect` here as a planning owner.
- **`none`** — delivery is not required yet (out of wave, not in product, deferred, superseded, etc.). Put a **durable reason** in Note. Optional: link an open **task** only when material uncovered work still needs an owner. Do **not** require a linked `type:defect` for a `none` row. Do not invent tracking when delivery is correctly not needed.
- **Defects** — only for wrong game/interface behavior vs expected play (acceptance/playtest Fail). They do not stand in for uncovered stories or map hygiene.

Stale `#n` in Owner/Note alone is non-material hygiene: repair in place; do not Fail solely for it; never file a defect for the stale pointer.

## Issue / AC drafting

When drafting task acceptance criteria that cite this map: require Owner/Note to match the routing above. Never write an AC that every `none` must name a live `type:defect`.

## Splitting

If the file passes 500 words, split by design vs UX into `story-rows/design.md` and `story-rows/ux.md`. Leave a summary and links, and update `playtest.md`.
