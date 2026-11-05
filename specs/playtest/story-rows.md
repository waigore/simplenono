# Story rows

Authoring rules: [`.agents/specs/rules/playtest/story-rows.md`](../../.agents/specs/rules/playtest/story-rows.md).

Story↔work map for design stories and UX journeys/stories. Playtest results: in-repo index under [`docs/playtest/evidence/`](../../docs/playtest/evidence/); screenshots and logs on the wiki ([`wiki-evidence.md`](../../docs/playtest/wiki-evidence.md)). View stories are out of scope. Issue routing: [`docs/issues/requirements.md`](../../docs/issues/requirements.md).

## Rows

One row per playtestable design story and UX journey/story under coverage mode `full`. Owners are re-checked when wave planning files new epics/tasks.

| ID | Owner | Note |
|----|-------|------|
| `L-solve` | #109 | — |
| `E-cell` | #106 | — |
| `E-clue` | #107 | — |
| `E-puzzle` | #105 | — |
| `GS` | #108 | — |
| `END` | none | Wave 3 — leaves filed when that wave is expanded (epic #97). |
| `PRG` | none | Wave 2/3 — delivered through #94 and closed via #97; leaves not yet filed. |
| `J-play-puzzle` | #112 | — |
| `J-leave-resume` | #323 | `US1.1` delivered by #310; `US1.2` pause-then-quit delivered by #323. |
| `J-gallery-reset` | #94 | Gallery refresh and Reset allowedness are #94. The delivered confirm box and the `US1.2` cancel are #311; the box clauses on `US1.1` show/confirm are #96. |
| `J-settings` | #284 | — |
| `ACT-player` | none | Wave 2 — leaves filed when that wave is expanded (epic #95). |
| `NAV` | none | Wave 2 — leaves filed when that wave is expanded (epic #95). |
| `IN` | #111 | Mark input in Wave 1; platform bindings continue via epic #96 in Wave 2. |
| `EX` | #311 | `EX.confirm` show, Confirm to `END.O2`, and Cancel (`US1.1`–`US1.3`). |
| `UI-menu` | #623 | — |
| `UI-gallery` | #94 | `US1.6` "Then `EX.confirm` appears" is delivered by #311, whose box clauses are proved by #96. #94 proves Reset allowedness and the reset request. |
| `UI-puzzle` | #110 | — |
| `UI-result` | none | Wave 2 — leaves filed when that wave is expanded (epic #95). |
| `UI-settings` | none | Wave 2 — leaves filed when that wave is expanded (epic #95). Hint-assist toggles: `US1.8` delivered by #651. |

## Owner rules

- **`#n`** — open epic or task that delivers the story.
- **`none`** — not delivered yet; Note holds a durable reason (e.g. out of wave, not in product). Link a **task** in Note only when material work is uncovered and needs an owner. Never require a `type:defect` for a `none` row.
- **Defects** — game/interface fails only; not planning owners for uncovered stories.
