# Acceptance run — issue #127 (accept)

- **Issue:** #127 GDScript lint/format tooling for Code lint (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-02-accept`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-02
- **Build / session id:** `main@1fa6659`, containing the deliverable `c864c6b` (PR #146). No `TEL.3` session id exists — telemetry is unimplemented on this build, and this deliverable adds none.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless, local reproduction of the `Code lint` commands
- **Under acceptance:** gdtoolkit lint/format tooling from PR #146, merged as `c864c6b`

## Scope

**No playtest protocols are in scope.** Per [`playtest.md`](../../../../../specs/playtest/playtest.md), a run is required only when deliverables change playable behaviour; this is CI tooling plus a formatting pass over existing sources. The merge's `game/` diff was inspected to confirm it is declaration reordering and line wrapping only, with no behavioural change.

The criteria judged are the five acceptance criteria in the issue body, against [`criteria.md`](criteria.md).

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| Playtest protocols | **not applicable** | Tooling/CI deliverable; no playable behaviour changes, so the gate does not apply and no screenshots are required |
| AC 1 — no placeholders, `CC-<n>` with level | **pass** | `CC-1`, `CC-2`, both `must`; no `fill in` remains |
| AC 2a — command in Tooling table and workflow | **pass** | `gdformat --check game`, `gdlint game`, same pin `gdtoolkit==4.5.0` |
| AC 2b — `Code lint` fails on a deliberate violation | **pass** | Both steps exit 1 on a bad function; proved, then reverted |
| AC 3 — `Code lint` passes on the current tree | **pass** | 28 files unchanged, `gdlint` clean, exit 0 |
| AC 4 — `pocs/` excluded | **pass** | Same violation invisible under `pocs/` via the CI command, caught when run directly |
| AC 5 — no-tool branch | **N/A** | A tool was chosen; ADR-0007 is `Accepted` |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Notes | [`notes.md`](notes.md) | present |
| Criteria | [`criteria.md`](criteria.md) | present |
| Tool versions | [`logs/tool-versions.log`](logs/tool-versions.log) | `gdlint 4.5.0`, `gdformat 4.5.0` |
| Tree clean | [`logs/tree-clean.log`](logs/tree-clean.log) | 28 files, exit 0 on both |
| Deliberate violation detected | [`logs/violation-detected.log`](logs/violation-detected.log) | both exit 1 |
| Violation reverted | [`logs/violation-reverted.log`](logs/violation-reverted.log) | clean again, exit 0 |
| `pocs/` exclusion | [`logs/pocs-excluded.log`](logs/pocs-excluded.log) | probe ignored by CI command, caught directly |
| Screenshots | — | not required: no playable behaviour |

No `screenshots/` folder exists because no protocol requires one; [`evidence.md`](../../../../../specs/playtest/evidence.md) exempts this case from the graphical-run rule.
