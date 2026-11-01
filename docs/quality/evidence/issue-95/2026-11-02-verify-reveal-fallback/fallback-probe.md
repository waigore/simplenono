# Probes — issue #95, `dafd469`

Part of the independent checks for this run; the rest is in [`checks.md`](checks.md).

## Missing-picture fallback (the #218 repair)

Probe: `game/verify_probe_95.gd` (temporary, deleted after the run; no product code changed). It solved
`pack-000` through the real `Attempt`/`Rules` path (42 fills), instantiated the real `result.tscn`, and
drove `present()`/`advance()` for the three shipped-picture pairs at 0, 150, 299, 300, 301, 450, 599,
600, 601, and 650 ms. A frame counts as drawable only when a layer has `opacity() > 0.0` **and**
`has_content()`.

| Pair | Empty frames | Terminal layer at `S1` | Stages |
|------|--------------|------------------------|--------|
| both pictures absent | 0 | solved fills, `1.0` | `S2` → `S3` → `S1` |
| generated picture absent | 0 | pixel picture, `1.0` | `S2` → `S3` → `S1` |
| both present | 0 | generated picture, `1.0` | `S2` → `S3` → `S1` |

`S1` enables C1 in all three pairs. The chain completes on the sample tick that first crosses `2 × 300 ms`
(601 ms at the probe's fixed 1 ms boundary steps; the crossing is one rounding step, consistent with
`CFG.MORPH_STAGE_MS` per stage). Full trace: [`logs/reveal-probe.log`](logs/reveal-probe.log).

This closes the acceptance finding: no frame between `S2` and `S1` is empty, and the screen never ends
on blank paper.

## Prior pass's material finding — still fixed

One clock: `grep` over `game/` shows one `ResultScreen.advance(` call site (`Shell._process`,
`game/presentation/shell.gd:298`); `ResultScreen` owns no `_process`, and `Reveal.tick` has that one
caller. The clock code is untouched by #223 (docs only in `result.gd`), so the prior pass's proof — the
two real-frame tests fail against `94e6c55` and pass at `a9f8558` — carries to this commit; they pass here
as part of 227/227. The original clock probe itself is recorded in
[`../2026-11-02-verify-reveal-clock/checks.md`](../2026-11-02-verify-reveal-clock/checks.md).
