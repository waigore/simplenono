# Quality evaluator run — issue #95

- **Issue:** #95 Result, settings & navigation
- **Mode:** `deterministic`
- **Deliverable commit:** `94e6c556bde74c11ceec6d44d61c94dbcf83e429` (`main` HEAD; PR #202 `71efe63` settings + navigation, PR #208 `94e6c55` result screen)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 on macOS, headless
- **Observation source:** `integration/results.md`, from five sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<folder>`
  into this one folder (`app-start` 0, `paint` 0, `navigate` 0, `ui-ack` 0, `solve-reset` 0).

Selected axes are the Applies deterministic axes this deliverable can move: it adds the result reveal and the
cross-screen legs (I7), the timed settings surface (I8), and the open/solve/reset/back flows (I9).
`frame-time`/`hitch-bound` can also move (I1 names navigation), but only `paint` samples frames and it never
opens the result, so the reveal's frames are unobserved.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1 covers grid paint and navigation, but `navigate-samples.ndjson` is empty: no protocol samples a frame while the result reveal draws. | ≤ 16.7 ms frame time during grid paint and navigation | blocked | `no-invariant` — no harness observation exists for the reveal's frames. | `integration/samples/navigate-samples.ndjson` (empty) |
| `hitch-bound` | deterministic | Same gap: `navigate-hitches.ndjson` is empty. | No hitch longer than 100 ms during grid paint | blocked | `no-invariant` — no harness observation exists for the reveal's frames. | `integration/samples/navigate-hitches.ndjson` (empty) |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` is 288.9 ms; every leg is product-acknowledged. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793569925-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` is 8.4 ms; toggles are synchronous writes, not separately timed. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793569927-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran across four protocols; no failed flow and no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — cold launch to the interactive gallery is #94; the `app-start` row is context only.
- `resume-after-failure` (I10) — mark/elapsed restore is #96.
- `save-survives`, `failed-write` — this deliverable adds no `user://` write; the two session flags are memory-only.
- `runtime-signals` (I11) — no telemetry source is added or removed; S1–S5 and S4 are #163's.
- N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets changed; `review-asset` N/A.
- `review-code`: **Fail**, one `must-fix`, two suggestions — [`review-code.md`](review-code.md).
- Independent checks and run commands — [`checks.md`](checks.md). Finding detail and probe — [`rationale.md`](rationale.md).

## Verdict

`Fail` — `frame-time` and `hitch-bound` are blocked (`no-invariant`: no observation covers the result reveal),
which fails the run per [`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md);
the verified behavior also misses `result.md` S2/S3 (`CFG.MORPH_STAGE_MS` per stage), so
[`verify-project-issue`](../../../../../.agents/skills/verify-project-issue/SKILL.md) fails verification.
