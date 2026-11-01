# Quality evaluator run — issue #112

- **Issue:** #112 Journey: open a puzzle directly (shell → puzzle open leg)
- **Mode:** `deterministic`
- **Run id:** `2026-11-02-accept-graphical/quality` (beside this issue's graphical acceptance run)
- **Deliverable commit:** `09c022e` (`main` when this run started; the shell's open leg is unchanged since `f05441c`, PR [#155](https://github.com/waigore/simplenono/pull/155))
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02, Godot 4.7.2 on macOS, headless
- **Observation source:** `integration/results.md` in this folder — `navigate`, `solve-reset`, and `ui-ack` into one run folder

## Why this run exists

The previous acceptance run left #112 waiting on a `deterministic` record: `response-delay` (I8) and `transition-latency` (I7) can move at this layer and none existed for the deliverable, while acceptance could not produce one (#204). #204 did not land, so this run takes the other legal route in the accept skill — [`run-quality-evaluators`](../../../../../../.agents/skills/run-quality-evaluators/SKILL.md) **user request**: the user asked for this acceptance run, and the two axes are measured through their existing integration-level invariants (H3), not re-implemented here.

## Results

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: `ui-ack` opened `pack-000`, asked for settings, and went back; longest acknowledgement among `ack:open` / `ack:settings` / `ack:back` 7.0 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793569577-ui-ack.log` |
| `transition-latency` | deterministic | I7: `navigate` ran gallery→puzzle, puzzle→result, result→gallery; longest transition among the three 288.3 ms (`result-gallery`, which waits out the result's two morph stages). | Stage or mode transitions ≤ 500 ms | pass | — | `integration/logs/harness-1793569588-navigate.log` |
| `crash-free` | deterministic | I9: `navigate`, `solve-reset`, and `ui-ack` together ran the open, solve, reset, and back flows with no failed flow and no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `frame-time` (I1), `hitch-bound` (I2) — grid paint; this leaf adds no drawing. Covered by #110/#93.
- `time-to-playable` (I6) — gallery launch is #94's outcome, not the open leg's.
- `resume-after-failure` (I10), `save-survives`, `failed-write` — progress persistence is #96 (ADR-0002).
- `runtime-signals` (I11) — the S1–S5 seams and telemetry are #163's deliverable.
- N/A accessibility and localization axes are not scored.

## Bar and limits

Both selected latency axes are integration-level and observed headless on this machine; the numbers are sample observations, not device-tier certification. `response-delay` times the settings route (#95) as well as open and back, so it also proves the puzzle screen acknowledges C6 and C1 within the bar on this build.

## Reproduce

```
godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams \
    --protocol=ui-ack --run-dir=<this folder>
godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams \
    --protocol=navigate --run-dir=<this folder>
godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams \
    --protocol=solve-reset --run-dir=<this folder>
```
