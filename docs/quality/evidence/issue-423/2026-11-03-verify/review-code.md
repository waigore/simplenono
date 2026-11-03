## Code review: Pass

**Target:** PR #431 (`1161953`, squash on `main`) — `game/presentation/debug_seams.gd`,
`game/presentation/shell.gd`, `game/test/test_shell_open.gd`.

### Findings

- `[SRP]` `suggestion` — `game/presentation/debug_seams.gd:214,223-226` — `reset_puzzle()` (the S1 stage reset) now
  records through `note_reset()` and the shell's Confirm calls the same method. The node therefore both drives a
  debug stage reset and is the single emitter the shell depends on; that is already the node's documented job (it
  is the S4 sink for every event), so no change is required. Revisit only if a non-debug owner appears.
- `[CONT]` `suggestion` — `game/presentation/debug_seams.gd` `note_reset()` — it has no `is_enabled()` guard, unlike
  `reset_puzzle()` and `pause_session()`. It is safe because `_telemetry` is created only under `_ready()` with the
  same flag, and the early return keeps a flag-off shell silent; the asymmetry is deliberate (the shell calls it
  unconditionally) and the doc comment says so.

### Notes

- `shell.gd` `_on_reset_confirmed` — the event sits after `if not _pack.reset(puzzle_id): return`, so O7 refusal
  (B3) records nothing and the write, `_gallery.refresh()` (S5), and `dismiss_reset_confirm()` (S6) keep their order.
  No second emitter exists: a search over `game/` (excluding addons) finds one `_telemetry.reset()` call, inside
  `note_reset()`.
- The knobs already on the shell (`_seams.note_open`, `note_mark`, `note_leave`) are the existing pattern; the new
  call is continuity rather than a parallel seam (DIP: the shell keeps talking to the one seam, not to `Telemetry`).
- `game/test/test_shell_open.gd:371-455` — four behaviour-level tests through the shipped shell, the real gallery
  box, and the real `DebugSeams`; the telemetry tests boot a second shell with the flag on and the rest stay off, so
  no other test changed behaviour. They assert the exact fields (`TEL.1`–`TEL.5`), the one-event count with
  `before + 1`, the refused and cancelled cases, and the debug seam's one-not-two.
- Specs are non-code paths and out of scope for this review; they were checked in the verify comment.
- CI `Code lint`, `Unit tests`, `Coverage`, `Integration harness`, `PR hygiene`, and `Spec lint` all pass. Local
  `gdlint game` reports no problems and `gdformat --check game` leaves 90 files unchanged (CC-1, CC-2).
- No cataloged assets changed; `review-asset` is N/A. No screen drawing changed, so no mockup gate applies.
