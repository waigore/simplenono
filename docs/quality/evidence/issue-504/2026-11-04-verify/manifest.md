# Quality evaluator run — issue #504

- **Issue:** #504 Mobile: locked orientation default portrait with durable toggle (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `9c322b5` (`main`, squash of PR #514, head `b12724d`). The PR head under test was
  `be836d2`; `git diff be836d2 9c322b5 -- game/ specs/` is empty, so the tested tree is the merged tree.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64
- **Observation source:** [`results.md`](results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<folder>`
  for `app-start`, `ui-ack`, and `solve-reset`, under one isolated `HOME` (fresh `user://`).

The deliverable adds `OrientationLock`, which the shell runs in `_ready()` before the first screen (one
`ConfigFile.load` at launch), plus a durable write on change. That launch read is the `time-to-playable`
(I6) path, so I6 is selected. The write path and the shell-start change touch the same flows the
`crash-free` (I9) and `response-delay` (I8) rows record, so those are selected too. No paint, navigation,
or telemetry code changes, and the new document is not `SCH-progress`, so `frame-time`, `hitch-bound`,
`transition-latency`, `runtime-signals`, `resume-after-failure`, and the `save-survives` chain (I4, which
covers committed progress) are not selected.

No earlier record covers this `game/` tree: the nearest, #507 at `b104b65`, predates `orientation_lock.gd`,
`shell.gd` R7, and `project.godot`'s `display` section.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1842.6 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`results.md`](results.md) (`app-start` row) |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 30.6 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](results.md) (`ui-ack` row) |
| `crash-free` | deterministic | I9: flows `back`, `open`, `reset`, `solve` ran in both `ui-ack` and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](results.md) (`ui-ack`, `solve-reset` rows) |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed.
- `transition-latency` (I7) — no navigation leg changed.
- `resume-after-failure` (I10) — no `progress.cfg` or relaunch path changed; the new document is read at
  start only.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — I4 covers committed `SCH-progress`; F3 is a separate document under
  ADR-0009, and its own write-failure behavior is covered by unit tests, not by I4.
- Accessibility and Localization — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain-axis list is empty.
