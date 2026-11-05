# Quality evaluator run — issue #562

- **Issue:** #562 Remove empty-line auto-cross after ready (`type:task`, `priority:high`; requirement origin: feedback #566)
- **Mode:** `deterministic`
- **Deliverable commit:** `73c8c41` (`main` at verification, 2026-11-05; #562 shipped as `3288a38`, PR #572). `git diff e8a03ea 73c8c41 -- game/` is empty, and `73c8c41` differs from `3288a38` in 74 `game/` files, all from the later #550/#565/#573/#574 work; `game/play/` keeps what this issue merged.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores, load average 0.9–2.3 during the runs). The `.godot` import cache was built before the GUT and harness runs.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=solve-reset --run-dir=<this folder>`
  under a fresh `HOME` (`user://`), plus the GUT suite
  `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` (31 scripts, 371 tests, 371 passing,
  21 209 asserts, exit 0) and an independent probe on a clean detached worktree at `73c8c41`.

The deliverable deletes `Rules.auto_cross_cells`, `AttemptState.auto_cross`, `MarkGrid.auto_cross`, and the
`end_get_set_ready` write, so ready takes line status, commits only on a change, allows marks, and emits E3 with the board
as the loaded progress left it. The selected axes are the Applies deterministic axes that path can move: the commit
decision at the ready edge (`save-survives`, `failed-write`, I4), the open flow through the beat (`crash-free`, I9), and
the restore-on-reopen behaviour the issue's AC 4 names (`resume-after-failure`, I10).

No existing passing record covers these axes for `game/` at `73c8c41`: #565's record
([`issue-565/2026-11-05-verify`](../../issue-565/2026-11-05-verify/manifest.md)) is at `e8a03ea`, whose `game/` matches
this tree, but it selects only `time-to-playable` and holds no row for any axis below — so this is a fresh run rather than a
reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `save-survives` | deterministic | I4 (`integration`, read from the test result): GUT covers the commit/restore round-trips that the ready edge no longer performs — `test_leave_with_changed_marks_writes_the_record_and_closes_the_attempt` and `test_leave_during_get_set_ready_commits_restored_marks_without_a_beat_write` (`game/test/test_leave.gd`), `test_pause_during_get_set_ready_commits_the_restored_marks_as_held` and `test_pause_then_quit_restores_the_marks_and_elapsed_on_reopen` (`game/test/test_pause_resume.gd`), `test_progress_file_round_trips_marks_row_major` (`game/test/test_pack_progress.gd`). 371/371 pass, exit 0. Ready itself writes nothing (`test_ready_writes_nothing_and_commits_nothing`), so the commits that persist an attempt are the player's marks, pause, and leave, and all three still land. | Committed progress (ever-completed, PB, marks, elapsed, attempt) survives quit, crash, and upgrade | pass | — | `game/test/test_leave.gd`; `game/test/test_pause_resume.gd`; `game/test/test_pack_progress.gd`; suite log `/home/waigore/qe562/logs/gut-suite.log` (outside the repo, `docs/quality/evidence/**/logs/` is ignored); CI `Unit tests` on main |
| `failed-write` | deterministic | I4 (`integration`, read from the test result): `test_a_failed_write_leaves_the_previous_file` (`game/test/test_pack_progress.gd:298`) and `test_a_failed_write_leaves_the_previous_document` (`game/test/test_orientation_lock.gd:146`) still pass; the delete removes a write at the ready edge, it does not touch `ProgressFile`'s replace-or-keep-previous path. | A failed progress write leaves the previous commit loadable | pass | — | same suite log; `game/test/test_pack_progress.gd:298` |
| `crash-free` | deterministic | I9: `solve-reset` ran the `open`, `solve`, `reset`, and `back` flows (`flows_ok`) with no crash and no failed flow; the open flow — the only one this deliverable changes — passes through the ready edge in both of that run's open/ready pairs (the cycle that solves, and the cycle that resets). `flows.solve` reads `{"solved_grid": "pass", "solution_fills": "match"}`. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |
| `resume-after-failure` | deterministic | I10 (`integration`, read from the test result): `test_open_restores_an_in_progress_record` and `test_open_in_progress_record_keeps_marks_blocked_until_beat_end` (`game/test/test_open_ready.gd:339`, `:355`) commit an in-progress record at elapsed 18, reopen it on a fresh `Attempt`, restore the fill and 18, keep marks blocked through the beat, and end the beat with the restored board and no new crosses. The independent probe on a clean `73c8c41` worktree reproduces it outside the tests: teapot empty-clue rows 0/3/12 and columns 0/13 read as empty run lists (the fixture is unchanged), reopen restores `loaded_elapsed=18`, `fill=1`, `status=IN_PROGRESS`, `crosses=0`, `row0_0=CLEAR`, `elapsed=18`. | After kill/crash mid-puzzle, next launch is gallery; marks and elapsed restore on reopen | pass | — | `game/test/test_open_ready.gd:339`; `game/test/test_open_ready.gd:355`; probe `/home/waigore/qe562/logs/probe.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint, sampler, or layout path changed; the ready edge loses a loop instead of
  gaining one, so the grid-paint window cannot move against its bar.
- `time-to-playable`, `transition-latency`, `response-delay` (I6, I7, I8) — launch and navigation legs are untouched; the
  beat's length (`CFG.GET_SET_READY_MS`) and the shell's call order are unchanged.
- `runtime-signals` (I11) — the only telemetry-path edit is the comment on `DebugSeams.note_ready` (`game/presentation/debug_seams.gd`); no event, sampler, or severity source is added or removed, and E3 is still emitted once per open.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## Noted while running (not a scoring row)

- **`kill-relaunch` fails I10 on its elapsed leg at head and at base.** On `73c8c41` the protocol reads
  `RELAUNCH verify gallery=true opened=true marks=true elapsed=false pass=false`, and the same command on the pre-#562 base
  `8c941af` (a separate worktree, fresh `HOME`) reads `RELAUNCH mark held puzzle=pack-000 elapsed=3` then
  `gallery=true opened=true marks=true elapsed=false pass=false`. The cause is in the harness child, not the deliverable:
  `relaunch_child.gd` opens, ends the beat, marks (which commits at elapsed 0), and only then calls `advance(3)`, so the
  committed record never holds the advance. The row is therefore not scored here — it cannot discriminate this
  deliverable and it fails identically without it. The reopen-and-restore outcome the issue moves is scored from the
  unit/integration result above. The stale known-gap line in [`game/test/integration/README.md`](../../../../../game/test/integration/README.md)
  ("kill-relaunch fails I10 until progress persistence restores marks and elapsed (#96)") no longer describes the failure.
  Follow-up filed as a task: #604.
- **Mockup check** — [`MC.puzzle`](../../../../../specs/ux/mockups/catalog.md) is still `approved` and draws its crosses as
  player marks (rows of `cell cross` buttons), not as pre-crossed empty-clue lines, so the approved mockup matches the new
  rule; no catalog change was needed.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
