# Quality evaluator run — issue #94

- **Issue:** #94 Gallery & pack progression (`type:epic`, Wave 2 — Complete play journey)
- **Mode:** `deterministic`
- **Deliverable commit:** `48d2b58` (`origin/main` HEAD; PR #194 `9d6ffb7` pack serve + progress file, PR #199 `52e8275` gallery screen + shell route, PR #213 `48d2b58` reset leg + story rows)
- **Evaluated:** 2026-11-02 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 on macOS, headless
- **Observation source:** [`results.md`](integration/results.md), from five sequential
  `run_protocol.gd` runs into this folder (`app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset`)

Selected axes are the Applies deterministic axes this deliverable can move: the gallery screen is
the launch target (I6), the gallery→puzzle and leave legs (I7, I8), the reset flow (I9), and the
new `user://progress.cfg` write path (I4).

## Axes

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1 names grid paint **and navigation**. Only `paint` samples frames (p95 6.94 ms over 203 frames) and never draws the gallery; `navigate-samples.ndjson` is empty although the gallery builds 200 nodes in one navigation frame. | ≤ 16.7 ms frame time during grid paint and navigation | blocked | `no-invariant` — no harness observation covers gallery/navigation frames. | `integration/samples/navigate-samples.ndjson` (empty); `integration/samples/paint-samples.ndjson` |
| `time-to-playable` | deterministic | I6: cold launch to the interactive gallery — `home_ready` is `Shell.GALLERY_VIEW` with `%Gallery` visible in tree — 253.3 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793571375-app-start.log` |
| `transition-latency` | deterministic | I7: longest of `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` is 290.3 ms; every leg is product-acknowledged. | Gallery↔puzzle, puzzle→result, result→gallery ≤ 500 ms | pass | — | `integration/logs/harness-1793571378-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:open`, `ack:settings`, `ack:back` is 7.3 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | `integration/logs/harness-1793571380-ui-ack.log` |
| `crash-free` | deterministic | I9: open, solve, reset, and back ran across four protocols; no failed flow or crashed run; the reset ran through the gallery C2 trigger. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md) |
| `save-survives` | deterministic | I4: O7 writes the cleared record and a new `Pack` reads that file; marks and elapsed round-trip through `ProgressFile`. Unit level; the restart leg is I10. | Committed progress survives quit, crash, and upgrade | pass | — | `game/test/test_pack_progress.gd` |
| `failed-write` | deterministic | I4: `test_a_failed_write_leaves_the_previous_file` fails the temp write and the next read still loads the previous commit. | A failed write leaves the previous commit loadable | pass | — | `game/test/test_pack_progress.gd` |

## Cross-reference

- No cataloged assets changed; `review-asset` N/A.
- `review-code`: **Pass**, four suggestions — [`review-code.md`](review-code.md).
- Selection argument: [`selection.md`](selection.md). Independent checks, commands, and the UI
  comparison: [`checks.md`](checks.md). Selection reasoning and the UI finding:
  [`rationale.md`](rationale.md).
- **Verdict:** `Fail` — see [`rationale.md`](rationale.md#verdict).
