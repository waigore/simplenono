# Independent checks — issue #423

- **Deliverable:** `1161953` (`main`, squash of PR #431), 9 files, +162/−16 — two implementation files, one test
  file, and six spec files. Trees observed at `main` `278717c` (`git diff 1161953 278717c -- game/` is empty).
- **Worktree:** `.orc/worktrees/issue-workflow-verify-agent-1-20261103T011605521131Z`, fast-forwarded to `278717c`.
  No game-code edits; this folder is the only addition.

## Commands

| Check | Command | Result |
|-------|---------|--------|
| Format | `gdformat --check game` | 90 files unchanged (CC-2) |
| Lint | `gdlint game` | no problems (CC-1) |
| Spec lint | `python3 .github/scripts/spec_lint.py` | 0 errors, 1 pre-existing glossary warning |
| Unit tests | `godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` | 324/324 pass, 23 296 asserts (log in `logs/gut-suite.log`) |
| Solve/reset harness | `... run_protocol.gd -- --debug-seams --protocol=solve-reset --run-dir=<this folder> --story-ids=US1.1` | exit 0; I9 flows open, solve, reset, back all pass; one story-keyed `reset` line |

The first `solve-reset` attempt inherited an in-progress `pack-000` record from an earlier run, and its solve leg
failed on already-marked cells; with a fresh `user://progress.cfg` the protocol passes end to end. That is the
harness's documented dirty-record behaviour, not a game failure.

The `paint` protocol was also probed (`/tmp`, not cited): I1 p95 19.51 ms under a load average near 2 on this
4-core box — host contention, no paint code changed, so `frame-time` is not selected for this deliverable.

## CI on PR #431

`Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` all pass.

## Deliverable checks

- **One event per real Confirm** — `game/presentation/shell.gd` `_on_reset_confirmed` calls `_seams.note_reset()`
  after `_pack.reset(puzzle_id)` returns true; `game/presentation/debug_seams.gd` `note_reset()` is the only path to
  `Telemetry.reset()`. A search over `game/` (excluding addons) finds no other `reset` emit.
- **No double event** — `reset_puzzle()` (the debug seam) calls `note_reset()` instead of the sink directly, and the
  shell's Confirm never goes through `reset_puzzle()`, so neither route emits twice.
- **Write, refresh, dismissal unchanged** — `_gallery.refresh()` (S5) and `_gallery.dismiss_reset_confirm()` (S6)
  keep their order after the event; `_pack.reset` is untouched.
- **Refused Confirm (B3)** — the early `return` on a false O7 keeps an unknown id writing nothing and emitting
  nothing.
- **Cancel (B2)** — `_on_reset_cancelled` is untouched and only dismisses.
- **Tests** — `game/test/test_shell_open.gd` adds four: a real Confirm (gallery `activate_reset` then
  `reset_confirm().confirm()`) records exactly one event with `TEL.1`–`TEL.5` and `count() == before + 1`; a refused
  Confirm records none; a Cancel records none; `reset_puzzle()` records exactly one. They run under Unit tests /
  Coverage and are in `logs/gut-suite.log`.
- **Scope held** — the diff changes no other telemetry event, picture, pack row, font, music, or SFX; no main-tree
  UI drawing changed, so no mockup approval applies.
- **Specs** — new `specs/technical/sequences/reset-telemetry.md` (T1, B1, postconditions match the code), linked
  from `sequences/reset.md`, `components/shell.md` C2, `verification.md` S4, `technical.md`, and `traceability.md`.
  Spec lint reports 0 errors.

## Spec rows touched

`verification.md` S4 gains the cross-link to `reset-telemetry.md`, and its S5 and S6 rows are re-worded in the same
diff without a behaviour change. These are spec paths, out of scope for this code review.

## Follow-up

None material.
