# Independent checks — issue #323

- **Deliverable:** `1520675` (`main`, squash of PR #340), 10 files, +581/−46. The local branch commit `62fd0ec`
  has an identical tree (`git diff 62fd0ec 1520675` is empty), so the measured tree is the merged tree.
- **Worktree:** `chore/323-verify-evidence` branched from `origin/main` at `1520675`; no game-code edits.

## Commands

| Check | Command | Result |
|-------|---------|--------|
| Format | `gdformat --check game` | 90 files unchanged |
| Lint | `gdlint game` | no problems |
| Spec lint | `python3 .github/scripts/spec_lint.py` | 0 errors, 1 pre-existing glossary warning |
| Unit tests | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` | 317/317 pass (log in `logs/gut-suite.log`) |
| Paint harness | `... run_protocol.gd -- --debug-seams --protocol=paint --run-dir=<this folder>` | exit 0; I1 p95 16.67 ms, I2 longest 21.60 ms |
| Navigate harness | `... --protocol=navigate` | exit 0; I1 p95 16.38 ms, I2 longest 32.79 ms, I7 456.6 ms |
| UI-ack harness | `... --protocol=ui-ack` | exit 0; I8 longest acknowledgement 30.4 ms |
| Solve/reset harness | `... --protocol=solve-reset` | exit 0; I9 flows open, solve, reset, back all pass |

Each protocol ran with a fresh `user://progress.cfg`. The first `solve-reset` run inherited an in-progress
`pack-000` record left by an earlier run and its solve flow failed on already-marked cells; with the document
removed the protocol passes end to end. That is the harness's documented dirty-record behaviour, not a game
failure.

## CI on PR #340

`Code lint`, `Unit tests` (317/317), `Coverage`, `Integration harness`, `PR hygiene`, `Spec lint`, and
`Auto-merge` all pass.

## Deliverable checks

- `game/presentation/keyboard_input.gd` — `NOTIFICATION_WM_GO_BACK_REQUEST` arrives in `_notification` and goes
  through `handle_go_back()`: `EX.confirm` consumes it with no effect, any screen that owns `IN.back` acts through
  the existing `Shell.back_from_input()`, and `UI-gallery` relays the platform's own Back. No `DisplayServer`
  branch and no second back action.
- `game/presentation/shell.gd` — `back_from_input()` keeps the Escape route and consumes Back on `UI-result`
  while C1 is unavailable; `_show_gallery()` clears `_settings_return`, so `close_settings()` is the only exit
  that resumes an attempt paused into settings.
- `game/project.godot` — `application/config/quit_on_go_back=false`, so a routed Back does not also close the app
  and the gallery can hand the event back to the platform.
- `game/test/test_android_back.gd` — 9 behaviour-level tests through the shipped shell and the real node:
  notification wiring, puzzle→gallery, settings→back/resume, result→gallery with and without C1, gallery
  pass-through, `EX.confirm` consumption, and the single-`in_back` seam.
- `game/test/test_pause_resume.gd` — 5 tests: `SEQ pause` S5–S7 round trip, `US1.2` pause→quit→relaunch→reopen,
  B2 held commit, B3 skipped commit, and the paused-path guard. Temporary `user://` paths only.
- Specs — `B37` in `specs/ux/controls/bindings.md`; `US1.11` and its coverage row/note in
  `specs/ux/stories/controls/bindings.md`; `US1.2` (`Proves`: N1, N2, S2) in
  `specs/ux/stories/journeys/leave-resume.md`; `J-leave-resume` Owner `#323` in `specs/playtest/story-rows.md`;
  the pause-then-quit step pair plus pass/fail row in `specs/playtest/ux/leave-resume.md`. The journey spec and
  `MC.leave-resume` are untouched, matching the story-only choice the review accepted.
- Parent #96 — the platform-bindings bullet reads `B11–B37`, and the evidence comment (6577622014) records
  `B37`/`US1.11`, `US1.2`, and the pause/resume proof.
- No screen layout, asset, or catalog row changed; the mockup gate and `review-asset` are N/A.

## Hygiene repaired here

- `game/test/test_android_back.gd.uid` and `game/test/test_pause_resume.gd.uid` — the two new scripts were the
  only `.gd` files in `game/` without their tracked Godot UID sidecar (175 tracked `.uid` files; a fresh import
  re-created these two as untracked). They are added in this evidence PR so the tree matches the repo's import
  layout; no game code changes.

## Follow-up

None material. Non-blocking: `US1.2`'s **Proves** line lists `N1, N2, S2` while the issue AC wrote the set as
`N1, S2, N2`; the set and the coverage rows agree, so this is ordering only. The `J-leave-resume` row's Note
survives beside an owned `#323` exactly as the task AC required.
