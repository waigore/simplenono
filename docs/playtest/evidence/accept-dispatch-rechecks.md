# Acceptance dispatch re-check log

One line per unattended `issue-workflow-accept-agent` run, oldest first; each ends in an accept
or a hold. Context and the remaining holds: [`accept-dispatch-deadlock.md`](accept-dispatch-deadlock.md).

| Build | Suite | Picked | Outcome |
|-------|-------|--------|---------|
| `2601fee` | 132/132 | `#105` | `#110` drew the board; posted nothing |
| `881774e` | 145/145 | `#111` | passed at `CTR-attempt` O2 ([record](issue-111/2026-11-02-accept/manifest.md)); found `IN` is cited only by `PTU-settings` |
| `b290095` | 120/120 | `#112` | all 200 ids opened at the seam; two Applies deterministic axes can move and no `issue-112` record exists ([record](issue-112/2026-11-02-accept/manifest.md)) |
| `59872bd` | 123/123 | `#156` | only the screenshots gate remained ([record](issue-156/2026-11-02-accept/manifest.md)) |
| `3f402fe` | 139/139 | `#156` | **accepted** graphically — `PTD-ready-and-marks` S1–S4, US1.7 ([record](issue-156/2026-11-02-accept-graphical/manifest.md)) |
| `67e36f5` | 125/125 | `#108` | `PS1.1`–`PS1.7` passed at the seam; screenshots remained ([record](issue-108/2026-11-02-accept/manifest.md)) |
| `effca0a` | 139/139 | `#105` | **accepted** graphically — one puzzle per size, every clue bar matched ([record](issue-105/2026-11-02-accept-graphical/manifest.md)) |
| `859d834` | 139/139 | `#132` | **accepted** graphically — S1–S4/P1–P3, US1.7, the #156 reopen path ([record](issue-132/2026-11-02-accept-graphical/manifest.md)) |
| `c0b053d` | — | `#107` | **accepted** graphically — `E-clue` P1–P3 re-judged on `aff969b`, 4 screenshots ([record](issue-107/2026-11-02-accept-graphical/manifest.md)) |
| `1015ee9` | 139/139 | `#108` | **accepted** graphically — `PTD-ready-and-marks` S1–S3/P2 and the `GS` clauses, 5 screenshots ([record](issue-108/2026-11-02-accept-graphical/manifest.md)) |

Earlier, out of this list's order: `#106` was accepted graphically on `269d854`
([record](issue-106/2026-11-02-accept-graphical/manifest.md)).

`#109`, `#111`, and `#112` remain; see the holds note.
