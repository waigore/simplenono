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

| Step | Check | Observation | Outcome |
|------|-------|-------------|---------|
| S1 | C2 on an ever-completed puzzle raises the intent | `#000` fired; the intent reached `CMP-shell`; the gallery stayed Default; nothing was cleared | **pass** |
| B1 | C2 refused on a not-started puzzle | No intent reached the shell; the record was unchanged | **pass** |
| S2 | Choose Cancel on `EX.confirm` | No confirm surface in this build — `EX.confirm` is #96's | **not reachable** |
| S3 | Reset again; Confirm | Same surface missing | **not reachable** |
| P1 | Cancel leaves progress unchanged | Cannot be judged through the surface; the never-wipe half (S1 hand-off clears nothing) **holds** | **partial** |
| P2 | Confirm clears marks, elapsed, PB, ever-completed; gallery returns to Default | Not reachable through the surface. The clear + refresh this epic owns was observed through `CTR-pack.O7` + S5: `#000` returned to `Not started`, its Best was gone, Reset was withdrawn, and the count fell to `Completed 47 / 200`; leaving a puzzle re-read `O1`/`O2` the same way | **partial — `O7`/S5 half pass, confirm half not reachable** |
| F1 | Cancel still wipes, or Confirm leaves progress intact | Did not occur on the reachable legs (nothing wipes without a Confirm) | — |
| F2 | Reset unavailable when ever-completed / in progress, or confirm never appears | The first clause did **not** occur (US1.6 passes); "confirm never appears" is true of this build but for #96's boundary, not an interface defect in #94 | — |

## Verdict

The gallery-screen and pack serve/clear deliverables **pass**. `PTU-gallery-reset` is
**Waiting**: its confirm legs belong to epic #96, which has not shipped `EX.confirm`. No
interface reason fails a #94 deliverable, so no defect is filed. See
[`failure.md`](failure.md).
