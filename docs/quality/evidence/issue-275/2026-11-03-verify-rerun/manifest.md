# Quality evaluator run — issue #275

- **Issue:** #275 Puzzle pictures pack-170–pack-173 (15×15) (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `58e6637` (the tree acceptance tested at `ef1c0b7`; `game/` at `58e6637` is the tree measured) — PR #453 squash `d688934` plus the picture slices merged after it, acceptance playtest evidence `e3c857d`
- **Evaluated:** 2026-11-03 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 headless on Linux
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<scratch folder>`
  in a detached worktree at `58e6637` after a clean `--import` (harness session `harness-1793712076`). The harness writes
  `logs/`, `samples/`, and `results/` into the run folder; those are gitignored under `docs/quality/evidence/`, so only
  this record is kept in git and `results.md` gives the reproduce steps.

Only `time-to-playable` is selected. This deliverable adds eight static picture files and rewrites four pack rows' fills
and clues; it changes no runtime code, so no grid-paint, navigation, acknowledgement, crash, resume, signal, or save axis
can move. It does put two new picture assets per puzzle on the gallery path — `shell.gd` `_picture_for` resolves each
visible tile's `picture-id` through the manifest at shell setup — so launch-to-interactive-gallery is the one Applies
deterministic axis this deliverable can reach.

No existing record covers `game/` at `58e6637`. The issue's earlier record, `issue-275/2026-11-03-verify`, names
`cf9b4d1` (PR #453's unmerged head); `git diff --name-only cf9b4d1 58e6637 -- game/` is non-empty (the sibling
slices' pictures and the `pack-174`–`pack-187` row rewrites), so it cannot be reused. This is a fresh run, which is what
acceptance returned the issue for.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 2195.0 ms at `58e6637` after a clean re-import; `flows_failed` empty, `crashed` false. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`integration/results.md`](integration/results.md), harness session `harness-1793712076` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable adds data and assets only.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed.
- `crash-free` (I9) — no flow code changed; the `app-start` run above loaded the shell with the new rows and pictures.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.
