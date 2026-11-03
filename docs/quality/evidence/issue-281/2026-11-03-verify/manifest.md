# Quality evaluator run — issue #281

- **Issue:** #281 Puzzle pictures pack-192–pack-195 (20×20) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `6d7ba7a` (PR #491 head, squash-merged to `main` as `02c332e`; `game/` at `6d7ba7a` is the tree measured)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on macOS
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<scratch folder>`
  in a checkout whose `game/` is identical to `6d7ba7a` (`git diff --quiet 6d7ba7a -- game/` holds), harness session
  `harness-1793720643`. The harness's `logs/`, `samples/`, and `results/` are gitignored under
  `docs/quality/evidence/`, so this record keeps only the markdown.

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows'
fills and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or
save axis can move. It does put two new picture assets per puzzle on the gallery path — the shell resolves each
visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

No existing record covers `game/` at `6d7ba7a`: the passing records diff against it (`git diff --name-only <recorded>
6d7ba7a -- game/`) — #280 `a3c50b7` 16 files, #279 `58e6637` 24, #277 `0eb2d1d` 48. This record is a fresh run, not a
reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 292.0 ms, `flows_failed` empty, `crashed` false. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`integration/results.md`](integration/results.md), harness session `harness-1793720643` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds data the pack loader already accepts (the `app-start`
  run above loaded the shell home with the new rows and pictures, `flows_failed` empty).
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
deterministic.

## Caveat for readers

The harness run is on macOS; the #278–#280 records measured Linux. The axis bar (≤ 3 s) is platform-agnostic and the
observation clears it by an order of magnitude. CI covers the Linux path for `Integration harness`.
