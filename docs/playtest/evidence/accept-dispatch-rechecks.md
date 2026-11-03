# Acceptance dispatch re-check log

One line per unattended `issue-workflow-accept-agent` run, oldest first; each ends in an accept
or a hold. Context and the remaining holds: [`accept-dispatch-deadlock.md`](accept-dispatch-deadlock.md).
The earliest ten runs are on [page 1](accept-dispatch-rechecks-1.md).

| Build | Suite | Picked | Outcome |
|-------|-------|--------|---------|
| `dcd9a24` | 142/142 | `#109` | **accepted** graphically — `PTD-solve-and-pb` S1–S3/P1–P3, `PS1.4`/G1/B3, 8 screenshots ([record](issue-109/2026-11-02-accept-graphical/manifest.md)) |
| `43d2064` | 142/142 | `#110` | **accepted** graphically — `UI-puzzle` US1.1–US1.7 on a reopened record, S1/S2/S3, 7 screenshots ([record](issue-110/2026-11-02-accept-graphical/manifest.md)) |
| `3cab7de` | 151/151 | `#163` | **accepted** — S1–S5 behind the one flag; 60-check graphical capture, 5 screenshots; tooling, so no protocol; re-checked on `cd08f79` (170/170) ([record](issue-163/2026-11-02-accept/manifest.md)) |
| `9c8f2b4` | 170/170 | `#91` | **accepted** — bootstrap epic; smoke, GUT/CI, layout and shell substrate all hold ([record](issue-91/2026-11-02-accept/manifest.md)) |
| `52db79a` | 185/185 | `#191` | **accepted** graphically — `PTD-ready-and-marks` S1–S3 re-run, `SND.X1`–`X3`/`M1`/`M2` and `HAP.H1` judged from player state, 6 screenshots ([record](issue-191/2026-11-02-accept-graphical/manifest.md)); found no protocol cites `SND.*`/`HAP.H1` |
| `b1c1285` | 198/198 | `#111` | `IN` US1.6–US1.8 now judged **graphically** — 5 screenshots ([record](issue-111/2026-11-02-accept-graphical/manifest.md)); only the missing `PTU-mark-input` protocol remains (#203) |
| `5e5fe85` | 198/198 | `#112` | open leg now judged **graphically** — gallery start, `S2`/`S1` open, 200/200 ids, 5 screenshots ([record](issue-112/2026-11-02-accept-graphical/manifest.md)); only the deterministic record remains (#204) |
| `a2cdbed` | 198/198 | `#111` | repeat hold — `game/` is identical to `b1c1285`, so the graphical record stands; #203 (`PTU-mark-input`) is still `pending-implementation` with no PR |
| `09c022e` | 215/215 | `#112` | **accepted** graphically — `J-play-puzzle` S1 open leg, 200/200 ids, 5 screenshots on `5e5fe85` (open leg unchanged), plus a deterministic record written for the user-requested run: I7 288.3 ms, I8 7.0 ms, I9 pass ([playtest](issue-112/2026-11-02-accept-graphical/manifest.md), [quality](issue-112/2026-11-02-accept-graphical/quality/manifest.md)) |
| `a0e6e3a` | 218/218 | `#95` | **failed** graphically — `PTU-settings` pass (toggles stick across reopen); `PTU-play-puzzle` P1 and the ever-completed `P2` pass, but `UI-result` `S1 Default` is blank with every layer empty, and both of `pack-000`'s picture ids are absent from `assets/manifest.json`; defect [#218](https://github.com/waigore/simplenono/issues/218), 12 screenshots ([record](issue-95/2026-11-02-accept-graphical/manifest.md)) |
| `ce5a677` | 246/246 | `#224` | **accepted** — typography-only; `PTU-settings` P1/P2 and `PTU-play-puzzle` P1/P2 pass, one family with `tnum` on every screen, T1 half the cell, T2 18/27 px at 720/1080, 30 checks, 12 screenshots ([record](issue-224/2026-11-02-accept-graphical/manifest.md)) |
| `12f2c8f` | — | `#247` | **accepted** graphically — picture slice 058–061: derive byte-identical, judge 1 line-logic solution per puzzle, fills 89/70/57/73 in band; `PTU-play-puzzle` P1–P2, `PTD-crosses-and-fills`, `PTD-solve-and-pb`, `PTU-mark-input` on the shipped rows, 36 checks, 9 screenshots ([record](issue-247/2026-11-03-accept-graphical/manifest.md)) |
| `fb99b16` | 142/142 | `#263` | **accepted** graphically — picture slice 122–125: independent fills 61/84/85/61, one line-logic solution each, derive byte-identical, judge pass; cited the issue's own `deterministic` record at `9053c8c`; `PTU-play-puzzle`, `PTD-ready-and-marks`, `PTD-crosses-and-fills`, `PTD-solve-and-pb`, `PTU-mark-input` through `xvfb-run`, 35 checks, 9 screenshots ([playtest](issue-263/2026-11-03-accept-graphical/manifest.md), [quality cite](../../quality/evidence/issue-263/2026-11-03-accept/manifest.md)) |

Out of this list's order, `#106` was accepted graphically on `269d854`
([record](issue-106/2026-11-02-accept-graphical/manifest.md)). `#111` remains; see the holds note.
