# Quality evaluator run — issue #311

- **Issue:** #311 EX.confirm reset box (`type:task`, Wave 2 — Complete play journey)
- **Mode:** `deterministic`
- **Deliverable commit:** `6884a36` (`main`, squash of PR #320; `game/` at `6884a36` is the tree measured and matches the branch commit `99dcd4e`)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from three runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`paint`, `navigate`, `solve-reset`), plus [`logs/gut-suite.log`](logs/gut-suite.log) for the unit-level I4 rows.
  Each protocol ran with a fresh `user://` document; the harness leaves `pack-000` in progress and later runs would
  start from a dirty record.

Selected axes are the Applies deterministic axes this deliverable can move: the reset confirm is a new
navigation/UI path drawn over the gallery (I1, I2, I7), the reset flow is part of `crash-free` (I9), and the
Confirm handler now commits through `CTR-pack` O7 and re-reads O1/O2 (I4).

No existing record covered `game/` at `6884a36`: the #310 record (`16c8df9`) predates this deliverable's
`game/` changes, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 14.18 ms over 203 frames; `navigate` p95 13.64 ms over 235 frames (gallery 9.52 ms / 73, reveal 13.75 ms / 162). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 16.30 ms in `paint` (203 frames) and 20.04 ms in `navigate` (235 frames); no frame exceeded 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest of `home-puzzle`, `puzzle-result`, `result-gallery` was 412.0 ms. | ≤ 500 ms | pass | — | `integration/logs/harness-1793609101-navigate.log`; `integration/results/navigate.json` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran in `paint`, `navigate`, and `solve-reset` with no failed I9 flow and no crashed run. The `solve-reset` protocol still exits 1 on its separate `leave` step (stale harness expectation noted in #310's record); that step is not one of the four I9 flows. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |
| `save-survives` | deterministic | I4: `test_confirming_the_box_clears_the_record_and_re_reads_o1_and_o2` confirms through the overlay, then reads `user://progress.cfg` back and finds the record cleared; `test_pack_progress.gd` covers the reset round-trip and `test_a_failed_write_leaves_the_previous_file` the failed commit. | Committed progress survives quit, crash, and upgrade | pass | — | `logs/gut-suite.log`; `game/test/test_shell_open.gd`; `game/test/test_pack_progress.gd` |
| `failed-write` | deterministic | I4: `test_a_failed_write_leaves_the_previous_file` fails the temp write and the next read still loads the previous commit; the reset path adds no new write seam. | A failed write leaves the previous commit loadable | pass | — | `logs/gut-suite.log`; `game/test/test_pack_progress.gd` |

## Not selected

- `time-to-playable` (I6) — no launch path changed; the overlay is built when the gallery is constructed after launch.
- `response-delay` (I8) — `ui-ack` times open, settings, and settings-Back; the confirm show/confirm leg is not one
  of them, and the overlay adds no timed UI step on those legs.
- `resume-after-failure` (I10) — no resume path changed; `kill-relaunch` still fails its elapsed leg as recorded
  for #310.
- `runtime-signals` (I11) — no log, sampler, or telemetry source was added or removed; the reset event is emitted
  by the existing seam.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or
`blocked`.
