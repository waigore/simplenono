# Why #110's blocked rows are gone — selection notes

From [manifest.md](manifest.md).

## What changed since the last run on this issue

The `2026-11-01T174729Z` run on `bc438de` returned `crash-free` and `runtime-signals` as `blocked`
(`no-invariant`): there was no way to drive the open/solve/reset/back flows, no frame samples, and no
telemetry surface in `game/`. That manifest also recorded that re-implementing the screen could not clear
either row.

Two suppliers have since merged to `main`:

- **#163** (`3f402fe`) — S1–S5 seams and the S4 telemetry sink: `TEL event=…` lines with `TEL.1`–`TEL.5`.
- **#166** (`859d834`, via #173/#178) — the integration harness: six protocol drive lists, per-frame
  sampling, the S4 log, and `integration/results.md`.

So `crash-free` is no longer blocked: the flows run and this run observed them. `frame-time` and
`hitch-bound` became selectable for the same reason — they are the grid-paint axes of this very screen.
`response-delay` is selected because C1/C6 and the open route are the screen's own acknowledgements.

## Why `runtime-signals` is still not this issue's row

`game/presentation/puzzle.gd` calls no `Telemetry` method; the seam does, on the shell/attempt it observes.
I11 is the outcome #163 delivers, and #163's own deterministic run already selects it and records the
severity-tagged-log quarter as outstanding. Scoring it again here would report #163's gap as #110's failure —
exactly the loop the previous verification comment warned against.

## Why `transition-latency` is not selected

`navigate` fails I7 on the `puzzle-result` leg: the result screen is #95 and is absent, so the transition is
never acknowledged. The screen's own leg, `transition:home-puzzle`, is `ok` in
`integration/results/navigate.json`, and its duration is far under the bar. The axis outcome cannot be moved
by this deliverable; failing #110 on it would blame a missing screen that this task does not own.

## Why the numbers are credible

- The paint protocol applies one mark per processed frame, so the 203 sampled frames include the screen's real
  per-mark redraw path (`PuzzleBoard.set_marks` → cell `queue_redraw`), not a synchronous burst.
- `crash-free` is run-level: every I9 flow ran in at least one protocol of this folder. `navigate`'s and
  `kill-relaunch`'s nonzero exits are their own axes' failures, and neither run crashed.
- `ui-ack` times the settings leg at C6's `IN.pause` intent; the settings screen (#95) and its O4 pause (#96)
  do not exist yet, so the leg measures the product's acknowledgement, which is what I8 states.

## Honest limits

- Headless: frames are engine process frames, not a phone GPU. The `frame-time` bar is a desktop proxy for the
  mid-range-phone target.
- The run used `--story-ids=UI-puzzle` so TEL.4 is populated; the harness does not set a story id by default.
  All 592 events in the folder carry `story=UI-puzzle`.
