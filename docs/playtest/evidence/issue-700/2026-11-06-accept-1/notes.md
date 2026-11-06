# Notes — #700 `self-test` seam run folder

- **Build:** `main@e646158` (`game/` equals the deliverable `e032fc4`)
- **Session:** `harness-1793976518`
- **Headless**, fresh `user://`; no screenshots required or taken.

## What was judged

AC 5 only. The `navigate` figures (ACs 1–4, 6) are the verifier's run and are cited,
not re-run: AC 2 needs a quiet host, and the `navigate` leg is host-timed. ACs 7–11
are spec/protocol inspection, recorded in the acceptance comment.

## Seam read-back

`_measure` (`game/test/integration/supervisor.gd:238-267`) reads `start` **after**
`await _execute(action)` by default; `polls_action: true` opens it before the action.
`_await_condition` (`:279-290`) crosses one frame before its first probe, so a
synchronous action's state is read on its drawing turn and no leg measures `0 ms`.

## One flake seen, not in the recorded run

The first attempt at this folder failed `rest-span` (`fixture:frame` ratio `0.490`,
bound `≥ 0.5`) because `fixture:frame` read `3.806 ms` against a `7.766 ms` p95 — a
long sampled frame had inflated the denominator. It did not recur: 8 of 9 further runs
on identical code passed, and the recorded run reads `1.014`. The `rest-span` lower
bound is not in this issue's ACs (AC 5 binds the `< 1.5 ×` upper bound, which passed
in every run); logged here for whoever owns host-timing flakiness in the harness.

## No defect

The issue is the harness itself; this folder is its own proof. No game or interface
behaviour is touched by the deliverable.
