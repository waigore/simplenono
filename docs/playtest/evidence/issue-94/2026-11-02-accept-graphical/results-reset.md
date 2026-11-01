# Results — `PTU-gallery-reset` (`J-gallery-reset`)

Part of [`results.md`](results.md). Build `main@6f7264f`, five-shot graphical run, 41 probe
checks.

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
