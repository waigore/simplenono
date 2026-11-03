# Playtest run — issue #311 (EX.confirm reset box)

- **Issue:** #311 `EX.confirm` reset box: show, Confirm to O7, Cancel (`type:task`, Wave 2, parent #96)
- **Run id:** `2026-11-02-accept-graphical`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), unattended, 2026-11-02
- **Build / session id:** `6884a36` (merge of PR #320), Godot 4.7.2.stable, session `issue-311-accept-311-graphical`
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md)) · graphical (Xvfb, 1100×844 desktop and 390×844 mobile)
- **Level:** UX (`J-gallery-reset` US1.1–US1.2, protocol [`PTU-gallery-reset`](../../../../../specs/playtest/ux/gallery-reset.md))
- **Mockups:** `MC.gallery-mobile`, `MC.gallery-desktop`, and `MC.gallery-reset` are `approved`; the run uses the shipped gallery and the new `EX.confirm` card/sheet.

## Scope

The issue's playable deliverables add the reset confirm box and its Confirm/Cancel path.
Intersecting the `full` coverage set with the IDs those deliverables can affect gives
`J-gallery-reset` US1.1–US1.2 / `PTU-gallery-reset` S1–S3, P1–P2, plus `UI-gallery` US1.6
and `EX` US1.1–US1.3. No other journey or design story is reachable from this change.

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `J-gallery-reset` US1.1 / `PTU-gallery-reset` S1 | **pass** | C2 on an in-progress + ever-completed puzzle shows `EX.confirm` with `copy.reset-title`, `copy.confirm`, `copy.cancel` |
| `J-gallery-reset` US1.1 / `PTU-gallery-reset` S3 | **pass** | Confirm clears the record through O7, re-reads O1/O2, and returns the gallery to Default |
| `J-gallery-reset` US1.2 / `PTU-gallery-reset` S2 | **pass** | Cancel dismisses the box and writes nothing |
| `PTU-gallery-reset` P1 | **pass** | Cancel leaves ever-completed, in-progress, elapsed, PB, marks, tile, and rate unchanged |
| `PTU-gallery-reset` P2 | **pass** | Confirm clears marks, elapsed, PB, and ever-completed; the tile reads Not started; rate 0 / 200 |
| `PTU-gallery-reset` F1 | **not observed** | Cancel did not wipe progress; Confirm did not leave progress intact |
| `PTU-gallery-reset` F2 | **not observed** | Reset was available and the confirm appeared |
| `UI-gallery` US1.6 | **pass** | Activating C2 on an allowed puzzle shows `EX.confirm` |
| `EX` US1.1–US1.3 | **pass** | Show, Confirm, and Cancel behave as the exception story states |
| Blocking behind the box | **pass** | C1/C2 calls and a real pointer click on the tile behind the box raised nothing |

## Screenshots

| Image | Judged state |
|-------|--------------|
| [`00`](screenshots/00-gallery-reset-available.png) | N1: the tile reads Done · In progress, shows Best 1:00, and offers Reset |
| [`01`](screenshots/01-confirm-dialog.png) | S1: `EX.confirm` card with the reset title, Cancel, and Confirm |
| [`02`](screenshots/02-gallery-after-cancel.png) | US1.2/P1: after Cancel the gallery is unchanged (byte-identical to `00`) |
| [`03`](screenshots/03-confirm-mobile-sheet.png) | S1 at mobile width: the approved bottom-sheet form of `EX.confirm` |
| [`04`](screenshots/04-gallery-after-confirm.png) | US1.1/P2: after Confirm the tile reads Not started, no best, no Reset; rate 0 / 200 |

`00` and `02` are byte-identical (`sha256 3b906a4a…`), which corroborates that Cancel
wrote nothing.

## Paths

| Artifact | Path |
|----------|------|
| Notes and per-check judgement | [`notes.md`](notes.md) |
| Probe (removed from `game/` after the run) | [`probe/probe_accept_311.gd`](probe/probe_accept_311.gd) |
| Capture console, 45/45 checks, exit 0, with `session-start` / `session-end` lines | [`logs/probe-graphical.log`](logs/probe-graphical.log) |

## Quality evaluator

Deterministic: covered by [`docs/quality/evidence/issue-311/2026-11-02-verify/manifest.md`](../../../../quality/evidence/issue-311/2026-11-02-verify/manifest.md)
(`game/` at `99dcd4e` equals `game/` at `6884a36`; `git diff 99dcd4e 6884a36 -- game/` is empty).
`llm-judge`: N/A — every rubric axis is deterministic and the domain axis list is empty.
