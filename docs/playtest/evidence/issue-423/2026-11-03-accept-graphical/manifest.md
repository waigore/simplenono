# Playtest run — issue #423 (gallery Confirm reset telemetry)

- **Issue:** #423 Gallery Confirm reset emits no telemetry event (TEL.1 / S4) (`type:task`)
- **Run id:** `2026-11-03-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-03
- **Build / session id:** `1161953` (squash merge of PR #431) — session `issue-423-accept`, build id
  `1161953` (Godot 4.7.2.stable.official, Linux, graphical `xvfb-run`, 1152×648, no `--headless`)
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Level:** UX — protocol [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md)
- **Protocol cites:** [`J-gallery-reset`](../../../../../specs/ux/journeys/gallery-reset.md) (N1, S1, S2, B2, N2),
  [`UI-gallery`](../../../../../specs/ux/screens/gallery.md) US1.6, [`EX.confirm`](../../../../../specs/ux/exceptions.md)
  US1.1–US1.3

These deliverables add one S4 `reset` telemetry event to the gallery Confirm path, so playtesting is required.
The intersection of the `full` coverage set with what the change can reach is the gallery reset flow and the
telemetry it records; no other screen or flow changed in the slice.

## Results

| Protocol / item | Level | Result |
|-----------------|-------|--------|
| `PTU-gallery-reset` S1 — `UI-gallery.C2` opens `EX.confirm` | UX | pass |
| `PTU-gallery-reset` S2 / B2 / P1 — Cancel writes nothing and records no `reset` event | UX | pass |
| `PTU-gallery-reset` S3 / P2 — Confirm clears the record, gallery back to Default | UX | pass |
| `PTU-gallery-reset` F1 / F2 | UX | not observed — Cancel left progress intact, Confirm cleared it, Reset was offered and the box appeared |
| AC1 — one real Confirm records exactly one `reset` event with `TEL.1`–`TEL.5` | — | pass |
| AC2 — a Confirm whose O7 is refused (`SEQ reset` B3) records no `reset` event | — | pass |
| AC3 — the debug seam's `reset_puzzle` still records exactly one `reset`, not two | — | pass |
| AC4 — Cancel records nothing; the box's presentation is untouched | — | pass |
| AC5 — no other telemetry event changed | — | pass |
| `PTU-play-puzzle`, `PTU-mark-input`, `PTD-*`, `PTU-leave-resume`, `PTU-settings` | — | N/A — not reached by a reset-telemetry change |

Final line: `probe423: RESULT pass (56 checks, 6 shots)`; 56 `probe423: PASS` lines, 0 failures, exit 0.

## Judged states (all images from this graphical run of this build)

| Path | Protocol / item | What it shows |
|------|-----------------|---------------|
| `screenshots/00-gallery-before-reset.png` | `PTU-gallery-reset` N1, `UI-gallery` US1.6 | Gallery Default; the seeded `pack-000` tile reads `Done · In progress`, `Best 1:00`, Reset offered; rate `Completed 1 / 200` |
| `screenshots/01-confirm-dialog.png` | `PTU-gallery-reset` S1, `EX` US1.1 | `EX.confirm` drawn over the gallery with `copy.reset-title`, Confirm, and Cancel |
| `screenshots/02-gallery-after-cancel.png` | `PTU-gallery-reset` S2 / B2 / P1, `EX` US1.3 | After a pointer click on Cancel: box dismissed, tile still `Done · In progress`, `Best 1:00`, rate `1 / 200` |
| `screenshots/03-gallery-after-confirm.png` | `PTU-gallery-reset` S3 / P2, AC1 | After a pointer click on Confirm: box dismissed, tile `Not started`, no best, Reset no longer offered, rate `0 / 200`; the run's single real-Confirm `reset` event is the `TEL` line above it |
| `screenshots/04-gallery-after-refused-confirm.png` | AC2 / `SEQ reset` B3 | After a Confirm whose O7 was refused: record unchanged, no `reset` event recorded |
| `screenshots/05-gallery-after-seam-reset.png` | AC3 | After `DebugSeams.reset_puzzle("pack-000")`: record cleared, exactly one `reset` event for the seam reset |

## Telemetry (`TEL.1`–`TEL.5`)

Two `TEL event=reset` lines exist in the run log, one per reset that happened, and no other `TEL` action:

```
TEL event=reset time=1793670450.479 session=issue-423-accept build=1161953 story=US1.1 outcome=pass   # real gallery Confirm
TEL event=reset time=1793670452.945 session=issue-423-accept build=1161953 story=US1.1 outcome=pass   # debug-seam reset
```

`SEV level=info event=session-start` / `session-end` lines bracket the run (two shells booted, so two pairs).
No `SEV` error or warning line appears.

## Paths

| Artifact | Path |
|----------|------|
| Notes and per-check judgement | [`notes.md`](notes.md) |
| Reproduce commands | [`reproduce.md`](reproduce.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_accept_423.gd`](probe/probe_accept_423.gd) |
| Capture console: all 56 checks, the `TEL`/`SEV` lines, exit 0 | [`logs/probe-graphical.log`](logs/probe-graphical.log) |
| `DBG.2` state dump after the seam reset | [`logs/state-after-seam-reset.json`](logs/state-after-seam-reset.json) |
| `gdlint`, `gdformat --check`, `spec_lint`, full GUT suite at the build | [`logs/checks.log`](logs/checks.log) |
| `test_shell_open.gd` alone, 21/21 including the four `reset`-telemetry tests | [`logs/gut-shell-open.log`](logs/gut-shell-open.log) |

## Quality evaluator

Deterministic: reused [`docs/quality/evidence/issue-423/2026-11-03-verify/manifest.md`](../../../../quality/evidence/issue-423/2026-11-03-verify/manifest.md)
(`runtime-signals` I11 and `crash-free` I9, both pass). The record's tree is `278717c`; `game/` at this run's
build `1161953` equals it (`git diff 1161953 278717c -- game/` is empty), so the reuse rule holds and
`deterministic` was not re-run. `llm-judge`: N/A — every rubric axis is `deterministic` and the domain axis list
is empty.
