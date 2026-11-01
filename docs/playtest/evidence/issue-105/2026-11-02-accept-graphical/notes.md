# Notes — issue #105 graphical acceptance run

Build `main@effca0a`, Godot 4.7.2.stable, session `issue-105-capture`, 2026-11-02. Shipped
`res://data/pack.json` (200 puzzles: 10×10×10, 15×15×170, 20×20×20). Drive paths are the real
shell, `PuzzleScreen`, `Board`, and `MarkInput`; observations come from the screen, `DBG.2`
`inspect()`, `DBG.4` story ids, and `TEL.*` in [`logs/capture-console.log`](logs/capture-console.log).

## How the run was driven

- **Start:** `reset_puzzle(id)` for `pack-000`, `pack-010`, `pack-180`, then `DebugSeams.open_puzzle`
  (`DBG.3` / O1); `DBG.4` overlay on with `E-puzzle,PTD-ready-and-marks`.
- **Pack:** the shell loads `res://data/pack.json` through `CMP-pack` R5 / O8 at `_ready`; the probe
  asserts 200 accepted, 0 rejected.
- **Input:** one tap per cell through `MarkInput.press_cell` / `release_stroke`, the layer the mouse
  and touch bindings call; tools go through `PuzzleScreen.select_tool` (C3–C5).
- **Elapsed:** `PuzzleScreen.tick()` is the O3 call `_process` makes, with `_process` disabled.
- **Pause:** `DBG.1` (`pause_session` / `resume_session`), because C6's routing is #96.
- **Solve:** every `solution_fills` position on `pack-000` is tapped with Fill.

## Protocol results

- **S1 — pass.** Fresh `pack-000` is `S2`, marks blocked, a tap on `(5,5)` leaves `CLEAR`, `0:00`
  (`00`).
- **S2 — pass.** Fill → clear → cross on `(5,5)` apply; `inspect()` returns `attempt`, `mark_grid`,
  `progress` and changes nothing. Empty clue rows 0 and 9 auto-cross every cell at Ready, so P2 is
  judged rather than N/A (`01`).
- **S3 — pass.** A fill on `(0,0)`, not in `solution_fills`, stays; the screen stays `S1`,
  `is_solved()` is false, no fail state (`02`).
- **S4 — pass.** On `pack-010`: mark, `tick(18.0)` → `0:18`, pause moves to `S3` and logs
  `TEL event=pause`; a tap changes nothing; `tick(4.0)` leaves `0:18`; resume returns `S1` and a tap
  applies (`06`, `07`).

## E-puzzle PS1.1

- **P1 size — pass.** 10×10, 15×15, 20×20 boards from `pack-000`, `pack-010`, `pack-180`.
- **P2 solution — pass.** Filling exactly the served `solution_fills` solves `pack-000`; `03` keeps
  every fill and the record is `ever_completed` with a personal best. The independent Python audit
  recomputes both clue lists from each fill set: 200/200 valid.
- **P3 clues — pass.** At all three sizes every row label equals the entry's F3 runs (`·` when
  empty) and every column label equals one F4 run in order.
- **P4 identity — pass.** `Attempt` and `Shell` serve the opened id; `DBG.2` reports it; opening
  `no-such-puzzle` returns false and changes nothing (G2).

## Non-blocking observations

- **No pause chrome.** `S3` looks like `S1`; only `state_id()`, `inspect()`, and telemetry separate
  them. Expected until #96 routes C6.
- **Picture ids are placeholders**, unique per entry but with no files until the Wave 3 asset pass
  (#98); PS1.4 is not this issue's criterion.
- **No id on the puzzle screen**, so identity is judged through `DBG.2`; the board is the
  size/clue evidence.

Nothing here is a game or interface failure.

## Reproduce

```sh
cp docs/playtest/evidence/issue-105/2026-11-02-accept-graphical/probe/probe_capture_105.gd game/
godot --headless --path game --import
godot --path game -s res://probe_capture_105.gd -- --debug-seams \
  --session-id=issue-105-capture --story-ids=E-puzzle,PTD-ready-and-marks \
  --shot-dir="$(pwd)/docs/playtest/evidence/issue-105/2026-11-02-accept-graphical/screenshots"
rm game/probe_capture_105.gd
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```
