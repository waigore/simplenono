# Acceptance criteria — issue #191

Build `main@52db79a`; deliverable commit `cd08f79` (PR #196). Evidence is the probe in
[`probe/`](probe/probe_accept_191.gd) plus the shipped suite; paths point into this run
folder.

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | GUT exits 0 with 0 failing, including the two new test files | Pass | [`logs/gut-suite.log`](logs/gut-suite.log): 15 scripts, 185 tests, 185 passing, 29 437 asserts, exit 0; `test_asset_resolver.gd` (7 tests) and `test_audio_feedback.gd` (13) run in it |
| 2 | `CMP-shell` R6: manifest read once at app start; five audio IDs loadable; unknown/draft/deprecated and missing manifest loud-fail with no baked-path fallback; no `res://assets/…` literal outside the resolver | Pass | probe `logs/probe-graphical.log`: "R6: SND.X1…M2 resolves to a loadable AudioStream", "R6: SND.X1 is the fill tick file" / X2 cross / X3 clear, "ACC.A3: an unknown ID returns null with no fallback", "ACC.A3: a missing manifest returns null with no fallback" (both print a `push_error` line), "E1: no asset file path is baked into game logic outside asset_resolver.gd ([])", "E1: only asset_resolver.gd names the manifest" |
| 3 | Cue mapping single-source: five IDs only in `audio_cues.gd`; catalog cross-check `approved` + `serves` | Pass | probe: "ACC.A1: the five cue IDs live only in audio_cues.gd ([\"res://presentation/audio_cues.gd\"])"; for each cue "is approved in the catalog" and "lists <cue> in serves"; `test_asset_resolver.gd` repeats the guard in CI |
| 4 | `asset-access` G1/G2: ticks preload and stay; bed streams on open, keeps playing under the sting, stops/mutes per F2/session end | Pass | probe: "G1: the fill/cross/clear tick is loaded at app start", "G2: no bed before a puzzle opens", "G2: the bed player holds the SND.M1 stream", "G2: the bed plays while a puzzle is open", "G2: the bed streams (loops)", "S14: the bed keeps playing under the sting", "G2: leaving the puzzle stops the bed" |
| 5 | `SEQ-mark` S8 / `SND.X1`–`X3`: accepted fill, cross, clear each play their own tick; B2 and B1 play none | Pass | probe: "S8: an accepted fill plays its tick", cross, clear; "B2: a drag over the same mark raises no S8" and "plays no tick"; "B1: a paused tap leaves the grid unchanged" and "plays no tick"; `test_audio_feedback.gd` covers the same through the real `MarkInput` |
| 6 | `SEQ-mark` S14 / `SND.M2`: solve plays the 1 s sting once over the continuing bed; duplicate E1 does not replay; no result screen | Pass | probe: "the attempt solves on its own solution" (marks committed from the pack's own `solution_fills`), "S14: the solve plays the sting", "S14: the bed keeps playing under the sting", "S14: the sting is a 1 s stream advancing in play", "S14: a duplicate E1 does not restart the sting", "no result screen: leave returns to the gallery (#95 keeps the result)" |
| 7 | `HAP.H1`: fill/cross click once at 0.25 for 20 ms on iOS/Android; clear and desktop none; F1 off suppresses | Pass (seam) | probe: "H1: fill clicks on iOS", "cross clicks on Android", "0.25 for 20 ms each", "one click per accepted mark", "clear fires nothing", "macOS fires nothing", "F1 off suppresses the click". A physical click is not observable on this machine; the shipped device adapter only calls `Input.vibrate_handheld`, which this build's platform gate skips |
| 8 | `SCH-preferences` I1: F2 mutes the bed but not ticks/sting; F1/F2 defaults on/off for the session, no `user://` write | Pass | probe: "F1: session default is on", "F2: session default is off", "F2: mute stops the bed", "I1: mute leaves the sting playing", "F2: unmute restarts the bed", "L1-L3: the flags and their readers keep no user:// write" |
| 9 | No screen UI added; no settings/gallery/result scene or navigation; `MC.*` gate does not apply | Pass | `logs/deliverable-scope.log`: the deliverable commit changes no `.tscn`, no gallery/result/settings scene, and `game/presentation/shell.tscn` is untouched by it. Gallery (#199) and settings (#95) are other issues' surfaces |
| 10 | No new asset entries/files, no second manifest reader, no manifest-format/spec/ADR change; #98 entries can resolve through this resolver | Pass | `logs/deliverable-scope.log`: no `assets/`, `specs/`, or manifest file in `cd08f79`; probe "E1: only asset_resolver.gd names the manifest"; `asset_manifest.py --check` 0 errors ([`logs/repo-checks.log`](logs/repo-checks.log)); resolver returns any manifest ID, so #98's font/picture entries resolve when they land |

## Falsification

Both mutations were applied to the acceptance tree, run, and reverted
([`logs/falsify-bed.log`](logs/falsify-bed.log), [`logs/falsify-haptics.log`](logs/falsify-haptics.log)):

- Removing `_audio.on_puzzle_open()` → 5 failures (bed player, bed playing, loop, bed under
  the sting, unmute restart) — exit 1.
- Removing the F1 check in `haptics.gd` → "H1: F1 off suppresses the click" — exit 1.

The restored tree passes again ([`logs/probe-headless-restored.log`](logs/probe-headless-restored.log)).
