# Quality evaluator run — issue #268 (acceptance)

- **Issue:** #268 Puzzle pictures pack-142–pack-145 (15×15) (`type:task`)
- **Mode:** `deterministic` — **re-observed at acceptance**, not written by verification
- **Tree under acceptance:** `main@62a3d52`
- **Recorded by:** `issue-workflow-accept-agent` (parallel id 1), 2026-11-03, Godot 4.7.2 headless on Linux

## Why this record exists

Verification Passed #268 without a `deterministic` record and recorded the axis as N/A. This deliverable puts two new
`CompressedTexture2D` assets per puzzle on the gallery path (`shell.gd` `_picture_for` resolves each visible tile's
`picture-id` through the manifest at shell setup), so `time-to-playable` is the one Applies deterministic axis it can
reach — the same selection #259, #263, #269, and #271 made. Reading every `deterministic` record in
`docs/quality/evidence/` (`git diff <recorded> dafc87c -- game/`) shows no passing record for the deliverable commit
`dafc87c` (PR #441 squash).

The slice itself is byte-identical from the delivery commit `dafc87c` through the tree measured here (`62a3d52`);
only later slices' entries and later code touch `game/` in between:

```bash
git diff --name-only dafc87c 62a3d52 -- \
  game/assets/puzzle-pictures/pack-142* game/assets/puzzle-pictures/pack-143* \
  game/assets/puzzle-pictures/pack-144* game/assets/puzzle-pictures/pack-145* \
  assets/catalog/01a17720-ca00-71eb-9fa0-62d0ea14673b.json \
  assets/catalog/01a17720-ca00-70e3-8dcf-a543be0b5c8c.json \
  assets/catalog/01a17720-ca00-70b3-9177-80c74fc60602.json \
  assets/catalog/01a17720-ca00-73d1-ba6e-c3b91935f39c.json \
  assets/catalog/01a17720-ca00-709e-b397-27e4806a9e25.json \
  assets/catalog/01a17720-ca00-72ce-b9fc-fb01cc3107c6.json \
  assets/catalog/01a17720-ca00-7182-bf60-95e1eae97b7a.json \
  assets/catalog/01a17720-ca00-70a4-9aa7-1a7b573c1039.json
# expected: no output
```

`game/data/pack.json` rows `pack-142`–`pack-145` compare equal row for row between `dafc87c` and `62a3d52`.

## Observation

```bash
godot --headless --path game -s test/integration/run_protocol.gd -- \
    --debug-seams --protocol=app-start --run-dir=docs/quality/evidence/issue-268/2026-11-03-accept
```

→ `HARNESS protocol=app-start outcome=pass run=integration/logs/harness-1793677024-app-start.log`

| Axis | Evaluator | Observation | Bar | Result | Blocked reason | Evidence path |
|------|-----------|-------------|-----|--------|----------------|---------------|
| `time-to-playable` | deterministic | I6: cold launch to the interactive shell home (gallery) **1982.3 ms** at `62a3d52` (the delivered slice) | Cold launch to interactive gallery ≤ 3 s | **pass** | — | [`integration/results.md`](integration/results.md); log `integration/logs/harness-1793677024-app-start.log` |

This is software-rendered Linux measurement on the acceptance host, not a mid-range-phone certification; it is the
same method every picture-slice record uses here. The graphical acceptance playtest ran on the same build:
[`docs/playtest/evidence/issue-268/2026-11-03-accept-graphical/manifest.md`](../../../../playtest/evidence/issue-268/2026-11-03-accept-graphical/manifest.md).

This is software-rendered Linux measurement on the acceptance host, not a mid-range-phone certification; it is the
same method every picture-slice record uses here. The graphical acceptance playtest ran on the same build:
[`docs/playtest/evidence/issue-268/2026-11-03-accept-graphical/manifest.md`](../../../../playtest/evidence/issue-268/2026-11-03-accept-graphical/manifest.md).

## Not selected

`frame-time`, `hitch-bound`, `transition-latency`, `response-delay`, `crash-free`, `resume-after-failure`,
`runtime-signals`, `save-survives`, `failed-write` — the deliverable adds stored pictures and rewrites four rows'
fills and clues, and changes no runtime code, so none of those outcomes can move. Accessibility and Localization axes
are `N/A` in [`specs/definition/quality.md`](../../../../../specs/definition/quality.md).

## llm-judge

Not applicable. Every axis in [`specs/definition/quality/rubrics.md`](../../../../../specs/definition/quality/rubrics.md)
is `deterministic` and its domain-axes list is `None`, so no judge record exists to read and this skill's `llm-judge`
mode selects nothing.

No row is **fail** or **blocked**.
