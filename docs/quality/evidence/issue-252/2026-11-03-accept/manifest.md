# Quality evaluator cues — issue #252 (acceptance)

- **Issue:** #252 Puzzle pictures pack-078–pack-081 (15×15) (`type:task`)
- **Mode:** `deterministic` (reused observation; acceptance does not judge a rubric)
- **Deliverable commit:** `ee57b38` (`main` after PR #372 — the squash that lands the slice), observed
  on `main@c41c104`, where nothing under this slice's pictures or its four pack rows changed
- **Observed:** 2026-11-03 by `issue-workflow-accept-agent` (parallel id 1), Godot 4.7.2 headless on macOS arm64
- **Observation source:** [`integration/results.md`](../../../playtest/evidence/issue-252/2026-11-03-accept-graphical/quality-app-start/integration/results.md) — one `app-start` run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<folder>`

Only `time-to-playable` is selected. The deliverable adds eight static picture files and rewrites four pack rows' fills and clues;
it changes no runtime code, so no grid-paint, navigation acknowledgement, crash, resume, signal, or save axis can move. It does put
two new `CompressedTexture2D` assets per puzzle on the gallery path, so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 307.5 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793647724-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run above passed and the graphical capture loaded all 200 rows.
- `resume-after-failure` (I10), `runtime-signals` (I11), `save-survives` / `failed-write` (I4) — no save, log, or sampler path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is `deterministic`, and the
domain axes list is empty.
