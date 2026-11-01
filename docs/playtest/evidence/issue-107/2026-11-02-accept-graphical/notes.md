# Notes — issue #107 graphical acceptance run

Build `main@aff969b`, Godot 4.7.2.stable, session `issue-107-capture`, 2026-11-02. Shipped
`res://data/pack.json` (200 puzzles). All observations come from the real shell → `PuzzleScreen`
→ `PuzzleBoard` path, the delivered `ClueLines` mapper, and `DBG.2` `inspect()` in
[`logs/capture-console.log`](logs/capture-console.log).

## How the run was driven

- **Start:** `reset_puzzle` on `pack-000` (empty rows) and `pack-001` (empty columns), then
  `DBG.3` open through `CTR-attempt` O1; `DBG.4` overlay on with
  `E-clue,PTD-ready-and-marks`.
- **Clue layer:** for each line, the probe reads the board's rendered clue text and the mapper's
  `ClueLine` (`orientation`, `index`, `run_lengths`, `is_empty`) and compares both with the
  loaded definition's F3/F4 lists. Nothing is recomputed from F5.
- **Auto-cross:** after the get-set-ready beat, the probe enumerates every cell whose mark is
  `CROSS` and compares that set with the cells on empty-clue lines only.
- **Determinism:** `PuzzleScreen.set_process(false)`; the run never waits on wall-clock timing.

## Protocol results

- **`E-clue` P1 — pass.** The mapper returns 10 row + 10 column lines for a size-10 puzzle and
  15 + 15 for the fixture; orientation is carried on every line and the board draws the row bar
  (right-aligned) and column bar (end-aligned) separately (`00`, `02`).
- **`E-clue` P2 — pass.** Indices run `0…size−1` within each orientation; the probe asserts row
  and column indices independently, so row 3 and column 3 are different lines (fixture: row 3
  `[]`, column 3 `[3]`).
- **`E-clue` P3 — pass.** Run lengths are the pack lists verbatim, in order. An empty list is a
  line with zero runs that keeps its slot and is rendered as `·` (`00`: rows 0, 9; `02`:
  columns 0, 1, 8, 9), never null or omitted.
- **`PTD-ready-and-marks` P2 — pass.** The fixture has empty clue lines, so the protocol's
  "N/A if none" escape does not apply. pack-000 after Ready: exactly 20 cells crossed (rows 0
  and 9), every other cell clear, attempt `in_progress`, elapsed `0:00` (`01`). pack-001:
  exactly 40 cells crossed (columns 0, 1, 8, 9) (`03`). The auto-cross itself is #132's open-ready
  edge; this run uses it to judge that the empty line this deliverable produces is the line the
  rule sees.
- **Out of scope:** `E-clue` S1/S2/I2/I4 (`CMP-rules` R2/R3, #108),
  `PTD-ready-and-marks` S1/S3/S4 (`E-cell`/marks/pause, judged by #156), and
  `PTD-crosses-and-fills` P1–P2 (`GS.is-solved` #108, result screen #95).

## Non-blocking observations

- **Empty-line glyph is `·`.** It is the approved `MC.puzzle` glyph, so a zero-run line is
  visible rather than blank. Good.
- **The Ready panel dims the board.** Screenshots `00`/`02` are taken during get-set-ready, which
  is when the clues are first shown; the bars are readable but dim. Not a protocol requirement.
- **GUT still exits 0 when a test script fails to parse.** Unchanged and still unowned; this run
  read `Scripts = 11` and `Tests = 139` instead of trusting only the exit code. The same gap is
  recorded in [`accept-dispatch-deadlock.md`](../../accept-dispatch-deadlock.md).

Nothing here is a game or interface failure.

## Reproduce

```sh
cp docs/playtest/evidence/issue-107/2026-11-02-accept-graphical/probe/probe_capture_107.gd game/
godot --path game -s res://probe_capture_107.gd -- --debug-seams \
  --session-id=issue-107-capture --story-ids=E-clue,PTD-ready-and-marks \
  --shot-dir="$(pwd)/docs/playtest/evidence/issue-107/2026-11-02-accept-graphical/screenshots"
rm game/probe_capture_107.gd
```
