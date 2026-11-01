# Falsification — #109 accept

The solver's co-located assertions are not treated as the proof. Each mutation below was
applied to the working tree, the probe and the suite were re-run, and the file was restored.
`git status --short` after both runs showed only the untracked probe file.

## Mutation 1 — the personal-best rule (PS1.6 / P2)

`game/records/progress_rules.gd`, in `record_solve`:

```diff
-if not target.has_personal_best() or time < target.personal_best:
+if true:  # MUTATION: PB overwritten by every solve
```

| Run | Result | Log |
|-----|--------|-----|
| Probe | 4/5 passing, **1 failing**: `[100] expected to equal [50]: P2: longer run keeps PB 50`, exit 1 | [`logs/probe-mutation-pb.log`](logs/probe-mutation-pb.log) |
| Suite | 120/122, **2 failing**, exit 1 | [`logs/gut-mutation-pb.log`](logs/gut-mutation-pb.log) |

So `PTD-solve-and-pb` P2 is decided by the rule under acceptance and not by the probe's own
expectations.

## Mutation 2 — the solve check (PS1.5 / P1)

`game/play/attempt.gd`, in `mark`:

```diff
-if _rules.is_solved(grid):
-	return _solve(line_status)
+pass  # MUTATION: solve check removed
```

| Run | Result | Log |
|-----|--------|-----|
| Probe | **8 asserts failing**: `P1: ever-completed true`, `P1: record not in progress`, `P1: stored marks cleared`, `P1: stored elapsed cleared`, `P1: PB equals this run's time`, `P1: attempt not started`, `P1: attempt marks cleared`, `P1: attempt elapsed 0`, plus E1 not emitted and the record left in progress — exit 1 | [`logs/probe-mutation-no-solve.log`](logs/probe-mutation-no-solve.log) |

With the check removed the solving mark falls through to the O5 commit, so the same run also
confirms criterion 6's structural reading: the solve path is distinguishable from the commit
path by the shape of the record it leaves.

## A false positive the probe caught in itself

The probe's first version failed P2 because its seed called `ProgressRules.reset()` (O7, the
gallery reset) to clear the record before the "first solve". `reset` clears ever-completed
but keeps `personal_best` by design, so the *first* solve in that scenario already started
from PB 50 and the longer replay appeared to overwrite it. The fix was in the probe's seed,
not in the build. Recorded here because a run that only reported "P2 failed" would have
filed a defect against correct code.
