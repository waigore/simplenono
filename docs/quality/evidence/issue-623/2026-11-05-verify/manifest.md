# Quality evaluator run — issue #623

- **Issue:** #623 Main menu screen UI: entry, gallery back, exit, version stamp (`type:task`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `7d69040` (`main`, squash of PR #636, merged 2026-11-05T08:26:06Z). `game/` at `7d69040` is the tree measured.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable on Linux x86_64 (4 cores). The `.godot` import cache was rebuilt (`godot --headless --path game --import`) before the GUT and harness runs. The host was shared with other agents; load average read 0.86–2.0 during the measurement window.
- **Observation source:** [`integration/results.md`](integration/results.md), from one run each of
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<this folder>`
  for `app-start`, `paint`, `navigate`, `ui-ack`, `solve-reset`, and `kill-relaunch`, each under a fresh `HOME` (`user://`).
  The independent GUT suite run (`godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit`, fresh `HOME`)
  read 34 scripts, 408 tests, 408 passing, 21 630 asserts, exit 0.

The deliverable adds the main menu as the new-session front door (`NAV.N1`), wires Puzzles → gallery, gallery Back to main menu,
desktop-only Exit, settings return-to-opener, and the bottom-left build stamp from `CTR-build-info`; an interrupted session still
resumes on the gallery (`NAV.N2`). It changes the boot path, the gallery chrome, and the navigation routes, so the selected axes are
the Applies deterministic axes those paths can move: `time-to-playable` (I6 — the boot now lands on the menu), `frame-time` and
`hitch-bound` (I1/I2 — the menu and the gallery chrome), `response-delay` (I8 — the menu and gallery controls), `crash-free` (I9 —
the open, solve, reset, and back flows), and `resume-after-failure` (I10 — the `N2` boot decision reads the stored attempt).

No existing passing record covers `game/` at `7d69040`: the newest passing deterministic records predate PR #633 and #636, so this
is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (menu) 1786.5 ms. | Cold launch to interactive gallery ≤ 3 s | pass | — | [`results.md`](integration/results.md); `integration/samples/app-start-samples.ndjson` |
| `frame-time` | deterministic | I1: `paint` p95 16.67 ms over 203 frames; `navigate` p95 gallery 9.25 ms over 71 frames, reveal 15.00 ms over 172 frames (all windows 14.87 ms) over 243 frames. | ≤ 16.7 ms during grid paint and navigation | pass | — | [`results.md`](integration/results.md); `integration/samples/paint-samples.ndjson`; `integration/samples/navigate-samples.ndjson` |
| `hitch-bound` | deterministic | I2: longest frame 24.57 ms (`paint`, 203 frames) and 33.35 ms (`navigate`, 243 frames); no hitch above 100 ms. | No hitch longer than 100 ms during grid paint on mid-range phones | pass | — | `integration/samples/paint-hitches.ndjson`; `integration/samples/navigate-hitches.ndjson` |
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 24.6 ms. | Non-paint UI acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json` |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, reset, back across `paint`, `navigate`, `ui-ack`, and `solve-reset`; `flows_failed` empty and `crashed` false in all four results; oracle `flows.solve` reads `{solved_grid: pass, solution_fills: match}` in `navigate` and `solve-reset`. | No crash across open, solve, reset, and back | pass | — | `integration/results/paint.json`; `integration/results/navigate.json`; `integration/results/ui-ack.json`; `integration/results/solve-reset.json` |
| `resume-after-failure` | deterministic | I10: launch entry gallery stand-in (shell home); reopened true; marks restored true; elapsed restored true. | Next launch is gallery; reopen restores marks and elapsed | pass | — | [`results.md`](integration/results.md); `integration/logs/relaunch-verify.json` |

## Not selected

- `transition-latency` (I7) — the deliverable's new menu↔gallery and menu↔settings transitions are not in the I7 target
  ("Gallery↔puzzle, puzzle→result, and result→gallery"); the target's three legs were run anyway in `navigate`. The
  deliverable-relevant legs pass: `home-puzzle` 36.5 ms and `result-gallery` 118.0 ms. The harness's aggregate I7 row reads
  562.3 ms because its `puzzle-result` leg times the solve action (41 fills, one per frame with a full board refresh), not the
  puzzle→result screen change. That leg is not a deliverable path: the same protocol's aggregate I7 row reads 659.1 ms at the
  prior passing commit `006de2c` and 690.6 ms at the parent `2719ea1` on this host, so the reading is host-speed dependent, not a
  regression from this deliverable. The axis is therefore not one this deliverable can move, and it is not claimed as a row.
- `runtime-signals` (I11) — no log, sampler, or telemetry source added or removed.
- `save-survives`, `failed-write` (I4) — no save schema or commit path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable: every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md) is
`deterministic`, and the domain axes list is empty. No judge record exists to read, so no `llm-judge` row applies.
