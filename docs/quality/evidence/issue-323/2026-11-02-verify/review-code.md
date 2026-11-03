## Code review: Pass

**Target:** PR #340 (`1520675`, squash on `main`) — `game/presentation/keyboard_input.gd`,
`game/presentation/shell.gd`, `game/project.godot`, `game/test/test_android_back.gd`,
`game/test/test_pause_resume.gd`.

### Findings

- `[SRP]` `suggestion` — `game/presentation/keyboard_input.gd:104-118` — the input node now owns the Android
  platform-back relay (`platform_back`, `_quit_on_platform_back`) beside the keyboard rows. Both are platform
  input edges and the relay is one callable, so the responsibility still reads as "resolve this platform's input
  for the shell"; revisit only if a second OS notification arrives.
- `[CONT]` `suggestion` — `game/presentation/keyboard_input.gd:112` — `handle_go_back()` returns `false` after it
  has already invoked `platform_back`, so "false" means "not consumed by the shell", not "nothing happened". The
  doc comment says so; a caller that later treats the return as "no action" would be surprised.

### Notes

- `handle_go_back()` reuses `Shell.back_from_input()` and the one `in_back` action, so B37 is an extension of the
  Escape route rather than a parallel seam; the new test asserts the action map still holds only the single
  `in_back` binding.
- `back_from_input()` keeps returning `true` for `RESULT_VIEW` even while `UI-result.C1` is unavailable, which
  matches the review's implementation note (consume there rather than hand the event to the platform) and is
  documented at the method. Only `UI-gallery` reports `false`, which is what the gallery pass-through test pins.
- `_show_gallery()` clearing `_settings_return` makes the paused-path guard an invariant of every gallery return,
  not a special case; `close_settings()` is still the only resume exit, and the new guard test exercises the
  gallery path.
- Both new test files run against the shipped shell and real nodes and use temporary `user://` paths; the
  `_remove()` helper matches the nine existing test files, so it is continuity rather than new duplication.
- `test_android_back.gd` covers each screen branch, the unavailable-C1 case, the gallery pass-through, the
  confirm-box consumption, and the absence of a second action. `test_pause_resume.gd` covers the round trip, the
  quit/relaunch restore, B2/B3, and the guard.
- CI `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` all pass. Local
  `gdformat --check game` (90 files) and `gdlint game` are clean, and `spec_lint.py` reports 0 errors.
- No cataloged assets changed; `review-asset` is N/A. No screen drawing changed, so no mockup gate applies.
