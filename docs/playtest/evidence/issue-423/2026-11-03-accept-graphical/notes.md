# Notes — issue #423 acceptance playtest

## Prep

Build under test is `1161953`, the squash merge of PR #431, run in a clean worktree at that commit. The session id
is `issue-423-accept`, the build id `1161953`. The probe ran the real `Shell` scene with the seams on
(`--debug-seams`), the shipped gallery, and the real `ConfirmOverlay` card. Progress went to a temporary
`user://progress-accept-423.cfg`; the real `user://progress.cfg` was never touched, and the temporary document was
removed at the end.

To reach `PTU-gallery-reset` S1 without a long solve, the temporary document seeded `pack-000` as ever-completed and
in progress: elapsed 42, personal best 60, and a grid with one fill. That is prep only; every judged step uses the
shipped `UI-gallery.C2`, Cancel, and Confirm controls, driven by pointer clicks on the drawn buttons.

The telemetry story id for the run is `US1.1` (`--story-ids=US1.1`), the run's active UX story. `TEL.1`–`TEL.5`
are read back from the S4 sink the shell owns (`DebugSeams.telemetry()`), not parsed from the log alone; the log
line for each event is kept beside them.

## Protocol judgement

| Step | Action | Observation | Outcome |
|------|--------|-------------|---------|
| N1 | Open the gallery | `pack-000` tile reads `Done · In progress`, `Best 1:00`, Reset offered; rate `Completed 1 / 200` | pass |
| S1 | Activate `UI-gallery.C2` Reset | `EX.confirm` is drawn with `copy.reset-title`, `Confirm`, and `Cancel`; no `reset` event recorded when the box opens | pass |
| S2 | Pointer click on Cancel | Box dismisses; gallery Default; tile, best, and rate unchanged; the document re-read compares equal; no event at all, so no `reset` event | pass |
| S3 | Activate Reset again, pointer click on Confirm | Box dismisses; gallery Default; tile `Not started`, no best, Reset no longer offered; rate `Completed 0 / 200`; ever-completed and in-progress false, elapsed 0, PB and marks absent | pass |
| P1 | Cancel path | Document re-read identical; `00` and `02` show the same tile state before and after Cancel | pass |
| P2 | Confirm path | All cleared values read back from the document, not just the tile; `03` shows the tile and rate after Confirm | pass |
| F1/F2 | Fail conditions | Not observed: Cancel did not wipe, Confirm cleared, Reset was available and the box appeared | — |

## Acceptance criteria

| Criterion | Observation | Outcome |
|-----------|-------------|---------|
| A real gallery Confirm records exactly one `reset` event with name, timestamp, session id, build id, story id, and outcome (S4 / `TEL.1`–`TEL.5`) | The run's `telemetry.count()` grew by exactly 1 on the Confirm click; exactly one `reset` event exists; it carries `name=reset`, `timestamp=1793670450.479`, `session_id=issue-423-accept`, `build_id=1161953`, `story_id=US1.1`, `outcome=pass`; the same values appear on its `TEL` log line. Covered by `test_a_gallery_confirm_records_exactly_one_reset_event` in `game/test/test_shell_open.gd` | pass |
| A Confirm whose reset writes nothing emits no `reset` event (`SEQ reset` B3) | `reset_confirm().show_for("no-such-puzzle")` then a pointer click on Confirm: the event count is unchanged, exactly one `reset` event exists in the shell (the earlier real one), and the document compares equal. Covered by `test_a_refused_gallery_confirm_records_no_reset_event` | pass |
| The debug seam's `reset_puzzle` still records exactly one `reset` event, not two | On a second shell, `reset_puzzle("pack-000")` grew the count by exactly 1 and left exactly one `reset` event; the tile re-reads `Not started`. Covered by `test_the_debug_seam_reset_still_records_one_event` | pass |
| Confirm / Cancel behaviour beyond telemetry is unchanged; Cancel records nothing; the box's presentation is untouched | Cancel path above; `01` shows the box as shipped; PR #431 does not touch `confirm_overlay.gd`. Covered by `test_a_cancelled_gallery_confirm_records_no_reset_event` | pass |
| No other telemetry event, picture, pack row, font, music, or SFX is changed | The run log carries exactly two `TEL` lines, both `event=reset` (one per reset), and no other action. PR #431's nine files are `debug_seams.gd`, `shell.gd`, `test_shell_open.gd`, and six spec files — no picture, pack row, font, music, or SFX | pass |
| Repo checks pass; a code review against `docs/solid.md` and `docs/coding-conventions.md` passes | At the build: `gdlint game` no problems, `gdformat --check game` 90 unchanged, `spec_lint.py` 0 errors (1 pre-existing glossary warning), GUT 324/324 (23 296 asserts). PR #431's `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` are all green. Code review: the verification run's [`review-code.md`](../../../../quality/evidence/issue-423/2026-11-03-verify/review-code.md) — Pass, two suggestions, no must-fix | pass |

## Non-blocking observations

- `03`, `04`, and `05` are pixel-identical because the gallery after any reset of `pack-000` looks the same. Each
  was captured at its own step; the difference between them is what the record holds, which the probe asserts.
- The shell keeps no telemetry when the seams are off (`H2`), which is by design: the S4 sink only exists in a
  debug run. Acceptance therefore proves the event on the debug-enabled build the playtest bar requires.
- The reset box's first-open layout is #380's subject and was not re-judged here; `01` is taken with the box already
  laid out.

## Blockers

None.
