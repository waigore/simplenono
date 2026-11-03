# Quality evaluator run — issue #263 (acceptance)

- **Issue:** #263 Puzzle pictures pack-122–pack-125 (15×15) (`type:task`)
- **Mode:** `deterministic` — **cited for acceptance, not re-run**
- **Tree under acceptance:** `main@fb99b16`
- **Recorded by:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-03

## Cited record

[`docs/quality/evidence/issue-263/2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md)
— the verifier's `deterministic` run at this issue's deliverable commit `9053c8c` (the squash of PR #402). One Applies
axis is selected and passes.

## Reuse check

The record is written for the deliverable commit itself, so no tree parity beyond the slice is needed to make it
valid:

```bash
git diff --quiet 9053c8c fb99b16 -- game/assets/puzzle-pictures/pack-122* \
  game/assets/puzzle-pictures/pack-123* game/assets/puzzle-pictures/pack-124* \
  game/assets/puzzle-pictures/pack-125*          # empty
```

- The eight picture files, their `.import` sidecars, and the eight catalog entries are unchanged from `9053c8c` to
  `fb99b16`.
- `game/data/pack.json`: rows `pack-122`–`pack-125` compare equal row for row between `9053c8c` and `fb99b16`.
- The 164 other `game/` paths that differ belong to later picture slices (`pack-1xx` files) and to #431's reset
  telemetry (`game/presentation/shell.gd`, `game/presentation/debug_seams.gd`, `game/test/test_shell_open.gd`).

The record's selection still holds: this deliverable adds eight static `CompressedTexture2D` files to the gallery path
and rewrites four rows' fills and clues, and changes no runtime code, so `time-to-playable` is the one Applies
deterministic axis it can reach. The acceptance playtest ran on a graphical build of `fb99b16` —
[`docs/playtest/evidence/issue-263/2026-11-03-accept-graphical/manifest.md`](../../../playtest/evidence/issue-263/2026-11-03-accept-graphical/manifest.md).

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) **312.0 ms** at `9053c8c` | Cold launch to interactive gallery ≤ 3 s | **pass** | — | [`issue-263/2026-11-03-verify/manifest.md`](../2026-11-03-verify/manifest.md); log `integration/logs/harness-1793650945-app-start.log` |

No other Applies axis can move on stored pictures and pack data (`frame-time`, `hitch-bound`,
`transition-latency`, `response-delay`, `crash-free`, `resume-after-failure`, `runtime-signals`, `save-survives`,
`failed-write`), as the cited record states. No row is **fail** or **blocked**.

## llm-judge

Not applicable. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and its domain-axes list is `None`, so no judge record exists to read and this skill's `llm-judge`
mode selects nothing.
