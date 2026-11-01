# Criteria — issue #163

Judged on a detached worktree of `main@3cab7de` (`3f402fe` + `fdcb298`), Godot 4.7.2. Logs are in this folder. The capture probe ([`probe/probe_capture_163.gd`](probe/probe_capture_163.gd)) ran once from `game/test/` and was removed.

## AC 1 — H1 / H2: one flag; off unreachable, boot unchanged

- `test_flag_off_hides_every_seam_and_keeps_the_boot`: home view, 200 pack entries, and every seam absent or returning its empty value.
- Flag-off boot exit 0 with 0 `TEL`/`SEV` ([flag-off-boot.log](logs/flag-off-boot.log)); `--debug-seams` exit 0 with `session-start`/`session-end` ([flag-on-boot.log](logs/flag-on-boot.log)).
- `is_enabled()` needs `OS.is_debug_build()`, so a release export has none.

## AC 2 — S1 / `DBG.1`: halt and continue (O4/O5)

- `pause_session()` → paused, marks blocked, screen `S3`; `advance(3)` leaves elapsed unchanged.
- `resume_session()` → not paused, screen `S1`.
- Images [01](screenshots/01-paused-session.png), [02](screenshots/02-resumed-session.png); [capture console](logs/capture-console.log).

## AC 3 — S1 / `DBG.3`: open in place (O1); unknown id (`G3`)

- `pack-000` opens and the beat runs; `pack-007` opens in place and replaces the attempt.
- `no-such-puzzle` returns false; attempt, id, and a second `inspect()` are unchanged.
- Images [03](screenshots/03-opened-in-place.png), [04](screenshots/04-unknown-id-unchanged.png).

## AC 4 — S2 / `DBG.2`: three schemata, read-only

- `inspect()` returns `attempt`, `mark_grid`, `progress` ([inspect-before.json](logs/inspect-before.json)); after pausing only `paused` changes ([inspect-paused.json](logs/inspect-paused.json)).
- `inspect()` equals the pre-call snapshot after the refused open; `test_s2_inspect_creates_no_record` proves no record is invented.

## AC 5 — S3 / `DBG.4`: overlay on/off

- `set_story_ids([...])` holds both ids; `toggle_overlay()` on shows them, off hides.
- Image [00](screenshots/00-flag-on-home-overlay.png): `story: L-solve.PS1.1, US1.7`.

## AC 6 — S4 / `TEL.1`–`TEL.5`: one event per action, headless and graphical

- Capture: six events (`open`, `ready`, `commit`, `pause`, `resume`, `open`) each with name, timestamp, session, build, story, outcome ([telemetry-events.ndjson](logs/telemetry-events.ndjson)).
- Headless and graphical `paint` each log 405 `TEL` lines, exit 0 ([headless](logs/paint-headless.log), [graphical](logs/paint-graphical.log)).
- `test_s4_each_reachable_action_emits_exactly_one_event` covers all nine actions.

## AC 7 — S5 / `SIT.3`: CLI dump under `logs/`

```
godot --headless --path game -s res://presentation/dump_state.gd -- \
  --debug-seams --puzzle-id=pack-042 --run-folder=<run> --session-id=accept163
```

- exit 0; `state-pack-042.json` holds attempt, a 15×15 grid, and progress ([log](logs/s5-dump.log)).
- Unknown id exit 1 ([log](logs/s5-unknown-id.log)); flag off exit 2 ([log](logs/s5-flag-off.log)).
- The capture's `dump_state()` wrote `state-pack-007.json`.

## AC 8 — tests, format, lint

- GUT: 12 scripts, **151/151**, 29 279 asserts, exit 0 ([log](logs/gut-suite.log)); re-run on `cd08f79`: 14 scripts, 170/170 ([log](logs/gut-suite-cd08f79.log)); seam sources unchanged.
- `gdformat --check game` 61 unchanged; `gdlint game` clean; `spec_lint.py` 0 errors, 1 pre-existing warning.

## AC 9 — no gameplay/rule/progress/screen change; S6 not redelivered; no new ID

- `git diff fdcb298 3cab7de -- specs` is empty.
- The five seam sources and `test_verification_seams.gd` are byte-identical at `3cab7de`.
- No `user://` write in the seam files; `pause`/`resume` have no caller outside the seam; S6 stays #105.
