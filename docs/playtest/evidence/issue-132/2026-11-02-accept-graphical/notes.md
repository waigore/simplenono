# Notes — issue #132 graphical acceptance run

Build `main@859d834`, Godot 4.7.2.stable, session `issue-132-capture`, 2026-11-02. Shipped
`res://data/pack.json`, `pack-000` (10×10). All drive paths are the real shell, `PuzzleScreen`, and
`MarkInput`; observations come from the screen, `DBG.2` `inspect()`, and `TEL.*` in
[`logs/capture-console.log`](logs/capture-console.log).

## How the run was driven

The probe is #156's accepted capture probe, re-run unchanged against this build
([`probe/probe_capture_132.gd`](probe/probe_capture_132.gd)). It was copied into `game/` for one run and
removed afterwards.

- **Start:** `reset_puzzle("pack-000")`, then `shell.open_puzzle` (`DBG.3` / O1); `DBG.4` overlay on with
  `US1.7,PTD-ready-and-marks.F1`.
- **Input:** one tap per cell through `MarkInput.press_cell` / `release_stroke`, the layer the mouse and
  touch bindings call. Tools go through `PuzzleScreen.select_tool` (C3–C5).
- **Elapsed:** `PuzzleScreen.tick()` is the O3 call `_process` makes; the probe disables `_process` so the
  run is deterministic instead of frame-timing dependent.
- **Pause:** `DBG.1` (`pause_session` / `resume_session`), because C6's routing is #96 and no pause chrome
  exists. The one step not driven by a player-facing control; declared here.
- **Fixture:** open, end the beat, tap `(4,0)`, tick to `0:18`, commit through `AttemptState.commit` (O5,
  the call O2 uses; leave persistence is #96), leave, reopen.

## Protocol results

- **S1 — pass.** Fresh `pack-000` is `S2`, marks blocked, a tap on `(5,5)` leaves `CLEAR`, elapsed
  `0:00`; the board is inert behind the Ready panel (`00`).
- **S2 — pass.** Fill → clear → cross on `(5,5)` apply and redraw; `inspect()` returns `attempt`,
  `mark_grid`, `progress` and changes nothing (`01`).
- **S3 — pass.** A fill on `(0,0)`, not in `solution_fills`, stays; the screen stays `S1` and
  `is_solved()` is false (`02`).
- **S4 — pass.** Pause moves to `S3` and logs `TEL event=pause`; a tap changes nothing; `tick(4.0)` leaves
  `0:22`. Resume returns `S1` and a tap applies (`06`, `07`).
- **P1–P3 — pass.** No `F1` or `F2` trigger.
- **P2 — pass, judged.** `pack-000` has empty clue rows 0 and 9 and columns 0 and 9; after the beat those
  36 still-clear cells carry `cross` in `inspect()` (`01`), and the attempt reports
  `attempt_status: in_progress` before any player mark. The crosses are drawn by the beat's own write at
  beat end, with no player input.

## The ready edge (#132's own deliverable)

- `L-solve` PS1.1 on a fresh puzzle — at beat end the empty-clue cells are crosses, the attempt is
  `in_progress`, marks are allowed (`STOP`), elapsed is `0:00`. Before the beat, marks are blocked and
  no `ready` event appears in the log.
- `L-solve` PS1.1 on a reopened attempt — the beat starts again (`S2`), marks are blocked, the stored
  fill is drawn, elapsed is `0:18` and frozen, and the cells are `MOUSE_FILTER_IGNORE`. A tap changes
  nothing (`03`, `04`). After the beat: `S1`, `STOP`, the tap fills `(4,1)`, elapsed `0:22` (`05`).
  This is the #156 path that failed acceptance on `a8b54dc`; it passes here.
- `E3` — exactly one `TEL event=ready` per open in the log (three opens: first, fixture, reopen). The
  beat emits `ready` last, after the beat's own auto-cross and commit; a reopen whose auto-cross changes
  no stored value skips the commit (`test_auto_cross_does_not_commit_when_nothing_changed`). In this log
  the two extra `commit` lines after the first `ready` are the player taps of `01`, and the reopen's
  `commit` is the #156 fixture's own O5 call after its tap, so the beat's own commit is the one right
  after `ready` in each open.
- `L-solve` PS1.9 at 200 / 500 / 1500 ms is proven by the shipped suite, not by this run: the probe
  ends the beat directly rather than waiting on the timer. Tests
  `test_marks_stay_blocked_until_the_beat_ends_at_each_ready_length` and
  `test_elapsed_ticks_only_after_the_beat` cover it
  ([`logs/gut-suite.log`](logs/gut-suite.log)); the screenshot of the blocked state is `00`.

## Non-blocking observations

- **No pause chrome.** `S3` looks like `S1`; only `state_id()`, `inspect()`, and telemetry separate them.
  Expected until #96 routes C6.
- **Leave does not persist elapsed.** C1's O6 does not commit the record; the fixture commits explicitly
  through O5. Also #96.
- **`pack-000` is 10×10 here** (empty clue rows/columns 0 and 9, 36 crossed cells); earlier #132 records
  describe a 15×15 teapot. The pack entry that id resolves to has changed since those runs. Nothing in the
  judged outcomes depends on the size.

Nothing here is a game or interface failure.

## Reproduce

```sh
cp docs/playtest/evidence/issue-132/2026-11-02-accept-graphical/probe/probe_capture_132.gd game/
godot --path game -s res://probe_capture_132.gd -- --debug-seams \
  --session-id=issue-132-capture --story-ids=US1.7,PTD-ready-and-marks.F1 \
  --shot-dir="$(pwd)/docs/playtest/evidence/issue-132/2026-11-02-accept-graphical/screenshots"
rm game/probe_capture_132.gd
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```
