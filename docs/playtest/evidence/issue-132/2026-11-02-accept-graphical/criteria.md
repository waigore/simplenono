# Acceptance criteria — issue #132 on `main@859d834`

Criteria come from the issue body ("Acceptance criteria"). Evidence is this run unless a test is named.

| Criterion | Verdict | Evidence |
|-----------|---------|----------|
| GUT suite exits 0 and `game/test/test_open_ready.gd` is present and green | Pass | [`logs/gut-suite.log`](logs/gut-suite.log): 11 scripts, 139/139, 29 204 asserts, exit 0 |
| `CMP-rules` R3 / `CTR-rules` O3 `auto_cross_cells` returns only still-clear cells of empty-clue lines and writes nothing | Pass | Graphical: `pack-000` rows/columns 0 and 9 crossed at beat end, nothing else (`01`); `inspect()` shows the grid unchanged before the beat and the crosses after it. Model: `test_the_edge_writes_exactly_the_rules_auto_cross`, `test_empty_clue_rows_and_columns_contribute_their_still_clear_cells`, `test_auto_cross_writes_nothing_and_is_deterministic` |
| `PS1.1` — beat end: empty-clue cells crossed, attempt in progress, marks allowed when not paused, elapsed 0 | Pass (fresh and reopened) | `00` → `01` (fresh, `in_progress`, tools enabled, `0:00`); `03` → `05` (reopened, blocked, then marks and ticking) |
| `PS1.9` — marks blocked at 200 / 500 / 1500 ms through the beat, allowed after with elapsed 0 | Pass | `test_marks_stay_blocked_until_the_beat_ends_at_each_ready_length`; blocked state pictured in `00` |
| `SEQ-open` S4–S5, S7–S13 — open returns the loaded grid/elapsed with marks blocked; then auto-cross → line status → commit only on change → marks allowed → `E3` | Pass | `TEL event=ready` exactly once per open, `commit` only after a changing beat ([`logs/capture-console.log`](logs/capture-console.log)); reopened open returns `0:18` blocked (`03`) |
| `CTR-attempt` E3 — id, post-auto-cross grid, line status, once per successful open | Pass | Three `open` events, three `ready` events, no extra `ready`; `DBG.2` payload at `01` matches the drawn grid |
| `SEQ-open` B1 — unknown id: no beat, no write, no O5, no E3, previous attempt untouched | Pass | `test_an_unknown_id_changes_nothing` and `test_an_unknown_id_during_a_beat_changes_nothing` (shipped suite); not re-driven graphically — no player route opens an unknown id |
| `SEQ-open` B3 — pause during the beat does not end it early; marks stay blocked; no tick | Pass | `test_a_pause_during_the_beat_waits_for_the_beat_and_revives_marks_on_resume`; `S4` here proves the post-beat pause shape (`06`, `07`) |
| `CTR-attempt` O3 / G1 — `advance` adds nothing during the beat, blocked, or paused | Pass | `04`: `tick(4.0)` during the reopened beat leaves `0:18`; `06`: paused `tick(4.0)` leaves `0:22`; `test_advance_adds_elapsed_while_ready_and_nothing_while_blocked` |
| No line-closure rule; no solve check (R4); no pause/resume/leave operations (O4–O6); no progress-file write | Pass | Diff surface of #140/#147/#160; no `user://` I/O in `game/play/` or `game/records/` |
| `game/presentation/` unchanged by this task, so the `MC.puzzle` gate does not apply | Pass | #132's PRs do not touch the screen; #110's `puzzle.tscn` is used as a consumer only |
