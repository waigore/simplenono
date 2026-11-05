# Playtest run — issue #642 (graphical acceptance, gallery unsolved placeholder)

- **Issue:** #642 Gallery R2: unsolved tile placeholder is a box with question mark
  (`type:task`, `status:pending-acceptance`, `priority:normal`)
- **Run id:** `2026-11-05-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-05
- **Build / session id:** deliverable commit `a988a0c7` (PR #657 squash on `main`);
  probed at `main@2f905b80` where `game/presentation/gallery_thumb.gd` and
  `gallery_tile.gd` match the deliverable (`git diff a988a0c7 HEAD --` those paths is
  empty). Session `issue-642-accept`, Godot 4.7.2.stable, Metal 4.0 on Apple M5, app
  frame 360×640, macOS arm64, fresh `user://`.
- **Coverage mode:** `full` · graphical
- **Wiki page:** <https://github.com/waigore/simplenono/wiki/Playtest-issue-642-2026-11-05-accept-graphical>

## Scope

The deliverable replaces the unsolved gallery-tile mini filled-grid glyph with a simple
RULE box and a centered Ink "?" (`US1.3` / R2). Ever-completed solution thumbnails,
status / PB / Reset rules, and `GS.gallery-thumbnail` stay unchanged.

| Story / protocol | Why it is in scope |
|------------------|--------------------|
| Issue AC / `UI-gallery` US1.3 | Not-ever-completed tiles: box + "?", not mini-grid / not picture |
| Issue AC / `UI-gallery` US1.2 | Ever-completed tile still draws the solution thumbnail |
| Issue AC / status · PB · C2 | Status, personal best, and Reset allowedness unchanged |
| [`PTU-gallery-layout`](../../../../../specs/playtest/ux/gallery-layout.md) S1 / P1, P2, P4 | First viewport at 360×640: margin, 2 columns, square thumb |
| [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md) S1 (allowedness) | C2 withdrawn on fresh; available on in-progress and ever-completed |

Out of scope: `PTU-gallery-layout` S2–S3 scroll/drag legs (no layout change),
`PTU-gallery-reset` Cancel/Confirm wipe (no Reset behaviour change), puzzle / menu /
settings / mark-input protocols — no code there in the diff.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Issue AC / US1.3 not-started (`pack-000`) | **pass** | `shows_picture=false`; inset Paper + Ink "?" (223 Ink px, fraction 0.024) + RULE frame; status Not started; no Best; C2 withdrawn |
| Issue AC / US1.3 in-progress (`pack-001`) | **pass** | same placeholder reading; status In progress; C2 allowed and drawn |
| Issue AC / US1.2 ever-completed (`pack-003`) | **pass** | `shows_picture=true`; Done; Best 1:01; C2 allowed |
| `PTU-gallery-layout` S1 / P1, P2, P4 | **pass** | 360×640: margin present, 2 columns, square thumbnail region |
| `PTU-gallery-reset` S1 allowedness | **pass** | fresh withdraws C2; in-progress and ever-completed keep it |

Capture: `capture: RESULT pass (4 shots, 0 failed)`, exit 0 —
[wiki `logs/capture.log`](https://github.com/waigore/simplenono/wiki/Playtest-issue-642-2026-11-05-accept-graphical).

## Judged states (all images from this graphical run of this build)

| Wiki path (`playtest/issue-642/2026-11-05-accept-graphical/`) | Protocol / pass item | What it shows |
|------|----------------------|---------------|
| `screenshots/01-gallery-first-viewport.png` | `PTU-gallery-layout` S1 | cold gallery at 360×640 |
| `screenshots/02-tile-not-started.png` | US1.3 / AC | `pack-000` box + "?" placeholder |
| `screenshots/03-tile-in-progress.png` | US1.3 / AC | `pack-001` placeholder + Reset |
| `screenshots/04-tile-ever-completed.png` | US1.2 / AC | `pack-003` solution thumbnail + Done + Best |

## Paths

| Artifact | Path |
|----------|------|
| Judged detail | [`notes.md`](notes.md) |
| Probe (copied to `game/` for the run, removed after) | [`probe/probe_accept_642.gd`](probe/probe_accept_642.gd) |
| Capture console (RESULT pass) | wiki page, `logs/capture.log` |
| `DBG.2` state dump | wiki page, `logs/state-attempt.json` |
| Screenshots (4, graphical run of this build) | wiki page, `screenshots/` |

## Quality evaluator

`deterministic`: **N/A** — verification of #642 recorded that the glyph-only placeholder
swap cannot move Applies performance / reliability / load axes; no covering
`deterministic` record is required for this deliverable.

`llm-judge`: **N/A**. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and the domain-axes list is empty.

## Notes

- **Frames.** The placeholder draw path is shared across gallery frames; one run at the
  360×640 test viewport covers the visual AC. Layout S2–S3 and full reset Cancel/Confirm
  are out of scope (no change there).
- **Sparse Ink.** Mini-grid filled cells would push Ink fraction well above the 0.22
  ceiling; both placeholder tiles measured 0.024 with a RULE inset frame.
