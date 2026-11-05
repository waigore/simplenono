# Quality evaluator run — issue #610

- **Issue:** #610 K5 pack-look closing review across the 200 approved pairs (`type:task`)
- **Mode:** `deterministic`
- **Deliverable commit:** `249aa66` (`main`, squash of PR #621; `game/` at `249aa66` is the tree measured)
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64. The `.godot` import cache was rebuilt (`godot --headless --path game --import`) before the GUT and harness runs.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=app-start --run-dir=<this folder>`

Only `time-to-playable` is selected. This deliverable replaces 17 picture pairs (same asset ids, version raised),
rewrites 17 `game/data/pack.json` rows from the stored pixels, regenerates `assets/manifest.json`, and amends the
`K5` row in `specs/assets/kinds/puzzle-pictures.md`; it changes no runtime code, so no grid-paint, navigation,
acknowledgement, crash, resume, signal, or save axis can move. It keeps the same count of `CompressedTexture2D`
picture assets per puzzle on the gallery path (`shell.gd` resolves each visible tile's `picture-id` through the
manifest at shell setup), so launch-to-interactive-gallery is the one Applies deterministic axis this deliverable
can reach.

No existing record covered `game/` at `249aa66`: the newest passing deterministic records differ in `game/`
(#565's `e8a03ea` differs in 53 files, including the 34 replaced picture files and `pack.json`), so this is a fresh
run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) 2248.8 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`results.md`](integration/results.md); `integration/samples/app-start-samples.ndjson`. The harness wrote `integration/logs/harness-1793855127-app-start.log`, which the run folder keeps uncommitted |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — no paint or navigation code changed; the deliverable does not reach those paths.
- `transition-latency`, `response-delay` (I7, I8) — no navigation or input path changed. A `navigate` probe run for
  this verification failed at its `solve` step (`no fill was written` for `pack-000`) and at the reveal-window
  frame-time p95; the same `solve` failure reproduces at `249aa66^` (pre-PR), so it is a pre-existing harness/product
  gap, not a regression from this deliverable, and it is not a selected axis.
- `crash-free` (I9) — no flow code changed; the deliverable rewrites pack rows the pack loader already accepts
  (`generate_pack.py --check` reports `game/data/pack.json` current) and picture entries the resolver already accepts
  (`asset_catalog.py` / `asset_manifest.py --check` report 0 errors).
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in `specs/definition/quality.md`.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.
