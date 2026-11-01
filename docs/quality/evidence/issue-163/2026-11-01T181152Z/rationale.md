# Rationale — issue #163 quality evaluator run

Why the selected axes landed where they did, and who owns the remaining gap.

## `runtime-signals` — blocked, but materially advanced

I11 reads: "Severity-tagged error/crash logs, frame/hitch samples, and story-ID telemetry events are present (`runtime-signals`)", smoke level, "Debug build with S4".

This deliverable **is** S4. Before it, `#110` recorded the whole axis as `blocked` because "no telemetry, no frame sampling, and no tick sampling" existed in `game/`. That is no longer true for one third of the invariant.

### What was observed

Headless debug launch on `3f402fe`, main scene loaded as the shell does at boot, with the seams on:

```
$ godot --headless --path game -s <probe> -- --debug-seams \
    --story-ids=L-solve.PS1.1,US1.7 --session-id=verify163
TEL event=open  time=1793556621.530 session=verify163 build=4.7.2-stable (official) story=L-solve.PS1.1 outcome=pass
TEL event=ready time=1793556622.035 session=verify163 build=4.7.2-stable (official) story=L-solve.PS1.1 outcome=pass
TEL event=commit time=1793556622.036 session=verify163 build=4.7.2-stable (official) story=L-solve.PS1.1 outcome=pass
```

Each line carries all five `TEL.*` fields, the story id comes from the running protocol's argument, and the same call records one `Telemetry` event (`events()` → `open`, `ready`, `commit`). With the flag off the identical boot prints zero `TEL` lines and no overlay node exists.

### Why it still blocks

I11 conjoins three signal families. The other two — severity-tagged error/crash logs and frame/hitch timing samples — are not in `game/`. `grep` finds only the pre-existing `push_error` sites in `game/records/pack.gd`, and no frame or hitch sampler anywhere. An all-or-nothing invariant cannot pass on the family this issue delivers.

This is a rubric-shape problem, not a defect in the seams. I11 could pass today if it were split (telemetry presence vs. severity logs + timing samples), which is `author-quality-rubrics` work — not something verification may do.

## `save-survives` and `failed-write` — pass

I4 covers both. PR #169 writes only under the caller's run folder for the S5 dump and never touches `user://` or a committed record; `pause()`/`resume()`/`progress_record()` forward to and read existing behaviour. Neither outcome can move, so both are `pass` with the diff as evidence.

## What this does not change

- The implementation itself verifies Pass on all nine acceptance criteria (see the issue comment). The Fail here is the rubric row, not the seams.
- The block is identical in kind to #110's, so the workflow consequence is the same: the gate returns to `pending-implementation` under the skill's rule even though no repair can clear it.

## Who owns the gap

| Gap | Owner |
|-----|-------|
| Split I11 into telemetry presence (now satisfiable) vs. severity logs + frame/hitch samples | `author-quality-rubrics` (product owner) |
| Severity-tagged error/crash log sink | unowned in `specs/technical/verification.md` |
| Frame/hitch timing samples | #166 (protocol driver filed from #110) |
