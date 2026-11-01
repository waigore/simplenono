# Falsification — issue #95 graphical acceptance

Each observation the run leaned on, and what would have overturned it.

| Claim | Would be false if | Checked |
|-------|-------------------|---------|
| The morph spends both stages on real frames | the morph reached `S1` in roughly one stage window | yes — 560.8 ms over 69 real frames, `2 × stage_ms` = 600 ms; the prior verify measured 600.0 ms fixed-delta |
| The settings values persist across reopen | reopening showed the defaults again | yes — `Haptics Off`, `Mute music On` after Back and reopen ([`p4`](screenshots/p4-settings-reopened-stuck.png)) |
| The gallery shows the solved puzzle ever-completed | `#000` still read `Not started` | yes — `Done`, `Best 0:00`, `Completed 1 / 200` ([`p11`](screenshots/p11-gallery-after-result-back.png)) |
| **The result's `S1 Default` is blank** | any content was drawn at `S1` | yes — [`p10`](screenshots/p10-result-default.png) shows only the Back button on paper; `ResultReveal._apply_frames()` sets every filled layer to `0.0` and the picture layer to `1.0` with a `null` texture |
| The blank is caused by the missing picture ids, not by the capture | the ids resolve, or the pixel picture is present and the screen still blanks | yes — both `pack-000` ids are absent from `assets/manifest.json`, which holds five audio entries ([`logs/pictures-absent.log`](logs/pictures-absent.log)) |
| The blank is a deliverable defect, not a harness artefact | the spec allows an empty `S1`, or the mockup's default is empty | yes — `UI-result` R1 says *Always*, S1 names the generated picture, and the approved mockup's `default` draws one |
| The result screen can still be judged and was not merely late | waiting longer produced a picture | no — the probe waited for `is_morphing()` to clear (the stage clock's own end) and captured afterwards; nothing else paints the screen |

## What this run does **not** claim

- It does not re-judge `frame-time`/`hitch-bound`; the deterministic record covers them and is cited,
  not re-run.
- It does not judge `PTU-leave-resume`, `PTU-gallery-reset`, or `PTU-mark-input`, which belong to
  #96, #94, and #111.
- It does not fault #98 for the absent pictures. #98 owns delivering them; this run faults #95's
  screen for resolving to nothing rather than to its best available layer.
