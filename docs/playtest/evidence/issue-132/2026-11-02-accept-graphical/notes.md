# Notes — issue #132 graphical acceptance run

Build `main@859d834`, Godot 4.7.2.stable, session `issue-132-capture`, 2026-11-02. Shipped
`res://data/pack.json`, `pack-000` (10×10). All drive paths are the real shell, `PuzzleScreen`, and
`MarkInput`; observations come from the screen, `DBG.2` `inspect()`, and `TEL.*` in
[`logs/capture-console.log`](logs/capture-console.log). How the run was driven, declared drives, and
non-blocking observations: [`method.md`](method.md).

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
- **P2 — pass, judged.** `pack-000` has empty clue rows and columns 0 and 9; after the beat those 36
  still-clear cells carry `cross` in `inspect()` (`01`), and the attempt reports
  `attempt_status: in_progress` before any player mark. The crosses are the beat's own write.

## The ready edge (#132's own deliverable)

- `L-solve` PS1.1, fresh — at beat end the empty-clue cells are crosses, the attempt is `in_progress`,
  marks are allowed (`STOP`), elapsed `0:00`. Before the beat marks are blocked and no `ready` event
  appears in the log.
- `L-solve` PS1.1, reopened — the beat starts again (`S2`), marks are blocked, the stored fill is drawn,
  elapsed is `0:18` and frozen, cells are `MOUSE_FILTER_IGNORE`. A tap changes nothing (`03`, `04`).
  After the beat: `S1`, `STOP`, the tap fills `(4,1)`, elapsed `0:22` (`05`). This is the #156 path that
  failed acceptance on `a8b54dc`; it passes here.
- `E3` — exactly one `TEL event=ready` per open (three opens: first, fixture, reopen). The beat emits
  `ready` after its own auto-cross and commit; a reopen whose auto-cross changes no stored value skips
  the commit (`test_auto_cross_does_not_commit_when_nothing_changed`). The reopen's `commit` line is the
  fixture's own O5 call after its tap.
- `L-solve` PS1.9 at 200 / 500 / 1500 ms is proven by the shipped suite, not here: the probe ends the
  beat directly rather than waiting on the timer.
  `test_marks_stay_blocked_until_the_beat_ends_at_each_ready_length` and
  `test_elapsed_ticks_only_after_the_beat` cover it ([`logs/gut-suite.log`](logs/gut-suite.log)); the
  blocked state is pictured in `00`.

## Reproduce

```sh
cp docs/playtest/evidence/issue-132/2026-11-02-accept-graphical/probe/probe_capture_132.gd game/
godot --path game -s res://probe_capture_132.gd -- --debug-seams \
  --session-id=issue-132-capture --story-ids=US1.7,PTD-ready-and-marks.F1 \
  --shot-dir="$(pwd)/docs/playtest/evidence/issue-132/2026-11-02-accept-graphical/screenshots"
rm game/probe_capture_132.gd
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```
