# Verdict and selection notes — issue #166

From [manifest.md](manifest.md).

## Not selected

`runtime-signals` (I11) — smoke level, outside the harness scope named in the issue body. `save-survives` / `failed-write`
(I4) — settled by the persistence diff, not this harness. N/A accessibility and localization axes are not scored.

## Verdict

`Fail` — two Applies deterministic axes (`transition-latency`, `resume-after-failure`) exceed their bars on this
deliverable's own observations. Both rows are failed by product gaps #95 and #96 that the issue body records as
out of scope, not by harness defects.
