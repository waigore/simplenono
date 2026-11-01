# Results — issue #94 graphical acceptance

Build `main@6f7264f`, five-shot graphical run, 41 probe checks. Reproduce with
[`manifest.md`](manifest.md) and [`probe/probe_accept_94.gd`](probe/probe_accept_94.gd).

## `UI-gallery` — story row #94

| ID | Check | Observation | Outcome |
|----|-------|-------------|---------|
| US1.1 | `copy.completion` and the bar read `CTR-pack.O2` | `Completed 48 / 200` for 48 ever-completed of 200; rate `0.24` (the 50-of-200 → `0.25` arithmetic is unit-proved in `test_pack_progress.gd`) | **pass** |
| US1.2 | Done tile shows status, best, and the ever-completed read | `#001` → `Done`, `Best 4:13`, Reset offered | **pass** |
| US1.2 | In-progress tile | `#002` → `In progress`, no best (none set), Reset offered | **pass** |
| US1.3 | Never-started tile draws the generic placeholder, no best, no Reset | `#003` → `Not started`, no best, Reset withdrawn, `shows_picture=false` | **pass** |
| US1.4 (render half) | Settings control is drawn and the route exists; the `NAV.T2` transition is #95's | Settings button present; `UI-settings` reachable | **pass** |
| US1.5 (render half) | Tile C1 raises open; the `NAV.T1` transition is #95's | A tile opened its puzzle | **pass** |
| US1.6 | Reset available when ever-completed or in progress | Reset drawn and fired for `#001` (ever-completed) and `#002` (in progress) | **pass** |
| US1.6b | Reset unavailable when not started | On `#003`: not drawn, `activate_reset` returns false, no intent reaches the shell, record unchanged | **pass** |
| S1 | The gallery is the no-puzzle screen | App start lands on the gallery; leaving a puzzle returns to it; 2 columns at 390 px, 4 at 990/1400 px | **pass** |
| R2 layout | The picture region is square and shares the tile width | `picture_aspect = 1.000` at desktop width | **pass** |

## `PTU-gallery-reset` — `J-gallery-reset`

Step table: [`results-reset.md`](results-reset.md). `S1` and `B1` pass; `S2`/`S3` are **not
reachable** and `P1`/`P2` are **partial** because no confirm surface exists in this build.

## Verdict

The gallery-screen and pack serve/clear deliverables **pass**. `PTU-gallery-reset` is
**Waiting**: its confirm legs belong to epic #96, which has not shipped `EX.confirm`. No
interface reason fails a #94 deliverable, so no defect is filed. See
[`failure.md`](failure.md).
