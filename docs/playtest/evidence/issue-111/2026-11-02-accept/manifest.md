# Playtest run — issue #111

- **Issue:** #111 UI actions: mark input (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@881774e`. No `TEL.3` session id exists — no first-party
  script emits `TEL.*` on this build.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Scope

First acceptance run for this issue. The deliverable landed as PR
[#154](https://github.com/waigore/simplenono/pull/154) (`b99b31d`) and was
verified on 2026-11-01. `git diff b99b31d 881774e -- game/presentation/mark_input.gd
game/presentation/mark_gesture.gd game/test/test_mark_input.gd game/project.godot` is
empty, so the code under acceptance is exactly the verified deliverable.

Story owned by this issue: `IN` ([`story-rows.md`](../../../../../specs/playtest/story-rows.md)).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `IN` US1.6 / US1.6b (tap apply and toggle) | pass at the delivered layer | probe + `test_desktop_click_applies_fill_and_toggles_it_off` |
| `IN` US1.7 (complement) | pass at the delivered layer | probe + `test_desktop_secondary_click_applies_complement_and_toggles` |
| `IN` US1.8 (drag-paint, no per-cell toggle) | pass at the delivered layer | probe + `test_desktop_drag_paints_cross_without_per_cell_toggle` |
| `IN` C3/C4/C5 tool select | pass at the delivered layer | probe + `test_keyboard_f_x_c_select_tools_and_next_tap_applies` |
| `IN` blocked / paused → no `CTR-attempt.O2` | pass at the delivered layer | probe + `test_blocked_marks_send_no_o2_call`, `test_paused_board_sends_no_o2_call` |
| `PTU-settings` | not runnable | the only protocol citing `IN`; it exercises settings toggles, not mark input, and needs `UI-settings` (#95, Wave 2) |
| `PTD-ready-and-marks` | out of scope for this deliverable | its `Cites` line omits `IN`; its mark steps judge `E-cell`/`E-clue`/`GS` semantics (#106/#107/#108) |
| Graphical re-run | **waiting** | no S1–S4 seam exists, so [`verification.md`](../../../../../specs/technical/verification.md) H1 bars a gate run on this build |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Falsification | [`falsification.md`](falsification.md) | present |
| Probe source (run once, then removed from `game/test/`) | [`probe_accept_111.gd`](probe_accept_111.gd) | present |
| Log — full suite at `881774e` | [`logs/gut-accept.log`](logs/gut-accept.log) | present (10 scripts, 145/145, 29 688 asserts, exit 0) |
| Log — fresh-worktree import | [`logs/import.log`](logs/import.log) | present |
| Log — independent probe | [`logs/probe.log`](logs/probe.log) | present (6/6, 151 total, exit 0) |
| Log — falsification, tap toggle removed | [`logs/falsify-tap.log`](logs/falsify-tap.log) | present (2 failing, exit 1) |
| Log — falsification, block removed | [`logs/falsify-blocked.log`](logs/falsify-blocked.log) | present (2 failing, exit 1) |
| Screenshot — `IN` judged state (tap, complement, drag-paint) | `screenshots/mark-input.png` | **waiting on a graphical re-run of a seam-complete build** |

Per [`specs/playtest/evidence.md`](../../../../../specs/playtest/evidence.md), omitting
screenshots in a headless run is marked waiting here and is not a protocol fail; the issue
stays `status:pending-acceptance`.
