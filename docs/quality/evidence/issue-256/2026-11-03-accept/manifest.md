# Quality evaluator run — issue #256 (acceptance)

- **Issue:** #256 Puzzle pictures pack-094–pack-097 (15×15) (`type:task`)
- **Mode:** `deterministic` — **cited for acceptance, not re-run**
- **Tree under acceptance:** `main@1c046f6`
- **Recorded by:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-03

## Cited record

[`docs/quality/evidence/issue-256/2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md)
— verifier's `deterministic` run at deliverable commit `4e61ae8` (the squash of PR #387), written by
`issue-workflow-verify-agent` during verification of this same issue.

## Reuse check

`git diff 4e61ae8 1c046f6 -- game/` is **not** empty (241 paths). Every one of them belongs to a later picture
slice: new `game/assets/puzzle-pictures/pack-*.png` and their `.import` sidecars, plus those slices' own
`game/data/pack.json` rows. The one pre-existing file that moved, `game/data/pack.json`, changes only rows
outside this slice — `pack-094`–`pack-097` are byte-identical from `4e61ae8` to `1c046f6`:

```python
rows('4e61ae8')[id] == rows('1c046f6')[id]  # True for pack-094, -095, -096, -097
```

The record's selection holds unchanged: this deliverable adds eight static `CompressedTexture2D` files to the
gallery path and rewrites four rows' fills and clues, and changes no runtime code, so `time-to-playable` is the one
Applies deterministic axis it can reach.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) **293.5 ms** at `4e61ae8` | Cold launch to interactive gallery ≤ 3 s | **pass** | — | [`issue-256/2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md); log `integration/logs/harness-1793645146-app-start.log` |

No other Applies axis can move on stored pictures and pack data (`frame-time`, `hitch-bound`,
`transition-latency`, `response-delay`, `crash-free`, `resume-after-failure`, `runtime-signals`, `save-survives`,
`failed-write`), as the cited record states. No row is **fail** or **blocked**.

## llm-judge

Not applicable. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and its domain-axes list is `None`, so no judge record exists to read and this skill's
`llm-judge` mode selects nothing.
