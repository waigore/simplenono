# Quality evaluator run — issue #166

- **Issue:** #166 — Integration harness for the Applies integration-level quality invariants
- **Mode:** `deterministic`
- **Deliverable commit:** `86d57d04ddba0f9b814999d007427b632d522915` — PR [#178](https://github.com/waigore/simplenono/pull/178) head (its last commit is the `main` merge `4e9e78d`). The PR merged to `main` as `ac0dcae` while this verification ran; the run is against the PR head, which has the same tree.
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), detached worktree of that commit, local Godot 4.7.2 on macOS; headless
- **Observation source:** `integration/results.md` in this folder, produced by six sequential runs of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=docs/quality/evidence/issue-166/2026-11-02-verify-rerun`
  into this one run folder (`app-start` 0, `paint` 0, `navigate` 1, `ui-ack` 0, `solve-reset` 0, `kill-relaunch` 1).

Selected axes are the Applies deterministic integration axes whose outcome this deliverable can move, now that the
harness measures product acknowledgement rather than driver CPU time. The three latency axes are scored from this run
because the repair under review exists to make them measurable.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1 p95 6.94 ms over 203 sampled paint frames (one mark per processed frame: 200 cells + 3 pause frames, vs 103 before) | ≤ 16.7 ms | pass | — | `integration/samples/paint-samples.ndjson` |
| `hitch-bound` | deterministic | I2 longest frame 7.12 ms over the same 203 frames; `paint-hitches.ndjson` empty | ≤ 100 ms | pass | — | `integration/samples/paint-hitches.ndjson` |
| `time-to-playable` | deterministic | I6 cold launch to the interactive shell home (gallery stand-in until #94) 184.6 ms, measured from engine start across real processed frames | ≤ 3 s | pass | — | `integration/logs/harness-1793558848-app-start.log` |
| `transition-latency` | deterministic | I7 longest transition 2287.8 ms; `puzzle-result` was **not acknowledged within 2000 ms** because `UI-result` (#95) does not exist, so the 500 ms bar is exceeded. `home-puzzle` and `result-gallery` legs complete inside the run | ≤ 500 ms | fail | — | `integration/logs/harness-1793558851-navigate.log` |
| `response-delay` | deterministic | I8 longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` 8.5 ms, each leg crossing processed frames and waiting for its probe (previously 1.3 ms of synchronous driver time) | ≤ 500 ms | pass | — | `integration/logs/harness-1793558854-ui-ack.log` |
| `crash-free` | deterministic | I9 open, solve, reset, and back all ran across the six protocols, no failed flow and no crashed run; `navigate` and `kill-relaunch` exit 1 on their own axes, which I9 records rather than treating as a harness error | No crash across open, solve, reset, and back | pass | — | `integration/results.md` |
| `resume-after-failure` | deterministic | I10 next launch entry is the gallery stand-in (true), reopen succeeded, but `marks restored: false` and `elapsed restored: false` — progress persistence (#96) does not restore yet | Gallery entry; reopen restores marks and elapsed | fail | — | `integration/logs/relaunch-verify.json` |

## Not selected

`runtime-signals` (I11) — smoke level, outside the harness scope named in the issue body. `save-survives` / `failed-write`
(I4) — settled by the persistence diff, not this harness. N/A accessibility and localization axes are not scored.

## Verdict

`Fail` — two Applies deterministic axes (`transition-latency`, `resume-after-failure`) exceed their bars on this
deliverable's own observations. Both rows are failed by product gaps #95 and #96 that the issue body records as
out of scope, not by harness defects.
