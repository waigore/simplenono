# Acceptance criteria — issue #191

Build `main@52db79a`; deliverable `cd08f79`. Evidence is the probe in [`probe/`](probe/probe_accept_191.gd),
the graphical log [`logs/probe-graphical.log`](logs/probe-graphical.log) (79 checks, exit 0), and the
shipped suite [`logs/gut-suite.log`](logs/gut-suite.log).

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | GUT exits 0, 0 failing, including the two new files | Pass | 185/185 tests, 29 437 asserts, exit 0 |
| 2 | R6 reads the manifest once; five IDs load; unknown/missing loud-fail, no fallback; no asset path outside the resolver | Pass | probe R6 checks for SND.X1–X3/M1/M2; unknown ID and missing manifest return null after `push_error`; no asset path or manifest name outside `asset_resolver.gd` |
| 3 | Cue mapping single-source; catalog `approved` + `serves` | Pass | five IDs only in `audio_cues.gd`; every catalog entry approved and serving its cue |
| 4 | G1/G2: ticks preload; bed starts, loops, survives the sting, stops/mutes per F2 | Pass | ticks loaded at app start; bed player playing and looping on open; playing under the sting; stopped on leave |
| 5 | S8 tick per accepted fill/cross/clear; B2/B1 silent | Pass | each mark plays its own tick; drag over the same mark raises no S8; paused tap leaves the grid and plays nothing |
| 6 | S14 sting once over the bed at E1; duplicate silent; no result screen | Pass | the pack's own solution solves; sting plays and advances; bed continues; duplicate E1 does not restart; leave returns to gallery |
| 7 | HAP.H1: 0.25/20 ms, fill/cross, iOS/Android, F1-gated | Pass (seam) | iOS fill and Android cross click at 0.25/20; clear and macOS fire nothing; F1 off suppresses |
| 8 | I1: F2 mutes the bed only; defaults on/off; session-only | Pass | mute stops the bed while the sting plays; unmute restarts; defaults asserted; no `user://` write in the flag path |
| 9 | No screen UI added; `MC.*` gate does not apply | Pass | deliverable commit changes no `.tscn`; gallery/settings/result are #199/#95 |
| 10 | No new assets/files, no second reader, no manifest/spec/ADR change | Pass | commit touches no `assets/`, `specs/`, or manifest; resolver serves any manifest ID (#98) |

Falsification mutations are recorded in [`falsification.md`](falsification.md).
