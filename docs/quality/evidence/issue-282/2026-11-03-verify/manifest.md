# Quality evaluator run — issue #282

- **Issue:** #282 Puzzle pictures pack-196–pack-199 (20×20) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `1b5dbc9` (PR #489 squash on `main`; `game/` at `1b5dbc9` is the tree measured)
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on macOS
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<scratch folder>`
  in a detached worktree checked out at `1b5dbc9` with a clean `git status -- game/` (verified before and after
  `godot --headless --import --path game`, which produced no tracked change). Harness session `harness-1793718363`.
  The harness's `logs/`, `samples/`, and `results/` are gitignored under `docs/quality/evidence/`, so this record keeps
  only the markdown.

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new picture assets per puzzle on the gallery path — `shell.gd` `_picture_for` resolves each
visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

No existing record covers `game/` at `1b5dbc9`: the passing records diff against it
(`git diff --name-only <recorded> 1b5dbc9 -- game/`) — #280 `a3c50b7` 17 files, #280 evidence-only `d874be3` 17,
#279 `58e6637` 33. This record is a fresh run, not a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 284.3 ms, `flows_failed` empty, `crashed` false. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`integration/results.md`](integration/results.md), harness session `harness-1793718363` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the deliverable adds data the pack loader already accepts (the `app-start`
  run above loaded the shell home with the new rows and pictures, `flows_failed` empty, `crashed` false).
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
