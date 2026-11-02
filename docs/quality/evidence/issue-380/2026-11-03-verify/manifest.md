# Quality evaluator run — issue #380

- **Issue:** #380 Gallery reset confirm draws blank on first open until a window resize (`type:defect`)
- **Mode:** `deterministic`
- **Deliverable commit:** `fcbe319` (PR #384 head, `fix/380-confirm-first-layout`, after merging `main`; the layout fix is `0a11ec0`, and `game/` at `fcbe319` is the tree measured)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on macOS arm64
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=solve-reset --run-dir=<this folder>`
  with a fresh `user://` document, plus `integration/logs/harness-1793640220-solve-reset.log` for the per-step flow record.

The only Applies deterministic axis this deliverable can move is `crash-free` (I9): the fix changes
`ConfirmOverlay._layout()`, which runs when the gallery's reset flow opens `EX.confirm`, so the reset
flow is the one I9 flow whose code changed. The `solve-reset` protocol drives all four I9 flows and
records no crashed run and no failed flow.

No existing record covers `game/` at `fcbe319`: the #311 record (`6884a36`) predates this deliverable's
`game/` changes, so this is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, back, reset; `flows_failed` empty; `crashed` false. | No crash across open, solve, reset, and back | pass | — | `integration/results/solve-reset.json`; `integration/logs/harness-1793640220-solve-reset.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1–I2) — the fix shapes the autowrapped title once when the box opens; it
  adds no per-frame work in the `paint` grid window or the `navigate` gallery/reveal windows the harness
  samples, and `solve-reset` claims no I1/I2 row.
- `response-delay` (I8) — `ui-ack` times open, settings, and settings-Back; the reset confirm's show leg
  is not one of them (the same reading as the #311 record).
- `transition-latency` (I7) — no gallery↔puzzle, puzzle→result, or result→gallery transition changed.
- `save-survives`, `failed-write` (I4) — no persistence path changed; the copy and the confirmed/cancelled
  intents are untouched.
- `time-to-playable` (I6) — no launch path changed; the overlay is built with the gallery after launch.
- `resume-after-failure` (I10) — no resume path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source was added or removed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge`
row applies.

## Verdict

`Pass` — the selected Applies deterministic axis is observed and within its bar, and no row is `fail` or
`blocked`.
