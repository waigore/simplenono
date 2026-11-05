# Quality evaluator run — issue #601

- **Issue:** #601 Puzzle Leave button: label invisible until clicked (`type:defect`, `priority:high`)
- **Mode:** `deterministic`
- **Deliverable commit:** `ed91db1` (PR #607 squash, merged 2026-11-05T01:31:22Z).
  `git diff ed91db1 3aeedaf -- game/` is empty (`3aeedaf` is `main` at this run), so the
  observed tree is the shipped tree.
- **Evaluated:** 2026-11-05 by `issue-workflow-verify-agent` (parallel id 1), Godot 4.7.2 stable
  on Linux x86_64, headless software rendering. The host has 4 cores and ran other agents'
  Godot and GUT processes throughout (load average 1.4–5.0); the two claimed protocols ran at
  1.9–2.3.
- **Observation source:** [`integration/results.md`](integration/results.md), from
  `godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams
  --protocol=<id> --run-dir=<this folder>` for `ui-ack` and `solve-reset`, each under a fresh
  `HOME` (`user://`). The harness wrote `integration/logs/`, which the repo gitignores; the
  cited log names are kept in [`integration/results.md`](integration/results.md).

The deliverable is a colour-state fix on existing chrome: `PuzzleScreen._ready` now also pins
`font_focus_color` (C1, C6, C3–C5) and `font_hover_pressed_color` (C1, C6) to `PAL.INK` through
`_style_chrome_button()` and `_style_tool_buttons()`, plus one GUT test. The overrides run once
when the screen is built, on the same buttons with the same text, and `present()` is untouched:
no paint, layout, sampler, save, log, or navigation path changed. The selected axes are therefore
the Applies deterministic axes that path can move — `response-delay` (I8, the puzzle screen's
open, settings, and Back acknowledgements) and `crash-free` (I9, the open, solve, reset, and back
flows that build and draw the screen).

No existing passing record covers `game/` at `ed91db1`: the nearest, #600 at `c39d12f`, diffs
against this tree in `game/presentation/puzzle.gd` and `game/test/test_puzzle_screen.gd`, so this
is a fresh run rather than a reuse.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `response-delay` | deterministic | I8: longest acknowledgement among `ack:back`, `ack:open`, `ack:settings` 28.7 ms. | Non-paint UI (open puzzle, settings toggle, Back) acknowledges ≤ 500 ms | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json`; `integration/logs/harness-1793845493-ui-ack.log` |
| `crash-free` | deterministic | I9: `flows_ok` = open, solve, reset, back across the folder (`ui-ack` ran open and back, `solve-reset` ran all four); `flows_failed` empty, `crashed` false, oracle `flows.solve` = `{solved_grid: pass, solution_fills: match}`. | No crash across open, solve, reset, and back | pass | — | [`results.md`](integration/results.md); `integration/results/ui-ack.json`; `integration/results/solve-reset.json` |

## Not selected

- `frame-time`, `hitch-bound` (I1, I2) — the change sets four colour values at build time; no
  paint, sampler, or layout path gained or lost work.
- `time-to-playable` (I6) — no launch path changed.
- `transition-latency` (I7) — no navigation leg changed. Context only, not a scoring row: the
  `navigate` protocol ran against this tree and its longest leg was always
  `transition:puzzle-result` (658.7–715.1 ms against the ≤ 500 ms bar), while `home-puzzle` and
  `result-gallery` stayed well inside it. The same multi-leg probe on a pre-deliverable worktree
  at `6ec4077` reads `home-puzzle` 37.0 ms, `puzzle-result` 574.5 ms, `result-gallery` 110.6 ms,
  so the slow leg is the result morph and predates this issue. The protocol's `navigate` output
  was not kept in this folder because the issue does not claim that axis; the pre-deliverable
  worktree is outside the repo at `/tmp/opencode/wt601base`.
- `resume-after-failure` (I10) — no save or restore path changed.
- `runtime-signals` (I11) — no telemetry event, sampler, or severity source changed.
- `save-survives`, `failed-write` (I4) — no persistence path changed.
- Accessibility and Localization axes — `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).
