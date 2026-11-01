# Judgement — issue 107

Per-clause outcome for the run described in [`notes.md`](notes.md). Owner row:
`E-clue`. No clause this deliverable can decide failed.

| Protocol | Clause | Outcome |
|---|---|---|
| `PTD-ready-and-marks` | P2 — empty-clue lines auto-cross still-clear cells after ready | **Not judgeable at this layer.** Auto-cross is `CMP-rules` R3 / `#108`; this mapper only exposes which lines are empty. The fixture does have 7 all-empty rows and 4 all-empty columns, so the premise is exercised, but the auto-cross action itself is not delivered here. |
| `PTD-ready-and-marks` | P1, P3, F1, F2 | **Out of scope** — mark transitions (`E-cell`, `#106`), pause (`IN.pause`, `#111`), solve state (`GS`, `#108`), and screen (`UI-puzzle`, `#110`). |
| `PTD-crosses-and-fills` | P1, P2, F1, F2 | **Out of scope** — all of it is the `GS.is-solved` solve check (`#108`). `E-clue` is cited only because the line runs are the input to that check. |
