# Acceptance dispatch holds (#109, #111, #112)

Why these sit on `status:pending-acceptance`. Full re-check log:
[`accept-dispatch-rechecks.md`](accept-dispatch-rechecks.md).

## The loop

| Fact | Effect |
|------|--------|
| All are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one. |
| [`evidence.md`](../../../specs/playtest/evidence.md) requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. | Each leaf needs one graphical re-run before it can be accepted. |
| `#112` (`f05441c`) routes the shell to `puzzle.tscn`; `#169` (`3f402fe`) adds `DBG.*` / `TEL.*` S1–S5, the [`verification.md`](../../../specs/technical/verification.md) H1 precondition. | A graphical run is possible; `#156`, `#105`, `#132`, `#107`, `#106`, and `#108` used it. |
| C6's settings routing (#96) and the gallery/result screens (#94/#95) are absent. | Protocols needing them are judged at the seam. |
| [`workflow.md`](../../issues/workflow.md). | `pending-acceptance` exits only by Accept, Fail (+defect), or Clarify. |

## Why each still sits here

- **`#109`** — its story (`L-solve`) owns `PTD-solve-and-pb`, which was judged headless at the seam
  ([record](issue-109/2026-11-02-accept/manifest.md)), before any graphical path existed. It needs
  the graphical re-run, not a new judgement.
- **`#111`** — marked input passes at the `CTR-attempt` O2 seam
  ([record](issue-111/2026-11-02-accept/manifest.md)), but `IN` is cited only by `PTU-settings`,
  which never places a mark. Even a seam-complete build has no protocol that photographs a mark
  transition for `IN`.
- **`#112`** — all 200 ids open at the seam
  ([record](issue-112/2026-11-02-accept/manifest.md)); two Applies deterministic axes
  (`response-delay`, `transition-latency`) can move and no `issue-112` record exists for the commit.

## Unblocking — what is left

Each is a spec or workflow change an accept agent must not make:

1. **Fix where the deterministic record comes from.** Only verify may run `deterministic` mode, so
   a verify that defers an axis to acceptance leaves acceptance no legal way to produce it (#112).
2. **Give `IN` a protocol that places a mark**, or fix its `Cites` (#111).

`#96` will still route C6 to pause and add the S3 pause chrome. Everything else was closed by the
S1–S5 seams and the graphical runs logged in
[`accept-dispatch-rechecks.md`](accept-dispatch-rechecks.md).
