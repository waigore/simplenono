# Quality evaluator run — issue #258 (acceptance)

- **Issue:** #258 Puzzle pictures pack-102–pack-105 (15×15) (`type:task`)
- **Mode:** `deterministic` — **cited for acceptance, not re-run**
- **Tree under acceptance:** `main@7d3cd10`
- **Recorded by:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-03

## Cited record

[`docs/quality/evidence/issue-258/2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md)
— verifier's `deterministic` run at deliverable commit `84082e1` (the squash of PR #390), written by
`issue-workflow-verify-agent` during verification of this same issue.

## Reuse check

`git diff 84082e1 7d3cd10 -- game/` is **not** empty (225 paths). Every one of them belongs to a later picture
slice: new `game/assets/puzzle-pictures/pack-*.png` and their `.import` sidecars, plus those slices' own
`game/data/pack.json` rows. The one pre-existing file that moved, `game/data/pack.json`, changes only rows
outside this slice — `pack-102`–`pack-105` are byte-identical from `84082e1` to `7d3cd10`:

```python
rows('84082e1')[id] == rows('7d3cd10')[id]  # True for pack-102, -103, -104, -105
```

The record's selection holds unchanged: this deliverable adds eight static `CompressedTexture2D` files to the
gallery path and rewrites four rows' fills and clues, and changes no runtime code, so `time-to-playable` is the one
Applies deterministic axis it can reach.

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) **302.5 ms** at `84082e1` | Cold launch to interactive gallery ≤ 3 s | **pass** | — | [`issue-258/2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md); log `integration/logs/harness-1793648757-app-start.log` |

No other Applies axis can move on stored pictures and pack data (`frame-time`, `hitch-bound`,
`transition-latency`, `response-delay`, `crash-free`, `resume-after-failure`, `runtime-signals`, `save-survives`,
`failed-write`), as the cited record states. No row is **fail** or **blocked**.

## llm-judge

Not applicable. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and its domain-axes list is `None`, so no judge record exists to read and this skill's
`llm-judge` mode selects nothing.
