# Playtest run — issue #648 (graphical acceptance, hint systems + hint-free star)

- **Issue:** #648 Hint systems + hint-free gallery star (`type:epic`, `priority:normal`)
- **Run id:** `2026-11-06-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-06
- **Build / session id:** `main@ffb6e29`, session `issue-648-accept`, Godot
  `4.7.2.stable.official.ed1daf0bf`, Linux x86_64, Xvfb, fresh `user://` per phase.
  Frames: 390×844 (the approved `MC.settings-mobile` / `MC.gallery-mobile` frame),
  1280×800 (the approved `MC.settings-desktop` / `MC.puzzle-desktop` /
  `MC.gallery-desktop` frame), and 900×1200 for the star sampling (the #654
  acceptance frame). `ffb6e29` is `main` at the run; `game/` is identical to the
  deterministic record's `d65a988` (`git diff d65a988 ffb6e29 -- game/` is empty).
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-648-2026-11-06-accept-graphical>

## Scope

The epic's outcome is the integrated hint system: three persisted settings toggles
(`SCH-preferences` F4–F6, ADR-0010), single/multi fill-hint overlays
(`features/fill-hints.md` R3, `PER.R8`), the line-level fillable shade
(`features/line-fillable-shade.md` R2), and the hint-free gallery star
(`PRG` PS1.8–PS1.9, `PER.R7`, `UIS.I1`). The run judges the shipped screens through
the real controls and pointer events.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| [`PTU-settings`](../../../../../specs/playtest/ux/settings.md) S1–S3 / P1 / P2 | Gallery → settings → Back; the hint toggles stick on reopen and across a relaunch |
| `PTU-settings` S6 / P5 | Enabling an assist during an open attempt is observable for hint-free |
| [`PTU-play-hints`](../../../../../specs/playtest/ux/play-hints.md) S1–S5 / P1 / F1 | Overlays apply at once, write no mark, clear on disable; the fill tap shades the max legal run; colours distinct |
| [`PTD-solve-and-pb`](../../../../../specs/playtest/design/solve-and-pb.md) S4 / P4 / F3 | Clean solve earns hint-free; enable voids; a later clean solve re-earns |
| [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md) S1–S3 / P1–P2 | Cancel keeps hint-free; Confirm clears it with the rest; the tile returns to Default |
| `US1.8`–`US1.11` | The toggles, overlays, and shade prove the puzzle-screen stories |
| `MC.settings-*`, `MC.puzzle*`, `MC.gallery-*` | The approved frames and states |

Out of scope: `PTU-settings` S4–S5 / P3–P4 are mobile-device steps (situational tool:
a phone or tablet). This run is a desktop build, where C4 is absent by spec, so those
steps are not applicable — the same treatment as the #95 and #651 settings acceptance
runs. `PTD-*` protocols other than `solve-and-pb` and the other `PTU-*` protocols are
untouched by this epic's deliverable.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-settings` S1 / P1 | **pass** | cold start on `UI-menu`; C1 reaches `UI-gallery`; gallery C3 opens `UI-settings`; C3 Back returns |
| `PTU-settings` S2 / P2 | **pass** | C5 and C6 flip On; the store holds both; the values stick on reopen |
| `PTU-settings` S3 / P2 | **pass** | a fresh process on the same `user://` still shows C5/C6 On; C7 stayed Off |
| `PTU-settings` S6 / P5 | **pass** | a fresh attempt is eligible; enabling C6 while paused makes it ineligible and latches the enable |
| `PTU-play-hints` S1–S3 / P1 / F1 | **pass** | F8 ghosts only with single-line; F8+F9 with multi-line; both off leaves 0 ghosts; marks unchanged |
| `PTU-play-hints` S4–S5 / P1 | **pass** | a fill tap shades r5c3–r5c8 (the max legal run); only the tap's own mark changed; toggle-off clears the shade |
| `PER.R8` / `PAL.K7` | **pass** | C8 ghost and C9 shade read distinct (sampled pixels) |
| `PTD-solve-and-pb` S4 / P4 / F3 | **pass** | clean solve sets hint-free; enable during an active attempt clears it; a later clean solve re-earns |
| `PTU-gallery-reset` S1–S3 / P1–P2 | **pass** | Cancel keeps ever-completed/hint-free/PB; Confirm clears all three; the tile returns to `Not started` |
| `US1.8`–`US1.11` | **pass** | the toggles, overlays, and shade behave as the stories state |
| `MC.settings-*`, `MC.puzzle*`, `MC.gallery-*` | **pass** | the approved rows, overlay/shade states, and star placement on the mobile and desktop frames |

