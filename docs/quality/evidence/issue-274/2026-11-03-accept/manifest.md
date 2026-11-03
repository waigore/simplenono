# Quality evaluator run — issue #274

- **Issue:** #274 Puzzle pictures pack-166–pack-169 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `ec135ed` (`main` at the acceptance run; `game/` at `ec135ed` is the tree measured)
- **Evaluated:** 2026-11-03 by `issue-workflow-accept-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new `CompressedTexture2D` assets per puzzle on the gallery path — the shell resolves each
visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

No earlier record was reused: the passing `deterministic` records on file belong to other issues and their probes, and
none of them reports this issue's deliverable. A record whose `game/` tree matches this one exists for #272
(`5b260e8`, `time-to-playable` 1900.4 ms pass), but it is that issue's record and is not cited as evidence here. This
run is the fresh record for #274.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 2023.7 ms, 0 rejected pack rows. | Cold launch to interactive gallery ≤ 3 s | pass | — | `integration/logs/harness-1793707807-app-start.log` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run above loaded the shell home with the new rows and
  pictures and recorded no failed flow.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies, so `run-quality-evaluators` adds no `llm-judge`
evidence for this issue.

