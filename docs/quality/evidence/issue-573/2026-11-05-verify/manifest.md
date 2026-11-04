# Quality evaluator run — issue #573

- **Issue:** #573 Gallery tile: the strip below the metadata swallows taps and drags (dead input band on every card) (`type:defect`, `priority:normal`)
- **Mode:** `deterministic`
- **Deliverable commit:** `38937ec` (`origin/main` at verification). The fix is PR #579 → `38937ec` (merged 2026-11-04), so the tree observed here is the tree that ships.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on macOS (darwin) arm64, quiet host (load average 2.0–2.2 on 10 cores).
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `paint`, `navigate`, `ui-ack`, and `solve-reset`, each under a fresh `HOME` (`user://`).

The deliverable is input-routing code on the tile band: `gallery_tile.gd` moves the Reset holder
inside C1 (anchored `FULL_RECT` inside the open button), sets `MOUSE_FILTER_IGNORE` on the
holder's margin/HBox/spacer and keeps `MOUSE_FILTER_STOP` only on the Reset button itself, draws
the row only when Reset is allowed, and adds the drawn strip to C1's floor height
(`hold_picture_square`). No save, persistence, launch, log, sampler, or join path changed, so the
selected axes are the Applies deterministic axes those changes can move: `frame-time` and
`hitch-bound` on the gallery window of grid paint (I1, I2), `transition-latency` for the
gallery↔puzzle↔result legs (I7), `response-delay` for the gallery's open and settings legs (I8),
and `crash-free` for the open/solve/reset/back flows (I9).

No existing passing record covers `game/` at `38937ec`: the nearest, #539's record at `aa8456e`,
diffs against this tree in `game/presentation/gallery_tile.gd`, `game/test/test_gallery.gd`, and
`game/test/test_touch_input.gd` — 18 files, 237 insertions, 335 deletions across the #562,
#577, #578, and #579 window. This is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `frame-time` | deterministic | I1: `paint` p95 6.94 ms over 203 frames; `navigate` p95 gallery 6.95 ms over 78 frames and reveal 7.14 ms over 161 frames (all windows 7.14 ms) over 239 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 7.28 ms (`paint`, 203 frames) and 14.45 ms (`navigate`, 239 frames); 0 hitches above 100 ms. | No hitch longer than 100 ms during grid paint | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `transition-latency` | deterministic | I7: longest transition among `transition:home-puzzle`, `transition:puzzle-result`, `transition:result-gallery` 218.9 ms. `gallery-mobile`/`gallery-desktop` both report `ok=true` in `navigate`, so the legs are a clean lane measurement. | ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793810201-navigate.log` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 7.5 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/logs/harness-1793810203-ui-ack.log` |
| `crash-free` | deterministic | I9: flows `open`, `solve`, `back`, `reset` all ran in `solve-reset` (`flows_ok` in `solve-reset.json`); no failed flow, no crashed run. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/solve-reset.json` |

The `crash-free` row is judged at run level, as the harness README defines it: every I9 flow must
have run in a protocol in the folder without a failed flow. `solve-reset` ran all four
(`open`, `solve`, `back`, `reset`); no protocol here records a failed flow or a crash.

## `integration/results.md` row-defect recurrence (harness, not this deliverable)

The known paperwork defect from #540's verification recurs unchanged: the generated summary
prints the run-level `crash-free` observation on every protocol row that claims I9, so `paint`,
`navigate`, and `ui-ack` also read "flows ran: back, open, reset, solve". The protocol JSONs are
right (`paint` ran `open`; `navigate` ran `open`, `solve`, `back`; `ui-ack` ran `open` and
`back`). The table above cites `solve-reset.json` for I9. Harness paperwork with no effect on a
result; already known from the two #540 records.

## Not selected

- `time-to-playable` (I6) — no launch path changed.
- `resume-after-failure` (I10) — no `user://` write or relaunch path changed.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

The judged finger behaviour on a real handset (a tap in the band opens the tile; a drag from it
scrolls R2) is a playtest observation, not a quality axis; acceptance owns it.

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge row applies.
