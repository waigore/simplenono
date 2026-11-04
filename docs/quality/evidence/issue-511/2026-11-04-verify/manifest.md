# Quality evaluator run — issue #511

- **Issue:** #511 Settings: mobile portrait↔landscape orientation control (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `be4bd6a` (`main` at verification). The issue's own code is PR #518 → `5868833`; `5868833..be4bd6a` carries `0b0b15b` (#505, `game/presentation/puzzle_board.gd` clue-unit accessors + `game/test/test_puzzle_board.gd`), so the record is written against the merged `main` tree that the issue will ship in.
- **Evaluated:** 2026-11-04 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64
- **Observation source:** [`integration/results.md`](integration/results.md), from `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>` for `ui-ack` and `solve-reset`, each under a fresh `HOME` (`user://`).

The deliverable adds `UI-settings.C4`, a mobile-only settings row that writes `SCH-preferences` F3 through `OrientationLock` and shows the value. I8 is the axis it can move: "settings toggle" acknowledgement, observed by the `ui-ack` protocol, which now drives the settings screen through its C1/C2 toggles (and, in tests, C4). I9 rides the same non-paint flows (open, settings/back, solve, reset) that build and press this screen's controls. No paint, navigation, launch, telemetry, or `SCH-progress` code changes, so `frame-time`, `hitch-bound`, `transition-latency`, `time-to-playable`, `runtime-signals`, `resume-after-failure`, and the `save-survives` chain are not selected (the durable orientation document is F3's own, not `SCH-progress`; #504's record at `9c322b5` covers the launch read).

No earlier record covers this `game/` tree: the nearest, #507 at `b104b65`, predates `5868833` in `game/presentation/settings.gd`, `settings.tscn`, `shell.gd`, and the two settings test files, and `5868833..be4bd6a` adds #505's `puzzle_board.gd` change on top.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 27.8 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md) (`ui-ack` row); `integration/logs/harness-1793767427-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `back`, `open`, `reset`, `solve` ran in both `ui-ack` and `solve-reset`; no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results/ui-ack.json`; `integration/results/solve-reset.json` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed.
- `transition-latency` (I7) — no navigation leg changed; the C4 press stays on Settings.
- `time-to-playable` (I6) — launch reads `OrientationLock` unchanged; the shell only re-presents it to the screen (#504's record covers the launch read).
- `resume-after-failure` (I10) — no `progress.cfg` or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- Save durability (I4) — covers committed `SCH-progress`; F3 is a separate document under ADR-0009.
- Accessibility and Localization — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is `deterministic`, and the domain-axis list is empty.
