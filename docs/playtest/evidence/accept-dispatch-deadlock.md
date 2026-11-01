# Acceptance dispatch deadlock (#105, #106, #107, #109)

Why four tasks sit on `status:pending-acceptance`, and what unblocks them.
Run records: [`#105`](issue-105/2026-11-01-accept-dispatch-hold/manifest.md),
[`#106`](issue-106/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#107`](issue-107/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#109`](issue-109/2026-11-02-accept/manifest.md).

`#132` left this list on 2026-11-02: its acceptance run found a real behaviour fail on the reopen
path (marks apply during get-set-ready when an in-progress attempt is restored), so it returned to
`status:pending-implementation` with a defect instead of waiting on screenshots. Record:
[`issue-132/2026-11-02-accept-fail`](issue-132/2026-11-02-accept-fail/manifest.md).

## The loop

| Fact | Effect |
|------|--------|
| All four are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one. |
| [`evidence.md`](../../../specs/playtest/evidence.md) requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. `PTD-ready-and-marks`, `PTD-crosses-and-fills`, and `PTD-solve-and-pb` all use the default, so none says none. | No Wave-1 leaf can be accepted. |
| `run/main_scene` is the `CMP-shell` text stub. #110 (merged `2601fee`) adds `puzzle.tscn`, which draws a board, but nothing routes to it and no `DBG.*` / `TEL.*` seam exists; [`verification.md`](../../../specs/technical/verification.md) H1 bars a gate run without S1–S4. | The screenshots cannot exist from any build. |
| [`workflow.md`](../../issues/workflow.md) and `status-transitions.md`. | `pending-acceptance` exits only by Accept, Fail (+defect), or Clarify. No blocked edge leaves the dispatch filter. |

Each accept run must therefore repeat a comment already on the threads, state something the
specs do not support, or take the third path: record the judgement here and post nothing.
That path re-judges no protocol and adds no result row.

`#109` differs: its own story (`L-solve`) had an unjudged protocol, `PTD-solve-and-pb`, so its
`2026-11-02-accept` run added a seam-level result — S1–S3 need `DBG.3` for a near-solve and
`DBG.2` for the personal best. It is the cleanest first candidate once the shell surface lands.

`#132` was in this list until 2026-11-02. Its final run judged `PTD-ready-and-marks` on the screen
build and triggered F1 on the reopen path (a persisted in-progress attempt keeps marks allowed
through get-set-ready), which is a behaviour fail rather than an evidence hold.

**2026-11-02 re-check** (on `main@2601fee`, shipped suite 132/132): #110 merged a drawn board
but changed none of the above. The run picked `#105` (priority tie; the pack loader unblocks
later Wave-1 leaves) and posted nothing.

## Unblocking — needs a human

Each is a spec or workflow change an accept agent must not make:

1. **Scope acceptance to the seam.** Add a no-screenshots clause to the design protocols
   for domain-layer tasks, or record a scope note on the issues' acceptance criteria.
2. **Give `pending-acceptance` a real waiting/blocked edge** so a structurally
   un-acceptable issue leaves the dispatch filter instead of being re-picked every run.
3. **Planner re-scopes the acceptance debt** onto the shell and mark-input work
   (#110 merged, #111 open) and closes the leaves as delivered at their layer.

Until one lands, the orchestrator keeps dispatching these four issues to
`issue-workflow-accept-agent`.
