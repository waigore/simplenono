# Acceptance dispatch deadlock (#105, #106, #107)

Why three issued tasks sit permanently on `status:pending-acceptance`, and what unblocks them.
Run records: [`issue-105/2026-11-01-accept-dispatch-hold/`](issue-105/2026-11-01-accept-dispatch-hold/manifest.md),
[`issue-106/2026-11-01-accept-dispatch-deadlock/`](issue-106/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`issue-107/2026-11-01-accept-dispatch-deadlock/`](issue-107/2026-11-01-accept-dispatch-deadlock/manifest.md).

## The loop

| Fact | Effect |
|------|--------|
| All three issues (#105, #106, #107) are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one of them. |
| [`evidence.md`](../../../specs/playtest/evidence.md) "Screenshots, logs, notes" requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. | `PTD-ready-and-marks` and `PTD-crosses-and-fills` both say "Default evidence rules"; neither says none. |
| `game/main.tscn` at `main@a8cb9d4` is one bare `Node`; `game/presentation/` is empty. | No board, no clue drawing, no `DBG` surface, no `TEL`. The screenshots cannot exist from any build that exists today. |
| [`workflow.md`](../../issues/workflow.md) "Transitions and evidence" and `status-transitions.md` "Allowed transitions". | `pending-acceptance` exits only by Accept, Fail (+defect), or Clarify. No edge to `pending-verification` (to widen scope to the shell), no blocked state (to leave the dispatch filter). |

Each accept run must therefore either repeat a comment already on the threads, or state
something the specs do not support. The `2026-11-01-accept-dispatch-deadlock` (#106, #107) and
`issue-105/2026-11-01-accept-dispatch-hold` (#105) runs take the third path: they record the
judgement here and post nothing on the issues. They re-judge no protocol and add no story or
protocol result row.

## Unblocking — needs a human

Each is a spec or workflow change an accept agent must not make:

1. **Scope acceptance to the seam.** Add a no-screenshots clause to the two design protocols
   for domain-layer tasks, or record a scope note on the issues' acceptance criteria.
2. **Give `pending-acceptance` a real waiting/blocked edge** so a structurally
   un-acceptable issue leaves the dispatch filter instead of being re-picked every run.
3. **Planner re-scopes the acceptance debt** onto the shell and mark-input work
   (#110/#111) and closes the leaves as delivered at their layer.

Until one lands, the orchestrator keeps dispatching #105/#106/#107 to
`issue-workflow-accept-agent`.
