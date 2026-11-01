# Notes — issue #166 acceptance record

Companion to [`assessment.md`](assessment.md). Only the parts that would push
that file past the `docs/` word limit live here.

## Why there is no `manifest.md`

No Applies quality axis can be moved by this deliverable. The harness is
measurement infrastructure: it **observes** `frame-time`, `hitch-bound`,
`time-to-playable`, `transition-latency`, `response-delay`, `crash-free`, and
`resume-after-failure`; it cannot change any of them. [`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md)
selects an axis only when the deliverable can change its outcome, and
[`docs/quality/evidence/README.md`](../../README.md) writes a folder only when
at least one axis is selected — and reserves `manifest.md` for that evaluator
record. The only qualitative axes (accessibility, localization) are not
delivered here. So the acceptance folder is a plain acceptance record, and its
`integration/` subtree is the harness output cited by the assessment.

Prior `issue-166` evaluator runs (`2026-11-02-deterministic`, `2026-11-02-verify-rerun`)
scored **product** axes against the harness; they remain valid product
observations and are not verdicts on #166.

## Criterion 3 and 4 detail

Criterion 3: every leg crosses a frame and waits on the product probe; the
`navigate` timeout and the `driver_time` note are recorded rather than timed
as driver CPU. Criterion 4: a real kill, relaunch, gallery entry, and reopen
were observed; the restores themselves belong to #96.

## Criterion 7

[`issue-110` run `2026-11-01T190448Z`](../../issue-110/2026-11-01T190448Z/manifest.md)
cites an integration-harness run for `frame-time`, `hitch-bound`, `time-to-playable`, and
the other measured axes without any `blocked` row.

## Artifacts cited by other issues

The product issues (#101, #110, #112) that were blocked on `no-invariant` for
I1, I2, I6–I10 can cite a run like this one for their axes. The harness run in
this folder is the `issue-166` deliverable's own output; a per-issue run is a
fresh invocation into that issue's run folder.
