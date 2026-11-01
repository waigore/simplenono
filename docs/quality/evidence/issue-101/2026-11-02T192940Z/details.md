# Quality evaluator run — issue #101 (details)

From [manifest.md](manifest.md): selection argument, the harness command, and the cross-reference checks.

## Why this run exists

The 2026-11-01 run (`../2026-11-01T154755Z/`) blocked `crash-free`, `resume-after-failure`, and `runtime-signals` with reason
`no-invariant`. That was true when it was written: the S1–S5 seams and the integration harness did not exist yet. The harness
landed with #166, and #163 merged the S4 telemetry sink whose severity-log quarter was the last outstanding piece. This run
re-evaluates against that harness on today's `main`. The product code under test is byte-identical to `ea50de5`; only the
observation method changed.

## Observation source

Six sequential runs of

```sh
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=<id> --run-dir=docs/quality/evidence/issue-101/2026-11-02T192940Z
```

into this folder: `app-start` 0, `paint` 0, `navigate` 1, `ui-ack` 0, `solve-reset` 0, `kill-relaunch` 1. Godot 4.7.2 on
macOS, headless. The `navigate` and `kill-relaunch` exits are their own axes (I7, I10), not I9.

## Selection

Selected: the Applies deterministic axes whose citing invariant the harness can now observe for this deliverable.

- The stub is the run entry, so launch and quit (`app-start`) reach it. I9's open/solve/reset/back flows run through
  #110/#112's puzzle screen, which sits behind this stub.
- I10 (`kill-relaunch`) and I11 (S4) now run and are observed directly.

Not selected — the stub does no paint, navigation, non-paint UI, or persistence of its own; those are #110/#112/#94–#96 rows:

- `frame-time` (I1), `hitch-bound` (I2) — the stub draws one `Label`; no surface of its own to sample.
- `transition-latency` (I7), `response-delay` (I8) — navigation and settings intents belong to #94/#95/#112.
- `time-to-playable` (I6) — measures cold launch to the *gallery*, which is #94; the stub's home view is a stand-in.
- `save-survives` / `failed-write` (I4) — the stub writes no committed progress.
- N/A accessibility and localization axes are not scored.

## Cross-reference

- `review-code` on PR #136 (`007140d`): **Pass**, no must-fix findings (recorded in the 2026-11-01 verify comment).
- Independent checks today on `origin/main` (`fdcb298`): GUT 142/142 pass; the six protocols ran headless as listed above.
- No cataloged assets added or changed; `review-asset` not applicable.
