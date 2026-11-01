# Notes — #107 re-check 2

## What changed since the last run

| Commit | Effect on #107 |
|--------|----------------|
| #132 `dd0948b` | The open/ready edge and `CMP-rules` R3 auto-cross now exist. `PTD-ready-and-marks` P2 was N/A only because this code was missing. |
| #141 `5e8f226` | Gallery mockups approved — docs only, no code. |

Nothing in the deliverable moved (`game/play/clue_line*.gd`, its tests, the fixture), and
`specs/playtest` did not move either.

## Judgement

- **`E-clue`** — pass at the delivered layer, unchanged: 15 row + 15 column lines for the
  teapot, `[]` on row 0, `[1, 9]` on row 6, `[10]` on row 7, F3/F4 verbatim, empty list
  kept as zero runs with its index, orientation separates row 3 from column 3, I1 reported
  as a mapping error with no lines.
- **`PTD-ready-and-marks` P2** — **pass**, no longer N/A. The probe reads the empty lines
  from the mapper under acceptance (rows `0–3, 12–14`; columns `0–1, 13–14`), opens the
  teapot, ends the beat, and observes **137 of 225** cells crossed — exactly the cells on
  an empty-clue line, nothing else. The attempt turns `IN_PROGRESS` with elapsed 0.
- **Out of scope** — `PTD-crosses-and-fills` P1–P2 need solve state and the result screen
  (#109/#110); the remaining `ready-and-marks` steps need `DBG.2`/`DBG.3`,
  `UI-puzzle.C2`–`C6`, and pause (#110/#111/#112). No clause this layer can decide failed.

## Why acceptance still waits

`specs/playtest/evidence.md` requires ≥1 screenshot of each judged state from a graphical
re-run of the same build. There is still no display surface: `grep` for `draw_`, `DBG.`,
and `TEL.` over `game/**` (minus `addons/`) returns nothing, and the only scene is
`game/presentation/shell.tscn`, a `CenterContainer` with one `Label` showing `pack-000`.
The screenshots are gated on the board and clue-bar screen (#110/#112) plus the shell's
debug/telemetry surface, not on anything #107 can add. No defect: nothing is wrong with the
game at the layer this task delivers.

## Flags for the planner

- This is the fifth hold on #107 and the sixth accept dispatch across the three leaves.
  The deadlock note stands: [`accept-dispatch-deadlock.md`](../accept-dispatch-deadlock.md).
- GUT still exits 0 when a test script fails to parse (logged as ignored). Unchanged and
  still unowned; #127 covers lint, not this.
- `#109` was mid-implementation in the primary checkout during this run (branch
  `task/109-solve-edge`, uncommitted). This run used a detached worktree at `22c88c2` and
  touched nothing else.
