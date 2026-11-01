# Notes — issue #218 acceptance playtest

## What was judged

The judged window is one full play: gallery → puzzle → get-set-ready → solve → the three-layer reveal through
`S2` and `S3` to `S1 Default` → Back to gallery. The probe drove the real shell, the real screens, the real
controls, and real engine frames, so the reveal ran its own clock rather than a test's `tick()`.

The reveal was sampled on **every real frame** of the chain, not only at its boundaries. A frame counts as empty
when none of the three layers is both above `0.01` opacity and holding content (`ResultMorphSlot.has_content()`).
Across 69 frames the count was **0**.

## Chain observed

```
1ms   stage=S2 drawable=1 fills=1.000 pixel=0.000 picture=0.000
32ms  stage=S3 drawable=1 fills=1.000 pixel=0.000 picture=0.000
69ms  stage=S1 drawable=1 fills=1.000 pixel=0.000 picture=0.000
```

With both pictures absent the chain holds the solved fills through both stages and ends on them at `S1`. That is
the "best shipped layer" rule US1.5 now states, and it is drawn, not blank.

## Build

`main@8cfb263`. The deliverable is the squash `dafd469` (PR #223); `8cfb263` adds only the verification evidence
folder (`git diff --stat dafd469 8cfb263` = documentation only), so the tested product tree is the verified one.

## Non-blocking marks

- **No stored pictures in this build.** `assets/manifest.json` holds five audio entries and neither `pack-000`
  picture id (`01a17720-ca00-71f5-8156-87c953625822`, `01a17720-ca00-7255-80b3-eb4ab429fc0b`). That is the
  premise of this defect, not a miss: the supplier is #98 (`status:pending-implementation`). The two
  picture-present pairs — generated only, and pixel plus generated — are covered by unit tests in
  `game/test/test_result_screen.gd` and by the verify-time reveal probe, and cannot be judged graphically until
  #98 ships the textures.
- **Morph wall time 561.2 ms against `2 × 300` = 600 ms.** This is the measured real-frame time over 69 frames
  at the frame budget, the same shape #95 recorded, and the reveal's own clock (`CFG.MORPH_STAGE_MS`) is
  unchanged. It does not indicate the clock drifting.
- **`S1` shows grid fills, not a picture.** Correct for this build, and what US1.5 says. Once #98 ships the
  textures, `S1` should end on the generated picture; that is #98's judged state, not this one's.
- **`p2` and `p3` are not byte-identical.** They are the same grid, camera, and chrome, so their layout matches;
  `p3` carries the staged marks. The probe records 41 of the 42 fills staged and drawn before the last one, so
  the judged state — a partial grid that stays on `UI-puzzle` — is what the image shows, and `p4`–`p6` carry the
  distinct result states.
