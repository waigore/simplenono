# Notes — issue #108 graphical acceptance

## Scope

The `GS` story (`PS1.1`–`PS1.7`, `V1`–`V6`, `Q1`, `H1` visibility) at its delivered layer, plus the
`GS` clauses of `PTD-ready-and-marks` S1–S3, driven through the real shell (`shell.tscn`), the
puzzle screen drawn by `#110`, and `MarkInput`'s tap path. Every observation is a screen value, a
contracted `CMP-rules` / `CMP-attempt` / `CMP-pack` call, or a `DBG.2` payload — nothing came from
an implementor's claim.

This is a re-judgement, not a citation of the earlier hold: S1–S3 were not runnable at `67e36f5`
because `DBG.3` and `DBG.2` did not exist, and `#156` (`5196281`) changed the marks-restored flag
that `V2`/`V6` depend on. `PTD-ready-and-marks` S4 and P3's pause half belong to #132 / #156.

## Judgement

- **Derived values are not stored.** The grid signature was identical around `Rules.is_solved` and
  `Rules.line_status`, and the `SCH-progress` record holds no `solved`, `is-solved`, `line-status`,
  `row-error`, `col-error`, or `satisfied` key (`SCH-attempt` I1). Line status returns `2 × size`.
- **Attempt status.** A fresh open blocks marks; a blocked tap leaves the grid identical, so
  in-progress cannot flip. The first accepted fill sets the record's `in_progress`. Empty-clue rows
  0 and 9 auto-cross at Ready (`open.md` S8) and that change reaches the record through O5.
- **Thumbnail (`PS1.5` / `H1`).** The flag follows `ever_completed` in both directions. The solve
  that normally sets it is `PTD-solve-and-pb`, which is #109's protocol.
- **Reset (`V3`).** `CTR-pack` O7 clears the record; the live attempt is untouched by it, and the
  not-started board comes from `AttemptState.clear_attempt` (L3) — what the delivered code and
  `test_game_state.gd` assert. No shipped production path calls it on reset yet, because gallery
  reset is #94.
- **Wrong fills (`PS1.3`/`PS1.4`).** A fill that cannot match the solution stays and the attempt
  stays `S1`; no fail state exists.

## Non-blocking observations

1. **The `DBG` reset writes the record but does not re-present the live attempt.** Correct for the
   seam's scope ("the stage reset ... until the gallery owns it", #94), but an operator resetting
   mid-puzzle sees the old board until reopening. Worth a sentence in the gallery-reset task.
2. **`DBG.2`'s `mark_grid` shows auto-crosses only after the beat ends.** The cold `S1` payload is
   all-clear because it is read during get-set-ready, before `open.md` S8; after Ready it carries
   the crossed rows, matching the board. Recorded so a later run does not read it as a delay.
3. **Deferrals.** `PS1.2`'s 200-puzzle proof and `PS1.5`'s shipped picture stay deferred to
   #94 / #97 / #98, as the issue body records.

## Reproduce

With the probe copied to `game/probe_capture_108.gd`:

```
godot --headless --path game --import
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit

RUN=<this folder>
mkdir -p "$RUN/screenshots"
godot --path game -s res://probe_capture_108.gd -- \
    --debug-seams --session-id=issue-108-capture \
    --story-ids=GS,PS1.1,PS1.7,PTD-ready-and-marks.P2 \
    --shot-dir="$RUN/screenshots"
```

The probe quits 1 unless all five judged states were saved and no check failed, so a section that
dies early cannot report a pass. The run must be graphical (`godot --path game`, not `--headless`).

Falsification mutations: [`falsification.md`](falsification.md).
