# Playtest run — issue #504 (graphical acceptance)

- **Issue:** #504 Mobile: locked orientation default portrait with durable toggle (`type:task`, `priority:high`)
- **Run id:** `2026-11-04-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-04
- **Build / session id:** `main@9c322b5` (PR [#514](https://github.com/waigore/simplenono/pull/514) squash `9c322b5`), Godot 4.7.2.stable, session `issue-504-accept`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (900×1200),
  Vulkan Forward+ on llvmpipe under Xvfb, Linux x86_64, fresh `user://` (isolated `HOME`)
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-504-2026-11-04-accept-graphical>

## Scope

#504 locks the mobile screen orientation and stores the choice durably. The running game has no
Settings orientation control: that is #511, which starts only after the `MC.settings-mobile` row is
re-approved. `PTU-settings` P3 judges that control, so it is not judged here; S4, S5, P4, and F3 are.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| `PTU-settings` S4 (`UI-settings.C4` absent from this build) | the mobile build's framing on a cold launch |
| `PTU-settings` S5 (force-quit, relaunch, tilt both ways) | the durable choice and the lock |
| `PTU-settings` P4 / F3 | the stored orientation survives the relaunch; a tilt does not rotate it |
| `PTU-settings` P3 | **out of scope** — needs `C4`, which is #511's |

Out of scope: every other protocol. The change adds no gallery, puzzle, result, settings, pack,
input, audio, or persistence-document code; `game/presentation/shell.gd` only gains the launch lock
and `game/presentation/orientation_lock.gd`.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-settings` S4 | **pass** | cold launch with nothing stored shows the gallery in the portrait framing and asks for portrait |
| `PTU-settings` S5 | **pass** | a stored landscape, then a stored portrait, are each restored and locked on the relaunch |
| `PTU-settings` P4 | **pass** | after a tilt left and a tilt right the held value, the stored value, and the drawn frame are unchanged |
| `PTU-settings` F3 | **not triggered** | no rotation on a tilt, no lost choice |
| `PTU-settings` P3 | **not judged** | the control is #511's |

Capture: **29 checks `capture: PASS`, 0 `capture: FAIL`**, final line
`capture: RESULT pass (6 shots, 29 checks, 0 failed)`, exit 0 —
[wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-504-2026-11-04-accept-graphical).

## The lock, judged

The lock is a platform call the exported Android and iOS apps make from
`display/window/handheld/orientation`. This build reads that setting back as `1` (Portrait), which
the exporters map to `android:screenOrientation` and `UISupportedInterfaceOrientations`. Each
relaunch path is a new `Shell` from the shipped scene, and the one
`DisplayServer.screen_set_orientation` call is recorded through the unit tests' seam:

| Launch | Held F3 value | Orientation asked to lock | Gallery first |
|--------|---------------|---------------------------|---------------|
| cold, nothing stored | `portrait` | Portrait | yes |
| nothing stored, document check | — | — | no document is written |
| stored `landscape` | `landscape` | Landscape | yes |
| stored `portrait` | `portrait` | Portrait | yes |
| tilt left (−90°), tilt right (+90°), upright | `landscape` | none re-made | yes |

The tilt frames are byte-identical to the pre-tilt frame, and no presentation code or project
setting asks for a sensor orientation.

## Judged states (wiki media, graphical run of this build)

| Wiki path (`playtest/issue-504/2026-11-04-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-cold-launch-portrait.png` | S4 | gallery in the portrait framing on a cold launch with nothing stored |
| `screenshots/02-relaunch-stored-landscape.png` | S5 | the relaunch that restored and locked the stored landscape |
| `screenshots/03-relaunch-stored-portrait.png` | S5 | the relaunch that restored and locked the stored portrait |
| `screenshots/06-tilt-upright.png` | P4 | the same upright frame after a tilt left and a tilt right |

The shots taken while the probe held the viewport turned (`04-tilt-left`, `05-tilt-right`) show a
rotated viewport, not the display frame the player sees, so they are not judged states; the frame
comparison for them is in the log.

A device re-run of S5 would confirm the platform path. This graphical run proves the app asks for
the right fixed orientation on each launch path and never for a sensor one.

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, reproduction | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_504.gd`](../probe/probe_accept_504.gd) |
| Capture console (29 PASS, final RESULT) | wiki page, `logs/capture.log` |
| Screenshots (4, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **cited, not re-run.** Verification wrote a passing record at the deliverable
commit `9c322b5` — [`docs/quality/evidence/issue-504/2026-11-04-verify/manifest.md`](https://github.com/waigore/simplenono/tree/main/docs/quality/evidence/issue-504/2026-11-04-verify),
evidence PR [#515](https://github.com/waigore/simplenono/pull/515). `time-to-playable` (I6),
`response-delay` (I8), and `crash-free` (I9) are pass; no row is `fail` or `blocked`. PR #515 is an
evidence-only PR; `game/` at `9c322b5` is the tree the record measured.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Display.** No monitor on this host; Xvfb (`xvfb-run`, 1000×1300×24) with Vulkan Forward+ on
  llvmpipe. The shipped `shell.tscn` ran at 900×1200 as on a phone; every shot is the display's
  real frame texture.
- **Why a desktop host can judge the mobile lock.** The lock call returns early on a desktop so the
  app is unchanged there; the probe records that call through `OrientationLock.platform_orientation`,
  the same seam the unit tests use, and reads the exported setting from `ProjectSettings`.
- **Probe side effect.** Godot rewrites `game/project.godot` (formatting and comments) when it runs
  with the `--import` flag the probe needed; the file is restored after the run and the run commit
  has no `game/` change.
