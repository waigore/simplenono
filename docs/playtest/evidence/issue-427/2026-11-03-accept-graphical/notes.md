# Notes — issue #427 acceptance

## What was judged

The music bed's lifetime: `SND.M1` in `specs/aesthetics/sound.md` (M1 context "Gallery and the open puzzle", L1),
`ACC.G2` in `specs/assets/access.md` (load "Gallery or puzzle opens", unload "Session end or mute bed only (SFX
stay)"), G2 in `specs/technical/asset-access.md`, and R4/R5 in `specs/technical/components/shell.md`, with
`SCH-preferences` F2 / `I1` for the mute. The defect says the shipped shell scoped the bed to one open puzzle.

Judged on `main@4041ef6` — the deliverable's `game/` is byte-identical to the verified squash `08ba1d5`
(`git diff 08ba1d5 4041ef6 -- game/` is empty). The probe boots the shipped `shell.tscn`, so the wiring observed is
the shell's.

Judged through state rather than the implementation's claims:

- the bed `AudioStreamPlayer` that the shell's own `PlayerSink` adds to `AudioFeedback`, found by stream identity and
  read for `playing` and `get_playback_position()`;
- the clip's decoded length (28 000 ms) recomputed from the stream's own MP3 data, so "playing" is not an empty or
  zero-length resource, and `loop` read off the stream;
- the playback position as a continuation witness: a stop-then-start (what the defect did on every leave) drops the
  position back to the top, so `pos(n) + 0.01 >= pos(n-1)` across app start → open → leave → reopen → result → Back
  is the regression check;
- the state dump (`DBG.2`) at the end and the shell's own view/tile strings for the screens.

## What the fix actually does, as observed

| Step | `AudioFeedback.bed_playing()` | bed player | position |
|------|-------------------------------|------------|----------|
| gallery at app start | true | playing | 1.67 ms |
| puzzle open | true | playing | 2.05 ms |
| after C1 Leave | true | playing | 2.70 ms |
| reopened from the gallery | true | playing | 2.97 ms |
| result screen | true | playing | 4.37 ms |
| gallery after Back | true | playing | 4.83 ms |
| settings, mute on | false | stopped | 0.00 ms |
| settings, mute off | true | playing | 0.09 ms → 0.56 ms |

Before the fix the first row was `bed_playing=false` (the gallery was silent) and the third row was `false` (leave
stopped the bed). Both are now the corrected behaviour, and the position never restarts across the navigation steps.

## Falsification

Two mutations on a scratch copy of `game/presentation/shell.gd`, each reverted before the recorded run:

1. **`_audio.start_session()` removed from `_ready()`** (the pre-fix gallery) — the probe fails at app start and on
   every later state; [`logs/falsify-no-start-session.log`](logs/falsify-no-start-session.log), exit 1, 30+
   `capture: FAIL` lines.
2. **`_audio._stop_bed()` added to `_on_attempt_left()`** (the pre-fix leave) — the probe passes the app-start and
   open states, then fails exactly at the leave: `FAIL G2: the bed keeps playing after leaving the puzzle`,
   including `no restart: pos 0.00ms >= 1.86ms`, and every state after it;
   [`logs/falsify-stop-on-leave.log`](logs/falsify-stop-on-leave.log), exit 1.

So the checks are load-bearing for the defect's two halves, not a restatement of the fix.

## Blockers and non-blocking marks

- **No sound device in this container.** Godot falls back to the dummy audio driver, so nothing can be heard here.
  Playback is judged from player state as above. A listening pass on the gallery, in the puzzle, after leave, and
  across the F2 toggle stays open for the product owner; it blocks no item.
- **No image input in this session.** The eight frames are verified as distinct, non-blank 900×1200 renders and are
  matched to their states by the captured state lines; the visual look stays open for the product owner.
- **Clearing the mute restarts the clip** from its start (~0.09 ms after a stop). No spec fixes the resume point, so
  this is non-blocking. If the product owner wants "resume where it was", that is a new spec line, not a defect.
- **`PTU-leave-resume` S4/S5 not driven.** Quit/relaunch restore is outside this slice's reach (no persistence path
  changed); the relaunch leg lives in the deterministic record's `solve-reset` and `navigate` protocols.
- **Screenshots do not show audio.** The bed is a stream; the images record the states it should be audible in. This
  is the `SND.*` protocol gap recorded for #191, not something an accept agent may paper over by inventing a
  protocol.

## Checks

[`logs/checks.log`](logs/checks.log): `spec_lint.py` 0 errors (1 pre-existing view/technical glossary warning),
`asset_manifest.py --check` 0 errors, `asset_catalog.py` 0 errors, `generate_pack.py --check` current,
`git diff 08ba1d5 4041ef6 -- game/` empty at `4041ef6315602431b38ae5b3a454d005147712d7`. No main-tree UI changed, so
no mockup-catalog gate applies.
