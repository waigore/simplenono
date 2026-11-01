# Notes — issue #106 graphical acceptance run

Build `main@269d854`, Godot 4.7.2.stable, session `issue-106-capture`, 2026-11-02. Shipped
`res://data/pack.json`, `pack-000`, 10×10, 42 solution fills, empty clue rows 0 and 9. All drive
paths are the real shell, `PuzzleScreen`, and `MarkInput`; observations come from the screen,
`DBG.2` `inspect()`, the `SIT.3` dump, and `TEL.*` in [`logs/capture-console.log`](logs/capture-console.log).

## How the run was driven

- **Start:** `reset_puzzle("pack-000")`, then `shell.open_puzzle` (`DBG.3` / O1); `DBG.4` overlay on
  with `PTD-ready-and-marks,PTD-crosses-and-fills`.
- **Input:** one tap per cell through `MarkInput.press_cell` / `release_stroke`, the same layer the
  mouse and touch bindings call. Tools go through `PuzzleScreen.select_tool` (C3–C5).
- **Elapsed:** `PuzzleScreen.tick()` is the same O3 call `_process` makes; the probe disables
  `_process` so the run is deterministic rather than frame-timing dependent.
- **Pause:** `DBG.1` (`pause_session` / `resume_session`), because C6's routing is #96 and no pause
  chrome exists. This is the one step not driven by a player-facing control; it is declared here.
- **Fixtures:** `PTD-ready-and-marks` uses the fresh `pack-000` board. `PTD-crosses-and-fills`
  leaves, resets progress, reopens, ends the beat, then fills every solution cell and crosses every
  non-solution cell (the beat had already auto-crossed rows 0 and 9). The last required fill,
  `(8,5)`, is placed after the `08` image and the `SIT.3` dump.

## Protocol results

- **S1 — pass.** Fresh `pack-000` is `S2`, marks blocked, a tap on `(5,5)` leaves it `CLEAR`, elapsed
  `0:00`; the board is inert behind the Ready panel (`00`).
- **P2 — pass.** The beat auto-crossed the 20 still-clear cells of empty-clue rows 0 and 9 (the count
  equals `Rules.auto_cross_cells`) and nothing else; elapsed ticks to `0:05` after Ready (`01`).
- **S2 — pass.** Fill → clear → cross on `(5,5)` each apply and redraw (`02`, `03`, `04`); `DBG.2`
  returns `attempt`, `mark_grid`, and `progress` and changes nothing.
- **S3 — pass.** A fill on `(1,1)`, which is not a solution fill, stays; the screen stays `S1`,
  `is_solved()` is false, and `ever_completed` is still false. No fail state (`05`).
- **S4 — pass.** Pause moves to `S3` and logs `TEL event=pause`; a tap changes nothing; `tick(4.0)`
  leaves `0:05`; resume returns `S1` and a fill applies (`06`, `07`).
- **P1–P3 — pass.** No `F1` or `F2` trigger in either protocol.
- **Crosses and fills — pass.** With all 42 solution cells filled and all 58 non-solution cells
  crossed, the attempt is still open before the last fill and solves on it (`08`, `09`). The solve
  cleared the attempt and wrote `ever_completed`, so crosses reached `GS.is-solved` as non-fills
  (`PTD-crosses-and-fills` P2, `E-cell` PS1.3).

## Non-blocking observations

- **No pause chrome.** `S3` looks like `S1`; only `state_id()`, `inspect()`, and telemetry separate
  them. Expected until #96 routes C6 (`06` is pixel-identical to `05`).
- **No result screen.** After the solve the screen keeps the pre-clear grid the `MarkResult` carries;
  result routing is #95, so `09` is the judged state instead of a screen change.
- **Leave does not persist elapsed.** The clean board for `PTD-crosses-and-fills` is reached by
  leaving, resetting progress, and reopening, not by a player leave path. Also #96.

Nothing here is a game or interface failure.

## Reproduce

```sh
cp docs/playtest/evidence/issue-106/2026-11-02-accept-graphical/probe/probe_capture_106.gd game/
godot --path game -s res://probe_capture_106.gd -- --debug-seams \
  --session-id=issue-106-capture --story-ids=PTD-ready-and-marks,PTD-crosses-and-fills \
  --shot-dir="$(pwd)/docs/playtest/evidence/issue-106/2026-11-02-accept-graphical/screenshots" \
  --run-folder="$(pwd)/docs/playtest/evidence/issue-106/2026-11-02-accept-graphical"
rm game/probe_capture_106.gd
```
