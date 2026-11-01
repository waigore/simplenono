# Playtest run — issue #105 (second acceptance dispatch hold)

- **Issue:** #105 Pack data & loader per ADR-0004 (`type:task`, parent #93 Core solve loop vertical)
- **Run id:** `2026-11-01-accept-dispatch-hold`
- **Runner:** `issue-workflow-accept-agent` (parallel id 1, dispatched worktree), 2026-11-01
- **Build / session id:** `main@a8cb9d4`. No `TEL.3` session id exists — telemetry is unimplemented.
- **Coverage mode:** `full` ([`coverage.md`](../../../../../specs/playtest/coverage.md))
- **Run type:** headless (no display)

## Why this folder exists

The prior run [`2026-11-01-accept`](../2026-11-01-accept/manifest.md) judged every in-scope
acceptance criterion and `E-puzzle` PS1.1 pass and is held only for graphical screenshots it
cannot produce. This second dispatch re-picks the same issue and finds **nothing new to
decide**: the judged build is byte-identical, no spec or workflow change has landed, and no
screenshot exists. Posting the same hold comment again would only repeat the thread.

Per [`procedures.md`](../../../../../specs/playtest/procedures.md) "a headless run may enter,
drive, observe, and judge … and marks screenshots as waiting on a graphical run", and per
[`evidence.md`](../../../../../specs/playtest/evidence.md) that omission is not a fail and
files no defect. Per the accept skill's "Waiting on screenshots" outcome the issue stays
`status:pending-acceptance`. So this run **posts nothing on the issue and changes no status**.

This folder is locatable evidence of the re-check, not an acceptance record.

## Re-check performed

| Check | Result |
|-------|--------|
| Judged build unchanged | `git diff --stat 4c8d1e5 HEAD -- game` is empty — the code under acceptance is still PR #124's merge |
| No spec change since the prior run | `git diff --stat a8cb9d4~1 HEAD -- specs docs/issues` is empty |
| Shipped pack | `python3 .github/scripts/generate_pack.py --check` → `pack.json is current` |
| Independent pack audit | 200 entries (`10: 10`, `15: 170`, `20: 20`); **0 invalid** ([`recheck-notes.md`](recheck-notes.md)) |
| GUT seam S6 on this build | 4 scripts, **52/52 pass, exit 0**, 27842 asserts ([`logs/gut-hold.log`](logs/gut-hold.log)) |
| Graphical surface | `game/main.tscn` is still one bare `Node`; `game/presentation/` is still empty |

## Results

| Story or protocol | Outcome | Note |
|-------------------|---------|------|
| `E-puzzle` / `PTD-ready-and-marks` — PS1.1 pack properties | pass at the delivered layer (carried forward) | [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md) |
| `E-puzzle` — PS1.2–PS1.5 | not judged — owned by #108/#109/#110/#111 | [`../2026-11-01-accept/playtest-gap.md`](../2026-11-01-accept/playtest-gap.md) |
| Graphical re-run | **still waiting** | no scene draws a board, clue lines, or a debug surface |

## Paths

| Artifact | Path | State |
|----------|------|-------|
| Prior judgement | [`../2026-11-01-accept/notes.md`](../2026-11-01-accept/notes.md) | present, unchanged |
| Prior manifest | [`../2026-11-01-accept/manifest.md`](../2026-11-01-accept/manifest.md) | present, unchanged |
| Playtest gap (four unblocking options) | [`../2026-11-01-accept/playtest-gap.md`](../2026-11-01-accept/playtest-gap.md) | present, unchanged |
| Audit and environment notes | [`recheck-notes.md`](recheck-notes.md) | present |
| Log — GUT suite re-run on this build | [`logs/gut-hold.log`](logs/gut-hold.log) | present |
| Screenshot — `E-puzzle` PS1.1 judged state | `screenshots/open-10-15-20.png` | **waiting on a graphical re-run of the same build** |
| Screenshot — `PTD-ready-and-marks` judged state | `screenshots/ready-and-marks.png` | **waiting on a graphical re-run of the same build** |
