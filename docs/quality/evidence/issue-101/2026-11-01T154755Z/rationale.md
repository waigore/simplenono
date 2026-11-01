# Why #101 blocked on three axes

Results are in the [manifest](manifest.md). This file records the reasoning behind the verdict, so a later reader does not re-litigate it.

## The deliverable is correct

Every acceptance criterion on #101 holds. `run/main_scene` is `res://presentation/shell.tscn`, `game/main.tscn` is deleted, and the stub holds `STUB_PUZZLE_ID = "pack-000"` (present in `game/data/pack.json`) as a plain `const` that it displays. It calls no `CTR-attempt` or `CTR-pack` operation, resolves no manifest, and navigates nowhere. GUT passes 96/96 and CI is green.

## The blocked rows are a scope artifact, not a code defect

Each blocked axis needs a runtime flow that #101's own body forbids it from building:

- I9 `crash-free` — needs open / solve / reset / back. AC 3 says the stub navigates nowhere; AC 4 puts those flows in #112 and #110.
- I10 `resume-after-failure` — needs a mid-puzzle attempt with persisted marks and elapsed. The stub holds no such state.
- I11 `runtime-signals` — S4 lists `CMP-shell` as its logger, but the events it logs (open, ready, mark, solved, pause, resume, leave, commit, reset) all originate in attempt operations the stub never performs.

So the evaluator cannot observe what it measures, and `run-quality-evaluators` records that as `blocked`, which `verify-project-issue` fails.

## Precedent

#99 hit the same wall for the same reason and failed verification with blocked `crash-free` and `resume-after-failure` rows. This run adds the third axis, `runtime-signals`, because the stub now exists and its absence of logging is a fact about a real scene rather than about a skeleton.

## Resolving it is not an implementation task

Re-running implementation cannot clear a blocked evaluator row without either changing the rubric or changing #101's AC, and both are outside an unattended verify agent's authority. The three options are recorded in the verify comment on #101:

1. Narrow which axes apply until the flow they measure exists (`author-quality-rubrics`).
2. Bring the first observability slice into this task (a body change, so refinement).
3. Have the product owner decide that blocked rows on unreachable axes do not fail verify (a change to `verify-project-issue`).

## Note on `N1`

[`specs/ux/navigation.md`](../../../../../specs/ux/navigation.md) `N1` says a new session opens on `UI-gallery`, while #101 makes the shell stub the run entry. That is consistent with #101 as scoped, since the shell → gallery handoff belongs to the open leg, but #112's body should state it so the requirement is not lost.
