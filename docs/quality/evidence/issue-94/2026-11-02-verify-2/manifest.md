# Quality evaluator run — issue #94

- **Issue:** #94 Gallery & pack progression (`type:epic`, Wave 2 — Complete play journey)
- **Mode:** `deterministic`
- **Deliverable commit:** `fe8c109` (`origin/main` HEAD; squash of PR #220, which fixed the
  navigation frame sampling and the R2 square tile picture from the prior verification fail)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 on
  macOS, headless
- **Observation source:** [`results.md`](integration/results.md), from five sequential
  `run_protocol.gd` runs into this folder (`app-start`, `paint`, `navigate`, `ui-ack`,
  `solve-reset`)

Selected axes are the Applies deterministic axes this deliverable can move: the gallery is
the launch target (I6), the gallery→puzzle and return legs (I1, I7), the reset flow (I9), and
the `user://progress.cfg` write path (I4).

## Axes

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `navigate` opens two windows — gallery p95 6.95 ms over 78 frames, reveal p95 6.94 ms over 173 frames (all windows 6.94 ms over 251); `paint` p95 6.94 ms over 203. | ≤ 16.7 ms during grid paint and navigation | pass | — | `integration/samples/navigate-samples.ndjson`; `integration/samples/paint-samples.ndjson` |
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 252.5 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793574114-app-start.log` |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` is 288.2 ms. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793574126-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` is 9.7 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793574132-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran across four protocols; no failed flow or crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md) |
| `save-survives` | deterministic | I4: O7 writes the cleared record and a fresh `Pack` reads it; marks and elapsed round-trip through `ProgressFile`. Unit level; the restart leg is I10. | Committed progress survives quit, crash, and upgrade | pass | — | `game/test/test_pack_progress.gd`; [`logs/gut-suite.log`](logs/gut-suite.log) |
| `failed-write` | deterministic | I4: `test_a_failed_write_leaves_the_previous_file` fails the temp write; the next read still loads the previous commit. | A failed write leaves the previous commit loadable | pass | — | `game/test/test_pack_progress.gd`; [`logs/gut-suite.log`](logs/gut-suite.log) |

## Cross-reference

- No cataloged assets changed; `review-asset` N/A.
- `review-code`: **Pass**, one suggestion — [`review-code.md`](review-code.md).
- Selection argument: [`selection.md`](selection.md). Independent checks and the UI
  comparison: [`checks.md`](checks.md). Verdict and advisory notes: [`rationale.md`](rationale.md).
- **Verdict:** `Pass`.
