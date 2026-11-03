# Quality evaluator cues — issue #251 (acceptance)

- **Issue:** #251 Puzzle pictures pack-074–pack-077 (15×15) (`type:task`)
- **Mode:** `deterministic` (fresh observation; acceptance does not judge a rubric)
- **Deliverable commit:** `main` at `9053c8c` (`git diff 84082e1 9053c8c -- game/` is empty, so the tree is the slice's `game/` as landed by PR #374)
- **Observed:** 2026-11-03 by `issue-workflow-accept-agent` (parallel id 1), Godot 4.7.2 headless on macOS arm64
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected. The deliverable adds eight static picture files and rewrites four pack rows'
fills and clues; it changes no runtime code, so no grid-paint, navigation acknowledgement, crash, resume, signal, or
save axis can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path, so
launch-to-interactive-gallery is the one Applies deterministic axis this deliverable can reach.

No existing record covers `game/` at this commit: `docs/quality/evidence/issue-251/` has no prior run, and the nearest
sibling slices' records (`issue-248`, `issue-246`, …) name commits whose `game/` trees differ. This is a fresh run.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 306.9 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793646469-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run above passed and the graphical capture on the same
  tree loaded all 200 rows and finished every judged flow.
- `resume-after-failure` (I10), `runtime-signals` (I11), `save-survives` / `failed-write` (I4) — no save, log, or
  sampler path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty.
