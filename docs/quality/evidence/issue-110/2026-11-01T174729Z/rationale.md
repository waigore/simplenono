# Rationale — issue #110 quality evaluator run

Why each selected axis blocked, and who owns the gap.

## The shared root cause

Every Applies quality axis whose invariant is **integration** (I1, I2, I6–I10) or **smoke** (I11) needs something the repo does not have yet: a harness that launches a debug build, drives a named protocol, samples timings, and writes a run folder. `specs/technical/verification.md` H1–H4 assume it, but on `bc438de` nothing implements it.

The same wall stopped #99 and #101. #101 recorded it as a policy question and its gate is still held; #110 is the third run to hit it.

## `crash-free` — blocked

I9 is integration level and needs four flows: open, solve, reset, back. This deliverable is a **screen**: it draws attempt state and raises intents. Routing is #112, solve is #109, leave and reset are #94/#95. Driving those flows from here would mean building work the issue body explicitly assigns elsewhere.

The GUT suite (125/125) and a clean headless launch are smoke evidence, not I9. A blocked row fails the run; so does this axis.

## `runtime-signals` — blocked

I11 is smoke level: error/crash logs, frame and hitch samples, story-ID telemetry, from a debug build with S4. Grepping `game/` outside `game/addons/` finds no telemetry, no frame sampling, and no tick sampling. The only `push_error` sites are `game/records/pack.gd` load failures, which predate this PR.

A debug launch cannot observe signals that are not implemented. This gap is not #110's to close.

## Why the two persistence axes passed

I4 covers both `save-survives` and `failed-write`. PR #164 changes `game/presentation/puzzle.gd` and `game/test/test_puzzle_screen.gd` only, so no write path is added or altered and neither outcome can move. These are `pass`, not `N/A`, because the axes apply and the evidence is a diff showing no persistence change.

## Who owns the gap

| Gap | Owner |
|-----|-------|
| Protocol driver, timing samples, kill-and-relaunch, run-folder writer | **#166** (filed from this verify) |
| S1–S5 debug seams and the S4 telemetry sink that H3 feeds | #163 |

#166 is the driver; #163 is the sink. Neither alone clears `crash-free`, and #163 alone does not clear the integration axes.

## Why this is not a code Fail

The screen is correct and every acceptance criterion holds on inspection. Returning #110 to implementation cannot clear a blocked evaluator row, because the missing piece is verification infrastructure, not screen behaviour. The gate still moves to `pending-implementation` per the skill, but the verify comment recommends the product owner decide between re-verifying after #166 and narrowing the axes via `author-quality-rubrics`.
