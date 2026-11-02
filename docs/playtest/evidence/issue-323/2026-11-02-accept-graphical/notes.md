# Notes — issue #323 acceptance playtest

## Prep

The build under test is `1520675` (`main`, squash of PR #340). The probe ran on
`62fd0ec` (the PR #340 merge commit); `git diff 62fd0ec 1520675` is empty, so the
judged tree is the deliverable tree. Godot 4.7.2.stable, graphical run under Xvfb at
900×1400, sessions `issue-323-accept-323-graphical`, build id `1520675`.

The run is two real Godot processes over one temporary document: `setup` plays
`PTU-leave-resume` S1–S4 and quits while `UI-settings` shows; `relaunch` is the app
starting again for S5 and the Android Back checks. The probe used the real `Shell`
scene, the shipped screens, the real `KeyboardInput` node, and real pointer events.
Progress went to `user://progress-accept-323.cfg`; the real `user://progress.cfg` was
never touched, and the temporary document was removed at the end.

Seeded prep only (not judged steps): `pack-001` in progress with every solution fill
except `(6,8)`, so the last fill can reach `UI-result`; `pack-000` left not started so
S1 starts on a fresh puzzle.

## Protocol judgement

| Step | Action | Observation | Outcome |
|------|--------|-------------|---------|
| `PTU-leave-resume` S1 | Open pack-000; wait Ready; tap `(1,1)` | Puzzle opens; after Ready the cell fills; elapsed advances to 3 s (`DBG.2`) | pass |
| S2 | `UI-puzzle.C1` Leave | `UI-gallery` opens; the attempt closes; the tile reads in progress and offers Reset | pass |
| S3 | `UI-gallery.C1` reopen; wait Ready | The `(1,1)` fill is restored; elapsed resumes at 3 s, not 0 | pass |
| P1/P2 | After S3 | Same cell mark restored; attempt stays in progress (`01` / `03` byte-identical) | pass |
| S4 | `UI-puzzle.C6` Settings, then quit the app | `UI-settings` shows; the attempt and shell are paused; settings remembers it returns to the puzzle; the pause committed marks, elapsed 3 s, and in-progress status | pass |
| S5 | Relaunch | App starts on `UI-gallery`; pack-000 reads in progress; reopen restores the mark and elapsed 3 s | pass |
| P3 | After S5, wait through get-set-ready | Elapsed ticks again; a new tap fills `(2,2)`, so marks are allowed (`06` byte-identical to `01` / `03`) | pass |
| `PTU-leave-resume` F1–F3 | Whole run | No lost mark or attempt status, no elapsed reset, no pause-then-quit restore loss | not observed |

## Android Back — `B37` / `US1.11`

| Screen / state | Action | Observation | Outcome |
|----------------|--------|-------------|---------|
| `UI-puzzle` | Engine `NOTIFICATION_WM_GO_BACK_REQUEST` | Leaves through `UI-puzzle.C1` to the gallery; the tile stays in progress; reopening shows the same marks, so Back placed none | pass |
| `UI-settings` (paused from puzzle) | Back | `UI-settings.C3` resumes the puzzle; the attempt is no longer paused; marks unchanged | pass |
| `UI-settings` (from gallery) | Back | Returns to `UI-gallery` | pass |
| `UI-gallery` (root) | Back | No screen change, no attempt, no write; the platform pass-through counter fired once (`12`) | pass |
| `UI-result` before `C1` | Back during the morph | Stays on `UI-result`; the notification is consumed (no platform pass-through) | pass |
| `UI-result` after `C1` | Back after the morph | Goes to `UI-gallery` through `UI-result.C1` (`14`, `15`) | pass |
| `EX.confirm` showing | Back | The box stays up, no screen change, no platform pass-through; `16` / `17` are byte-identical | pass |

The handler never cancels the confirm box and never raises `IN.cancel`; no mark is
placed by Back in any of the rows above.

## Supplementary checks (issue ACs)

- `keyboard_input.gd` handles `NOTIFICATION_WM_GO_BACK_REQUEST` through `handle_go_back`,
  contains no `DisplayServer` branch and no `OS.get_name` branch, and adds no second
  `in_android_back` action; `in_back` keeps its single Escape binding.
- `application/config/quit_on_go_back` is `false`, so a routed Back does not also quit.
- `SEQ pause` B2/B3 and the paused-path guard are unit-level rows, not playtest steps:
  `test_pause_during_get_set_ready_commits_the_restored_marks_as_held`,
  `test_pause_with_nothing_to_persist_skips_the_commit`, and
  `test_a_gallery_path_does_not_resume_the_paused_attempt` pass in the verification
  GUT log (`docs/quality/evidence/issue-323/2026-11-02-verify/logs/gut-suite.log`,
  317/317).

## Evidence integrity

- Probe exit 0 in both phases; 69 checks passed (24 setup, 45 relaunch); 18 screenshots
  saved; no `probe323: FAIL`, `SEV level=warn`, or `SEV level=error` line.
- Telemetry: `session-start` / `session-end` present in both phases; open/ready/commit/
  mark/leave/solved events keyed to the session and build.
- `01`, `03`, and `06` are byte-identical (`8e24d102…`): the board restored after Leave
  and after the quit/relaunch pause is the same frame the pause committed.
- `02`, `05`, `08`, `11`, and `12` are byte-identical (`1c60c1fd…`): the gallery after
  Leave, after relaunch, after Back from the puzzle, after Back from settings, and after
  a pass-through Back are the same in-progress gallery.
- `07`, `09`, and `10` are byte-identical (`2a9d4bc8…`): the two-mark board after the
  reopen, after Back from the puzzle, and after Back from paused settings is unchanged.
- `16` and `17` are byte-identical (`ef91efc3…`): Back while `EX.confirm` shows leaves
  the box exactly as it was.
