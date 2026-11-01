# Acceptance dispatch deadlock (#105, #106, #107, #108, #109, #111, #112)

Why seven tasks sit on `status:pending-acceptance`, and what unblocks them.
Run records: [`#105`](issue-105/2026-11-01-accept-dispatch-hold/manifest.md),
[`#106`](issue-106/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#107`](issue-107/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#109`](issue-109/2026-11-02-accept/manifest.md),
[`#111`](issue-111/2026-11-02-accept/manifest.md),
[`#112`](issue-112/2026-11-02-accept/manifest.md). `#108` has had no run yet.

`#132` left this list on 2026-11-02: its run found a real fail on the reopen path and returned it
to `status:pending-implementation` with a defect
([record](issue-132/2026-11-02-accept-fail/manifest.md)).

## The loop

| Fact | Effect |
|------|--------|
| All are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one. |
| [`evidence.md`](../../../specs/playtest/evidence.md) requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. The `PTD` protocols all use the default. | No Wave-1 leaf can be accepted. |
| #112 (`f05441c`) routes the shell to `puzzle.tscn`, so a player can open a puzzle and mark cells. `grep` over `game/` finds no `DBG.*` / `TEL.*` seam, and [`verification.md`](../../../specs/technical/verification.md) H1 bars a gate run without S1–S4. | No build can supply the screenshots, even though a screen draws. |
| [`workflow.md`](../../issues/workflow.md). | `pending-acceptance` exits only by Accept, Fail (+defect), or Clarify. No blocked edge leaves the filter. |

Each run must therefore repeat a comment already on the threads, state something the specs do not
support, or record the judgement here and post nothing.

`#109` differs: its story (`L-solve`) had an unjudged protocol, `PTD-solve-and-pb`; its run added
a seam-level result — S1–S3 need `DBG.3` and `DBG.2`.

## Re-checks

- **`2601fee` (suite 132/132):** #110 merged a drawn board, nothing else moved. Picked `#105`,
  posted nothing.
- **`881774e` (145/145):** picked `#111`, the only unjudged screen-layer candidate; all criteria
  passed at the `CTR-attempt.O2` seam ([record](issue-111/2026-11-02-accept/manifest.md)). Found
  that `IN` is cited only by `PTU-settings`, which never places a mark.
- **`b290095` (120/120):** picked `#112`, the only unjudged candidate. All 200 shipped ids opened
  in reverse pack order with B1 and E3 judged
  ([record](issue-112/2026-11-02-accept/manifest.md)). It found a second blocker: two Applies
  deterministic axes can move (`response-delay` for "open puzzle", `transition-latency` for the
  shell → puzzle swap) and `docs/quality/evidence/` holds no `issue-112` record. `#108` is the
  last unjudged candidate.

## Unblocking — needs a human

Each is a spec or workflow change an accept agent must not make:

1. **Scope acceptance to the seam** — a no-screenshots clause for domain-layer tasks.
2. **Give `pending-acceptance` a blocked edge** so an un-acceptable issue leaves the filter.
3. **Planner re-scopes the acceptance debt** onto shell and mark-input work.
4. **Give `IN` a protocol that places a mark**, or fix its `Cites`.
5. **Fix where the deterministic record comes from.** Only verify may run `deterministic` mode, so
   a verify that defers an axis to acceptance leaves acceptance no legal way to produce it (#112).

Until one lands, the orchestrator keeps dispatching these issues.
