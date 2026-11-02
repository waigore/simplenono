# Notes — issue #312 acceptance playtest

## Prep

The build under test is `56b973f` (`main` after PR #326). The issue's deliverable tree is
`fcd899e` (squash of PR #324); between the two, `game/` changes only
`game/test/test_pack_progress.gd` (from #325), so no product code differs. Godot
4.7.2.stable, graphical run under Xvfb at 1100×844, session
`issue-312-accept-312-graphical`, build id `56b973f`.

The probe ran in a clean worktree through the real `Shell` scene, the shipped screens and
`KeyboardInput` node. Keys were pushed through the viewport so every row travelled the
production `_input` path; pointer taps, secondary clicks, and drags were real mouse
events. Progress went to a temporary `user://progress-accept-312.cfg`; the real
`user://progress.cfg` was never touched, and the temporary document was removed at the
end.

Seeded prep only (not judged steps): `pack-000` ever-completed with PB 1:00 so
`UI-gallery.C2` Reset is available; `pack-001` in progress with every solution fill
except `(6,8)`, so S3 can place the last fill; `pack-002` left not started.

## Protocol judgement

| Step | Action | Observation | Outcome |
|------|--------|-------------|---------|
| `PTU-settings` S1 | C3 Settings (pointer) | `UI-settings` shows; focus starts on C1 Haptics | pass |
| S2 | Space on focused C1 | Haptics flips once (On → Off), not twice; focus stays on C1 | pass |
| S3 | Arrows Right/Down/Left/Up | Focus walks C1 → C2 → C3 → C2 → C1 in `Controls` order | pass |
| S3 | Escape | Returns to `UI-gallery` (B5 / `IN.back`) | pass |
| P2 | Reopen C3 | The Off state is still shown, and `02` / `03` are byte-identical | pass |
| `PTU-play-puzzle` S1 | Enter on the focused pack-001 tile | Opens `UI-puzzle` for pack-001 (B4 / `IN.activate`) | pass |
| S2 | Wait through get-set-ready | Board reaches Ready; focus starts on C1 Leave | pass |
| S2 | Down, Down | Focus steps C1 → C6 Settings → C3 Fill | pass |
| S3 | F, then tap `(6,8)` | Fill is selected (B7); the last fill solves and leaves for `UI-result` | pass |
| S4 | Wait for Default, Enter on C1 | Result C1 is focused; Enter returns to the gallery | pass |
| P1/P2 | Gallery after return | Flow completed without a stuck screen; pack-001 reads Done | pass |
| `PTU-leave-resume` S1 | Space on the focused pack-002 tile; tap `(1,1)` | Puzzle opens; after Ready the cell fills; elapsed advances to 2 s | pass |
| S2 | Escape | Leaves through `UI-puzzle.C1`; the attempt closes; the tile offers Reset | pass |
| S3 | Reopen the same tile | After Ready the `(1,1)` fill is restored and elapsed resumes at 2 s, not 0 | pass |
| `PTU-mark-input` S2/S3 | Tap `(1,4)`, tap again | Fills, then clears; the tap toggle matches US1.6/US1.6b | pass |
| S4 | Secondary click `(1,3)` with Fill | Becomes a cross (US1.7) | pass |
| S5 | X, then drag `(1,5)`→`(1,7)` | Cross tool selected (B8); all three cells cross in drag order (US1.8) | pass |
| C tool | C | Clear is selected (B9) | pass |
| B10 | P from the open puzzle | Settings shows, `GS.paused` true, shell state S3; tool and grid unchanged | pass |
| B5 | Escape from paused settings | Returns to the puzzle, resumes it, grid unchanged | pass |
| `PTU-gallery-reset` S1 | C2 Reset on pack-000 | `EX.confirm` shows | pass |
| S2 | Escape | Box dismisses; the progress document is byte-identical; the tile stays Done | pass |
| S3 | C2 then Enter | Box dismisses; tile reads Not started; Reset is no longer offered | pass |

Fail conditions F1/F2 of every protocol were not observed. The five protocols are the
intersection of the `full` coverage set with the IDs the keyboard routes can touch:
`J-play-puzzle` (gallery open, result back), `J-leave-resume` (Escape leave, reopen),
`J-gallery-reset` (Enter/Space confirm, Escape cancel), `J-settings` (focus, activate,
Escape back), and `IN`/`UI-puzzle` mark input (the new `_input` path must not disturb
marks or tools).

## Supplementary checks (issue ACs)

- Input map: `in_confirm` (Enter/KP Enter/Space), `in_cancel` and `in_back` (Escape),
  `in_point` (four arrows), `in_pause` (P); `in_activate` keeps its single mouse binding.
- `keyboard_input.gd` contains no `DisplayServer` branch — one code path for Windows,
  macOS, and Linux (the `bindings.md` mirror note, #96 PO answer).
- A single Space press flips haptics exactly once, so the focused button's own
  `ui_accept` does not double-fire.
- F/X/C still select Fill/Cross/Clear; the existing `test_mark_input.gd` regression test is
  green in the unit suite cited by verification.

## Evidence integrity

- Probe exit 0; 86 checks passed; 19 screenshots saved.
- Telemetry: `session-start` / `session-end` present, open/ready/commit/solved/leave/mark
  events keyed to the session and build; no `SEV level=error` or `level=warn` lines.
- `02`, `03`, and `15` are byte-identical (`d56fec53…`) because the settings screen is in
  the same state — Cancel with no write, reopen with the value stuck, then the same
  settings screen reached by P.
- `08`, `10`, and `12` are byte-identical (`719a1334…`): the board is the same `(1,1)`
  fill and the elapsed label is the same second; the intermediate `(1,4)` fill is
  visible in `11`, and clearing it returns to this frame.
