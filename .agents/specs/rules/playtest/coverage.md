# Authoring rules: playtest coverage

Read this before editing `specs/playtest/coverage.md`. Do not copy these rules into the spec.

Also read [playtest.md](playtest.md) and [ids.md](ids.md).

Which design stories and UX journeys must be playtested. View stories are never in scope.

## Mode

Restate that **Mode** is declared on the hub (`full` or `critical-only`). This file owns the critical set and the selection rules procedures use.

- **full**: every design story and every UX journey is in the playtest set (filtered further by issue scope in procedures).
- **critical-only**: only IDs listed in the Critical IDs table. The table must be non-empty. Complex projects use `full`; smaller projects may use `critical-only`.

## Critical IDs

When mode is `critical-only`, one row per ID: ID (`C1`, `C2`, …), the design story or UX journey/story ID, and why it is critical. When mode is `full`, write a single table row with "—" for all columns, or state "None — mode is full".

## Issue mapping

State that procedures select the intersection of (a) this coverage set and (b) IDs the issue's playable deliverables can affect. Point delivery ownership (epic/task vs `none`) at [`story-rows.md`](story-rows.md); do not redefine Owner routing here.

## Splitting

If the file passes 500 words, move Critical IDs to `coverage/critical.md`. Leave a summary and a link, and update `playtest.md`.
