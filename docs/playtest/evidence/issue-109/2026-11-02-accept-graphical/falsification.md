# Falsification — issue #109 acceptance run

Two mutations, each applied alone to the shipped code on `main@dcd9a24`, the probe re-run, then the
file restored. Both are caught, so the passes above are not a rubber stamp.

## 1. Personal-best rule: replace on every solve

`game/records/progress_rules.gd`, `record_solve`:

```gdscript
-	if not target.has_personal_best() or time < target.personal_best:
+	if true:  # FALSIFICATION: always replace the personal best
```

Result: **caught**. The `10:00` replay overwrote the stored PB.

```
capture: FAIL P2: the longer replay keeps the prior PB (600)
```

Full log: [`logs/falsify-pb-rule.log`](logs/falsify-pb-rule.log) (exit 1).

## 2. Solve check removed from the mark path

`game/play/attempt.gd`, `mark`:

```gdscript
-	if _rules.is_solved(grid):
+	if false:  # FALSIFICATION: the solve check is removed
```

Result: **caught**, 33 failing checks — the whole P1/P2/P3 chain, because no solve is ever
recognised:

```
capture: FAIL S1/P1: CTR-attempt E1 solved was emitted once
capture: FAIL P1: marks are cleared after the solve
capture: FAIL P1: ever-completed is true
capture: FAIL P1: PB is set to that run's time (<null>)
capture: FAIL P2: the prior PB survives reopening (<null>)
```

Full log: [`logs/falsify-no-solve.log`](logs/falsify-no-solve.log) (exit 1).

## Restored

Both files were restored from their originals; `git status --short game/` is clean except the probe
copy, which is removed after the run. The judged run then reported `capture: RESULT pass (8 shots)`.

## What the mutation check does not cover

The probe reaches the solve through one puzzle (`pack-000`) and one near-solve shape (the solution
minus its last fill). `Rules.is_solved` over other shapes is #108's (`PS1.1`), and the suite covers
it with the teapot fixture.
