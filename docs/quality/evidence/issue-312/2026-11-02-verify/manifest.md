# Quality evaluator run — issue #312

- **Issue:** #312 Desktop keyboard bindings B4–B10, B14–B20, B24–B30 (`type:task`, Wave 2 — Complete play journey)
- **Mode:** `deterministic`
- **Deliverable commit:** `fcd899e` (`main`, squash of PR #324; the tree is identical to branch head `2a6c57b`)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from four runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  (`paint`, `navigate`, `ui-ack`, `solve-reset`), plus [`logs/gut-suite.log`](logs/gut-suite.log) for unit-level context.
  Each protocol ran with a fresh `user://` document; the harness leaves `pack-000` in progress and later runs would
  start from a dirty record.

Selected axes are the Applies deterministic axes this deliverable can move: the new keyboard path adds
input routes to open, settings, and back (`response-delay`, I8), changes the focusable/visible control set on
the gallery, puzzle, settings, and result screens (`frame-time`, `hitch-bound`, I1–I2 during navigation), and its
`_input` handling runs inside the open/solve/reset/back flows (`crash-free`, I9).

No existing record covered `game/` at `fcd899e`: the #311 record (`6884a36`) predates this deliverable's
`game/` changes, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 16.67 ms over 203 frames; `navigate` p95 14.55 ms over 234 frames (gallery 9.26 ms / 72, reveal 14.58 ms / 162). | ≤ 16.7 ms frame time during grid paint and navigation | pass | — | `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 22.09 ms in `paint` (203 frames) and 30.03 ms in `navigate` (234 frames); no frame exceeded 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` was 31.4 ms. | ≤ 500 ms | pass | — | `integration/logs/harness-1793610637-ui-ack.log`; `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran in `paint`, `navigate`, `ui-ack`, and `solve-reset` with no failed I9 flow and no crashed run. `solve-reset` still exits 1 on its separate `leave` step (the stale harness expectation recorded for #310); that step is not one of the four I9 flows. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — no launch path changed; the keyboard node is built with the shell after home.
- `transition-latency` (I7) — the deliverable changes how a control is invoked, not the gallery↔puzzle,
  puzzle→result, or result→gallery transition work. (`navigate` measured it incidentally at 431.4 ms, inside the bar.)
- `save-survives`, `failed-write` (I4) — no persistence path changed; the keyboard rows only call existing
  shell intents.
- `resume-after-failure` (I10) — no resume path changed; `kill-relaunch` still has the elapsed-leg gap recorded
  for #310.
- `runtime-signals` (I11) — no log, sampler, or telemetry source was added or removed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.

## Verdict

`Pass` — every selected Applies deterministic axis is observed and within its bar, and no row is `fail` or
`blocked`. The `paint` p95 margin (16.67 ms against 16.7 ms) is narrow, but the keyboard deliverable adds no
per-frame paint work; the paint loop itself is unchanged and the value is within the bar.
