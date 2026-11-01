# Acceptance dispatch holds (#111, #112)

Why these sit on `status:pending-acceptance`. Full re-check log:
[`accept-dispatch-rechecks.md`](accept-dispatch-rechecks.md).

## The loop

| Fact | Effect |
|------|--------|
| All are `status:pending-acceptance`, `priority:normal`, `type:task`, no wave milestone. | Every accept dispatch picks one. |
| [`evidence.md`](../../../specs/playtest/evidence.md) requires an image of each pass state from a **graphical run of the same build**, unless the protocol says none. | Each leaf needs one graphical re-run before it can be accepted. |
| `#112` (`f05441c`) routes the shell to `puzzle.tscn`; `#169` (`3f402fe`) adds `DBG.*` / `TEL.*` S1–S5, the [`verification.md`](../../../specs/technical/verification.md) H1 precondition. | A graphical run is possible; `#156`, `#105`, `#132`, `#107`, `#106`, `#108`, and `#109` used it. |
| C6's settings routing (#96) and `UI-result` (#95) are absent; the gallery and settings screens landed (#199, #202). | Protocols needing the missing screens are deferred. |
| [`workflow.md`](../../issues/workflow.md). | `pending-acceptance` exits by Accept, Fail (+defect), Clarify, or the missing-record return to `pending-verification`. |

## Why each still sits here

- **`#111`** — `IN` US1.6–US1.8 judged graphically on `b1c1285`, five screenshots
  ([record](issue-111/2026-11-02-accept-graphical/manifest.md)), but `IN` is still cited only by
  `PTU-settings`, which never places a mark, so the images have no protocol row to sit under.
  The build gate (H1) closed with #169; only the protocol gap is left (#203).
- **`#112`** — accepted at `09c022e`. The open leg was judged graphically on `5e5fe85` (gallery
  start, `S2`/`S1` open, 200/200 ids, five screenshots:
  [record](issue-112/2026-11-02-accept-graphical/manifest.md)), and the deterministic record the
  earlier run waited on was written for the user-requested run:
  [quality record](issue-112/2026-11-02-accept-graphical/quality/manifest.md) (I7 288.3 ms,
  I8 7.0 ms, I9 pass, from `navigate` + `solve-reset` + `ui-ack`). #204 makes that user-requested
  route unnecessary: verification cannot Pass without the record, and acceptance may return the
  issue to `pending-verification` instead of waiting.

## Unblocking — what is left

Each is a spec or workflow change an accept agent must not make:

1. **Fix where the deterministic record comes from.** ~~Only verify may run `deterministic` mode, so
   a verify that defers an axis to acceptance leaves unattended acceptance no legal way to produce
   it.~~ **Chosen rule (#204, landed):** verification cannot Pass without the deterministic record
   for the deliverable commit, so a deferral is now a verification Fail rather than an acceptance
   wait; acceptance cites the record and, if one is ever missing for the commit, uses the new
   `pending-acceptance` → `pending-verification` return route so the one legal producer runs. No
   unattended run needs the user-requested route that #112 used. See
   [`docs/issues/workflow-deterministic-record.md`](../../issues/workflow-deterministic-record.md) and
   [`docs/quality/evidence/README.md`](../../quality/evidence/README.md#who-writes-a-record).
2. **Give `IN` a protocol that places a mark**, or fix its `Cites` (#111).

`#96` will still route C6 to pause and add the S3 pause chrome. Everything else was closed by the
S1–S5 seams and the graphical runs logged in
[`accept-dispatch-rechecks.md`](accept-dispatch-rechecks.md).

`#109` left this list on `dcd9a24`: `PTD-solve-and-pb` S1–S3 were re-run graphically through the
shell, screen, and `MarkInput`, with `DBG.2` PB reads
([record](issue-109/2026-11-02-accept-graphical/manifest.md)).
