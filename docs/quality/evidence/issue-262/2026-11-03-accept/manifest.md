# Quality evaluator run — issue #262 (acceptance)

- **Issue:** #262 Puzzle pictures pack-118–pack-121 (15×15) (`type:task`)
- **Mode:** `deterministic` — **cited for acceptance, not re-run**
- **Tree under acceptance:** `main@1161953`
- **Recorded by:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-03

## Cited record

[`docs/quality/evidence/issue-262/2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md)
— verifier's `deterministic` run at deliverable commit `3c7af65` (PR #397's head; its squash `fdbfa63` has the same
`game/` tree). One Applies axis is selected and passes.

## Reuse check

`git diff 3c7af65 1161953 -- game/` is **not** empty: the later commits belong to other picture slices (their
`pack-*.png` files, `.import` sidecars, and their own `game/data/pack.json` rows) and to #431's reset telemetry. This
slice's own artifacts are unchanged from the merge to the tree under acceptance:

- `git diff --quiet fdbfa63 1161953 --` for each of the eight catalog ids and each of the eight
  `game/assets/puzzle-pictures/pack-118…121-*.png(.import)` paths → no change.
- `game/data/pack.json`: rows `pack-118`–`pack-121` compare equal row for row between `fdbfa63` and `1161953`.

```python
rows('fdbfa63')[id] == rows('1161953')[id]  # True for pack-118, -119, -120, -121
```

The record's selection still holds: the deliverable adds eight static `CompressedTexture2D` files to the gallery path
and rewrites four rows' fills and clues, and changes no runtime code, so `time-to-playable` is the one Applies
deterministic axis it can reach.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) **305.7 ms** at `3c7af65` | Cold launch to interactive gallery ≤ 3 s | **pass** | — | [`issue-262/2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md); log `integration/logs/harness-1793650131-app-start.log` |

No other Applies axis can move on stored pictures and pack data (`frame-time`, `hitch-bound`,
`transition-latency`, `response-delay`, `crash-free`, `resume-after-failure`, `runtime-signals`, `save-survives`,
`failed-write`), as the cited record states. No row is **fail** or **blocked**.

## llm-judge

Not applicable. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and its domain-axes list is `None`, so no judge record exists to read and this skill's `llm-judge`
mode selects nothing.
