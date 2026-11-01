# Acceptance dispatch deadlock (#105, #106, #107, #109, #111)

Why five tasks sit on `status:pending-acceptance`, and what unblocks them.
Run records: [`#105`](issue-105/2026-11-01-accept-dispatch-hold/manifest.md),
[`#106`](issue-106/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#107`](issue-107/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#109`](issue-109/2026-11-02-accept/manifest.md),
[`#111`](issue-111/2026-11-02-accept/manifest.md).

`#132` left this list on 2026-11-02: its acceptance run found a real behaviour fail on the reopen
path (marks apply during get-set-ready when an in-progress attempt is restored), so it returned to
`status:pending-implementation` with a defect instead of waiting on screenshots. Record:
[`issue-132/2026-11-02-accept-fail`](issue-132/2026-11-02-accept-fail/manifest.md).

## The loop

| Fact | Effect |
|------|--------|
| All five are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one. |
| [`evidence.md`](../../../specs/playtest/evidence.md) requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. `PTD-ready-and-marks`, `PTD-crosses-and-fills`, and `PTD-solve-and-pb` all use the default, so none says none. | No Wave-1 leaf can be accepted. |
| #112 (`f05441c`) routes the shell to `puzzle.tscn`, so a player can open a puzzle and mark cells. `grep` over `game/` finds no `DBG.*` / `TEL.*` seam, and [`verification.md`](../../../specs/technical/verification.md) H1 bars a gate run without S1–S4. | No build can supply the screenshots, even though a screen draws. |
| [`workflow.md`](../../issues/workflow.md) and `status-transitions.md`. | `pending-acceptance` exits only by Accept, Fail (+defect), or Clarify. No blocked edge leaves the dispatch filter. |

Each accept run must therefore repeat a comment already on the threads, state something the
specs do not support, or take the third path: record the judgement here and post nothing.

`#109` differs: its own story (`L-solve`) had an unjudged protocol, `PTD-solve-and-pb`, so its
run added a seam-level result — S1–S3 need `DBG.3` and `DBG.2`. It is the cleanest first
candidate once the shell surface lands.

**2026-11-02 re-check** (`main@2601fee`, suite 132/132): #110 merged a drawn board but changed
none of the above. The run picked `#105` (the pack loader unblocks later leaves) and posted nothing.

**2026-11-02 re-check 2** (`main@881774e`, suite 145/145): the run picked `#111`, the only
unjudged candidate on the screen layer. Every criterion passed at the `CTR-attempt.O2` seam with
two falsification mutations caught ([record](issue-111/2026-11-02-accept/manifest.md)). It found
a second blocker for that issue alone: `IN` is cited only by `PTU-settings`, which never places a
mark and needs the Wave-2 settings screen (#95), so even a seam-complete build could not produce
`IN`'s screenshots.

## Unblocking — needs a human

Each is a spec or workflow change an accept agent must not make:

1. **Scope acceptance to the seam** — a no-screenshots clause for domain-layer tasks, or a
   scope note on the acceptance criteria.
2. **Give `pending-acceptance` a blocked edge** so a structurally un-acceptable issue leaves
   the dispatch filter.
3. **Planner re-scopes the acceptance debt** onto the shell and mark-input work and closes the
   leaves as delivered at their layer.
4. **Give `IN` a protocol that places a mark**, or fix its `Cites`; today `PTU-settings` is the
   only citation and its steps never touch the grid.

Until one lands, the orchestrator keeps dispatching these five issues to
`issue-workflow-accept-agent`.
