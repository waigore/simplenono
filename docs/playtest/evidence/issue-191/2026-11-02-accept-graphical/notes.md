# Notes — issue #191 acceptance

## What was judged

Presentation plumbing, not a screen: `CMP-shell` R4 (ticks, bed, sting, haptic) and R6 (the
manifest resolver), with `SCH-preferences` F1/F2 at their session defaults. The acceptance
tree is this build, `main@52db79a`; the five deliverable files are byte-identical to the
verified deliverable commit `cd08f79`, and `shell.gd`'s audio callbacks and open/leave calls
are unchanged since then (gallery routing from #199 is the only shell edit). The probe boots
the shipped `shell.tscn` itself, so the wiring observed is the shell's, not a fixture's.

Judged through observable state rather than the implementor's claims: the real
`AssetResolver` reading `assets/manifest.json`, the real `AudioStreamPlayer` nodes the shell's
`PlayerSink` adds (stream identity, `playing`, playback position), marks driven through the
shipped `MarkInput`, and the solve produced by committing the pack definition's own
`solution_fills` through `Attempt.mark`, which raises `CTR-attempt` E1.

## Playtest scope and the audio gap

`PTD-ready-and-marks` S1–S3 was re-run as the state carrier for `SND.X1`–`X3` and S14, and
passes. **No design story or playtest protocol cites `SND.*` or `HAP.H1`.** The only protocol
that mentions the haptics preference, `PTU-settings`, judges the settings screen and needs
`UI-settings` (#95). So the audible and haptic outputs have no protocol that can photograph
them: this run records the states where the cues fire (six images) and judges playback from
the player/log observations. That is a spec coverage gap, not a defect in this build —
recorded here for `audit-spec-tbd` / playtest authoring, and an accept agent must not invent a
protocol.

`HAP.H1` is judged at the seam: the real `DeviceSink` only reaches `Input.vibrate_handheld`,
which the platform gate skips on macOS, so no physical click can occur on this machine. The
gate, intensity, duration, and kinds are asserted directly; CI's `test_audio_feedback.gd`
holds the same through the injected sink.

## Non-blocking observations

- The solve screenshot shows the pre-clear grid: S11 clears the attempt and the result
  surface is #95's, so the screen does not repaint after the solve. The sting judgement is the
  player state in the log, not the image.
- The verify note about "+28 tests" vs 19 added functions is paperwork and does not affect
  this decision (185 tests pass here).
- The deterministic record belongs to `cd08f79`; the audio path is identical on this build and
  the gallery addition is read-only for the resolver (`has()`). The gallery's own flows are
  #199's deliverable, not judged here.
- The `[CONT]` suggestion in the verify comment (`MarkResult` solve flag) is outside this
  issue's `CTR-attempt` scope; no follow-up filed.

## Checks

- Suite: 185/185, exit 0. Lint: `gdformat` and `gdlint` clean. Smoke: clean boot.
  `asset_manifest.py --check`: 0 errors. `spec_lint.py`: 0 errors, 1 pre-existing glossary
  warning.
- Two falsification mutations caught (bed start, F1 gate) and reverted; the restored tree
  passes again.
