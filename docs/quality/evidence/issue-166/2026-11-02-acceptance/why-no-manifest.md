# Acceptance record — issue #166 (details)

From [assessment.md](assessment.md): why no `manifest.md`, what the run folder means for other issues, and the commands.

## Why there is no `manifest.md`

No Applies quality axis can be moved by this deliverable. The harness is
measurement infrastructure: it **observes** `frame-time`, `hitch-bound`,
`time-to-playable`, `transition-latency`, `response-delay`, `crash-free`, and
`resume-after-failure`; it cannot change any of them. [`run-quality-evaluators`](../../../../../.agents/skills/run-quality-evaluators/SKILL.md)
selects an axis only when the deliverable can change its outcome, and
[`docs/quality/evidence/README.md`](../../README.md) writes a folder only when
at least one axis is selected — and reserves `manifest.md` for that evaluator
record. The only qualitative axes (accessibility, localization) are not
delivered here. So this folder is a plain acceptance record, and its
`integration/` subtree is the harness output cited below.

Prior `issue-166` evaluator runs (`2026-11-02-deterministic`, `2026-11-02-verify-rerun`)
scored **product** axes against the harness; they remain valid product
observations and are not verdicts on #166.

## Artifacts cited by other issues

The product issues (#101, #110, #112) that were blocked on `no-invariant` for
I1, I2, I6–I10 can cite a run like this one for their axes. The harness run in
this folder is the `issue-166` deliverable's own output; a per-issue run is a
fresh invocation into that issue's run folder.

## Commands

Protocols were driven from a detached worktree of `origin/main` (`66c6363`) with
`godot --headless --path game --import` once, then one
`godot --headless --path game -s test/integration/run_protocol.gd -- --debug-seams --protocol=<id> --run-dir=<folder>`
per protocol into this run folder. Standard output and error are kept as
`integration/logs/accept-<protocol>.stdout.log`.
