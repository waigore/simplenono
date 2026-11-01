# Notes — issue #109 graphical acceptance

## Scope

The solve-check edge at the layer it was delivered: the `CTR-attempt` O2 mark path and its solve
branch in `game/play/attempt.gd`, observed through the real shell, #110's puzzle screen, #111's
`MarkInput`, and the `DBG.1` / `DBG.2` / `DBG.3` seams. Every judged value is a screen value, a
record read through `DBG.2`, a contracted call, or a `TEL` event — nothing comes from an
implementor's claim.

This is a re-judgement on a later build, not a citation of the earlier hold: the headless run
([`../2026-11-02-accept/manifest.md`](../2026-11-02-accept/manifest.md)) was made before any build
drew a board or exposed a debug surface.

## Judgement

- **The solve records once, with the stopped time.** Each solve called O6 once and emitted E1 once,
  with the puzzle id and the same stopped elapsed (`[["pack-000", 59]]`, then `600`, then `8`).
- **The attempt resets, the record keeps the run.** After each solve the attempt is `not_started`
  with no marks and elapsed 0; the record reads
  `{ever_completed: true, in_progress: false, marks: null, elapsed: 0, personal_best: N}`. PB is the
  only value that survives, 59 → 59 → 8, so it is replaced only when shorter.
- **A wrong fill is not a solve.** The fill stuck, the screen stayed `S1`, `is_solved` was false, no
  E1 was emitted, and the record gained no PB and no `ever_completed`.
- **Blocked and paused taps are inert.** During the beat and while paused a fill left the grid
  unchanged, emitted no E1, and wrote nothing. Pause itself commits the marks it must keep
  ([`pause.md`](../../../../../specs/technical/sequences/pause.md) S2), so the probe baselines after
  pausing and judges the paused tap.
- **The commit split shows in the record.** A non-solving mark changed the stored record (O5); the
  solve left a record with no marks and `in_progress: false`, which only O6 produces. The suite also
  asserts O5 is not called on the solve branch.

## Non-blocking observations

1. **The screen keeps the old elapsed until refreshed.** The label shows the stopped time until
   `refresh()` runs; the probe calls the shipped `refresh()` (a pure read) before the post-solve
   screenshot. Correct for now: the result screen that owns that transition is #95.
2. **`03` / `05` / `07` are identical images** — the same cleared board; the differing PB is in the
   `capture: P* record=` log lines.
3. **No pause chrome** until #96 adds `S3` chrome, so `01` cannot show a paused indicator.
4. **S1 is seeded, not typed.** The near-solve grid is written through O5 and reopened with `DBG.3`,
   which is S1's own wording; the solving fill goes through `MarkInput`, and every reopen is a real
   O1 open.

## Limits

The probe solves one puzzle (`pack-000`) with one near-solve shape (the solution minus its last
fill). `Rules.is_solved` over other shapes is #108's `PS1.1` and the suite's teapot fixture.
