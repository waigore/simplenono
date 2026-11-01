# Acceptance dispatch holds (#105, #106, #107, #108, #109, #111, #112)

Why these issues sit on `status:pending-acceptance`, and what unblocks them.
Run records: [`#105`](issue-105/2026-11-01-accept-dispatch-hold/manifest.md),
[`#106`](issue-106/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#107`](issue-107/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#109`](issue-109/2026-11-02-accept/manifest.md),
[`#111`](issue-111/2026-11-02-accept/manifest.md),
[`#112`](issue-112/2026-11-02-accept/manifest.md).

Two issues left the filter on 2026-11-02:

- `#132`: its run found a real fail on the reopen path and returned it to
  `status:pending-implementation` with a defect
  ([record](issue-132/2026-11-02-accept-fail/manifest.md)).
- `#156`: `#169` (`3f402fe`) supplied the S1–S5 seams, and its graphical re-run accepted it
  ([record](issue-156/2026-11-02-accept-graphical/manifest.md)). This is the first acceptance with
  real screenshots.

## The loop

| Fact | Effect |
|------|--------|
| All are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one. |
| [`evidence.md`](../../../specs/playtest/evidence.md) requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. | Each leaf needs one graphical re-run before it can be accepted. |
| #112 (`f05441c`) routes the shell to `puzzle.tscn`; `#169` (`3f402fe`) adds `DBG.*` / `TEL.*` S1–S5, the [`verification.md`](../../../specs/technical/verification.md) H1 precondition. | A run can now supply screenshots; #156 proved the path. |
| C6's settings routing (#96) and the gallery/result screens (#94/#95) are absent. | Protocols needing those player paths are judged at the seam, with the drive path declared. |
| [`workflow.md`](../../issues/workflow.md). | `pending-acceptance` exits only by Accept, Fail (+defect), or Clarify. |

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
  ([record](issue-112/2026-11-02-accept/manifest.md)). Found a second blocker: two Applies
  deterministic axes can move (`response-delay`, `transition-latency`) and
  `docs/quality/evidence/` holds no `issue-112` record. `#108` is the last unjudged candidate.
- **`59872bd` (123/123):** picked `#156`, the only unjudged defect. Every criterion passed at the
  seam, including the reopen path the #132 run found; only the screenshots gate remained
  ([record](issue-156/2026-11-02-accept/manifest.md)).
- **`3f402fe` (139/139):** picked `#156` again now that `#169` supplies S1–S5. The graphical re-run
  passed `PTD-ready-and-marks` S1–S4 and US1.7 and accepted it with 8 screenshots
  ([record](issue-156/2026-11-02-accept-graphical/manifest.md)).

## Unblocking — what is left

Each is a spec or workflow change an accept agent must not make:

1. **Fix where the deterministic record comes from.** Only verify may run `deterministic` mode, so
   a verify that defers an axis to acceptance leaves acceptance no legal way to produce it (#112).
2. **Give `IN` a protocol that places a mark**, or fix its `Cites` (#111).
3. **Route C6 to pause** (#96) so `PTD-ready-and-marks` S4 needs no seam drive path, and add the
   S3 pause chrome the evidence image cannot show.

The S1–S5 seams made these unnecessary: scoping acceptance to the seam, a blocked edge out of
`pending-acceptance`, and re-scoping the acceptance debt.
