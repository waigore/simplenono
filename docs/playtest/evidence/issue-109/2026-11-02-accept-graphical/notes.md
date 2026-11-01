# Notes — issue #109 graphical acceptance

## Scope

The solve-check edge at the layer it was delivered: the `CTR-attempt` O2 mark path and its solve
branch in `game/play/attempt.gd`, observed through the real shell (`shell.tscn`), #110's puzzle
screen, #111's `MarkInput` tap path, and the shipped `DBG.1` / `DBG.2` / `DBG.3` seams. Every judged
value is a screen value, a stored record read through `DBG.2`, a contracted call
(`CMP-rules` / `CMP-attempt` / `CMP-pack`), or a `TEL` event — nothing comes from an implementor's
claim.

This is a re-judgement on a later build, not a citation of the earlier hold: the headless run
([`../2026-11-02-accept/manifest.md`](../2026-11-02-accept/manifest.md)) was made before any build
drew a board or exposed a debug surface. `PS1.1`/`PS1.9` stay #132's and `PS1.1`–`PS1.3` are not
asserted here, as the issue body requires.

## Judgement

- **The solve records once, with the stopped time.** Each solve called `CTR-pack` O6 exactly once and
  emitted `CTR-attempt` E1 exactly once, with the puzzle id and the same stopped elapsed
  (`[["pack-000", 59]]`, then `600`, then `8`; `TEL event=solved` appears once per solve). PB went 59 after the first solve, stayed 59 after the `10:00` replay, and
  became 8 after the `0:08` replay — so the PB rule is "replace only when shorter".
- **The attempt resets, the puzzle record keeps the run.** After every solve the attempt reports
  `not_started` with no marks and elapsed 0, and the record reads
  `{ever_completed: true, in_progress: false, marks: null, elapsed: 0, personal_best: N}`.
  `personal_best` is the only value that survives.
- **A wrong fill is not a solve.** The wrong fill stuck, the screen stayed `S1`, `is_solved` was
  false, no E1 was emitted, and the record gained no PB and no `ever_completed`.
- **Blocked and paused taps are inert.** During the ready beat and while paused, a fill left the grid
  unchanged, emitted no E1, and wrote nothing. Pause itself does write (it commits the marks it has
  to keep, [`pause.md`](../../../../../specs/technical/sequences/pause.md) S2), so the probe takes its
  baseline after pausing and judges the paused tap, not the pause.
- **The commit split is visible in the record.** A non-solving accepted mark changed the stored
  record (O5); the solving mark left a record with no marks and `in_progress: false`, which only O6
  produces. The shipped test additionally asserts O5 is not called on the solve branch
  (`RecordingProgress.commit_calls`), which the record alone cannot show.

## Non-blocking observations

1. **The screen still shows the old elapsed until it is refreshed.** After a solve the label keeps
   the stopped time until something calls `refresh()`; the probe calls the shipped `refresh()` (a
   pure read) before the post-solve screenshot. That is correct for now: the result screen that owns
   the in-game transition is #95, and the solved board plus the stopped time is what it will show.
   Recorded so a later run does not read the label as a delay.
2. **`03` / `05` / `07` are identical images.** Each is the same cleared post-solve board; the
   evidence that distinguishes them is the stored PB in the `capture: P* record=` log lines.
3. **No pause chrome.** The paused shot cannot show a paused indicator until #96 adds `S3` chrome.
4. **`PTD-solve-and-pb` S1 is seeded, not typed.** The probe writes the near-solve grid through
   `CTR-pack` O5 and reopens it with `DBG.3`, which is S1's own wording ("`DBG.3` into a not-started
   puzzle one correct fill from solve"). The solving fill itself is placed through `MarkInput`, and
   the reopens that follow are real O1 opens.

## Reproduce

With the probe copied to `game/probe_capture_109.gd`:

```
godot --headless --path game --import
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit

RUN=<this folder>
mkdir -p "$RUN/screenshots"
godot --path game -s res://probe_capture_109.gd -- \
    --debug-seams --session-id=issue-109-capture --build-id=main@dcd9a24 \
    --story-ids=L-solve,PS1.4,PS1.5,PS1.6,PTD-solve-and-pb.P1,PTD-solve-and-pb.P2,PTD-solve-and-pb.P3 \
    --shot-dir="$RUN/screenshots" --run-folder="$RUN"
rm game/probe_capture_109.gd
```

The probe quits 1 unless all eight judged states were saved and every check passed, so a section that
dies early cannot report a pass. The run must be graphical (`godot --path game`, not `--headless`).

Falsification mutations: [`falsification.md`](falsification.md).
