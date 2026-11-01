# Notes — issue #132, run `2026-11-02-accept-fail`

## What was judged

`PTD-ready-and-marks` (Design) on `main@a8b54dc`, the first build that contains both #132's ready
edge and its real consumer, the #110 puzzle screen. The previous acceptance run
(`2026-11-02-accept`) judged this protocol on `main@a0c2e39`, before `puzzle.tscn` existed. This
run re-judged S1 through the screen and the persisted-attempt path, which no earlier run covered.

## Method

1. Read `game/play/attempt.gd`, `attempt_state.gd`, `mark_grid.gd`, `game/records/progress_record.gd`,
   `progress_rules.gd`, and `game/presentation/puzzle.gd` / `puzzle_board.gd`.
2. Ran the shipped suite on a clean detached worktree: 132/132, exit 0.
3. Wrote an independent probe into `game/test/` for the run (source kept under `probe/`, removed
   from the tree afterwards). It drives the real `Pack`, `Attempt`, `Rules`, `AttemptState`, and
   the real `PuzzleScreen` scene — no fakes.

## Finding — reopened in-progress attempts skip the mark block

`ProgressRecord.marks_copy()` (`game/records/progress_record.gd`) rebuilds the stored grid as
`MarkGrid.new(marks.size, true)` — marks allowed — because the marks are applied through
`apply_mark`. `Attempt._state_for()` then calls `AttemptState.show_grid()` with that grid, which
replaces the open-time grid. The attempt is still in get-set-ready (`Attempt.get_set_ready()` is
true, the screen reports `S2`), but `marks_allowed()` is already true for the whole beat.

Observed on `main@a8b54dc`:

- a mark during the beat is accepted and committed (`apply_mark` returns true);
- `advance()` adds elapsed during the beat (probe: 18 → 21; shipped pack: 0 → 3);
- on `PuzzleScreen`, `state_id()` is `S2` while `marks_allowed()` is true, the cells keep
  `MOUSE_FILTER_STOP`, and `copy.elapsed` counts up (`0:18` → `0:25`).

The fresh-puzzle path is unaffected: `MarkGrid.new(size)` starts blocked, and S1 passes there.
The shipped test `test_open_restores_an_in_progress_record` comments "the beat is still blocked on
open" but asserts neither `marks_allowed()` nor `advance()`, so the gap is not covered.

Specs contradicted: `SCH-attempt` F5 ("False during get-set-ready and while paused") and I2;
`SEQ-open` S4 ("Marks blocked, not paused. Progress supplies marks and elapsed"), B3, and the
postcondition "Marks are allowed when S7 has passed"; `UI-puzzle` `US1.7`; `PTD-ready-and-marks`
F1 ("Marks apply during get-set-ready → blocks acceptance").

## Judgement

`PTD-ready-and-marks` **F1 is triggered** on the reopen path, and #132's acceptance criterion
"`SEQ-open` S4–S5 … O1 returns the loaded grid and elapsed with marks blocked" fails. This is a
game-behaviour fail, not a spec or evidence gap: the probe reproduces it on both the teapot fixture
and the shipped 200-puzzle pack. A defect is filed and #132 returns to implementation.

Everything else this layer decides still passes (P2 auto-cross, P3 pause/wrong-fill, E3 payload,
B1 unknown id, B3 pause during the beat, `CTR-rules` O3).
