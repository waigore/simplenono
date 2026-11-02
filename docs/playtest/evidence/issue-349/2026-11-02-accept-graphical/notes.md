# Notes — issue #349 acceptance playtest

## Prep

The build under test is `480e41e` (`main`, squash of PR #352, the fix for the result
reveal). Godot 4.7.2.stable, graphical run on macOS (Metal 4.0, Forward+), window
900×1400, session `session-1793630126`.

The run plays `PTU-play-puzzle` on `pack-001` seeded one correct fill from solve
(the `DBG.3` fixture), through the real `Shell` scene, the shipped gallery/puzzle/result
screens, real pointer events, and a temporary `user://progress-accept-349.cfg`. The real
`user://progress.cfg` was never touched, and the temporary document was removed at the
end. The probe is in [`probe/probe_accept_349.gd`](probe/probe_accept_349.gd); it was
copied into `game/` for the run and removed after.

## Scope

`full` coverage ([`coverage.md`](../../../../../specs/playtest/coverage.md)) intersected
with the IDs this deliverable can affect. The change only alters what `UI-result` R1
paints in its reveal layers, so the required protocol is
[`PTU-play-puzzle`](../../../../../specs/playtest/ux/play-puzzle.md) (`J-play-puzzle`,
`UI-result`), plus the issue's own aspect criterion ([`result.md`](../../../../../specs/ux/screens/result.md)
R1 / S1; `PER.R5`). No design story is reachable from this change.

## Protocol judgement — `PTU-play-puzzle`

| Step | Action | Observation | Outcome |
|------|--------|-------------|---------|
| S1 | Start on `UI-gallery`; open the seeded `pack-001` via `UI-gallery.C1` | Gallery shows the seeded tile in progress; it opens `UI-puzzle` | pass |
| S2 | Wait through get-set-ready | Board reaches Ready; marks are allowed | pass |
| S3 | Place the last correct fill | The solve leaves for `UI-result`; the morph runs and C1 appears only at S1 Default | pass |
| S4 | `UI-result.C1` Back to gallery | Returns to `UI-gallery`; the result screen is gone | pass |
| P1 | Whole run | Gallery → puzzle → result → gallery completes without a stuck screen | pass |
| P2 | Gallery after S4 | `pack-001` reads `Done` with `Best 0:30` and its thumbnail | pass |
| F1/F2 | Whole run | Not observed: the solve reached `UI-result`, and Back returned to the gallery with the completion kept | pass (not observed) |

## Issue #349 — the reveal keeps the picture's natural proportions

After the morph settles on `UI-result` S1 Default, the generated picture is the opaque
drawn layer. The probe read the live geometry
([`logs/probe-graphical.log`](logs/probe-graphical.log)):

| Observation | Value |
|-------------|-------|
| Reveal host (`ResultReveal` size) | 836 × 360 |
| Drawn square (`ResultMorphSlot.square()`) | 360 × 360 at x = 238, centered |
| Stored source (`pack-001-generated.png`) | 1024 × 1024 |
| Picture box (`picture_box()`) | 360 × 360 |
| Drawn ÷ source aspect | 1.0000 ÷ 1.0000 |

A supplementary 200 × 100 source fitted to 360 × 180 inside the same square, so a
non-square source keeps its own ratio instead of stretching.

The captured frame agrees ([`screenshots/02-result-s1-default.png`](screenshots/02-result-s1-default.png)).
A pixel pass over that PNG ([`logs/screenshot-pixel-analysis.log`](logs/screenshot-pixel-analysis.log))
found the picture's drawn region at `x 270–629, y 32–391` — exactly 360 × 360, aspect
1.0000 — instead of the old wide band. The subject's dark silhouette measured 310 × 175
(drawn aspect 1.7714) against the same silhouette in the 1024 × 1024 source at
881 × 499 (1.7655), a 0.3% difference, so no vertical squash remains.

The gallery thumbnail after return also draws the picture square
([`screenshots/03-gallery-after-result-back.png`](screenshots/03-gallery-after-result-back.png)).

## Quality evaluator

Deterministic: covered by [`docs/quality/evidence/issue-349/2026-11-02-verify/manifest.md`](../../../../quality/evidence/issue-349/2026-11-02-verify/manifest.md)
(PR #353): `frame-time`, `hitch-bound`, and `crash-free` all pass for deliverable
`480e41e`, and `git diff 480e41e` for `game/` is empty in this run.

`llm-judge`: N/A — every rubric axis in
[`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is deterministic, and the domain axis list is empty.
