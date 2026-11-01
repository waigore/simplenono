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

## Not selected

- `runtime-signals` (I11) — the screen emits no signal; `DebugSeams` records S4. This is #163's producer row, where
  its own run selects the axis and records the severity-log quarter as outstanding.
- `transition-latency` (I7) — fails on `puzzle-result` (2291.6 ms) because `UI-result` is #95; the screen's own
  `home-puzzle` leg is `ok` in `integration/results/navigate.json`.
- `time-to-playable` (I6) — launch to the gallery stand-in (#94); the screen is not on that path.
- `resume-after-failure` (I10) — restore is #96.
- `save-survives` / `failed-write` (I4) — the screen writes no committed progress; leave/commit is #96.
- N/A accessibility and localization axes are not scored.

## Cross-reference

- `review-asset`: N/A, no cataloged assets changed.
- `review-code` on PR #152 + #164: **Pass**, no must-fix; one `suggestion` (`_line_status` cached across a bare
  `refresh()`).
- Independent checks on `859d834`: GUT `11 scripts / 139 tests / 139 passing / 29204 asserts` exit 0;
  `gdformat --check game` 57 files unchanged; `gdlint game` Success; both PRs' five checks SUCCESS.
- `MC.puzzle` is still `approved`; regions R1–R3, states S1–S3, and `copy.*` match the mockup and UX spec.

## Verdict

`Pass` — every selected axis meets its bar. Selection notes and limits: [`rationale.md`](rationale.md).
