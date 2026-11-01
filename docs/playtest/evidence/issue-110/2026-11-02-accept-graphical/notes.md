# Notes — issue #110 graphical acceptance

## Scope

The `UI-puzzle` story (`US1.1`–`US1.7`) at its delivered layer, plus the `PTD` clauses of
`ready-and-marks` S1–S3, driven through the real shell, the shipped puzzle screen, and `MarkInput`'s
tap path. Every observation is a screen value (`state_id`, `marks_allowed`, `elapsed_text`,
`selected_tool`, a cell's rendered mark), a `DBG.2` inspect, or a saved viewport image — no
implementor claim was taken as the verdict.

This is the first graphical run for #110. The earlier dispatch at `2601fee` posted no record
([`accept-dispatch-rechecks.md`](../../accept-dispatch-rechecks.md)); the deferred routes below are
still #94/#95/#96.

## Judgement

- **S1 vs S2.** On a reopened in-progress record the screen starts in `S2`, shows `copy.ready`, keeps
  Leave and Settings enabled, disables Fill/Cross/Clear, and blocks a tap. After the beat it is `S1`
  with the same `0:12` and every control available.
- **Elapsed.** The run disabled the screen's `_process` and drove `tick()` by hand: the restored
  record shows `0:12` before and after Ready with no tick, and five seconds while paused add nothing.
  This is the restored-elapsed case verification's earlier Fail asked for, now shown on screen.
- **Board.** The restored fill at (7,2) plus the auto-crossed empty rows 0 and 9 are drawn, the clue
  bars carry the line values, and the solution is never read or drawn (no `TextureRect` in the tree).
- **Tools.** Activating C3, C4, C5 in turn changes the selected tool and the next tap writes Fill,
  Cross, then Clear at the same clear cell.
- **Pause.** C6 raises `IN.pause`. S3 itself renders from attempt state: board unchanged, elapsed
  frozen, marks blocked. The settings surface and the O4 write are #95/#96; the screen was not
  credited with them.
- **Leave.** C1 raises `IN.back` and the shell returns home. That home view is the current gallery
  stand-in, not `UI-gallery` (#94).

## Non-blocking observations

1. **No pause chrome in S3.** `specs/ux/screens/puzzle.md` S3 says only "board unchanged; elapsed
   frozen" and "wait on settings", so the flat board is correct; the settings screen carries the cue.
2. **The debug story overlay overlaps R1.** The `DBG.4` overlay sits over the top-left of the chrome
   in these images. It is a debug seam, not shipped chrome; the R1 controls are still visible and
   were read programmatically.
3. **`PTU-play-puzzle` and `PTU-leave-resume` are not runnable** until `UI-gallery` (#94) and
   `UI-result` (#95) ship. They are recorded as deferred, not failed, and no defect is filed: the
   missing screens have open owners and the #110 review scoped this screen to the puzzle surface.

## Reproduce

See [`manifest.md`](manifest.md#reproduce).
