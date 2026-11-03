# Quality evaluator run — issue #280

- **Issue:** #280 Puzzle pictures pack-188–pack-191 (20×20) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `a3c50b7` (PR #481 squash on `main`; `game/` at `a3c50b7` is the tree measured)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<scratch folder>`
  in a checkout whose `game/` is identical to `a3c50b7` (`git diff --quiet a3c50b7 -- game/` holds), harness session
  `harness-1793713639`. The harness's `logs/`, `samples/`, and `results/` are gitignored under
  `docs/quality/evidence/`, so this record keeps only the markdown.

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows'
fills and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or
save axis can move. It does put two new picture assets per puzzle on the gallery path — `shell.gd` `_picture_for`
resolves each visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is
the one Applies deterministic axis this deliverable can reach.

No existing record covers `game/` at `a3c50b7`: the passing records diff against it (`git diff --name-only
<recorded> a3c50b7 -- game/`) — #279 `58e6637` 17 files, #277 `0eb2d1d` 49, #276 `5b777e3` 49, #275 `cf9b4d1` 73,
#274 `ec135ed` 57. This record is a fresh run, not a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 1988.9 ms, `flows_failed` empty, `crashed` false. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`integration/results.md`](integration/results.md), harness session `harness-1793713639` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds data the pack loader already accepts (the
  `app-start` run above loaded the shell home with the new rows and pictures, `flows_failed` empty).
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
