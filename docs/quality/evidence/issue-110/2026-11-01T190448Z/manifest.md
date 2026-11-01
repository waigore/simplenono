# Quality evaluator run — issue #110

- **Issue:** #110 Puzzle screen: grid & clue bars (`UI-puzzle`)
- **Mode:** `deterministic`
- **Deliverable commit:** `859d834c75fce8a89af448cf60a56574dea147d3` (`main` HEAD; merged screen from PR #152 `2601fee` and PR #164 `bc438de`)
- **Evaluated:** 2026-11-01 by `issue-workflow-verify-agent` (parallel id 1), detached worktree, Godot 4.7.2 on macOS, headless
- **Observation source:** `integration/results.md`, from six sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=docs/quality/evidence/issue-110/2026-11-01T190448Z --story-ids=UI-puzzle`
  into this one folder (`app-start` 0, `paint` 0, `navigate` 1, `ui-ack` 0, `solve-reset` 0, `kill-relaunch` 1).

Selected axes are the Applies deterministic axes this deliverable can move: the screen is the paint surface
(I1, I2), it is present in every open/solve/reset/back flow (I9), and its chrome acknowledges open, settings
intent, and Back (I8). The previous `blocked` rows were blocked for want of the harness, not the screen.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1 p95 6.94 ms over 203 sampled paint frames (one mark per processed frame) | ≤ 16.7 ms | pass | — | `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2 longest frame 7.81 ms; `paint-hitches.ndjson` empty | ≤ 100 ms | pass | — | `integration/samples/paint-hitches.ndjson` |
| `crash-free` | deterministic | I9 open, solve, reset, and back all ran across the six protocols; no failed flow or crashed run. The `navigate` and `kill-relaunch` exits are their own axes. | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |
| `response-delay` | deterministic | I8 longest acknowledgement among open, settings intent, and Back 8.6 ms | ≤ 500 ms | pass | — | `integration/logs/harness-1793560005-ui-ack.log` |

## Verdict

`Pass` — every selected axis meets its bar. Unscored axes: [`axes.md`](axes.md). Cross-reference checks:
[`checks.md`](checks.md). Selection notes and limits: [`rationale.md`](rationale.md).
