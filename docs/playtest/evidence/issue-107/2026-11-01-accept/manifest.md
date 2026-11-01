# Playtest evidence — issue 107

| Field | Value |
|---|---|
| Issue | #107 — Clue line derivation |
| Build / session id | `main@ed9e33b` (squash of PR #121). No `TEL.3` session id exists on this build; telemetry is not delivered. |
| Coverage mode | `full`, intersected to `E-clue` and the protocols that cite it |
| Run id | `2026-11-01-accept` |
| Mode | Headless (no graphical surface on this build) |

## Results

| Story / protocol | Outcome | Note |
|---|---|---|
| `E-clue` | pass at the delivered layer | 15 + 15 lines, indices `0…14`, runs verbatim from F3/F4, empty lists kept as zero runs, F3/F4 count mismatch is a mapping error |
| `PTD-ready-and-marks` P2 (empty-clue auto-cross) | N/A at this layer | auto-cross is `CMP-rules` R3 / #108; fixture does have 7 empty rows and 4 empty columns |
| `PTD-ready-and-marks` P1 / P3 | out of scope | needs `E-cell` marks (#106), pause (`IN.pause`, #111), `GS` (#108), `UI-puzzle` (#110) |
| `PTD-crosses-and-fills` P1 / P2 | out of scope | solve checking is `GS.is-solved` (#108) |
| `PTD-ready-and-marks` F1 / F2 | not observed to fail | out of scope at this layer |
| `PTD-crosses-and-fills` F1 / F2 | not observed to fail | out of scope at this layer |

## Paths

| Artifact | Path |
|---|---|
| Notes | [`notes.md`](notes.md) |
| Test log | [`logs/gut-accept.log`](logs/gut-accept.log) |
| Screenshot — `ready-and-marks` | `screenshots/ready-and-marks.png` — **waiting on a graphical run** (no judged state is drawable on this build) |
| Screenshot — `crosses-and-fills` | `screenshots/crosses-and-fills.png` — **waiting on a graphical run** (same reason) |

## Test run

```
godot --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit
```

`Scripts 3`, `Tests 33`, `Passing Tests 33`, `Asserts 642`, exit `0`
(Godot `4.7.2.stable.official`, the CI version). The `Scripts 3` count guards
against a test script being silently skipped by GUT.

## Folders not included

`screenshots/` is absent by design: this is a headless run and the build has no
scene that draws the clue lines, so a graphical re-run of this build cannot
produce a judged state either. Per
[`evidence.md`](../../../evidence.md), that omission is not a protocol fail and
files no defect.
