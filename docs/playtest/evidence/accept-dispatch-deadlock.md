# Acceptance dispatch holds (#107, #108, #109, #111, #112)

Why these sit on `status:pending-acceptance`.
Run records:
[`#107`](issue-107/2026-11-01-accept-dispatch-deadlock/manifest.md),
[`#109`](issue-109/2026-11-02-accept/manifest.md),
[`#111`](issue-111/2026-11-02-accept/manifest.md),
[`#112`](issue-112/2026-11-02-accept/manifest.md),
[`#108`](issue-108/2026-11-02-accept/manifest.md).

Four left the filter on 2026-11-02. `#106` was accepted graphically
([record](issue-106/2026-11-02-accept-graphical/manifest.md)). `#105` got a screen state for its
`E-puzzle` PS1.1 claim once `#169`'s seams and `#110`'s board landed, and its graphical re-run accepted
it with 8 screenshots ([record](issue-105/2026-11-02-accept-graphical/manifest.md)).
- `#132`: its first run found a reopen-path fail and returned it to
  `status:pending-implementation` with a defect
  ([record](issue-132/2026-11-02-accept-fail/manifest.md)); after the #160 repair and a verify Pass,
  the graphical re-run accepted it with 8 screenshots
  ([record](issue-132/2026-11-02-accept-graphical/manifest.md)).
- `#156`: `#169` (`3f402fe`) supplied the S1–S5 seams, and its graphical re-run accepted it
  ([record](issue-156/2026-11-02-accept-graphical/manifest.md)).

## The loop

| Fact | Effect |
|------|--------|
| All are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one. |
| [`evidence.md`](../../../specs/playtest/evidence.md) requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. | Each leaf needs one graphical re-run before it can be accepted. |
| #112 (`f05441c`) routes the shell to `puzzle.tscn`; `#169` (`3f402fe`) adds `DBG.*` / `TEL.*` S1–S5, the [`verification.md`](../../../specs/technical/verification.md) H1 precondition. | A run can now supply screenshots; #156 and #105 proved the path. |
| C6's settings routing (#96) and the gallery/result screens (#94/#95) are absent. | Protocols needing them are judged at the seam. |
| [`workflow.md`](../../issues/workflow.md). | `pending-acceptance` exits only by Accept, Fail (+defect), or Clarify. |

`#109` differs: its story (`L-solve`) had an unjudged protocol, `PTD-solve-and-pb`; its run added
a seam-level result — S1–S3 need `DBG.3` and `DBG.2`.

## Re-checks

- **`2601fee` (132/132):** `#110` drew the board; picked `#105`, posted nothing.
- **`881774e` (145/145):** picked `#111`, the only screen-layer candidate; passed at `CTR-attempt` O2
  ([record](issue-111/2026-11-02-accept/manifest.md)). Found that `IN` is cited only by
  `PTU-settings`, which never places a mark.
- **`b290095` (120/120):** picked `#112`; all 200 ids opened at the seam, but two Applies
  deterministic axes can move and no `issue-112` record exists
  ([record](issue-112/2026-11-02-accept/manifest.md)).
- **`59872bd` (123/123):** picked `#156`; only the screenshots gate remained
  ([record](issue-156/2026-11-02-accept/manifest.md)).
- **`3f402fe` (139/139):** accepted `#156` graphically — S1–S4 and US1.7
  ([record](issue-156/2026-11-02-accept-graphical/manifest.md)).
- **`67e36f5` (125/125):** picked `#108`; `PS1.1`–`PS1.7` passed at the seam, screenshots remain
  ([record](issue-108/2026-11-02-accept/manifest.md)).
- **`effca0a` (139/139):** accepted `#105`, the pack every later task reads
  ([record](issue-105/2026-11-02-accept-graphical/manifest.md)).
- **`859d834` (139/139):** accepted `#132`, the ready edge behind `puzzle.tscn` — S1–S4/P1–P3, US1.7,
  the #156 reopen path ([record](issue-132/2026-11-02-accept-graphical/manifest.md)). `#108` is the last
  candidate with no graphical run.

## Unblocking — what is left

Each is a spec or workflow change an accept agent must not make:

1. **Fix where the deterministic record comes from.** Only verify may run `deterministic` mode, so
   a verify that defers an axis to acceptance leaves acceptance no legal way to produce it (#112).
2. **Give `IN` a protocol that places a mark**, or fix its `Cites` (#111).

The S1–S5 seams made the rest unnecessary (seam-scoped acceptance, a blocked edge out of
`pending-acceptance`, re-scoping the acceptance debt). `#96` will still retire drive item 3
(route C6 to pause, add the S3 pause chrome).