Capture: `capture: RESULT pass` on every phase (9 + 1 + 6 + 4 shots, 0 checks failed),
exit 0 — logs on the wiki page.

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-648/2026-11-06-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-settings-default.png` | `PTU-settings` S1 | 390×844: C5/C6/C7 default Off |
| `screenshots/02-settings-toggled.png` | `PTU-settings` S2 | C5 and C6 On |
| `screenshots/03-settings-reopened.png` | `PTU-settings` S3 | the values stick on reopen |
| `screenshots/04-void-on-enable.png` | `PTU-settings` S6 / P5 | the paused puzzle after enabling C6 |
| `screenshots/05-single-line-overlays.png` | `PTU-play-hints` S2, `US1.8` | F8 ghost crosses and fills, no marks |
| `screenshots/06-multi-line-overlays.png` | `PTU-play-hints` S3, `US1.9` | F8 + F9 ghosts |
| `screenshots/07-overlays-off.png` | `PTU-play-hints` S3, `US1.9` | both off, no ghost, marks unchanged |
| `screenshots/08-fillable-shade.png` | `PTU-play-hints` S4, `US1.10` | the C9 shade on the max legal run |
| `screenshots/09-shade-cleared.png` | `PTU-play-hints` S5, `US1.11` | shade gone, marks unchanged |
| `screenshots/10-settings-after-relaunch.png` | `PTU-settings` S3 / P2 | a fresh process still shows C5/C6 On |
| `screenshots/11-clean-solve.png` | `PTD-solve-and-pb` S4 | the clean solve reaches the result |
| `screenshots/12-gallery-star.png` | `PTD-solve-and-pb` P4, `PER.R7` | the star at the thumb's upper-left |
| `screenshots/13-void-no-star.png` | `PTD-solve-and-pb` P4 | the voided tile shows no star |
| `screenshots/14-re-earn-star.png` | `PTD-solve-and-pb` P4 | the re-earned tile shows the star |
| `screenshots/15-reset-confirm.png` | `PTU-gallery-reset` S1 | `EX.confirm` for the hint-free puzzle |
| `screenshots/16-reset-cleared.png` | `PTU-gallery-reset` P2 | Confirm clears hint-free; tile Default |
| `screenshots/desktop-01-settings.png` | `MC.settings-desktop` | 1280×800: C5–C7 visible, C4 absent |
| `screenshots/desktop-02-overlays.png` | `MC.puzzle-desktop` | 1280×800: single-line overlays |
| `screenshots/desktop-03-shade.png` | `MC.puzzle-desktop` | 1280×800: the C9 shade |
| `screenshots/desktop-04-gallery-star.png` | `MC.gallery-desktop` | 1280×800: the hint-free star |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail, observations | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_648.gd`](probe/probe_accept_648.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture-first.log`, `capture-relaunch.log`, `capture-star.log`, `capture-desktop.log` |
| `DBG.2` state dumps | wiki page, `logs/state-pack-004.json`, `logs/state-pack-005.json` |
| Screenshots (20, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **pass** — [`docs/quality/evidence/issue-648/2026-11-06-verify/manifest.md`](../../../../quality/evidence/issue-648/2026-11-06-verify/manifest.md)
(PR #689, merged `4dbe2e0`), `response-delay` (35.4 ms ≤ 500 ms), `crash-free`,
`hitch-bound` (35.21 ms ≤ 100 ms), `save-survives`, and `failed-write` all pass.
The record was taken at `d65a988`; `game/` at this run's `ffb6e29` is identical
(`git diff d65a988 ffb6e29 -- game/` is empty), so the record covers this tree.
`frame-time` is not claimed: the record explains the p95 reading is a host-load
artifact, identical to the #652 record and worse on the pre-overlay parent.
This run did not re-run the evaluators — acceptance cites, it does not re-run
`deterministic`.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Sample board.** The protocol's "10×10 sample board" is `pack-000`, the first
  10×10 pack puzzle. `US1.8`'s illustrative cells describe the mockup's sample, not
  `pack-000`; the run judged `pack-000`'s actual precomputed F8/F9 cells.
- **Shade tap.** `US1.10` says "marks unchanged"; the tap itself writes its own fill
  (the normal mark path). The run asserts the shade writes no mark of its own: only
  the tapped cell changed.
- **Star frame.** The star sampling ran at 900×1200 (the #654 acceptance frame) so the
  thumb square is fully inside the frame; the mobile and desktop gallery frames are
  covered by the settings/puzzle phases and the desktop star shot.
- **Relaunch start.** The first phase leaves `pack-000` in progress, so the relaunch
  resumes on the gallery (`NAV.N1/N2`); a fresh store would start on the menu. Both
  are legal, and the persistence check is the settings values.
