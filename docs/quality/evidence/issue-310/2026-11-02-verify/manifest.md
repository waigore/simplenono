# Quality evaluator run — issue #310

- **Issue:** #310 Leave O6 attempt-side write path (`type:task`, Wave 2 — Complete play journey)
- **Mode:** `deterministic`
- **Deliverable commit:** `16c8df9` (`main`, squash of PR #316; `game/` at `16c8df9` is the tree measured)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from two runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`paint`, `solve-reset`), plus [`logs/gut-suite.log`](logs/gut-suite.log) for the unit-level I4 rows.

Selected axes are the Applies deterministic axes this deliverable can move: the leave path now writes
`user://progress.cfg` through `CTR-pack` O5, so the save axes (I4) move; every mark now writes the file, so
grid-paint frame time and hitches (I1, I2) move; and the leave/back flow is part of the crash-free flows (I9).

No existing record covered `game/` at `16c8df9`: the #236 record (`f19ef80`) predates this deliverable's
`game/` changes, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 frame time 16.55 ms over 203 frames. The per-mark `CTR-pack` O5 file write is the new cost; the bar is met with a narrow margin. | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 27.18 ms over 203 frames; no frame exceeded 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran in `solve-reset`; no failed flow and no crashed run. The protocol's separate `leave` step exits 1 (see the note below); that step is not one of the four I9 flows. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |
| `save-survives` | deterministic | I4: `test_leave_with_changed_marks_writes_the_record_and_closes_the_attempt` writes marks, elapsed, and attempt status through O5 and reads them back from the temporary `user://` document; `test_leave_then_reopen_restores_the_marks_and_elapsed` reopens from a fresh pack and restores both. `test_pack_progress.gd` covers the solve/reset round-trips. | Committed progress survives quit, crash, and upgrade | pass | — | `logs/gut-suite.log`; `game/test/test_leave.gd`; `game/test/test_pack_progress.gd` |
| `failed-write` | deterministic | I4: `test_a_failed_write_leaves_the_previous_file` fails the temp write and the next read still loads the previous commit. | A failed write leaves the previous commit loadable | pass | — | `logs/gut-suite.log`; `game/test/test_pack_progress.gd` |

## Not selected

- `time-to-playable` (I6) — no launch path changed; the deliverable adds no startup work.
- `transition-latency` (I7), `response-delay` (I8) — the harness does not time the leave leg (`navigate` times
  gallery→puzzle, puzzle→result, and result→gallery; `ui-ack` times open, settings, and settings-Back). The
  leave path is synchronous and covered by GUT; no timed leg changed.
- `resume-after-failure` (I10) — `kill-relaunch` still fails its elapsed leg because `advance` does not commit,
  which this task explicitly leaves out of scope ("in-progress advancement wiring beyond what O5/O6 already do").
  The deliverable's own leave-then-reopen leg is covered by `test_leave_then_reopen_restores_the_marks_and_elapsed`.
- `runtime-signals` (I11) — no log, sampler, or telemetry source was added or removed; E2 was already declared
  and S4 already logs `leave`.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## Note: `solve-reset` leave step

The `solve-reset` protocol exits 1 on its `leave` step after the solve: the result screen is showing, the
attempt is already solved/closed, and `Shell.leave_puzzle()` correctly follows `SEQ-leave` B2 (no open attempt →
no change, current screen stays). The harness's `_leave()` still expects `shell.attempt() == null`, which was
true under the old shortcut. This is a stale harness expectation, not a game-behavior gap; it is recorded as a
follow-up task in the verification comment.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or
`blocked`. The `frame-time` margin is narrow and should be watched on mid-range hardware.
