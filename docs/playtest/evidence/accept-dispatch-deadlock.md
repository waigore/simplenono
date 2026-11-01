# Acceptance dispatch deadlock (#105, #106, #107, #109)

Why four issued tasks sit permanently on `status:pending-acceptance`, and what unblocks them.
Run records: [`issue-105/2026-11-01-accept-dispatch-hold/`](issue-105/2026-11-01-accept-dispatch-hold/manifest.md),
[`issue-106/2026-11-01-accept-dispatch-deadlock/`](issue-106/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`issue-107/2026-11-01-accept-dispatch-deadlock/`](issue-107/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`issue-109/2026-11-02-accept/`](issue-109/2026-11-02-accept/manifest.md).

## The loop

| Fact | Effect |
|------|--------|
| All four issues (#105, #106, #107, #109) are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one of them. |
| [`evidence.md`](../../../specs/playtest/evidence.md) "Screenshots, logs, notes" requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. `PTD-ready-and-marks`, `PTD-crosses-and-fills`, and `PTD-solve-and-pb` all say "Default evidence rules"; none says none. | No Wave-1 leaf can be accepted. |
| `game/main.tscn` at `main@a8cb9d4` is one bare `Node`; at `main@fa6fe3e` the only first-party scene is the `CMP-shell` text stub (`game/presentation/shell.tscn`). Nothing draws, and there is no `DBG.*` or `TEL.*`. | The screenshots cannot exist from any build that exists today. |
| [`workflow.md`](../../issues/workflow.md) "Transitions and evidence" and `status-transitions.md` "Allowed transitions". | `pending-acceptance` exits only by Accept, Fail (+defect), or Clarify. No edge to `pending-verification` (to widen scope to the shell), no blocked state (to leave the dispatch filter). |

Each accept run must therefore either repeat a comment already on the threads, or state
something the specs do not support. Runs that cannot add anything take the third path: they
record the judgement here and post nothing on the issues. They re-judge no protocol and add
no story or protocol result row.

`#109` differs: it is the first leaf whose own story (`L-solve`) had a protocol
(`PTD-solve-and-pb`) that no run had yet judged, so its `2026-11-02-accept` run did add a
protocol result — at the seam, since S1–S3 need `DBG.3` to enter a near-solve and `DBG.2` to
read the personal best. It is also the cleanest first candidate for a graphical acceptance
once the shell surface lands.

## Unblocking — needs a human

Each is a spec or workflow change an accept agent must not make:

1. **Scope acceptance to the seam.** Add a no-screenshots clause to the design protocols
   for domain-layer tasks, or record a scope note on the issues' acceptance criteria.
2. **Give `pending-acceptance` a real waiting/blocked edge** so a structurally
   un-acceptable issue leaves the dispatch filter instead of being re-picked every run.
3. **Planner re-scopes the acceptance debt** onto the shell and mark-input work
   (#110/#111) and closes the leaves as delivered at their layer.

Until one lands, the orchestrator keeps dispatching #105/#106/#107/#109 to
`issue-workflow-accept-agent`.
