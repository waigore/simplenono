# Finding — the reveal runs on two clocks

Deliverable commit `94e6c556bde74c11ceec6d44d61c94dbcf83e429` (PR #202 + PR #208 merged).

## The duplicate

`result.gd` drives `ResultReveal.advance()` from its own `_process`
(`game/presentation/result.gd:121-122`), and `shell.gd` drives the same reveal from
`Shell._process` (`game/presentation/shell.gd:278-285`, including the paused-attempt
guard). Both nodes are in the tree and processing while `UI-result` is up, so every
frame adds `delta` twice.

## Probe

A temporary GUT test (deleted after the run; no product code changed) instantiated the
real `shell.tscn`, solved `pack-000`, and printed the reveal once per processed frame:

```
FRAME 0 wall_ms=10.1 stage=S2 p=0.000
FRAME 1 wall_ms=10.3 stage=S2 p=0.817
FRAME 3 wall_ms=22.9 stage=S2 p=0.847
FRAME 5 wall_ms=37.4 stage=S2 p=0.933
FRAME 7 wall_ms=50.5 stage=S3 p=0.033
FRAME 9 wall_ms=64.1 stage=S3 p=0.120
FRAME 11 wall_ms=77.8 stage=S3 p=0.207
```

At the measured ~6.5 ms frame delta one clock advances `0.0217` per stage per frame;
the observed step is `0.043` — two ticks. The reveal therefore spends about **300 ms
total instead of 600 ms** (S2 + S3 at `CFG.MORPH_STAGE_MS` = 300 ms each), contradicting
`UI-result` S2/S3, US1.2 ("both stages have finished (600 ms)"), `MOT.T2`/`MOT.T3`, and
`MOT.E1`/`E2`.

A second probe paused the attempt after the solve and waited 800 ms: the reveal still
reached `S1`, so the epic's own claim that "the stage clock pauses with the attempt" is
false in the engine loop.

## Repair

Keep one clock. Either drop `ResultScreen._process` and let the shell drive `advance()`
(the view, beat, and pause guards already live there), or move those guards into the
screen and drop the shell's call. Add real-frame tests: an `await get_tree().process_frame`
loop that asserts both stages take `2 × CFG.MORPH_STAGE_MS`, and a real-frame pause test.
The current `test_the_shell_clock_finishes_the_morph` and
`test_a_paused_attempt_freezes_the_morph` call `_process` directly and never cross an
engine frame, so they pass with the duplicate clock present.

## Hygiene (not a fail cause)

`specs/playtest/story-rows.md` rows `UI-result`, `UI-settings`, `J-settings`, `NAV`, and
`ACT-player` remain `none` with a durable reason naming open epic #95: valid while the
epic owns delivery, so no repair landed on a failing verify.
