# Notes — issue #105 acceptance run

Judgement of what the delivered layer can decide. Every value below is from this build.

## `E-puzzle` PS1.1 — pack properties

*Given the local pack of 200 puzzles (10×10×10, 15×15×170, 20×20×20), when the player opens puzzle id X,
then size is 10×10, 15×15, or 20×20 per pack data, and solution and clues are that pack entry's fixed data,
and identity is X.*

| Step | Observation |
|------|-------------|
| Pack contents | 200 entries: `{10: 10, 15: 170, 20: 20}` — the `entities/puzzle.md` P4 distribution |
| O8 on the shipped pack | `accepted_count=200 rejected=0` |
| F1–F7 mapping | For all 200 entries, the served `PuzzleDefinition` matched the raw entry on F1 id, F2 size, F3 row-clues, F4 col-clues, F5 solution-fills, F6 picture-id, F7 pixel-picture-id |
| I1 / I2 / I3 | Independent audit: 0 invalid entries. F3/F4 each hold `size` lists; every F5 position is in-grid; F3 and F4 are exactly the runs recomputed from F5 |
| I4 / I5 | 200 unique F1, 200 unique F6, 200 unique F7, no F6 = F7, 200 distinct fill sets |
| O3 by id | `pack-000` (10), `pack-010` (15), `pack-180` (20) each return size, clues, fills, and both picture ids |
| G2 unknown id | `"no-such-puzzle"` → `null`, definitions still 200 |

Outcome: **pass at the delivered layer**. The pack a puzzle screen will open is complete, valid, and
served by id.

## `PTD-ready-and-marks` — judged part

The protocol's only `E-puzzle` claim is PS1.1 (opening a puzzle shows that entry's size and clues).
There is no board to open and no `DBG.3` to enter a fixture, so steps S1–S4 could not be driven.

- P1–P3 (marks, auto-cross, wrong-fill, pause) — not judged. Owned by #106/#108/#111.
- The `E-puzzle` part it would exercise (open a not-started puzzle) — no open path exists yet.

## Not judged, and why

| Story clause | Owner | Missing deliverable |
|--------------|-------|---------------------|
| PS1.2 open not started | #109 / calibrate get-set-ready (#101 shell) | attempt state, `CMP-shell` |
| PS1.2b open restores in progress | #108 / Wave 2 persistence | attempt restore |
| PS1.3 first solve → ever-completed | #109 | solve loop, `END.W1` |
| PS1.4, PS1.4b, PS1.4c pictures | #110 | result and gallery surfaces |
| PS1.5 reset | #110 / Wave 2 | gallery reset |

## Non-blocking marks

- The pack's picture ids are placeholders until the Wave 3 asset pass (#98). They are unique and
  distinct per entry (I4/I5 hold), so nothing here fails; the files they name do not exist yet. This is
  recorded in the implementation summary and is owned by #98.
- `game/data/` and the 200-entry pack are syntactically current: `generate_pack.py --check` reports the
  file is current and its 68 unit tests pass.
