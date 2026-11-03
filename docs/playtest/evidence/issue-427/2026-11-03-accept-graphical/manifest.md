# Playtest run — issue #427 (graphical acceptance)

- **Issue:** #427 Music bed stops on leaving a puzzle and never plays in the gallery (`type:defect`, `priority:high`)
- **Run id:** `2026-11-03-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-03
- **Build / session id:** `main@4041ef6`, Godot 4.7.2.stable, session `issue-427-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical
  (900×1200) through `xvfb-run` on Linux x86_64 (`godot --path game`, not `--headless`), CPU rendering (llvmpipe)

## Scope

Deliverable: PR [#434](https://github.com/waigore/simplenono/pull/434) (squash `08ba1d5`, `MERGED`) —
`game/presentation/audio_feedback.gd`, `game/presentation/shell.gd`, and `game/test/test_audio_feedback.gd`.
`git diff 08ba1d5 4041ef6 -- game/` is empty, so this tree plays exactly the delivered code
([`logs/checks.log`](logs/checks.log), last lines). The only other commits since are evidence folders.

The slice changes a shell-level audio stream's lifetime (app start, open, leave, result, settings mute), not
screen content or game rules. Protocols were selected by that reach:

| Protocol / story | Why it is in scope |
|------------------|--------------------|
| `PTU-play-puzzle` P1 (`J-play-puzzle`) | Gallery → puzzle → result → gallery must stay unstuck now that leave/Back touch audio |
| `PTU-leave-resume` surface (`J-leave-resume`) | S1 open + mark, S2 `UI-puzzle.C1` Leave back to the gallery, S3 `UI-gallery.C1` reopen — the exact flow the defect broke |
| `PTU-settings` surface (`J-settings`) | Settings is reachable over the gallery again with the bed running; `UI-settings.C2` mute and `C3` Back are the F2 path this fix re-scoped |
| `ACC.G2` / `SND.M1` (no protocol row) | The defect itself: the bed's unload rule is "session end or mute bed only" |
| `SCH-preferences` F2 / `I1` | Mute stops the bed only, and clearing it resumes |

Out of scope, with reason:

- `PTU-leave-resume` S4/S5 (pause, quit, relaunch, restore) — no persistence, commit, or restore path is in the
  deliverable; the relaunch leg is the two-process harness of the deterministic record.
- `PTU-gallery-reset`, `PTU-mark-input`, and every Design protocol — the slice changes no mark, reset, clue, or
  solve rule. A board was still solved (shot `05`) to reach the result screen, and it behaved as before.
- `PTD-pack-finished` — needs a 199-completed fixture; untouched here.

**No design story or playtest protocol cites `SND.*`** (the same gap recorded for #191). The bed therefore has no
protocol that could photograph it: this run records the states where it should sound and judges playback from the
player state, the decoded clip, and the console log, not by listening (see [Notes](#notes)).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `ACC.G2` bed at app start | **pass** | `SND.M1` loaded and streaming on the gallery before any puzzle opened; 28 000 ms looped clip |
| `ACC.G2` bed across open | **pass** | Player still running, playback position advanced (`2.05 ms ≥ 1.67 ms`) — not restarted |
| `ACC.G2` bed after leave | **pass** | C1 Leave → gallery keeps the same stream (`2.70 ms ≥ 2.05 ms`); tile reads In progress |
| `ACC.G2` bed on reopen | **pass** | `UI-gallery.C1` reopen keeps it (`2.97 ms ≥ 2.70 ms`) |
| `ACC.G2` bed on the result | **pass** | Solve → result keeps it (`4.37 ms ≥ 2.97 ms`) |
| `ACC.G2` bed after Back | **pass** | Result Back → gallery keeps it (`4.83 ms ≥ 4.37 ms`) |
| `SCH-preferences` F2 / `I1` | **pass** | Mute stops the bed (`playing=false`), clearing the mute resumes it on the gallery, ticks and sting untouched |
| Settings screen does not stop the bed | **pass** | Bed running with the mute off while settings covers the gallery (`5.11 ms ≥ 4.83 ms`) |
| `PTU-play-puzzle` P1 | **pass** | Gallery → puzzle → result → gallery with no stuck screen |
| `PTU-leave-resume` S1–S3 | **pass** | Real tap fills a clear cell; Leave closes the attempt; reopen shows the puzzle |
| `PTU-settings` surface | **pass** | Settings opens, C2 flips the mute, C3 Back returns to the gallery |
| Pack load | **pass** | 200 puzzles accepted, 0 rejected |

Capture log: **78 `capture: PASS`, 0 `capture: FAIL`**, final line `capture: RESULT pass (8 shots, 0 checks failed)`,
exit 0 — [`logs/capture.log`](logs/capture.log).

## Judged states (all images from this graphical run of this build)

| Path | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-app-start-bed.png` | `ACC.G2` load | The gallery at app start, bed streaming (`pos=1.67 ms`) |
| `screenshots/02-puzzle-open-bed.png` | `ACC.G2`, `PTU-leave-resume` S1 | `pack-004` open and ready, one real tap filled a clear cell, bed still streaming |
| `screenshots/03-gallery-after-leave-bed.png` | `ACC.G2` unload, `PTU-leave-resume` S2 | Back on the gallery after C1 Leave, `pack-004` In progress, bed still streaming |
| `screenshots/04-puzzle-reopened-bed.png` | `PTU-leave-resume` S3 | `pack-005` reopened through `UI-gallery.C1`, bed still streaming |
| `screenshots/05-result-bed.png` | `ACC.G2`, `PTU-play-puzzle` P1 | `pack-003` solved → result screen, bed still streaming |
| `screenshots/06-gallery-after-back-bed.png` | `ACC.G2`, `PTU-play-puzzle` P1 | Result Back → gallery with `pack-003` done, bed still streaming |
| `screenshots/07-settings-mute-bed-stopped.png` | `SCH-preferences` F2 | Settings over the gallery with the BGM mute on; the bed player is stopped |
| `screenshots/08-settings-unmuted-bed.png` | `SCH-preferences` F2 | Same screen with the mute off; the bed is streaming again |

Only `01`, `03`, `06` and the two settings frames are distinguishable by eye; the bed itself is audio, so the
judgement of playback is the state lines in [`logs/capture.log`](logs/capture.log), not the images.

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, scope, blockers | [`notes.md`](notes.md) |
| Reproduce | [`reproduce.md`](reproduce.md) |
| Probe (copied to `game/`, removed after the run) | [`probe/probe_accept_427.gd`](probe/probe_accept_427.gd) |
| Capture console (78 PASS, telemetry, final RESULT) | [`logs/capture.log`](logs/capture.log) |
| `DBG.2` state dump after the run | [`logs/state-pack-003.json`](logs/state-pack-003.json) |
| Falsification — `start_session()` removed | [`logs/falsify-no-start-session.log`](logs/falsify-no-start-session.log) |
| Falsification — bed stopped on leave | [`logs/falsify-stop-on-leave.log`](logs/falsify-stop-on-leave.log) |
| Repo checks and the build identity | [`logs/checks.log`](logs/checks.log) |

## Quality evaluator

`deterministic`: cited, not re-run. Verification wrote a passing record at this issue's deliverable commit `08ba1d5` —
[`../../../../quality/evidence/issue-427/2026-11-03-verify/manifest.md`](../../../../quality/evidence/issue-427/2026-11-03-verify/manifest.md).
It measures `game/` at `5812bf4`, whose `game/` is identical to `08ba1d5` and equal to this tree's
(`git diff 08ba1d5 4041ef6 -- game/` empty). `time-to-playable` 2044.1 ms ≤ 3 s, `frame-time` p95 8.33 ms ≤ 16.7,
`hitch-bound` 48.49 ms ≤ 100, `transition-latency` 248.1 ms ≤ 500, `crash-free` pass. No row is `fail` or `blocked`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is `None`, so there is no judge record to read and no evidence is written.

## Notes

- **Audible output was not heard.** The container has no sound device — Godot reports
  `All audio drivers failed, falling back to the dummy driver` and
  `capture: audio driver=Dummy mix_rate=44100`. The bed is judged from the real `AudioStreamPlayer` the shell's
  `PlayerSink` adds (stream identity, `playing`, playback position), from the clip's decoded length (28 000 ms), and
  from the continuation witness that a restart-on-leave would break. This is the method the #191 acceptance used for
  the same stream. A listening pass on a machine with an output device stays open for the product owner and blocks
  nothing.
- **Look is not eyeballed.** This session has no image input, so the eight frames are verified as distinct,
  non-blank 900×1200 renders (519/519 and 342/351 distinct colours, 2824 for the picture reveal) and as the screens
  their state lines name. A human look stays open for the product owner.
- **Clearing the mute restarts the clip from its beginning** (position resets to ~0.09 ms). Nothing in
  `sound.md` / `SCH-preferences` fixes the resume point, so this is recorded as a non-blocking observation, not a
  defect.
