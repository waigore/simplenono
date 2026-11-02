# Playtest run — issue #349 (result reveal keeps the picture's proportions)

- **Issue:** #349 Result reveal picture is vertically compressed (`type:defect`, `priority:high`)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `480e41e` (`main`, squash of PR #352);
  `session-1793630126`; Godot 4.7.2.stable, graphical on macOS (Metal 4.0), 900×1400
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
  · graphical
- **Level:** UX — `PTU-play-puzzle` (`J-play-puzzle`, `UI-result`), plus the issue's
  aspect criterion ([`result.md`](../../../../../specs/ux/screens/result.md) R1 / S1; `PER.R5`)

## Scope

The deliverables change only what `UI-result` R1 paints in its reveal layers.
Intersecting the `full` coverage set with the IDs that change can affect gives
`PTU-play-puzzle` S1–S4 / P1–P2 and the issue's own aspect observation on S1 Default.
No design story is reachable from this change.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `PTU-play-puzzle` S1–S3 | **pass** | Gallery opens the seeded `pack-001`; Ready; the last fill solves to `UI-result` and the morph settles on S1 Default |
| `PTU-play-puzzle` S4 | **pass** | `UI-result.C1` returns to `UI-gallery`; the result screen is gone |
| `PTU-play-puzzle` P1 | **pass** | Gallery → puzzle → result → gallery completes without a stuck screen |
| `PTU-play-puzzle` P2 | **pass** | `pack-001` reads `Done` with `Best 0:30` and a thumbnail after return |
| `PTU-play-puzzle` F1–F2 | **not observed** | The solve reached `UI-result`; Back reached the gallery; ever-completed stuck |
| Issue #349 aspect, `UI-result` S1 Default | **pass** | 1024 × 1024 source draws 360 × 360 (aspect 1.0000) in the 836 × 360 host; screenshot region pixel-check is 360 × 360; subject silhouette drawn 1.7714 vs source 1.7655 |
| Issue #349 non-square source | **pass** | A 200 × 100 source fits 360 × 180 inside the square, keeping 2:1 |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-gallery-start.png) | S1: `UI-gallery`, seeded `pack-001` in progress |
| [`01`](screenshots/01-puzzle-before-last-fill.png) | S2: `UI-puzzle` Ready, one correct fill from solve |
| [`02`](screenshots/02-result-s1-default.png) | S3 / #349: `UI-result` S1 Default, the picture drawn 360 × 360 with natural proportions |
| [`03`](screenshots/03-gallery-after-result-back.png) | S4 / P2: gallery after Back; `pack-001` Done, Best 0:30, thumbnail |

## Paths

| Artifact | Path |
|----------|------|
| Notes and per-step judgement | [`notes.md`](notes.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_accept_349.gd`](probe/probe_accept_349.gd) |
| Probe console, 23/23 checks, exit 0 | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| Screenshot pixel pass | [`logs/screenshot-pixel-analysis.log`](logs/screenshot-pixel-analysis.log) |

## Quality evaluator

Deterministic: covered by
[`docs/quality/evidence/issue-349/2026-11-02-verify/manifest.md`](../../../../quality/evidence/issue-349/2026-11-02-verify/manifest.md)
(PR #353) — `frame-time`, `hitch-bound`, and `crash-free` pass for `480e41e`, and the
`game/` tree is unchanged between that record and this run.
`llm-judge`: N/A — every rubric axis is deterministic and the domain axis list is empty.
