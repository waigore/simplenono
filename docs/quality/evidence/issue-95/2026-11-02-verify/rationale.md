# Verification rationale — issue #95

Deliverable commit `94e6c556bde74c11ceec6d44d61c94dbcf83e429` (PR #202 + PR #208 merged).

## The reveal runs on two clocks

`result.gd` drives `ResultReveal.advance()` from its own `_process`
(`game/presentation/result.gd:121-122`), and `shell.gd` drives the same reveal from
`Shell._process` (`game/presentation/shell.gd:278-285`, including the paused-attempt
guard). Both nodes are in the tree and processing while `UI-result` is up, so every
frame adds `delta` twice.

A temporary GUT probe (deleted after the run; no product code changed) instantiated the
real `shell.tscn`, solved `pack-000`, and printed the reveal state once per processed
frame:

```
FRAME 0 wall_ms=10.1 stage=S2 p=0.000 shellproc=true screenproc=true
FRAME 1 wall_ms=10.3 stage=S2 p=0.817
FRAME 3 wall_ms=22.9 stage=S2 p=0.847
FRAME 5 wall_ms=37.4 stage=S2 p=0.933
FRAME 7 wall_ms=50.5 stage=S3 p=0.033
FRAME 9 wall_ms=64.1 stage=S3 p=0.120
FRAME 11 wall_ms=77.8 stage=S3 p=0.207
```

At the measured ~6.5 ms frame delta a single clock would advance `0.0217` per stage per
frame; the observed step is `0.043`, i.e. two ticks. The reveal therefore plays both
`CFG.MORPH_STAGE_MS` (300 ms) stages in roughly 300 ms of wall time instead of 600 ms,
and the shell's paused-attempt guard is bypassed because the screen's own clock ignores
it. A second probe paused the attempt after the solve and waited 800 ms: the reveal
still reached `S1`.

This contradicts `specs/ux/screens/result.md` S2/S3 and
`specs/ux/stories/screens/result.md` US1.2 ("both stages have finished (600 ms)"),
`MOT.T2`/`MOT.T3`, and the implementation's own claim that the stage clock pauses with
the attempt.

Suggested repair: keep one clock. Either drop `ResultScreen._process` and let the shell
drive `advance()` (the pause, beat, and view guards already live there), or move those
guards into the screen and drop the shell's call. Add a test that runs real frames (an
`await get_tree().process_frame` loop) and asserts the wall time of both stages, and a
real-frame pause test — the current `test_the_shell_clock_finishes_the_morph` and
`test_a_paused_attempt_freezes_the_morph` call `_process` directly and never cross an
engine frame, so they pass with the duplicate clock present.

## `review-code` report

```markdown
## Code review: Fail

**Target:** PR #202 and PR #208 code diffs (merged as 71efe63, 94e6c55)

### Findings
- `[SRP]` `must-fix` — game/presentation/result.gd:121-122 + game/presentation/shell.gd:278-285. Two owners drive the same reveal clock: the screen's `_process` and the shell's `_process`. Both run per frame, halving the spec'd stage duration and bypassing the shell's pause guard. Split the timing to one owner.
- `[CONT]` `suggestion` — game/presentation/settings.gd:18,26-27. `COPY_TITLE`, `HINT_HAPTICS`, `HINT_MUTE` are never read; settings.tscn hardcodes the same strings. Remove the constants or make the scene read them.
- `[CONT]` `suggestion` — game/presentation/result.gd:26,60 vs game/presentation/result_reveal.gd:96. `_clock_running` duplicates `ResultReveal.is_morphing()` as a second source of truth for "morphing".

### Notes
- Code lint / Unit tests / Coverage: all green on both PRs (`gh pr checks 202`, `gh pr checks 208`).
- Tests: 215/215 pass, but the result clock tests call `_process` directly instead of crossing engine frames, so they do not exercise the duplicate clock or the pause guard in the real loop.
- Everything else in the two diffs follows the surrounding presentation-layer patterns (intent signals, shell routing, one `SessionFlags` source).
```

## Material findings to return

1. Result reveal duration and pause behavior (above) — Fail, back to implementation.
2. Harness gap: no protocol samples frames during the reveal, so the new animation's
   frame budget has no observation. Recorded as blocked, not a product defect.

## Hygiene (not a fail cause)

- `specs/playtest/story-rows.md` rows `UI-result`, `UI-settings`, `J-settings`, `NAV`,
  and `ACT-player` are still `none` with a durable reason naming epic #95. The epic is
  open and owns the delivery, so the rows stay valid until acceptance; no repair landed
  on a failing verify.
