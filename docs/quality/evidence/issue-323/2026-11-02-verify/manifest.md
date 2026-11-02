# Quality evaluator run — issue #323

- **Issue:** #323 J-leave-resume pause leg, pause-then-quit story, and Android Back (`type:task`, Wave 2 — Complete play journey)
- **Mode:** `deterministic`
- **Deliverable commit:** `1520675` (`main`, squash of PR #340; the local branch head `62fd0ec` has an identical tree, `git diff 62fd0ec 1520675` is empty)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from four runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`paint`, `navigate`, `ui-ack`, `solve-reset`), plus [`logs/gut-suite.log`](logs/gut-suite.log) for the unit-level I4 rows.
  Each protocol ran with a fresh `user://` document; the harness leaves `pack-000` in progress and a later protocol would
  start from that dirty record (the first `solve-reset` attempt hit exactly that and was re-run clean).

Selected axes are the Applies deterministic axes this deliverable can move: the new B37 Back route adds an
acknowledgement path (`response-delay`, I8) and a back flow (`crash-free`, I9), it changes the result→gallery
exit and the gallery return (`frame-time`, `hitch-bound`, `transition-latency`, I1/I2/I7), and its pause→quit→reopen
leg is the outcome of the save-durability row (`save-survives`, I4).

No existing record covered `game/` at `1520675`: the #312 record (`fcd899e`) predates this deliverable's
`game/` changes, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 16.67 ms over 203 frames; `navigate` p95 16.38 ms over 233 frames (gallery 8.33 ms / 73, reveal 16.67 ms / 160). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 21.60 ms in `paint` (203 frames) and 32.79 ms in `navigate` (233 frames); no frame exceeded 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` was 456.6 ms. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793624678-navigate.log`; `integration/results/navigate.json` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` was 30.4 ms. | Non-paint UI (open, settings, Back) ≤ 500 ms | pass | — | `integration/logs/harness-1793624696-ui-ack.log`; `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran in `paint`, `navigate`, `ui-ack`, and `solve-reset` with no failed flow and no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |
| `save-survives` | deterministic | I4: `test_pause_then_quit_restores_the_marks_and_elapsed_on_reopen` pauses, reads the document through a second shell (the relaunch), and finds the marks and elapsed restored; `test_pause_during_get_set_ready_commits_the_restored_marks_as_held` and `test_pause_with_nothing_to_persist_skips_the_commit` cover the commit legs; `test_pack_progress.gd` keeps the round-trip and failed-write coverage. | Committed progress survives quit, crash, and upgrade | pass | — | `logs/gut-suite.log`; `game/test/test_pause_resume.gd`; `game/test/test_pack_progress.gd` |

## Not selected

- `time-to-playable` (I6) — no launch path changed; the Back handler and the gallery return run after home.
- `failed-write` (I4) — no write seam changed; the pause commit and the reopen read path are the existing ones,
  and `test_a_failed_write_leaves_the_previous_file` is unchanged and green.
- `resume-after-failure` (I10) — this deliverable proves the graceful quit/relaunch leg, not kill/crash mid-puzzle;
  the `kill-relaunch` elapsed-leg gap recorded for #310 is unchanged and unrelated to this diff.
- `runtime-signals` (I11) — the pause, resume, and leave events already existed and no log, sampler, or telemetry
  source was added or removed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or
`blocked`.
