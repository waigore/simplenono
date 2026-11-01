# Quality evaluator run — issue #95

- **Issue:** #95 Result, settings & navigation
- **Mode:** `deterministic`
- **Deliverable commit:** `94e6c556bde74c11ceec6d44d61c94dbcf83e429` (`main` HEAD; PR #202 `71efe63` settings + navigation, PR #208 `94e6c55` result screen)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 on macOS, headless
- **Observation source:** `integration/results.md`, from five sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<folder>`
  into this one folder (`app-start` 0, `paint` 0, `navigate` 0, `ui-ack` 0, `solve-reset` 0).

Selected axes are the Applies deterministic axes this deliverable can move: it adds the result reveal and the
cross-screen navigation legs (I7), the settings surface whose acknowledgement and Back are timed (I8), and it
is present in the open/solve/reset/back flows (I9). `frame-time` and `hitch-bound` can also move (I1 names
navigation), but only the `paint` protocol samples frames and it never opens the result screen, so the reveal's
frames have no citing observation and those rows are recorded as blocked.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1 lists grid paint and navigation, but `navigate-samples.ndjson` is empty: no protocol samples a frame while the result reveal draws. | ≤ 16.7 ms frame time (~60 fps) during grid paint and navigation | blocked | `no-invariant` — no harness observation exists for the result reveal's frames; `paint` samples grid paint only. | `integration/samples/navigate-samples.ndjson` (empty) |
| `hitch-bound` | deterministic | Same gap: `navigate-hitches.ndjson` is empty, so no hitch observation covers the reveal. | No hitch longer than 100 ms during grid paint on mid-range phones | blocked | `no-invariant` — no harness observation exists for the result reveal's frames. | `integration/samples/navigate-hitches.ndjson` (empty) |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` is 288.9 ms; all three legs are product-acknowledged (no `driver_time` row). | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793569925-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` is 8.4 ms. The settings toggles are synchronous flag writes and are not separately timed. | Non-paint UI (open puzzle, settings toggle, Back) acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793569927-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back all ran across `paint`, `navigate`, `ui-ack`, and `solve-reset`; no failed flow and no crashed run. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |

## Not selected

- `time-to-playable` (I6) — cold launch to the interactive gallery; the gallery is #94. The `app-start` row is context only.
- `resume-after-failure` (I10) — mark/elapsed restore is #96.
- `save-survives`, `failed-write` — this deliverable adds no `user://` write; the two session flags are memory-only.
- `runtime-signals` (I11) — no telemetry source is added or removed; the S1–S5 seams and S4 telemetry are #163's.
- N/A accessibility and localization axes are not scored.

## Cross-reference

- No cataloged assets changed; `review-asset` N/A.
- `review-code` on the PR #202 / #208 diffs: **Fail**, one `must-fix` (duplicate reveal clock, SRP) plus one
  `suggestion` (dead copy constants). Report in [`rationale.md`](rationale.md) and on issue #95.
- Independent checks on `94e6c55`: GUT `19 scripts / 215 tests / 215 passing / 29956 asserts` exit 0;
  `gdformat --check game` 80 files unchanged; `gdlint game` no problems; PR #202 and #208 all checks green.
  A temporary headless probe of the real frame loop showed the reveal advancing twice per frame and completing
  while the attempt was paused — see [`rationale.md`](rationale.md).

## Verdict

`Fail` — `frame-time` and `hitch-bound` are blocked (`no-invariant`: no observation covers the result reveal),
which fails the run per [`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md);
the verified behavior also misses `result.md` S2/S3 (`CFG.MORPH_STAGE_MS` per stage), so
[`verify-project-issue`](../../../../../.agents/skills/verify-project-issue/SKILL.md) fails verification.
