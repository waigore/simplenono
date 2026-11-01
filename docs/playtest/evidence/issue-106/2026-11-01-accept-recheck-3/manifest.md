# Acceptance re-check 3 — #106 Cell mark semantics

| Field | Content |
|-------|---------|
| Issue | #106 |
| Build / session id | `main@0115f68` (detached clean worktree; Godot 4.7.2) |
| Coverage mode | `full` |
| Scope | `E-cell` (owner) ∪ protocols citing it: `PTD-ready-and-marks`, `PTD-crosses-and-fills` |
| Run type | Headless — **screenshots waiting on a graphical run** |

## Results

| Story / protocol | Outcome | Note |
|---|---|---|
| `E-cell` (PS1.1–PS1.5, I1, I4, I5) | pass (delivered layer) | value-object layer only |
| `PTD-ready-and-marks` | pass at delivered layer; screen steps unjudged | S1/S2/S4 need `UI-puzzle.C2`–`C6`, `DBG.2`, `DBG.3`, `IN.pause` |
| `PTD-crosses-and-fills` | pass at delivered layer; screen steps unjudged | S1/S3 need `DBG.3`, `DBG.2`, result screen |

## Paths

- `logs/gut-recheck.log` — full suite at `0115f68`
- `logs/gut-mutation-marks-allowed.log` — falsification: mark gate removed
- `logs/gut-mutation-cross-as-fill.log` — falsification: crosses counted as fills
- `notes.md` — judgement text
- `screenshots/` — **waiting on a graphical run** (`ready-and-marks.png`, `crosses-and-fills.png`)

## Screenshot status

Both protocols say "Default evidence rules" and require ≥1 image of the judged state from a
graphical run of this same build. No first-party code at `0115f68` draws a board or exposes
`DBG.2`/`DBG.3`; the only scene is the `CMP-shell` text stub (`game/presentation/shell.tscn`).
Paths are marked waiting, per [`evidence.md`](../../../../specs/playtest/evidence.md).
