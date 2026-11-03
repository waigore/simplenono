# Notes — issue #310 leave O6 write path

**Verdict: pass.** On build `task/310-leave-o6-accept@16c8df9` the player can leave a
puzzle mid-attempt, the marks/elapsed/attempt status commit through the leave path, the
gallery reads In progress, and reopening restores the same board and elapsed after
get-set-ready. The leave-during-beat, no-attempt, and nothing-to-persist branches also hold.

## What was judged

The probe instantiated the shipped `res://presentation/shell.tscn` and drove the real
`UI-gallery` and `UI-puzzle` controls:

- `UI-gallery.C1` through the tile's open control (`GalleryScreen.activate_tile`).
- `UI-puzzle.C1` through `%LeaveButton`.
- The fill through the real `MarkInput` gesture layer (`press_cell` + `release_stroke`),
  with the fill tool selected.
- Elapsed through `PuzzleScreen.tick`, the screen's only O3 caller.

Progress went to `user://progress-accept-310.cfg` (injected through the shell's
`progress_path`); the real `user://progress.cfg` was never touched, and the temporary
document was removed at the end.

## Protocol `PTU-leave-resume` (`J-leave-resume` US1.1)

1. Start on `UI-gallery` with no attempt (N1).
2. `UI-gallery.C1` for `pack-000`: `UI-puzzle` opens, get-set-ready runs with marks
   blocked, then marks are allowed.
3. One correct fill placed; `DBG.2` reads it and the attempt is still unsolved.
4. Elapsed advanced to 18; `DBG.2` and the screen both read `0:18`.
5. `UI-puzzle.C1`: `UI-gallery` opens, the shell's attempt is null, and E2 `left` fired
   **once** with `pack-000`.
6. The temporary progress document holds in-progress, elapsed 18, and the stored marks.
   The `pack-000` tile reads In progress and offers Reset.
7. `UI-gallery.C1` reopens it; the beat runs with restored marks blocked, then allows
   marks.
8. P1: the same cell is filled. P2: elapsed reads 18, not 0, and the attempt stays in
   progress. The board screenshot after Ready is byte-identical to the pre-leave board.

## Branch coverage for the acceptance criteria

- **B1:** leave while the reopened attempt was still in get-set-ready. The document kept
  the restored marks, elapsed 18, and in-progress, and its mark count was identical to the
  pre-reopen record — the beat's auto-cross did not run.
- **B2:** `Shell.leave_puzzle()` with no open attempt left the gallery shown, opened no
  attempt, and left the record unchanged.
- **B3:** opened fresh `pack-001` and left during the beat. No marks existed yet, so no
  record was committed (not in progress, elapsed 0, no marks), the attempt cleared, and
  the gallery showed.
- **S3/S4:** every leave with an attempt cleared pause and the open attempt, and emitted
  E2 exactly once with the puzzle id (the probe counted the signal).

## Non-blocking marks

- **Telemetry reports one `commit` event on the B3 leave, where no commit happened.**
  `DebugSeams.note_leave()` calls `_sync_commit()` before untracking, but `Attempt.leave()`
  has already cleared `_puzzle_id`, so `progress_record()` returns null and the signature
  comparison changes. The pack write is genuinely skipped (B3 checks above), so this is an
  observability inaccuracy on the leave path, not a data or interface miss. It is a
  follow-up candidate for the verification seam, not a blocker for this task's criteria.
- The restore board is byte-identical before leave and after resume, which makes P1/P2
  unambiguous without reading the elapsed digits from the image.

## Reproduce

Copy the probe from [`probe/probe_accept_310.gd`](probe/probe_accept_310.gd) to
`game/probe_accept_310.gd`, then run it graphically (not `--headless`):

```
RUN=docs/playtest/evidence/issue-310/2026-11-02-accept-graphical
xvfb-run -a godot --path game -s res://probe_accept_310.gd -- \
    --debug-seams --session-id=issue-310-leave-accept-graphical \
    --build-id=task/310-leave-o6-accept@16c8df9 --story-ids=J-leave-resume \
    --shot-dir="$PWD/$RUN/screenshots"
```

The `--shot-dir` must be absolute (the process view is `game/`). Remove
`game/probe_accept_310.gd` (and its `.uid`) after the run; the probe is not product code.
