# Notes — issue #156 graphical acceptance run

Build `main@3f402fe`, Godot 4.7.2.stable, session `issue-156-capture`, 2026-11-02. Shipped
`res://data/pack.json` (200 puzzles), `pack-000`, 15×15. All drive paths are the real shell,
`PuzzleScreen`, and `MarkInput`; observations come from the screen, `DBG.2` `inspect()`, and
`TEL.*` in [`logs/capture-console.log`](logs/capture-console.log).

## How the run was driven

- **Start:** `reset_puzzle("pack-000")`, then `shell.open_puzzle` (`DBG.3` / O1); `DBG.4` overlay on
  with `US1.7,PTD-ready-and-marks.F1`.
- **Input:** one tap per cell through `MarkInput.press_cell` / `release_stroke`, the same layer the
  mouse and touch bindings call. Tools go through `PuzzleScreen.select_tool` (C3–C5).
- **Elapsed:** `PuzzleScreen.tick()` is the same O3 call `_process` makes; the probe disables
  `_process` so the run is deterministic rather than frame-timing dependent.
- **Pause:** `DBG.1` (`pause_session` / `resume_session`), because C6's routing is #96 and no pause
  chrome exists. This is the one step not driven by a player-facing control; it is declared here.
- **Fixture:** the body's discard → reopen path. Open, end the beat, tap `(4,0)`, tick to `0:18`,
  commit through `AttemptState.commit` (O5, the call O2 uses; leave persistence is #96), leave,
  reopen.

## Protocol results

- **S1 — pass.** Fresh `pack-000` is `S2`, marks blocked, a tap on `(5,5)` leaves `CLEAR`, elapsed
  `0:00`; the board is inert behind the Ready panel (`00`).
- **S2 — pass.** Fill → clear → cross on `(5,5)` apply and redraw; `inspect()` returns
  `attempt`, `mark_grid`, `progress` and changes nothing (`01`).
- **S3 — pass.** A fill on `(0,0)`, not in `solution_fills`, stays; the screen stays `S1` and
  `is_solved()` is false. No fail state (`02`).
- **S4 — pass.** Pause moves to `S3` and logs `TEL event=pause`; a tap changes nothing; `tick(4.0)`
  leaves `0:22`. Resume returns `S1` and a tap applies (`06`, `07`).
- **P1–P3 — pass.** No `F1` or `F2` trigger.

## The reopen path

Reopening the persisted attempt starts the beat again (`S2`). Marks are blocked throughout, the
stored fill at `(4,0)` is drawn, elapsed shows `0:18`, and `C2` cells are `MOUSE_FILTER_IGNORE`. A
tap on `(4,1)` changes nothing: the cell stays `CLEAR`, elapsed stays `0:18`, and the image is
byte-identical to the pre-tap image. After the beat, `S1`, the same tap fills `(4,1)`, cells are
`MOUSE_FILTER_STOP`, and elapsed reaches `0:22`.

## Non-blocking observations

- **No pause chrome.** `S3` looks like `S1`; only `state_id()`, `inspect()`, and telemetry separate
  them. Expected until #96 routes C6.
- **Leave does not persist elapsed.** C1's O6 does not commit the record; the fixture commits
  explicitly through O5. Also #96.

Nothing here is a game or interface failure.

## Reproduce

```sh
cp docs/playtest/evidence/issue-156/2026-11-02-accept-graphical/probe/probe_capture_156.gd game/
godot --path game -s res://probe_capture_156.gd -- --debug-seams \
  --session-id=issue-156-capture --story-ids=US1.7,PTD-ready-and-marks.F1 \
  --shot-dir="$(pwd)/docs/playtest/evidence/issue-156/2026-11-02-accept-graphical/screenshots"
rm game/probe_capture_156.gd
```
